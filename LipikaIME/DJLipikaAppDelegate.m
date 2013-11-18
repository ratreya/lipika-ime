/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaAppDelegate.h"
#import "DJInputEngineFactory.h"
#import "DJLipikaUserSettings.h"
#import <InputMethodKit/InputMethodKit.h>

@implementation DJLipikaAppDelegate

@synthesize mainMenu;

-(void)awakeFromNib {
    int runningTagId = 0;
    // Set selector for preferrence
    NSMenuItem* preferrence = [mainMenu itemWithTag:++runningTagId];
    if (preferrence) {
        [preferrence setAction:@selector(showPreferences:)];
    }
    // Add Convert file item
    NSMenuItem* convertFile = [[NSMenuItem alloc] initWithTitle:@"Convert file..." action:@selector(showPreferences:) keyEquivalent:@""];
    [convertFile setTag:++runningTagId];
    [mainMenu addItem:convertFile];
    // Add Schemes directory item
    NSMenuItem* openSchemes = [[NSMenuItem alloc] initWithTitle:@"Open schemes directory..." action:@selector(showPreferences:) keyEquivalent:@""];
    [openSchemes setTag:++runningTagId];
    [mainMenu addItem:openSchemes];
    // Add Scheme item to the mainMenu
    NSMenuItem* schemeSelectionItem = [[NSMenuItem alloc] initWithTitle:@"Input schemes" action:NULL keyEquivalent:@""];
    [schemeSelectionItem setTag:++runningTagId];
    [mainMenu addItem:schemeSelectionItem];

    // Create a schemes sub menus
    NSString* defaultScriptName = [DJLipikaUserSettings scriptName];
    NSString* defaultSchemeName = [DJLipikaUserSettings schemeName];
    NSMenu *scriptSubMenu = [[NSMenu alloc] initWithTitle:@"ScriptSubMenu"];
    NSArray *scriptNames = [DJInputEngineFactory availableScripts];
    for (NSString *scriptName in scriptNames) {
        NSMenuItem *scriptItem = [[NSMenuItem alloc] initWithTitle:scriptName action:NULL keyEquivalent:@""];
        [scriptItem setTag:++runningTagId];
        if ([defaultScriptName isEqualToString:scriptName]) {
            [scriptItem setState:NSOnState];
        }
        // Create schemes under this script
        NSMenu* schemeSubMenu = [[NSMenu alloc] initWithTitle:scriptName];
        NSArray* schemeNames = [DJInputEngineFactory availableSchemesForScript:scriptName];
        for (NSString* schemeName in schemeNames) {
            // Add add the schemes to the sub menu
            NSMenuItem* schemeItem = [[NSMenuItem alloc] initWithTitle:schemeName action:@selector(showPreferences:) keyEquivalent:@""];
            [schemeItem setTag:++runningTagId];
            if ([defaultScriptName isEqualToString:scriptName] && [defaultSchemeName isEqualToString:schemeName]) {
                [schemeItem setState:NSOnState];
            }
            [schemeSubMenu addItem:schemeItem];
        }
        [scriptItem setSubmenu:schemeSubMenu];
        [scriptSubMenu addItem:scriptItem];
    }
    [schemeSelectionItem setSubmenu:scriptSubMenu];
    [self configureCandiates];
}

-(void)configureCandiates {
    extern IMKCandidates* candidates;
    [candidates setPanelType:[DJLipikaUserSettings candidatePanelType]];
    [candidates setDismissesAutomatically:NO];
    [candidates setAttributes:[DJLipikaUserSettings candidateWindowAttributes]];
}

@end
