/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaUserSettings.h"
#import <InputMethodKit/InputMethodKit.h>

@implementation DJLipikaUserSettings

static int SETTINGS_VERSION = 1;
static NSDictionary* candidateStringAttributeCache = nil;

+(void)initialize {
    NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserSettings" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"Version"] != SETTINGS_VERSION) {
        [self reset];
    }
}

+(NSString*)scriptName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"ScriptName"];
}

+(void)setScriptName:(NSString*)scriptName {
    [[NSUserDefaults standardUserDefaults] setObject:scriptName forKey:@"ScriptName"];
}

+(NSString*)schemeName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SchemeName"];
}

+(void)setSchemeName:(NSString*)schemeName {
    [[NSUserDefaults standardUserDefaults] setObject:schemeName forKey:@"SchemeName"];
}

+(enum DJSchemeType)schemeType {
    return (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SchemeType"];
}

+(void)setSchemeType:(enum DJSchemeType)schemeType {
    [[NSUserDefaults standardUserDefaults] setInteger:schemeType forKey:@"SchemeType"];
}

+(NSString*)lipikaSchemeStopChar {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"LipikaSchemeStopChar"];
}

+(BOOL) isOverrideCandidateAttributes {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"OverrideCandidateFont"];
}

+(BOOL)isCombineWithPreviousGlyph {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"CombineWithPreviousGlyph"];
}

+(NSDictionary*)candidateWindowAttributes {
    NSMutableDictionary* windowAttributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [windowAttributes setValue:[NSNumber numberWithFloat:[DJLipikaUserSettings opacity]] forKey:(NSString*)IMKCandidatesOpacityAttributeName];
    [windowAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString*)IMKCandidatesSendServerKeyEventFirst];
    return windowAttributes;
}

+(void)setCandidateStringAttributes:(NSDictionary*)attributes {
    candidateStringAttributeCache = attributes;
    NSData* outputData = [NSArchiver archivedDataWithRootObject:attributes];
    [[NSUserDefaults standardUserDefaults] setObject:outputData forKey:@"CandidatesStringAttributes"];
}

+(NSDictionary*)candidateStringAttributes {
    if (candidateStringAttributeCache) return candidateStringAttributeCache;
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"CandidatesStringAttributes"];
    if (data) {
        candidateStringAttributeCache = [NSUnarchiver unarchiveObjectWithData:data];
    }
    return candidateStringAttributeCache;
}

+(NSString*)candidatePanelType {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"CandidatePanelType"];
}

+(BOOL)isShowInput {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowInputString"];
}

+(BOOL)isShowOutput {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowOutputString"];
}

+(BOOL) isOutputInCandidate {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"OutputInCandidate"];
}

+(float)opacity {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"IMKCandidatesOpacityAttributeName"];
}

+(void)reset {
    [self resetStandardUserDefaults];
    [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(enum DJBackspaceBehavior)backspaceBehavior {
    NSString* string = [[NSUserDefaults standardUserDefaults] stringForKey:@"BackspaceDeletes"];
    if ([string isEqualToString:@"Output character"]) {
        return DJ_DELETE_OUTPUT;
    }
    else if ([string isEqualToString:@"Mapping output"]) {
        return DJ_DELETE_MAPPING;
    }
    else if ([string isEqualToString:@"Input character"]) {
        return DJ_DELETE_INPUT;
    }
    else {
        return nil;
    }
}

+(enum DJOnUnfocusBehavior)unfocusBehavior {
    NSString* string = [[NSUserDefaults standardUserDefaults] stringForKey:@"OnUnfocusUncommitted"];
    if ([string isEqualToString:@"Gets discarded"]) {
        return DJ_DISCARD_UNCOMMITTED;
    }
    else if ([string isEqualToString:@"Restores on focus"]) {
        return DJ_RESTORE_UNCOMMITTED;
    }
    else if ([string isEqualToString:@"Automatically commits"]) {
        return DJ_COMMIT_UNCOMMITTED;
    }
    else {
        return nil;
    }
}

+(enum DJLogLevel)loggingLevel {
    return [DJLipikaUserSettings logLevelForString:[[NSUserDefaults standardUserDefaults] stringForKey:@"LoggingLevel"]];
}

+(NSString*)logLevelStringForEnum:(enum DJLogLevel)level {
    NSString* severity;
    switch (level) {
        case DJ_DEBUG:
            severity = @"Debug";
            break;
        case DJ_WARNING:
            severity = @"Warning";
            break;
        case DJ_ERROR:
            severity = @"Error";
            break;
        default:
            severity = @"Unknown";
            break;
    }
    return severity;
}

+(enum DJLogLevel)logLevelForString:(NSString*)level {
    if ([level isEqualToString:@"Debug"]) {
        return DJ_DEBUG;
    }
    else if ([level isEqualToString:@"Warning"]) {
        return DJ_WARNING;
    }
    else if ([level isEqualToString:@"Error"]) {
        return DJ_ERROR;
    }
    else {
        return nil;
    }
}

@end
