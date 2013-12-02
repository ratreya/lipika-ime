/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <InputMethodKit/InputMethodKit.h>
#import "DJLipikaAppDelegate.h"
#import "DJInputSchemeUberFactory.h"
#import "DJLipikaUserSettings.h"

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
    // Add Scheme item to the mainMenu
    NSMenuItem* schemeSelectionItem = [[NSMenuItem alloc] initWithTitle:@"Input scheme" action:NULL keyEquivalent:@""];
    [schemeSelectionItem setTag:++runningTagId];
    [mainMenu addItem:schemeSelectionItem];
    // Create a schemes submenu
    NSMenu* schemeSubMenu = [[NSMenu alloc] initWithTitle:@"SchemeSubMenu"];
    NSArray* schemeNames = [DJInputSchemeUberFactory availableSchemesForType:LIPIKA];
    NSString* defaultSchemeName = [DJLipikaUserSettings schemeName];
    enum DJSchemeType type = [DJLipikaUserSettings schemeType];
    for (NSString* schemeName in schemeNames) {
        // Add add the schemes to the sub menu
        NSMenuItem* schemeItem = [[NSMenuItem alloc] initWithTitle:schemeName action:@selector(showPreferences:) keyEquivalent:@""];
        [schemeItem setTag:++runningTagId];
        if (type == LIPIKA && [defaultSchemeName isEqualToString:schemeName]) {
            [schemeItem setState:NSOnState];
        }
        [schemeSubMenu addItem:schemeItem];
    }
    [schemeSelectionItem setSubmenu:schemeSubMenu];
    // Add Script item to the mainMenu
    NSMenuItem* scriptSelectionItem = [[NSMenuItem alloc] initWithTitle:@"Output script" action:NULL keyEquivalent:@""];
    [scriptSelectionItem setTag:++runningTagId];
    [mainMenu addItem:scriptSelectionItem];
    // Create a scripts submenu
    NSMenu *scriptSubMenu = [[NSMenu alloc] initWithTitle:@"ScriptSubMenu"];
    NSArray *scriptNames = [DJInputSchemeUberFactory availableScriptsForType:LIPIKA];
    NSString* defaultScriptName = [DJLipikaUserSettings scriptName];
    for (NSString *scriptName in scriptNames) {
        NSMenuItem *scriptItem = [[NSMenuItem alloc] initWithTitle:scriptName action:@selector(showPreferences:) keyEquivalent:@""];
        [scriptItem setTag:++runningTagId];
        if (type == LIPIKA && [defaultScriptName isEqualToString:scriptName]) {
            [scriptItem setState:NSOnState];
        }
        [scriptSubMenu addItem:scriptItem];
    }
    [scriptSelectionItem setSubmenu:scriptSubMenu];
    // Create a custom schemes submenu if needed
    NSArray *googleSchemes = [DJInputSchemeUberFactory availableSchemesForType:GOOGLE];
    if (googleSchemes && googleSchemes.count > 0) {
        NSMenuItem* googleSchemeItem = [[NSMenuItem alloc] initWithTitle:@"Custom schemes" action:NULL keyEquivalent:@""];
        [googleSchemeItem setTag:++runningTagId];
        [mainMenu addItem:googleSchemeItem];
        NSMenu* googleSubMenu = [[NSMenu alloc] initWithTitle:@"GoogleSubMenu"];
        for (NSString* googleScheme in googleSchemes) {
            // Add add the schemes to the sub menu
            NSMenuItem* schemeItem = [[NSMenuItem alloc] initWithTitle:googleScheme action:@selector(showPreferences:) keyEquivalent:@""];
            [schemeItem setTag:++runningTagId];
            if (type == GOOGLE && [defaultSchemeName isEqualToString:googleScheme]) {
                [schemeItem setState:NSOnState];
            }
            [googleSubMenu addItem:schemeItem];
        }
        [googleSchemeItem setSubmenu:googleSubMenu];
    }
    [self configureCandiates];
}

-(void)configureCandiates {
    extern IMKCandidates* candidates;
    [candidates setPanelType:[DJLipikaUserSettings candidatePanelType]];
    [candidates setDismissesAutomatically:NO];
    [candidates setAttributes:[DJLipikaUserSettings candidateWindowAttributes]];
}

@end
