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

@interface DJLipikaClientDelegate : NSObject {
    id<IMKTextInput> client;
    BOOL isDocumentAccessSupported;
    BOOL is32BitApplication;
}

-(id)initWithClient:(id<IMKTextInput>)theClient;
-(BOOL)isDocumentAccessSupported;
-(NSDictionary *)textAttributesAtCurrentPosition;
-(void)insertTextAtCurrentPosition:(NSString *)text;
-(void)replaceTextAtCurrentSelection:(NSString *)text;
-(void)setMarkedText:(NSAttributedString *)text withReplacementOffset:(int)offset;
-(void)clearMarkedText;
-(NSRange)selectedRange;
-(NSString *)previousTextOfLength:(unsigned long)length withOffset:(int)offset;

@end
