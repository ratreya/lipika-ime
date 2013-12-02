/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>

@interface DJParseTreeNode : NSObject {
    NSString *input;
    NSString *output;
    NSMutableDictionary *next;
}

@property NSString *input;
@property NSString *output;
/*
 * key is either a NSString with the next character or NSString of the class name.
 * If next character is not found then check if its class exists.
 */
@property NSMutableDictionary *next;

-(NSString*)description;

extern NSMutableArray* charactersForString(NSString *string);
extern NSArray* csvToArrayForString(NSString *csvLine);

@end
