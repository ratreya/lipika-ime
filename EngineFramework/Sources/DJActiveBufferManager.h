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
#import "Constants.h"

@interface DJActiveBufferManager : NSObject {
    // One instance of the engine per connection
    DJInputMethodEngine *engine;
    // Holds NSString outputs that need to be handed off to the client
    NSMutableArray *uncommittedOutput;
    // New output from the engine will replace all output after this index
    unsigned long finalizedIndex;
}

-(id<DJReverseMapping>)reverseMappings;
-(void)changeToSchemeWithName:(NSString *)schemeName forScript:scriptName type:(enum DJSchemeType)type;
-(NSArray *)outputForInput:(NSString *)string;
-(BOOL)hasDeletable;
-(void)delete;
-(NSArray *)flush;
-(NSArray *)uncommitted;

@end
