/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "Constants.h"

@interface DJLipikaUserSettings : NSUserDefaults

+(NSString*)scriptName;
+(void)setScriptName:(NSString*)scriptName;
+(NSString*)schemeName;
+(void)setSchemeName:(NSString*)schemeName;
+(enum DJSchemeType)schemeType;
+(void)setSchemeType:(enum DJSchemeType)schemeType;
+(NSString*)lipikaSchemeStopChar;
+(BOOL) isOutputInCandidate;
+(BOOL) isOverrideCandidateAttributes;
+(NSDictionary*)candidateWindowAttributes;
+(void)setCandidateStringAttributes:(NSDictionary*)attributes;
+(NSDictionary*)candidateStringAttributes;
+(NSString*)candidatePanelType;
+(BOOL)isCombineWithPreviousGlyph;
+(BOOL)isShowInput;
+(BOOL)isShowOutput;
+(enum DJLogLevel)loggingLevel;
+(NSString*)logLevelStringForEnum:(enum DJLogLevel)level;
+(enum DJLogLevel)logLevelForString:(NSString*)level;
+(enum DJBackspaceBehavior)backspaceBehavior;
+(enum DJOnUnfocusBehavior)unfocusBehavior;

+(void)reset;

@end
