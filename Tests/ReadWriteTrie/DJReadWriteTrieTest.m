/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJReadWriteTrie.h"

@interface DJReadWriteTrieTest : XCTestCase

@end

@implementation DJReadWriteTrieTest

-(void)testRetrival {
    DJReadWriteTrie *trie = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie addValue:@"1" forKey:@"a"];
    [trie addValue:@"2" forKey:@"ab"];
    [trie addValue:@"3" forKey:@"abc"];
    XCTAssertEqualObjects(@"1", [trie nodeForKey:@"a"].value);
    XCTAssertEqualObjects(@"2", [trie nodeForKey:@"ab"].value);
    XCTAssertEqualObjects(@"3", [trie nodeForKey:@"abc"].value);
}

@end
