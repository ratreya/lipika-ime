/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJActiveBufferManager.h"

@interface DJStringBufferManager : NSObject {
    DJActiveBufferManager *delegate;
    // The string in the client that is being replaced
    NSString *replacement;
}

-(void)changeToLipikaSchemeWithName:(NSString *)schemeName forScript:(NSString *)scriptName;
-(void)changeToCustomSchemeWithName:(NSString *)schemeName;
-(NSString *)outputForInput:(NSString *)string;
-(NSString *)outputForInput:(NSString *)string previousText:(NSString *)previousText;
-(BOOL)hasDeletable;
-(void)delete;
-(BOOL)hasOutput;
-(NSString *)output;
-(NSString *)input;
-(NSString *)flush;
-(NSString *)revert;
-(int)maxOutputLength;
-(NSString *)replacement;
-(id<DJReverseMapping>)reverseMappings;

@end
