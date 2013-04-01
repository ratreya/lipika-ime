/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DJLipikaUserSettings.h"
#import <InputMethodKit/InputMethodKit.h>

@implementation DJLipikaUserSettings

+(void)initialize {
    NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserSettings" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+(NSString*)schemeName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SchemeName"];
}

+(void)setSchemeName:(NSString*)schemeName {
    [[NSUserDefaults standardUserDefaults] setObject:schemeName forKey:@"SchemeName"];
}

+(BOOL)isShowCandidateWindow {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowCandidateWindow"];
}

+(enum DJCandidateWindowText) candidateTextType {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"CandidateTextType"];
}

+(NSDictionary*)candidateWindowAttributes {
    NSMutableDictionary* windowAttributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [windowAttributes setValue:[NSNumber numberWithFloat:[DJLipikaUserSettings opacity]] forKey:@"IMKCandidatesOpacityAttributeName"];
    [windowAttributes setValue:[NSNumber numberWithBool:YES] forKey:@"IMKCandidatesSendServerKeyEventFirst"];
    return windowAttributes;
}

+(NSDictionary*)candidateStringAttributes {
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"CandidatesStringAttributes"];
    NSMutableDictionary* attributes;
    if (data) {
        attributes = [NSUnarchiver unarchiveObjectWithData:data];
        if(attributes) return attributes;
    }
    // Default attributes
    attributes = [[NSMutableDictionary alloc] initWithCapacity:3];
    [attributes setValue:[NSFont fontWithName:@"DevanagariMT" size:14.0] forKey:NSFontAttributeName];
    [attributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    [attributes setValue:[NSColor whiteColor] forKey:NSBackgroundColorDocumentAttribute];
    return attributes;
}

+(void)setCandidateStringAttributes:(NSDictionary*)attributes {
    NSData* outputData = [NSArchiver archivedDataWithRootObject:attributes];
    [[NSUserDefaults standardUserDefaults] setObject:outputData forKey:@"CandidatesStringAttributes"];
}

+(BOOL)isShowInput {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowInputString"];
}

+(BOOL)isInputLikeClient {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"InputLikeClient"];
}

+(NSDictionary*)inputAttributes {
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"InputStringAttributes"];
    NSMutableDictionary* attributes;
    if (data) {
        attributes = [NSUnarchiver unarchiveObjectWithData:data];
        if(attributes) return attributes;
    }
    attributes = [[NSMutableDictionary alloc] initWithCapacity:5];
    [attributes setValue:[NSFont fontWithName:@"Helvetica" size:13.0] forKey:NSFontAttributeName];
    return attributes;
}

+(void)setInputAttributes:(NSDictionary*)attributes {
    NSData* inputData = [NSArchiver archivedDataWithRootObject:attributes];
    [[NSUserDefaults standardUserDefaults] setObject:inputData forKey:@"InputStringAttributes"];
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
