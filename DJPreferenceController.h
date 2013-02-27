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

#import <Cocoa/Cocoa.h>

@interface DJPreferenceController : NSWindowController <NSTextFieldDelegate> {
    IBOutlet NSTextField* opacity;
    IBOutlet NSComboBox* fontName;
    IBOutlet NSTextField* fontSize;
    IBOutlet NSColorWell* fontColor;
    IBOutlet NSColorWell* background;
    IBOutlet NSButton* save;
}

@property IBOutlet NSTextField* opacity;
@property IBOutlet NSComboBox* fontName;
@property IBOutlet NSTextField* fontSize;
@property IBOutlet NSColorWell* fontColor;
@property IBOutlet NSColorWell* background;
@property IBOutlet NSButton* save;

-(IBAction)saveValues:(id)sender;
-(IBAction)resetValues:(id)sender;

+(void)configureCandidates;

@end
