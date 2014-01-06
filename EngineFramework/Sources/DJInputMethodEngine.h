/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJInputMethodScheme.h"
#import "DJTrieNode.h"
#import "DJParseOutput.h"

@interface DJInputMethodEngine : NSObject {
    id<DJInputMethodScheme> scheme;
    DJTrieNode *currentNode;
    NSMutableArray *inputsSinceRoot;
    unsigned long lastOutputIndex;
}

@property id<DJInputMethodScheme> scheme;

-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;
-(NSArray *)executeWithInput:(NSString *)input;
-(NSArray *)inputsSinceLastOutput;
-(BOOL)hasDeletable;
-(void)reset;

@end
