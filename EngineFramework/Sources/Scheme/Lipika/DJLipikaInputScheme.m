/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaInputScheme.h"
#import "DJLipikaUserSettings.h"
#import "DJSchemeHelper.h"
#import "DJLipikaMappings.h"
#import "DJLogger.h"

enum DJReferenceType {
    SCRIPT = 1,
    SCHEME = 2
};

@interface DJMapReference : NSObject {
    enum DJReferenceType type;
    NSRange replacement;
    NSString *class;
    NSString *valueKey;
}

@property enum DJReferenceType type;
@property NSRange replacement;
@property NSString *class;
@property NSString *valueKey;

-(DJMapReference *)mapReferenceWithValueKey:(NSString *)valueKey;

@end

@implementation DJMapReference

@synthesize type;
@synthesize replacement;
@synthesize class;
@synthesize valueKey;

-(DJMapReference *)mapReferenceWithValueKey:(NSString *)theValueKey {
    DJMapReference *new = [[DJMapReference alloc] init];
    new.type = type;
    new.replacement = replacement;
    new.class = class;
    new.valueKey = theValueKey;
    return new;
}

@end

@implementation DJLipikaInputScheme

@synthesize fingerprint;

// These regular expressions don't have dynamic elements
static NSRegularExpression *twoColumnTSVExpression;
static NSRegularExpression *specificValueExpression;
static NSRegularExpression *mapStringSubExpression;
static NSRegularExpression *addendumSubExpression;

+(void)initialize {
    NSString *const twoColumnTSVPattern = @"^\\s*([^\\t]+?)\\t+(.+)\\s*$";
    NSString *const specificValuePattern = @"^\\s*(.+)\\s*/\\s*(.+)\\s*$";
    NSString *const mapStringSubPattern = @"(\\[[^\\]]+?\\]|\\{[^\\}]+?\\})";
    NSString *const addendumSubPattern = @"%@";

    NSError *error;
    twoColumnTSVExpression = [NSRegularExpression regularExpressionWithPattern:twoColumnTSVPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    specificValueExpression = [NSRegularExpression regularExpressionWithPattern:specificValuePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    mapStringSubExpression = [NSRegularExpression regularExpressionWithPattern:mapStringSubPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    addendumSubExpression = [NSRegularExpression regularExpressionWithPattern:addendumSubPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

-(id)initWithMappings:(NSDictionary *)aMappings imeLines:(NSArray *)imeLines {
    self = [super init];
    if (self == nil) {
        return self;
    }
    mappings = aMappings;
    forwardMapping = [[DJSimpleForwardMapping alloc] init];
    reverseMapping = [[DJSimpleReverseMapping alloc] init];
    addMapping = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    for (NSString *line in imeLines) {
        if ([twoColumnTSVExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *preMap = [twoColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"];
            NSString *postMap = [twoColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$2"];
            unsigned long numFormatSpecs = [addendumSubExpression numberOfMatchesInString:postMap options:0 range:NSMakeRange(0, postMap.length)];
            if (numFormatSpecs > 1) {
                [NSException raise:@"Invalid IME line" format:@"IME addendum line \"%@\": number of format specififers (%lu) is more than one.", line, numFormatSpecs];
            }
            logDebug(@"Parsing preMap: %@", preMap);
            NSArray *preValues = [self parseMapString:preMap];
            logDebug(@"Parsing postMap: %@", postMap);
            NSArray *postValues = [self parseMapString:postMap];
            // Process addendum lines
            if (numFormatSpecs > 0) {
                if (postValues.count > 1 || [postValues[0] count] > 1) {
                    [NSException raise:@"Invalid IME line" format:@"IME addendum line \"%@\": post value produces the following values when only one was expected: %@", line, postValues];
                }
                for (NSArray *preValueList in preValues) {
                    for (NSString *preValue in preValueList) {
                        [addMapping addValue:postValues[0][0] forKey:preValue];
                    }
                }
                continue;
            }
            // Process non-addendum IME lines
            if (preValues.count != postValues.count) {
                [NSException raise:@"Invalid IME line" format:@"For IME line \"%@\": count of mappings from left column :(%ld) does not match that from the right :(%ld)", line, (unsigned long)preValues.count, (unsigned long)postValues.count];
            }
            for (int i=0; i<preValues.count; i++) {
                NSArray *preValueList = [preValues objectAtIndex:i];
                NSString *postValue = [[postValues objectAtIndex:i] objectAtIndex:0];
                for (NSString *preValue in preValueList) {
                    [forwardMapping createSimpleMappingWithInput:preValue output:postValue];
                    [reverseMapping createSimpleMappingWithInput:preValue output:postValue];
                }
            }
        }
        else {
            logWarning(@"Must be two column TSV; Ignoring bad IME line: \"%@\"", line);
        }
    }
    return self;
}

-(NSDictionary *)mappings {
    return mappings;
}

-(void)postProcessResult:(DJParseOutput *)result withPreviousResult:(DJParseOutput *)previousResult {
    NSString *input = [previousResult.input stringByAppendingString:result.input];
    DJTrieNode *addNode = [addMapping nodeForKey:input];
    if (addNode && addNode.value) {
        result.output = [NSString stringWithFormat:addNode.value, result.output];
    }
}

-(NSArray *)parseMapString:(NSString *)mapString {
    NSArray *matches = [mapStringSubExpression matchesInString:mapString options:0 range:NSMakeRange(0, mapString.length)];
    NSMutableArray *references = [NSMutableArray arrayWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        DJMapReference *reference = [[DJMapReference alloc] init];
        NSString *token = [mapString substringWithRange:range];
        logDebug(@"Parsing token: %@", token);
        // Store replacement range
        reference.replacement = range;
        // Parse the token
        if ([[token substringToIndex:1] isEqualToString:@"["]) {
            reference.type = SCRIPT;
        }
        else if ([[token substringToIndex:1] isEqualToString:@"{"]) {
            reference.type = SCHEME;
        }
        else {
            [NSException raise:@"Internal error" format:@"Token is of unknown type: %@", token];
        }
        logDebug(@"Token type: %u", reference.type);
        NSString *moniker = [token substringWithRange:NSMakeRange(1, token.length-2)];
        if ([specificValueExpression numberOfMatchesInString:moniker options:0 range:NSMakeRange(0, moniker.length)]) {
            reference.class = [specificValueExpression stringByReplacingMatchesInString:moniker options:0 range:NSMakeRange(0, moniker.length) withTemplate:@"$1"];
            reference.valueKey = [specificValueExpression stringByReplacingMatchesInString:moniker options:0 range:NSMakeRange(0, moniker.length) withTemplate:@"$2"];
        }
        else {
            reference.class = moniker;
        }
        logDebug(@"Token class name: %@", reference.class);
        if (reference.valueKey) logDebug(@"Token value key: %@", reference.valueKey);
        [references addObject:reference];
    }
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithCapacity:0];
    // Return results sorted by key to enable correct mapping to script
    [self applyReferences:references atIndex:0 toMapString:mapString withAdjustment:0 results:results];
    NSMutableArray *sortedResults = [NSMutableArray arrayWithCapacity:results.count];
    [[[results allKeys] sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [sortedResults addObject:[results objectForKey:obj]];
    }];
    return sortedResults;
}

-(void)applyReferences:(NSArray *)references atIndex:(int)index toMapString:(NSString *)mapString withAdjustment:(unsigned long)adjustment results:(NSMutableDictionary *)results {
    DJMapReference *reference = [references objectAtIndex:index];
    if (reference.valueKey) {
        NSArray *substituants = [self substituantForReference:reference];
        NSRange range = NSMakeRange(reference.replacement.location - adjustment, reference.replacement.length);
        for (NSString *substituant in substituants) {
            NSString *result = [mapString stringByReplacingCharactersInRange:range withString:substituant];
            if (references.count - index > 1) {
                unsigned long subAdjustment = adjustment + (range.length - substituant.length);
                [self applyReferences:references atIndex:index+1 toMapString:result withAdjustment:subAdjustment results:results];
            }
            else {
                // Aggregate results by key so that CSV style scheme values can be later mapped to the appropriate script
                NSString *key = @"";
                for (int i=0; i<=index; i++) {
                    DJMapReference *ref = [references objectAtIndex:i];
                    key = [[key stringByAppendingString:ref.class] stringByAppendingString:ref.valueKey];
                }
                NSMutableArray *resultsForKey = [results objectForKey:key];
                if (!resultsForKey) resultsForKey = [NSMutableArray arrayWithObject:result];
                else [resultsForKey addObject:result];
                [results setObject:resultsForKey forKey:key];
            }
        }
    }
    else {
        NSArray *valueKeys = [mappings objectForKey:reference.class];
        if (!valueKeys) {
            [NSException raise:@"Unrecognized class name" format:@"Invalid class name: %@", reference.class];
        }
        for (NSString *valueKey in valueKeys) {
            DJMapReference *valueKeyRef = [reference mapReferenceWithValueKey:valueKey];
            NSMutableArray *remaining = [references mutableCopy];
            [remaining replaceObjectAtIndex:index withObject:valueKeyRef];
            [self applyReferences:remaining atIndex:index toMapString:mapString withAdjustment:adjustment results:results];
        }
    }
}

-(NSArray *)substituantForReference:(DJMapReference *)reference {
    NSString *substituant;
    if (reference.type == SCHEME) {
        substituant = ((DJMap *)[[mappings objectForKey:reference.class] objectForKey:reference.valueKey]).scheme;
    }
    else if (reference.type == SCRIPT) {
        substituant = ((DJMap *)[[mappings objectForKey:reference.class] objectForKey:reference.valueKey]).script;
    }
    else [NSException raise:@"Unregcognized reference type" format:@"Unknown reference type: %u", reference.type];
    if (!substituant) {
        [NSException raise:@"Unknown class/key" format:@"Could not find key: %@ in class: %@ for reference type: %u", reference.valueKey, reference.class, reference.type];
    }
    if (reference.type == SCRIPT) return [NSArray arrayWithObject:stringForUnicodes(substituant)];
    else return csvToArrayForString(substituant);
}

-(NSString *)stopChar {
    return [DJLipikaUserSettings lipikaSchemeStopChar];
}

-(DJSimpleForwardMapping *)forwardMappings {
    return forwardMapping;
}

-(DJSimpleReverseMapping *)reverseMappings {
    return reverseMapping;
}

@end
