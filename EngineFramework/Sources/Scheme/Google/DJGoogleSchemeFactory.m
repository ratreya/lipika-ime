/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleSchemeFactory.h"
#import "DJSchemeHelper.h"
#import "DJLogger.h"
#import "DJLipikaHelper.h"

@implementation DJGoogleSchemeFactory

#if TARGET_OS_IPHONE
    static BOOL iOS = YES;
#else 
    static BOOL iOS = NO;
#endif

static NSString *const SCHEMESPATH = @"%@/Contents/Resources/Schemes/Google";
static NSString *const VERSION = @"version";
static NSString *const NAME = @"name";
static NSString *const STOP_CHAR = @"stop-char";
static NSString *const CLASS_DELIMITERS = @"class-delimiters";
static NSString *const WILDCARD = @"wildcard";
static NSString *const EXTENSION = @"scm";

// These regular expressions don't have dynamic elements
static NSRegularExpression *headerExpression;
static NSRegularExpression *usingClassesExpression;
static NSRegularExpression *classesDelimiterExpression;

+(void)initialize {
    NSString *const headerPattern = @"^\\s*(.*\\S)\\s*:\\s*(.*\\S)\\s*$";
    NSString *const usingClassesPattern = @"^\\s*using\\s+classes\\s*$";
    NSString *const classesDelimiterPattern = @"^\\s*(\\S)\\s*(\\S)\\s*$";
    
    NSError *error;
    headerExpression = [NSRegularExpression regularExpressionWithPattern:headerPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    usingClassesExpression = [NSRegularExpression regularExpressionWithPattern:usingClassesPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid using classes regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    classesDelimiterExpression = [NSRegularExpression regularExpressionWithPattern:classesDelimiterPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid classes delimiter expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

+(DJGoogleInputScheme *)inputSchemeForScheme:scheme {
    // Parse one file at a time
    @synchronized(self) {
        NSString *schemesDirectory;
        if (iOS) {
            schemesDirectory = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.LipikaBoard"] path];
        }
        else {
            schemesDirectory = [NSString stringWithFormat:SCHEMESPATH, [[NSBundle mainBundle] bundlePath]];
        }
        NSString *filePath = [[schemesDirectory stringByAppendingPathComponent:scheme] stringByAppendingPathExtension:EXTENSION];
        DJGoogleSchemeFactory *factory = [[DJGoogleSchemeFactory alloc] initWithSchemeFile:filePath];
        return [factory scheme];
    }
}

+(DJGoogleInputScheme *)inputSchemeForSchemeFile:(NSString *)filePath {
    // Parse one file at a time
    @synchronized(self) {
        DJGoogleSchemeFactory *factory = [[DJGoogleSchemeFactory alloc] initWithSchemeFile:filePath];
        return [factory scheme];
    }
}

+(NSArray *)availableSchemes {
    NSError *error;
    NSString *schemesDirectory = [NSString stringWithFormat:SCHEMESPATH, [[NSBundle mainBundle] bundlePath]];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:schemesDirectory error:&error];
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:0];
    if (error != nil) {
        logError(@"Error accessing schemes directory: %@", [error localizedDescription]);
        return names;
    }
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.%@'", EXTENSION]]];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [names addObject:[obj stringByDeletingPathExtension]];
    }];
    return names;
}

-(id<DJInputMethodScheme>)scheme {
    return scheme;
}

-(id)initWithSchemeFile:(NSString *)filePath {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = [[DJGoogleInputScheme alloc] init];
    currentLineNumber = 0;

    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSDate *result = [fileAttribs objectForKey:NSFileModificationDate];
    scheme.fingerprint = result.timeIntervalSince1970;

    // Read contents of the Scheme file
    logDebug(@"Parsing scheme file: %@", filePath);
    scheme.schemeFilePath = filePath;
    linesOfScheme = linesOfFile(filePath);
    if ([self parseLinesOfFile]) {
        return self;
    }
    else {
        return nil;
    }
}

-(id)initWithSchemeData:(NSString *)data {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = [[DJGoogleInputScheme alloc] init];
    currentLineNumber = 0;

    scheme.schemeFilePath = @"";
    linesOfScheme = [data componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    if ([self parseLinesOfFile]) {
        return self;
    }
    else {
        return nil;
    }
    return self;
}

-(BOOL)parseLinesOfFile {
    @try {
        logDebug(@"Parsing Headers");
        [self parseHeaders];
    }
    @catch (NSException *exception) {
        logFatal(@"Error parsing scheme file: %@; %@", scheme.schemeFilePath, [exception reason]);
        return NO;
    }
    @try {
        logDebug(@"Parsing Mappings");
        [self parseMappings];
    }
    @catch (NSException *exception) {
        logFatal(@"Error parsing scheme file: %@; %@", scheme.schemeFilePath, [exception reason]);
        return NO;
    }
    [scheme onDoneParsingAtLine:currentLineNumber];
    return YES;
}

-(void)parseHeaders {
    // Parse out the headers
    for (NSString *line in linesOfScheme) {
        // For empty lines move on
        if ([line length] <=0 || isWhitespace(line)) {
            currentLineNumber++;
            continue;
        }
        logDebug(@"Parsing line: %@", line);
        if ([headerExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            NSString *key = [headerExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
            NSString *value = [headerExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
            logDebug(@"Parsed header. Key: %@; Value: %@", key, value);
            if ([key caseInsensitiveCompare:VERSION] == NSOrderedSame) {
                scheme.version = value;
            }
            else if ([key caseInsensitiveCompare:NAME] == NSOrderedSame) {
                scheme.name = value;
            }
            else if ([key caseInsensitiveCompare:STOP_CHAR] == NSOrderedSame) {
                scheme.stopChar = value;
            }
            else if ([key caseInsensitiveCompare:WILDCARD] == NSOrderedSame) {
                scheme.wildcard = value;
            }
            else if ([key caseInsensitiveCompare:CLASS_DELIMITERS] == NSOrderedSame) {
                if (![classesDelimiterExpression numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])]) {
                    [NSException raise:@"Invalid class delimiter value" format:@"Invalid value: %@ at line %d", value, currentLineNumber + 1];
                }
                scheme.classOpenDelimiter = [classesDelimiterExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$1"];
                scheme.classCloseDelimiter = [classesDelimiterExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$2"];
            }
            else {
                [NSException raise:@"Invalid key" format:@"Invalid key: %@ at line %d", key, currentLineNumber + 1];
            }
        }
        else if ([usingClassesExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            logDebug(@"Parsed using classes");
            scheme.usingClasses = YES;
        }
        else {
            logDebug(@"Done parsing headers");
            break;
        }
        currentLineNumber++;
    }
    logDebug(@"Headers end at: %d", currentLineNumber + 1);
}

-(void)parseMappings {
    [scheme onStartParsingAtLine:currentLineNumber];
    for (; currentLineNumber<[linesOfScheme count]; currentLineNumber++) {
        NSString *line = linesOfScheme[currentLineNumber];
        // For empty lines move on
        if ([line length] <=0 || isWhitespace(line)) continue;
        logDebug(@"Parsing line: %@", line);
        [scheme createMappingWithLine:line lineNumber:currentLineNumber];
    }
}

@end
