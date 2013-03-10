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

@implementation DJLipikaUserSettings

+(void)initialize {
    NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserSettings" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+(NSString*)schemeName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_SCHEME_NAME_KEY];
}

+(void)setSchemeName:(NSString*)schemeName {
    [[NSUserDefaults standardUserDefaults] setObject:schemeName forKey:DEFAULT_SCHEME_NAME_KEY];
}

+(NSString*)candidateFontName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_FONT_NAME_KEY];
}

+(float)candidateFontSize {
    return [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULT_FONT_SIZE_KEY];
}

+(NSFont*)candidateFont {
    NSString* fontName = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_FONT_NAME_KEY];
    float fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULT_FONT_SIZE_KEY];
    return [NSFont fontWithName:fontName size:fontSize];
}

+(NSColor*)fontColor {
    NSColor* color = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_FONT_COLOR_KEY]];
    if (color) {
        return color;
    }
    else {
        return [NSColor blackColor];
    }
}

+(NSColor*)backgroundColor {
    NSColor* color = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_BACKGROUND_KEY]];
    if (color) {
        return color;
    }
    else {
        return [NSColor whiteColor];
    }
}

+(float)opacity {
    return [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULT_OPACITY_KEY];
}

+(void)reset {
    [self resetStandardUserDefaults];
    [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(enum DJBackspaceBehavior)backspaceBehavior {
    NSString* string = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_BACKSPACE_BEHAVIOR_KEY];
    if ([string isEqualToString:@"Output character"]) {
        return DJ_DELETE_OUTPUT;
    }
    else if ([string isEqualToString:@"Mapping output"]) {
        return DJ_DELETE_MAPPING;
    }
    else {
        return nil;
    }
}

+(enum DJOnUnfocusBehavior)unfocusBehavior {
    NSString* string = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_UNFOCUS_BEHAVIOR_KEY];
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
    return [DJLipikaUserSettings logLevelForString:[[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_LOGGING_LEVEL_KEY]];
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
