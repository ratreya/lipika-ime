/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJInputMethodEngine.h"

@interface DJLipikaBufferManager : NSObject {
    // One instance of the engine per connection
    DJInputMethodEngine *engine;
    // Holds NSString outputs that need to be handed off to the client
    NSMutableArray *uncommittedOutput;
    // New output from the engine will replace all output after this index
    unsigned long finalizedIndex;
    // The string in the client that is being replaced
    NSString *replacement;
}

-(id)init;
-(void)changeToSchemeWithName:(NSString*)schemeName forScript:scriptName;
-(NSString*)outputForInput:(NSString*)string;
-(NSString*)outputForInput:(NSString*)string previousText:(NSString*)previousText;
-(BOOL)hasDeletable;
-(void)delete;
-(BOOL)hasOutput;
-(NSString*)output;
-(NSString*)input;
-(NSString*)flush;
-(NSString*)revert;
-(int)maxOutputLength;
-(NSString*)replacement;

@end
