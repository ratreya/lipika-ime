/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

@interface DJTestClient : NSObject<IMKTextInput> {
    NSString *committedString;
    NSString *markedString;
    NSRange selectedRange;
    NSRange markedRange;
    NSDictionary *attributes;
}

@property NSString *committedString;
@property NSString *markedString;
@property NSDictionary *attributes;

-(id)initWithCommittedString:(NSString *)theString;

@end
