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
#import "DJLipikaClientDelegate.h"
#import "DJTestHelper.h"
#import "DJTestClient.h"

@interface DJLipikaSchemeFactory (Test)

+(void)setSchemesDirectory:(NSString *)directory;

@end

@interface DJClientManagerTest : XCTestCase {
    DJTestClient *client;
    DJLipikaClientManager *manager;
}

@end

@implementation DJClientManagerTest

-(void)setUp {
    [super setUp];
    [DJLipikaSchemeFactory setSchemesDirectory:@"./Schemes"];
    [DJTestHelper setupUserSettings];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CombineWithPreviousGlyph"];
    client = [[DJTestClient alloc] initWithCommittedString:@""];
    manager = [[DJLipikaClientManager alloc] initWithClient:[[DJLipikaClientDelegate alloc] initWithClient:client]];
    [manager changeToSchemeWithName:@"Barahavat" forScript:@"Devanagari" type:DJ_LIPIKA];
}

-(void)testHappyCase {
    [manager inputText:@"namonamaH "];
    XCTAssertEqualObjects(client.committedString, @"नमोनमः ");
}

-(void)testUncommittedString {
    [manager inputText:@"namonamaH"];
    XCTAssertEqualObjects(client.committedString, @"");
    XCTAssertEqualObjects(client.markedString, @"namonamaH");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोनमः");
}

-(void)testActiveStopChar {
    [manager inputText:@"ma\\itri "];
    XCTAssertEqualObjects(client.committedString, @"मइत्रि ");
}

-(void)testInactiveStopChar {
    [manager inputText:@"ma\\\\itri "];
    XCTAssertEqualObjects(client.committedString, @"म\\इत्रि ");
}

-(void)testCommittedDelete {
    [manager inputText:@"namonamaH "];
    XCTAssertEqualObjects(client.committedString, @"नमोनमः ");
    BOOL isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"नमोनमH");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"ः");
}

-(void)testUncommittedDelete {
    [manager inputText:@"namonamaH"];
    XCTAssertEqualObjects(client.committedString, @"");
    XCTAssertEqualObjects(client.markedString, @"namonamaH");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोनमः");
    BOOL isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.committedString, @"");
    XCTAssertEqualObjects(client.markedString, @"namonama");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोनम");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"namonam");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोनम्");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"namona");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोन");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"namon");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमोन्");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"namo");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नमो");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"nam");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"नम्");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"na");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"न");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"n");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"न्");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.committedString, @"");
    XCTAssertEqualObjects(client.markedString, @"");
    XCTAssertTrue(manager.candidateManager.candidates.count == 0);
}

-(void)testMultipleSpaceDelete {
    [manager inputText:@"namonamaH  "];
    XCTAssertEqualObjects(client.committedString, @"नमोनमः  ");
    BOOL isHandled = [manager handleBackspace];
    XCTAssertFalse(isHandled);
    // Client will delete one character
    [client handleBackspace];
    XCTAssertEqualObjects(client.committedString, @"नमोनमः ");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"नमोनमH");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"ः");
}

-(void)testWhiteSpaceDelete {
    [manager inputText:@"namo \t\nnamaH\r"];
    XCTAssertEqualObjects(client.committedString, @"नमो \t\nनमः\r");
    BOOL isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"नमो \t\nनमH");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"ः");
    isHandled = [manager handleBackspace];
    XCTAssertTrue(isHandled);
    XCTAssertEqualObjects(client.markedString, @"नमो \t\nनma");
    XCTAssertEqualObjects(manager.candidateManager.candidates[0], @"म");
}

@end
