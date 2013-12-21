/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJLipikaSchemeFactory.h"
#import "DJLipikaClientManager.h"
#import "DJTestHelper.h"
#import "DJTestClient.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString *)directory;

@end

@interface DJClientManagerTest : XCTestCase

@end

@implementation DJClientManagerTest

-(void)setUp {
    [super setUp];
    [DJLipikaSchemeFactory setSchemesDirectory:@"./Schemes"];
    [DJTestHelper setupUserSettings];
}

-(void)testHappyCase {
    DJTestClient *client = [[DJTestClient alloc] initWithCommittedString:@""];
    DJLipikaClientManager *manager = [[DJLipikaClientManager alloc] initWithClient:client];
    [manager changeToSchemeWithName:@"Barahavat" forScript:@"Devanagari" type:DJ_LIPIKA];
    [manager inputText:@"namonamaH "];
    XCTAssertEqualObjects(client.committedString, @"नमोनमः ");
}

@end
