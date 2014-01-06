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
#import "DJLipikaBufferManager.h"

@interface DJLipikaClientManager : NSObject {
    long numMyCompositionCommits;
    DJLipikaClientDelegate *client;
    DJLipikaBufferManager *bufferManager;
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
-(void)changeToSchemeWithName:(NSString *)schemeName forScript:scriptName type:(enum DJSchemeType)type;
-(void)commit;

@end
