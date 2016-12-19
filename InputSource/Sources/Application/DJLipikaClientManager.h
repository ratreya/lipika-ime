/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJLipikaCandidates.h"
#import "DJStringBufferManager.h"

@interface DJLipikaClientManager : NSObject {
    long numMyCompositionCommits;
    DJLipikaClientDelegate *client;
    DJStringBufferManager *bufferManager;
    DJLipikaCandidates *candidateManager;
}

-(id)initWithClient:(DJLipikaClientDelegate *)theClient;
-(DJLipikaCandidates *)candidateManager;
-(BOOL)inputText:(NSString *)string;
-(BOOL)handleBackspace;
-(BOOL)handleCancel;
-(void)onFocus;
-(void)onUnFocus;
-(void)onEndSession;
-(void)onCandidateSelected:(NSString *)candidateString;
-(void)changeToCustomSchemeWithName:(NSString *)schemeName;
-(void)changeToSchemeWithName:(NSString *)schemeName forScript:scriptName;
-(void)commit;

@end
