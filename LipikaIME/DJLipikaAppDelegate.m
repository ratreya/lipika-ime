/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
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

#import "DJLipikaAppDelegate.h"
#import "DJInputEngineFactory.h"
#import "DJLipikaUserSettings.h"
#import <InputMethodKit/InputMethodKit.h>

@implementation DJLipikaAppDelegate

@synthesize mainMenu;

-(void)awakeFromNib {
    // Set selector for preferrence
    NSMenuItem* preferrence = [mainMenu itemWithTag:1];
    if (preferrence) {
        [preferrence setAction:@selector(showPreferences:)];
    }
    // Add Scheme item to the mainMenu
    int runningTagId = 2;   // 1 is taken by Preferrences... in MainMenu.nib
    NSMenuItem* schemeItem = [[NSMenuItem alloc] initWithTitle:@"Input Schemes" action:NULL keyEquivalent:@""];
    [schemeItem setTag:runningTagId];
    ++runningTagId;
    [mainMenu addItem:schemeItem];

    // Create a schemes sub menu
    NSString* defaultSchemeName = [DJLipikaUserSettings schemeName];
    NSMenu* schemeSubMenu = [[NSMenu alloc] initWithTitle:@"SchemesSubMenu"];
    NSArray* schemeNames = [DJInputEngineFactory availableSchemes];
    for (NSString* schemeName in schemeNames) {
        // Add add the schemes to the sub menu
        NSMenuItem* scheme = [[NSMenuItem alloc] initWithTitle:schemeName action:@selector(showPreferences:) keyEquivalent:@""];
        [scheme setTag:runningTagId];
        ++runningTagId;
        if ([defaultSchemeName isEqualToString:schemeName]) {
            [scheme setState:NSOnState];
        }
        [schemeSubMenu addItem:scheme];
    }
    [schemeItem setSubmenu:schemeSubMenu];
    [self configureCandiates];
    [self configureInput];
}

-(void)configureCandiates {
    extern IMKCandidates* candidates;
    [candidates setDismissesAutomatically:NO];
    [candidates setAttributes:[DJLipikaUserSettings candidateWindowAttributes]];
    candidateAttributes = [DJLipikaUserSettings candidateStringAttributes];
}

-(void)configureInput {
    inputAttributes = [NSMutableDictionary dictionaryWithDictionary:[DJLipikaUserSettings inputAttributes]];
    [inputAttributes setValue:[NSNumber numberWithInt:NSUnderlineStyleNone] forKey:NSUnderlineStyleAttributeName];
}

-(NSDictionary*)inputAttributes {
    return inputAttributes;
}

-(NSDictionary *)candidateStringAttributes {
    return candidateAttributes;
}

@end
