/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJCombinedBufferManager.h"
#import "DJInputSchemeFactory.h"
#import "DJLipikaUserSettings.h"

@implementation DJCombinedBufferManager

@synthesize scriptPopup;
@synthesize schemePopup;
@synthesize originalTextView;
@synthesize composedTextView;

-(id)init {
    self = [super init];
    if (!self) return self;
    manager = [[DJActiveBufferManager alloc] init];
    return self;
}

-(void)awakeFromNib {
    [scriptPopup addItemsWithTitles:[DJInputSchemeFactory availableScriptsForType:DJ_LIPIKA]];
    [schemePopup addItemsWithTitles:[DJInputSchemeFactory availableSchemesForType:DJ_LIPIKA]];
    [scriptPopup selectItemWithTitle:[DJLipikaUserSettings scriptName]];
    [schemePopup selectItemWithTitle:[DJLipikaUserSettings schemeName]];
}

-(BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if ([aTextView isEqual:originalTextView]) {
        NSLog(@"textDidChange for original");
    }
    else if ([aTextView isEqual:composedTextView]) {
        NSLog(@"textDidChange for composed");
    }
    else {
        NSLog(@"textDidChange for unknown");
    }
    return YES;
}

-(void)textViewDidChangeSelection:(NSNotification *)aNotification {
    if ([aNotification.object isEqual:originalTextView]) {
        NSLog(@"textViewDidChangeSelection for original");
    }
    else if ([aNotification.object isEqual:composedTextView]) {
        NSLog(@"textViewDidChangeSelection for composed");
    }
    else {
        NSLog(@"textViewDidChangeSelection for unknown");
    }
}

@end
