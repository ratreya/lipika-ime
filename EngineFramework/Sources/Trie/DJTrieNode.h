/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>

@interface DJTrieNode : NSObject {
    NSString *key;
    NSString *value;
    NSMutableDictionary *next;
}

@property NSString *key;
@property NSString *value;
@property NSMutableDictionary *next;

@end
