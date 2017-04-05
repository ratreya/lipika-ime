/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaUserSettings.h"

@implementation DJLipikaUserSettings

static NSString * const kVersion = @"Version";
static NSString * const kScriptName = @"ScriptName";
static NSString * const kCustomSchemeName = @"CustomSchemeName";
static NSString * const kSchemeName = @"SchemeName";
static NSString * const kSchemeType = @"SchemeType";
static NSString * const kLipikaSchemeStopChar = @"LipikaSchemeStopChar";
static NSString * const kOverrideCandidateFont = @"OverrideCandidateFont";
static NSString * const kCombineWithPreviousGlyph = @"CombineWithPreviousGlyph";
static NSString * const kCandidatesStringAttributes = @"CandidatesStringAttributes";
static NSString * const kCandidatePanelType = @"CandidatePanelType";
static NSString * const kShowInputString = @"ShowInputString";
static NSString * const kShowOutputString = @"ShowOutputString";
static NSString * const kOutputInCandidate = @"OutputInCandidate";
static NSString * const kIMKCandidatesOpacityAttributeName = @"IMKCandidatesOpacityAttributeName";
static NSString * const kBackspaceDeletes = @"BackspaceDeletes";
static NSString * const kOnUnfocusUncommitted = @"OnUnfocusUncommitted";
static NSString * const kLoggingLevel = @"LoggingLevel";
static NSString * const kFormatString = @"FormatString";
static NSString * const kInputCharacter = @"Input character";
static NSString * const kOutputCharacter = @"Output character";
static NSString * const kMappingOutput = @"Mapping output";
static NSString * const kAutomaticallyCommits = @"Automatically commits";
static NSString * const kRestoresOnFocus = @"Restores on focus";
static NSString * const kGetsDiscarded = @"Gets discarded";
static NSString * const kDebug = @"Debug";
static NSString * const kWarning = @"Warning";
static NSString * const kError = @"Error";
static NSString * const kFatal = @"Fatal";

static int SETTINGS_VERSION = 2;
static NSDictionary *candidateStringAttributeCache = nil;
static NSDictionary *candidatePanelEnumValues = nil;
static NSUserDefaults *standardUserDefaults = nil;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        candidatePanelEnumValues = @{
                                     @"kIMKSingleColumnScrollingCandidatePanel": @1,
                                     @"kIMKScrollingGridCandidatePanel": @2,
                                     @"kIMKSingleRowSteppingCandidatePanel": @3,
                                     };
    });
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserSettings" ofType:@"plist"]];
#if TARGET_OS_IPHONE
    standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.LipikaBoard"];
#else
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
#endif
    [standardUserDefaults registerDefaults:defaults];
    if ([standardUserDefaults integerForKey:@"Version"] != SETTINGS_VERSION) {
        [self reset];
    }
}

+(NSString *)scriptName {
    return [standardUserDefaults stringForKey:kScriptName];
}

+(void)setScriptName:(NSString *)scriptName {
    [standardUserDefaults setObject:scriptName forKey:kScriptName];
}

+(NSString *)customSchemeName {
    return [standardUserDefaults stringForKey:kCustomSchemeName];
}

+(void)setCustomSchemeName:(NSString *)schemeName {
    [standardUserDefaults setObject:schemeName forKey:kCustomSchemeName];
}

+(NSString *)schemeName {
    return [standardUserDefaults stringForKey:kSchemeName];
}

+(void)setSchemeName:(NSString *)schemeName {
    [standardUserDefaults setObject:schemeName forKey:kSchemeName];
}

+(enum DJSchemeType)schemeType {
    return (unsigned int)[standardUserDefaults integerForKey:kSchemeType];
}

+(void)setSchemeType:(enum DJSchemeType)schemeType {
    [standardUserDefaults setInteger:schemeType forKey:kSchemeType];
}

+(NSString *)lipikaSchemeStopChar {
    return [standardUserDefaults stringForKey:kLipikaSchemeStopChar];
}

+(BOOL) isOverrideCandidateAttributes {
    return [standardUserDefaults boolForKey:kOverrideCandidateFont];
}

+(BOOL)isCombineWithPreviousGlyph {
    return [standardUserDefaults boolForKey:kCombineWithPreviousGlyph];
}

+(NSDictionary *)candidateWindowAttributes {
#ifdef TARGET_OS_IPHONE
    return nil;
#else
    NSMutableDictionary *windowAttributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [windowAttributes setObject:[NSNumber numberWithFloat:[DJLipikaUserSettings opacity]] forKey:(NSString *)IMKCandidatesOpacityAttributeName];
    [windowAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)IMKCandidatesSendServerKeyEventFirst];
    return windowAttributes;
#endif
}

+(void)setCandidateStringAttributes:(NSDictionary *)attributes {
    candidateStringAttributeCache = attributes;
    NSData *outputData = [NSKeyedArchiver archivedDataWithRootObject:attributes];
    [standardUserDefaults setObject:outputData forKey:kCandidatesStringAttributes];
}

+(NSDictionary *)candidateStringAttributes {
    if (candidateStringAttributeCache) return candidateStringAttributeCache;
    NSData *data = [standardUserDefaults objectForKey:kCandidatesStringAttributes];
    if (data) {
        candidateStringAttributeCache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return candidateStringAttributeCache;
}

+(NSNumber *)candidatePanelType {
    return [candidatePanelEnumValues valueForKey:[standardUserDefaults stringForKey:kCandidatePanelType]];
}

+(BOOL)isShowInput {
    return [standardUserDefaults boolForKey:kShowInputString];
}

+(BOOL)isShowOutput {
    return [standardUserDefaults boolForKey:kShowOutputString];
}

+(BOOL) isOutputInCandidate {
    return [standardUserDefaults integerForKey:kOutputInCandidate];
}

+(float)opacity {
    return [standardUserDefaults floatForKey:kIMKCandidatesOpacityAttributeName];
}

+(void)reset {
    [self resetStandardUserDefaults];
    [[standardUserDefaults dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [standardUserDefaults removeObjectForKey:key];
    }];
    [standardUserDefaults synchronize];
}

+(enum DJBackspaceBehavior)backspaceBehavior {
    NSString *string = [standardUserDefaults stringForKey:kBackspaceDeletes];
    if ([string isEqualToString:kOutputCharacter]) {
        return DJ_DELETE_OUTPUT;
    }
    else if ([string isEqualToString:kMappingOutput]) {
        return DJ_DELETE_MAPPING;
    }
    else if ([string isEqualToString:kInputCharacter]) {
        return DJ_DELETE_INPUT;
    }
    else {
        return -1;
    }
}

+(enum DJOnUnfocusBehavior)unfocusBehavior {
    NSString *string = [standardUserDefaults stringForKey:kOnUnfocusUncommitted];
    if ([string isEqualToString:kGetsDiscarded]) {
        return DJ_DISCARD_UNCOMMITTED;
    }
    else if ([string isEqualToString:kRestoresOnFocus]) {
        return DJ_RESTORE_UNCOMMITTED;
    }
    else if ([string isEqualToString:kAutomaticallyCommits]) {
        return DJ_COMMIT_UNCOMMITTED;
    }
    else {
        return -1;
    }
}

+(enum DJLogLevel)loggingLevel {
    return [DJLipikaUserSettings logLevelForString:[standardUserDefaults stringForKey:kLoggingLevel]];
}

+(NSString *)logLevelStringForEnum:(enum DJLogLevel)level {
    NSString *severity;
    switch (level) {
        case DJ_DEBUG:
            severity = kDebug;
            break;
        case DJ_WARNING:
            severity = kWarning;
            break;
        case DJ_ERROR:
            severity = kError;
            break;
        case DJ_FATAL:
            severity = kFatal;
            break;
        default:
            severity = @"Unknown";
            break;
    }
    return severity;
}

+(enum DJLogLevel)logLevelForString:(NSString *)level {
    if ([level isEqualToString:kDebug]) {
        return DJ_DEBUG;
    }
    else if ([level isEqualToString:kWarning]) {
        return DJ_WARNING;
    }
    else if ([level isEqualToString:kError]) {
        return DJ_ERROR;
    }
    else if ([level isEqualToString:kFatal]) {
        return DJ_ERROR;
    }
    else {
        return -1;
    }
}

@end
