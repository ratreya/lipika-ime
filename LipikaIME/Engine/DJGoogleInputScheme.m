/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleInputScheme.h"
#import "DJLipikaUserSettings.h"
#import "DJLogger.h"

@implementation DJGoogleInputScheme

@synthesize schemeFilePath;
@synthesize name;
@synthesize version;
@synthesize usingClasses;
@synthesize classOpenDelimiter;
@synthesize classCloseDelimiter;
@synthesize wildcard;
@synthesize stopChar;

// This regular expression only has static elements
static NSRegularExpression* simpleMappingExpression;

+(void)initialize {
    NSString *const simpleMappingPattern = @"^\\s*(\\S+)\\s+(\\S+)\\s*$";
    NSError* error;
    simpleMappingExpression = [NSRegularExpression regularExpressionWithPattern:simpleMappingPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid simple mapping expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    // Set default values
    wildcard = @"*";
    stopChar = @"\\";
    usingClasses = YES;
    classOpenDelimiter = @"{";
    classCloseDelimiter = @"}";
    isProcessingClassDefinition = NO;
    
    return self;
}

-(void)onStartParsingAtLine:(int)lineNumber {
    forwardMappings = [[DJGoogleForwardMapping alloc] initWithScheme:self];
    reverseMappings = [[DJGoogleReverseMapping alloc] initWithScheme:self];

    // Regular expressions for matching mapping items
    NSError* error;
    NSString *const classDefinitionPattern = [NSString stringWithFormat:@"^\\s*class\\s+(\\S+)\\s+\\%@\\s*$", classOpenDelimiter];
    classDefinitionExpression = [NSRegularExpression regularExpressionWithPattern:classDefinitionPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class definition expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    /*
     * We only support one class per mapping
     */
    NSString *const classKeyPattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S+)\\%@(\\S*)\\s*$", classOpenDelimiter, classCloseDelimiter];
    classKeyExpression = [NSRegularExpression regularExpressionWithPattern:classKeyPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    /*
     * And hence only one wildcard value
     */
    NSString *const wildcardValuePattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S*)\\s*$", wildcard];
    wildcardValueExpression = [NSRegularExpression regularExpressionWithPattern:wildcardValuePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

-(void)createMappingWithLine:(NSString*)line lineNumber:(int)lineNumber {
    int currentLineNumber = lineNumber + 1;
    if ([simpleMappingExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
        logDebug(@"Found mapping expression");
        NSString* key = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
        NSString* value = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
        if ([classKeyExpression numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])]) {
            logDebug(@"Found class mapping");
            // Parse the key
            NSString* preClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$1"];
            NSString* className = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$2"];
            NSString* postClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$3"];
            logDebug(@"Parsed key with pre-class: %@; class: %@", preClass, className);
            if ([postClass length]) {
                [NSException raise:@"Class mapping not suffix" format:@"Class mapping: %@ has invalid suffix: %@ at line: %d", className, postClass, currentLineNumber];
            }
            BOOL isWildcard = NO;
            NSString* preWildcard;
            NSString* postWildcard;
            // Parse the value; may not have wildcards in it
            if ([wildcardValueExpression numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])]) {
                isWildcard = YES;
                preWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$1"];
                postWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$2"];
                logDebug(@"Parsed value with pre-wildcard: %@; post-wildcard: %@", preWildcard, postWildcard);
            }
            [self createClassMappingWithPreKey:preClass className:className isWildcard:isWildcard preValue:preWildcard postValue:postWildcard];
        }
        else {
            [self createSimpleMappingWithKey:key value:value];
        }
    }
    else if ([classDefinitionExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
        NSString *className = [classDefinitionExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
        [self startClassDefinitionWithName:className];
    }
    else if ([line isEqualToString:classCloseDelimiter]) {
        [self endClassDefinition];
    }
    else {
        [NSException raise:@"Invalid line" format:@"Invalid line %d", currentLineNumber];
    }
}

-(void)onDoneParsingAtLine:(int)lineNumber {
    if (isProcessingClassDefinition) {
        logWarning(@"Error parsing scheme file: %@; One or more class(es) not closed", name);
    }
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    if (isProcessingClassDefinition) {
        [forwardMappings createSimpleMappingForClass:currentClassName key:key value:value];
        [reverseMappings createSimpleMappingForClass:currentClassName key:key value:value];
    }
    else {
        [forwardMappings createSimpleMappingWithKey:key value:value];
        [reverseMappings createSimpleMappingWithKey:key value:value];
    }
}

-(void)createClassMappingWithPreKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    if (isProcessingClassDefinition) {
        [forwardMappings createClassMappingForClass:currentClassName preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
        [reverseMappings createClassMappingForClass:currentClassName preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
    }
    else {
        [forwardMappings createClassMappingWithPreKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
        [reverseMappings createClassMappingWithPreKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
    }
}

-(void)startClassDefinitionWithName:(NSString*)className {
    logDebug(@"Found beginning of class definition with name: %@", className);
    if (isProcessingClassDefinition) {
        logWarning(@"Did not see an end of class %@ before the beginning of class %@; forcing an end", currentClassName, className);
        [self endClassDefinition];
    }
    isProcessingClassDefinition = YES;
    currentClassName = className;
    [forwardMappings createClassWithName:className];
    [reverseMappings createClassWithName:className];
}

-(void)endClassDefinition {
    logDebug(@"Found end of class definition");
    if (!isProcessingClassDefinition) {
        logWarning(@"Seeing end of class without a corresponding beginning");
        return;
    }
    isProcessingClassDefinition = NO;
    currentClassName = nil;
}

-(DJGoogleForwardMapping*)forwardMappings {
    return forwardMappings;
}

-(DJGoogleReverseMapping*)reverseMappings {
    return reverseMappings;
}

@end
