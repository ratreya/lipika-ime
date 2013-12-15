/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <InputMethodKit/InputMethodKit.h>

@class DJLipikaInputController;

@interface DJLipikaCandidates : NSObject {
    DJLipikaInputController *controller;
    NSArray *currentCandidates;
}

-(id)initWithController:(DJLipikaInputController *)controller;
-(void)showCandidateWithInput:(NSString *)input output:(NSString *)output replacement:(NSString *)replacement;
-(NSArray *)candidates:(id)sender;
-(void)hide;

@end
