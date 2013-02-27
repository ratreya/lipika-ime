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
#import "Constants.h"

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

+(NSFont*)candidateFont {
    NSString* fontName = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_FONT_NAME_KEY];
    float fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULT_FONT_SIZE_KEY];
    return [NSFont fontWithName:fontName size:fontSize];
}

+(void)setCandidateFont:(NSString*)fontName fontSize:(float)fontSize {
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:DEFAULT_FONT_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:fontSize forKey:DEFAULT_FONT_SIZE_KEY];
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

+(void)setFontColor:(NSColor*)fontColor {
    NSData* data = [NSArchiver archivedDataWithRootObject:fontColor];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DEFAULT_FONT_COLOR_KEY];
}

+(NSColor*)backgroundColor {
    NSColor* color = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_BACKGROUND_KEY]];
    if (color) {
        return color;
    }
    else {
        return [NSColor colorWithCalibratedRed:135 green:206 blue:250 alpha:1.0];
    }
}

+(void)setBackgroundColor:(NSColor*)backgroundColor {
    NSData* data = [NSArchiver archivedDataWithRootObject:backgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DEFAULT_BACKGROUND_KEY];
}

+(float)opacity {
    return [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULT_OPACITY_KEY];
}

+(void)setOpacity:(float)opacity {
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:DEFAULT_OPACITY_KEY];
}

+(void)reset {
    [self resetStandardUserDefaults];
    NSString* domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
