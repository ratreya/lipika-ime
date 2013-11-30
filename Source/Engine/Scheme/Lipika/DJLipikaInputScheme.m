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

@end

@implementation DJMapReference

@synthesize type;
@synthesize replacement;
@synthesize class;
@synthesize valueKey;

@end

@implementation DJLipikaInputScheme

// These regular expressions don't have dynamic elements
static NSRegularExpression *twoColumnTSVExpression;
static NSRegularExpression *specificValueExpression;
static NSRegularExpression *mapStringSubExpression;

+(void)initialize {
    NSString *const twoColumnTSVPattern = @"^(\\S+)\\t+(\\S+)$";
    NSString *const specificValuePattern = @"^\\s*(\\S+)\\s*/\\s*(\\S+)\\s*$";
    NSString *const mapStringSubPattern = @"([\\S+]|{\\S+})";

    NSError* error;
    twoColumnTSVExpression = [NSRegularExpression regularExpressionWithPattern:twoColumnTSVPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    specificValueExpression = [NSRegularExpression regularExpressionWithPattern:specificValuePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    mapStringSubExpression = [NSRegularExpression regularExpressionWithPattern:mapStringSubPattern options:0 error:&error];
}

-(id)initWithSchemeTable:(NSDictionary*)theSchemeTable scriptTable:(NSDictionary*)theScriptTable imeLines:(NSArray*)imeLines {
    self = [super init];
    if (self == nil) {
        return self;
    }
    schemeTable = theSchemeTable;
    scriptTable = theScriptTable;
    // Figure out the common set of valid keys between the two tables
    validKeys = [NSMutableDictionary dictionaryWithCapacity:MAX(schemeTable.count, scriptTable.count)];
    NSMutableSet *commonClasses = [NSMutableSet setWithArray:[schemeTable allKeys]];
    NSSet *scriptClasses = [NSSet setWithArray:[scriptTable allKeys]];
    [commonClasses intersectSet:scriptClasses];
    for (NSString *className in commonClasses) {
        NSMutableSet *commonValueKeys = [NSMutableSet setWithArray:[[schemeTable objectForKey:className] allKeys]];
        NSSet *scriptValueKeys = [NSSet setWithArray:[[scriptTable objectForKey:className] allKeys]];
        [commonValueKeys intersectSet:scriptValueKeys];
        NSMutableArray *sortedValueKeys = [NSMutableArray arrayWithArray:[commonValueKeys allObjects]];
        [sortedValueKeys sortedArrayUsingSelector:@selector(compare:)];
        [validKeys setValue:sortedValueKeys forKey:className];
    }
    for (NSString *line in imeLines) {
        if ([twoColumnTSVExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *preMap = [twoColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"];
            NSString *postMap = [twoColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$2"];
            logDebug(@"Parsing preMap: %@", preMap);
            NSString *batchId = startBatch();
            NSArray *preValues = [self parseMapString:preMap];
            endBatch(batchId);
            logDebug(@"Parsing postMap: %@", preMap);
            batchId = startBatch();
            NSArray *postValues = [self parseMapString:postMap];
            endBatch(batchId);
            if (preValues.count != postValues.count) {
                [NSException raise:@"Invalid IME line" format:@"For IME line %@: count of mappings from left column (%ld) does not match that from the right (%ld)", line, preValues.count, postValues.count];
            }
            for (int i=0; i<preValues.count; i++) {
                [forwardMapping createSimpleMappingWithKey:[preValues objectAtIndex:i] value:[postValues objectAtIndex:i]];
                [reverseMapping createSimpleMappingWithKey:[preValues objectAtIndex:i] value:[postValues objectAtIndex:i]];
            }
        }
        else {
            [NSException raise:@"Invalid TSV line" format:@"Must be two column TSV; Ignoring bad line: %@", line];
        }
    }
    return self;
}

-(NSArray*)parseMapString:(NSString*)mapString {
    NSArray *matches = [mapStringSubExpression matchesInString:mapString options:0 range:NSMakeRange(0, mapString.length)];
    NSMutableArray *references = [NSMutableArray arrayWithCapacity:matches.count];
    NSRange range = [mapStringSubExpression rangeOfFirstMatchInString:mapString options:0 range:NSMakeRange(0, mapString.length)];
    while (range.location != NSNotFound) {
        DJMapReference *reference = [[DJMapReference alloc] init];
        NSString *token = [mapString substringWithRange:range];
        logDebug(@"Parsing token: %@", token);
        // Store replacement range
        reference.replacement = range;
        logDebug(@"Replacement range: %@", NSStringFromRange(range));
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
        NSString *moniker = [token substringWithRange:NSMakeRange(1, token.length-1)];
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
        range = [mapStringSubExpression rangeOfFirstMatchInString:mapString options:0 range:NSMakeRange(range.location + range.length, mapString.length)];
    }
    NSArray *formattedStrings = [NSArray arrayWithObject:mapString];
    for (DJMapReference *reference in references) {
        formattedStrings = [self applyReference:reference toMapStrings:formattedStrings];
    }
    return formattedStrings;
}

-(NSArray*)applyReference:(DJMapReference*)reference toMapStrings:(NSArray*)mapStrings {
    if (reference.valueKey) {
        return [self applyReference:reference withValue:reference.valueKey toMapStrings:mapStrings];
    }
    else {
        NSArray *valueKeys = [validKeys valueForKey:reference.class];
        if (!validKeys) {
            [NSException raise:@"Unrecognized class name" format:@"Invalid class name: %@", reference.class];
        }
        NSMutableArray *formattedStrings = [NSMutableArray arrayWithCapacity:valueKeys.count*mapStrings.count];
        for (NSString *valueKey in valueKeys) {
            [formattedStrings addObjectsFromArray:[self applyReference:reference withValue:valueKey toMapStrings:mapStrings]];
        }
        return formattedStrings;
    }
}

-(NSArray*)applyReference:(DJMapReference*)reference withValue:(NSString*)valueKey toMapStrings:(NSArray*)mapStrings {
    NSString *substituant;
    if (reference.type == SCHEME) substituant = [[schemeTable objectForKey:reference.class] objectForKey:valueKey];
    else if (reference.type == SCRIPT) substituant = [[scriptTable objectForKey:reference.class] objectForKey:valueKey];
    else [NSException raise:@"Unregcognized reference type" format:@"Unknown reference type: %u", reference.type];
    if (!substituant) {
        [NSException raise:@"Unknown class/key" format:@"Could not find key %@ in class name %@ for Script(1)/Scheme(2): %u", valueKey, reference.class, reference.type];
    }
    NSMutableArray *formattedStrings = [NSMutableArray arrayWithCapacity:mapStrings.count];
    for (NSString *mapString in mapStrings) {
        [formattedStrings addObject:[mapString stringByReplacingCharactersInRange:reference.replacement withString:substituant]];
    }
    return formattedStrings;
}

-(NSString*)stopChar {
    return [DJLipikaUserSettings lipikaSchemeStopChar];
}

-(DJSimpleForwardMapping*)forwardMappings {
    return forwardMapping;
}

-(DJSimpleReverseMapping*)reverseMappings {
    return reverseMapping;
}

@end
