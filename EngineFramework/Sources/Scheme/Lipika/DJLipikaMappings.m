/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJLogger.h"
#import "DJLipikaMappings.h"

#if TARGET_OS_IPHONE
static NSString *const SCHEMESPATH = @"%@/Schemes";
#else
static NSString *const SCHEMESPATH = @"%@/Contents/Resources/Schemes";
#endif

@implementation DJMap

@synthesize scheme;
@synthesize script;

-(id) initWithScript:(NSString *)aScript scheme:(NSString *)aScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    self.script = aScript;
    self.scheme = aScheme;
    return self;
}

@end

@implementation DJLipikaMappings : NSObject

static NSString *const kAppGroupName = @"group.LipikaBoard";

+(NSString *) mappingFilePathForScriptName:(NSString *)scriptName schemeName:(NSString *)schemeName {
    NSURL *dirURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier: kAppGroupName];
    return [[dirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.map", scriptName, schemeName]] path];
}

+(double)fingerPrintForScript:(NSString *)scriptName scheme:(NSString *)schemeName {
    NSString *filePath = [self mappingFilePathForScriptName:scriptName schemeName:schemeName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *result = [fileAttribs objectForKey:NSFileModificationDate];
        return result.timeIntervalSince1970;
    }
    else {
        return -1;
    }
}

+(OrderedDictionary *) mappingsForScriptName:(NSString *)scriptName schemeName:(NSString *)schemeName {
    NSString *filePath = [self mappingFilePathForScriptName:scriptName schemeName:schemeName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:&error];
        if (error) {
            logError(@"Unable to read mapping file: %@ due to %@", filePath, error.localizedDescription);
            return nil;
        }
        OrderedDictionary *mappings = [[OrderedDictionary alloc] initWithCapacity:0];
        [[contents componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *components = [obj componentsSeparatedByString:@"\t"];
            if (components.count != 4) {
                logWarning(@"Ignoring line %@ as it does not have 4 components", obj);
            }
            else {
                OrderedDictionary *class = [mappings objectForKey:components[0]];
                if (!class) {
                    class = [[OrderedDictionary alloc] initWithCapacity:0];
                    [mappings setObject:class forKey:components[0]];
                }
                [class setObject: [[DJMap alloc] initWithScript:components[3] scheme:components[2]] forKey:components[1]];
            }
        }];
        return mappings;
    }
    return nil;
}

+(void)storeMappings:(OrderedDictionary *)mappings scriptName:(NSString *)scriptName schemeName:(NSString *)schemeName {
    NSMutableString *content = [[NSMutableString alloc] init];
    for (NSString *type in mappings) {
        OrderedDictionary * typeMap = [mappings objectForKey:type];
        for (NSString *key in typeMap) {
            DJMap *map = [typeMap objectForKey:key];
            [content appendFormat:@"%@\t%@\t%@\t%@\n", type, key, map.scheme, map.script];
        }
    }
    [self storeMappingsContent:content scriptName:scriptName schemeName:schemeName];
}

+(void)storeMappingsContent:(NSString *)content scriptName:(NSString *)scriptName schemeName:(NSString *)schemeName {
    NSString *filePath = [self mappingFilePathForScriptName:scriptName schemeName:schemeName];
    NSError *error;
    [content writeToFile:filePath atomically:true encoding:NSUnicodeStringEncoding error:&error];
    if (error) {
        logError(@"Unable to write to file %@ due to %@", filePath, error.localizedDescription);
    }
}

@end
