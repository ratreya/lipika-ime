/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaSchemeFactory.h"
#import "DJSchemeHelper.h"
#import "DJLogger.h"

@implementation DJLipikaSchemeFactory

static NSString *const SCHEMESPATH = @"%@/Contents/Resources/Schemes";
static NSString *const SCHEMEEXTENSION = @"tlr";
static NSString *const SCRIPTEXTENSION = @"map";
static NSString *const IMEEXTENSION = @"ime";
static NSString *const SCHEMESUBDIR = @"Transliteration";
static NSString *const SCRIPTSUBDIR = @"Script";

// These regular expressions don't have dynamic elements
static NSRegularExpression *whitespaceExpression;
static NSRegularExpression *threeColumnTSVExpression;
static NSRegularExpression *scriptOverrideExpression;
static NSRegularExpression *schemeOverrideExpression;
static NSRegularExpression *imeOverrideExpression;
static NSString *schemesDirectory;

+(void)initialize {
    schemesDirectory = [NSString stringWithFormat:SCHEMESPATH, [[NSBundle mainBundle] bundlePath]];
    NSString *const whitespacePattern = @"^\\s+$";
    NSString *const threeColumnTSVPattern = @"^\\s*([^\\t]+?)\\t+([^\\t]+?)\\t+(. *)\\s*$";
    NSString *const scriptOverridePattern = @"^\\s*Script\\s*:\\s*(.+)\\s*$";
    NSString *const schemeOverridePattern = @"^\\s*Transliteration\\s*:\\s*(.+)\\s*$";
    NSString *const imeOverridePattern = @"^\\s*IME\\s*:\\s*(.+)\\s*$";

    NSError *error;
    whitespaceExpression = [NSRegularExpression regularExpressionWithPattern:whitespacePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    threeColumnTSVExpression = [NSRegularExpression regularExpressionWithPattern:threeColumnTSVPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    scriptOverrideExpression = [NSRegularExpression regularExpressionWithPattern:scriptOverridePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    schemeOverrideExpression = [NSRegularExpression regularExpressionWithPattern:schemeOverridePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    imeOverrideExpression = [NSRegularExpression regularExpressionWithPattern:imeOverridePattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
}

// Used for testing only
+(void)setSchemesDirectory:(NSString *)directory {
    schemesDirectory = directory;
}

+(DJLipikaInputScheme *)inputSchemeForScript:script scheme:scheme {
    // Parse one file at a time
    @synchronized(self) {
        DJLipikaSchemeFactory *factory = [[DJLipikaSchemeFactory alloc] initWithScript:script scheme:scheme];
        return [factory scheme];
    }
}

+(NSArray *)availableScripts {
    return [DJLipikaSchemeFactory fileInSubdirectory:SCRIPTSUBDIR withExternsion:[NSString stringWithFormat:@".%@", SCRIPTEXTENSION]];
}

+(NSArray *)availableSchemes {
    return [DJLipikaSchemeFactory fileInSubdirectory:SCHEMESUBDIR withExternsion:[NSString stringWithFormat:@".%@", SCHEMEEXTENSION]];
}

-(id<DJInputMethodScheme>)scheme {
    return scheme;
}

+(NSArray *)fileInSubdirectory:(NSString *)subDirectory withExternsion:(NSString *)extension {
    NSError *error;
    NSString *path = subDirectory? [schemesDirectory stringByAppendingPathComponent:subDirectory] : schemesDirectory;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '%@'", extension]]];
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:0];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [names addObject:[obj stringByDeletingPathExtension]];
    }];
    return names;
}

-(id)initWithScript:(NSString *)scriptName scheme:(NSString *)schemeName {
    self = [super init];
    if (self == nil) {
        return self;
    }
    // 1. parse script file
    NSMutableDictionary *scriptMap;
    @try {
        NSString *scriptFilePath = [[[schemesDirectory stringByAppendingPathComponent:SCRIPTSUBDIR] stringByAppendingPathComponent:scriptName] stringByAppendingPathExtension:SCRIPTEXTENSION];
        logDebug(@"Parsing script file: %@", scriptFilePath);
        NSString *batchId = startBatch();
        scriptMap = [self tsvToDictionaryForFile:scriptFilePath dictionary:nil];
        endBatch(batchId);
    }
    @catch (NSException *exception) {
        logFatal(@"Error parsing script file for script: %@, scheme: %@ due to %@", scriptName, schemeName, [exception reason]);
        return nil;
    }
    // 2. parse scheme file
    NSMutableDictionary *schemeMap;
    @try {
        NSString *schemeFilePath = [[[schemesDirectory stringByAppendingPathComponent:SCHEMESUBDIR] stringByAppendingPathComponent:schemeName] stringByAppendingPathExtension:SCHEMEEXTENSION];
        logDebug(@"Parsing scheme file: %@", schemeFilePath);
        NSString *batchId = startBatch();
        schemeMap = [self tsvToDictionaryForFile:schemeFilePath dictionary:nil];
        endBatch(batchId);
    }
    @catch (NSException *exception) {
        logFatal(@"Error parsing scheme file for script: %@, scheme: %@ due to %@", scriptName, schemeName, [exception reason]);
        return nil;
    }
    // 3. look for a script-scheme specific ime; if not found revert to default
    NSString *specificImeFilePath = [[schemesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", scriptName, schemeName]] stringByAppendingPathExtension:IMEEXTENSION];
    NSString *defaultImeFilePath = [[schemesDirectory stringByAppendingPathComponent:@"Default"] stringByAppendingPathExtension:IMEEXTENSION];
    NSString *imeFilePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:specificImeFilePath]) {
        imeFilePath = specificImeFilePath;
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:defaultImeFilePath]) {
        imeFilePath = defaultImeFilePath;
    }
    else {
        [NSException raise:@"Default IME not found in Schemes directory" format:@"Not found: %@", defaultImeFilePath];
    }
    // 4. expand out any referrences in ime
    @try {
        logDebug(@"Parsing IME file: %@", imeFilePath);
        NSString *batchId = startBatch();
        NSArray *imeLines = [self linesOfImeFile:imeFilePath schemeTable:schemeMap scriptTable:scriptMap depth:1];
        scheme = [[DJLipikaInputScheme alloc] initWithSchemeTable:schemeMap scriptTable:scriptMap imeLines:imeLines];
        endBatch(batchId);
    }
    @catch (NSException *exception) {
        logFatal(@"Error parsing IME file for script: %@, scheme: %@ due to %@", scriptName, schemeName, [exception reason]);
        return nil;
    }
    return self;
}

-(NSMutableDictionary *)tsvToDictionaryForFile:(NSString *)filePath dictionary:(NSMutableDictionary *)outerTable {
    NSArray *linesOfScheme = [self linesOfFile:filePath];
    if (!outerTable) outerTable = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *line in linesOfScheme) {
        logDebug(@"Parsing line %@", line);
        if([line length] <=0 || [whitespaceExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            continue;
        }
        else if ([threeColumnTSVExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *one = [threeColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
            NSString *two = [threeColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
            NSString *three = [threeColumnTSVExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$3"];
            if (!(one.length && two.length && three.length)) {
                logWarning(@"Not all values specified; ignoring line: %@", line);
                continue;
            }
            NSMutableDictionary *innerTable = [outerTable objectForKey:one];
            if (!innerTable) {
                innerTable = [NSMutableDictionary dictionaryWithCapacity:0];
                [outerTable setObject:innerTable forKey:one];
            }
            [innerTable setObject:three forKey:two];
        }
        else {
            [NSException raise:@"Invalid TSV line" format:@"Bad line: \"%@\"; not a three column TSV", line];
        }
    }
    return outerTable;
}

-(NSArray *)linesOfImeFile:(NSString *)filePath schemeTable:(NSMutableDictionary *)schemeTable scriptTable:(NSMutableDictionary *)scriptTable depth:(int)depth {
    if (depth > 5) {
        [NSException raise:@"IME referrences depth greater than five" format:@"Terminating IME parsing at %@", filePath];
    }
    logDebug(@"Parsing IME file: %@", filePath);
    NSArray *lines = [self linesOfFile:filePath];
    NSMutableArray *imeLines = [NSMutableArray arrayWithCapacity:0];
    for (NSString *line in lines) {
        if([line length] <=0 || [whitespaceExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            continue;
        }
        logDebug(@"Parsing line %@", line);
        if ([scriptOverrideExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *override = [scriptOverrideExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"];
            NSArray *scriptOverrides = csvToArrayForString(override);
            for (NSString *scriptOverride in scriptOverrides) {
                NSString *scriptFilePath = [[[schemesDirectory stringByAppendingPathComponent:SCRIPTSUBDIR] stringByAppendingPathComponent:scriptOverride] stringByAppendingPathExtension:SCRIPTEXTENSION];
                logDebug(@"Parsing script override file: %@", scriptFilePath);
                [self tsvToDictionaryForFile:scriptFilePath dictionary:scriptTable];
            }
        }
        else if ([schemeOverrideExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *override = [schemeOverrideExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"];
            NSArray *schemeOverrides = csvToArrayForString(override);
            for (NSString *schemeOverride in schemeOverrides) {
                NSString *schemeFilePath = [[[schemesDirectory stringByAppendingPathComponent:SCHEMESUBDIR] stringByAppendingPathComponent:schemeOverride] stringByAppendingPathExtension:SCHEMEEXTENSION];
                logDebug(@"Parsing scheme override file: %@", schemeFilePath);
                [self tsvToDictionaryForFile:schemeFilePath dictionary:schemeTable];
            }
        }
        else if ([imeOverrideExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)]) {
            NSString *override = [imeOverrideExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"];
            NSArray *imeFileNames = csvToArrayForString(override);
            for (NSString *imeFileName in imeFileNames) {
                NSString *imeFilePath = [[schemesDirectory stringByAppendingPathComponent:imeFileName] stringByAppendingPathExtension:IMEEXTENSION];
                logDebug(@"Including IME override file: %@", imeFilePath);
                [imeLines addObjectsFromArray:[self linesOfImeFile:imeFilePath schemeTable:schemeTable scriptTable:scriptTable depth:depth+1]];
            }
        }
        else {
            [imeLines addObject:line];
        }
    }
    return imeLines;
}

-(NSArray *)linesOfFile:(NSString *)filePath {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        [NSException raise:@"Unable to read file" format:@"Failed to open file %@ for reading", filePath];
    }
    NSData *dataBuffer = [handle readDataToEndOfFile];
    NSString *data = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
    return [data componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
}

@end
