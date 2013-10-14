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

#import <InputMethodKit/InputMethodKit.h>

@class DJLipikaInputController;

@interface DJLipikaCandidates : NSObject {
    DJLipikaInputController* controller;
    NSArray* currentCandidates;
}

-(id)initWithController:(DJLipikaInputController*)controller;
-(void)showCandidateWithInput:(NSString*)input output:(NSString*)output replacement:(NSString*)replacement;
-(NSArray*)candidates:(id)sender;
-(void)hide;

@end
