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

-(DJReadWriteTrie *)testTrie {
    DJReadWriteTrie *trie = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie addValue:@"1" forKey:@"a"];
    [trie addValue:@"2" forKey:@"ab"];
    [trie addValue:@"3" forKey:@"abc"];
    [trie addValue:@"4" forKey:@"ap"];
    [trie addValue:@"5" forKey:@"apq"];
    [trie addValue:@"6" forKey:@"apr"];
    [trie addValue:@"7" forKey:@"ax"];
    [trie addValue:@"8" forKey:@"axy"];
    [trie addValue:@"9" forKey:@"axz"];
    return trie;
}

-(void)assertTestTrie:(DJReadWriteTrie *)trie {
    XCTAssertEqualObjects(@"1", [trie nodeForKey:@"a"].value);
    XCTAssertEqualObjects(@"2", [trie nodeForKey:@"ab"].value);
    XCTAssertEqualObjects(@"3", [trie nodeForKey:@"abc"].value);
    XCTAssertEqualObjects(@"4", [trie nodeForKey:@"ap"].value);
    XCTAssertEqualObjects(@"5", [trie nodeForKey:@"apq"].value);
    XCTAssertEqualObjects(@"6", [trie nodeForKey:@"apr"].value);
    XCTAssertEqualObjects(@"7", [trie nodeForKey:@"ax"].value);
    XCTAssertEqualObjects(@"8", [trie nodeForKey:@"axy"].value);
    XCTAssertEqualObjects(@"9", [trie nodeForKey:@"axz"].value);
}

-(void)testHappyCase {
    DJReadWriteTrie *trie = [self testTrie];
    [self assertTestTrie:trie];
}

-(void)testTrieCloning {
    DJReadWriteTrie *original = [self testTrie];
    DJReadWriteTrie *clone = [original cloneTrieUsingBlock:^DJTrieNode *(DJTrieNode *original) {
        DJTrieNode *clone = [[DJTrieNode alloc] init];
        clone.key = original.key;
        clone.value = original.value;
        return clone;
    }];
    [self assertTestTrie:clone];
}

-(void)testTrieMergingRootAtRoot {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    DJReadWriteTrie *trie2 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie2 addValue:@"4" forKey:@"ap"];
    [trie2 addValue:@"5" forKey:@"apq"];
    [trie2 addValue:@"6" forKey:@"apr"];
    DJReadWriteTrie *trie3 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie3 addValue:@"7" forKey:@"ax"];
    [trie3 addValue:@"8" forKey:@"axy"];
    [trie3 addValue:@"9" forKey:@"axz"];
    [trie1 mergeTrieWithHead:trie2.trieHead intoNode:trie1.trieHead];
    [trie1 mergeTrieWithHead:trie3.trieHead intoNode:trie1.trieHead];
    [self assertTestTrie:trie1];
}

-(void)testTrieMergingRootAtNonRoot {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    DJReadWriteTrie *trie2 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie2 addValue:@"4" forKey:@"ap"];
    [trie2 addValue:@"5" forKey:@"apq"];
    [trie2 addValue:@"6" forKey:@"apr"];
    DJReadWriteTrie *trie3 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie3 addValue:@"7" forKey:@"ax"];
    [trie3 addValue:@"8" forKey:@"axy"];
    [trie3 addValue:@"9" forKey:@"axz"];
    DJTrieNode *atNode2 = [trie2 nodeForKey:@"ap"];
    [trie2 mergeTrieWithHead:trie3.trieHead intoNode:atNode2];
    DJTrieNode *atNode1 = [trie1 nodeForKey:@"ab"];
    [trie1 mergeTrieWithHead:trie2.trieHead intoNode:atNode1];
    XCTAssertEqualObjects(@"7", [trie1 nodeForKey:@"abapax"].value);
}

-(void)testTrieMergingNonRootAtRoot {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    DJReadWriteTrie *trie2 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie2 addValue:@"4" forKey:@"ap"];
    [trie2 addValue:@"5" forKey:@"apq"];
    [trie2 addValue:@"6" forKey:@"apr"];
    DJReadWriteTrie *trie3 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie3 addValue:@"7" forKey:@"ax"];
    [trie3 addValue:@"8" forKey:@"axy"];
    [trie3 addValue:@"9" forKey:@"axz"];
    DJTrieNode *atNode2 = [trie2 nodeForKey:@"ap"];
    [trie1 mergeTrieWithHead:atNode2 intoNode:trie1.trieHead];
    XCTAssertNil([trie1 nodeForKey:@"ap"].value);
    XCTAssertNil([trie1 nodeForKey:@"apq"].value);
    // The following is expected but obviosly wrong
    XCTAssertEqualObjects(@"apq", [trie1 nodeForKey:@"q"].key);
    XCTAssertEqualObjects(@"apr", [trie1 nodeForKey:@"r"].key);
    XCTAssertEqualObjects(@"5", [trie1 nodeForKey:@"q"].value);
    XCTAssertEqualObjects(@"6", [trie1 nodeForKey:@"r"].value);
}

-(void)testTrieMergingNonRootAtNonRoot {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    DJReadWriteTrie *trie2 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie2 addValue:@"4" forKey:@"ap"];
    [trie2 addValue:@"5" forKey:@"apq"];
    [trie2 addValue:@"6" forKey:@"apr"];
    DJReadWriteTrie *trie3 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie3 addValue:@"7" forKey:@"ax"];
    [trie3 addValue:@"8" forKey:@"axy"];
    [trie3 addValue:@"9" forKey:@"axz"];
    DJTrieNode *atNode2 = [trie2 nodeForKey:@"ap"];
    [trie2 mergeTrieWithHead:trie3.trieHead intoNode:atNode2];
    DJTrieNode *atNode1 = [trie1 nodeForKey:@"ab"];
    [trie1 mergeTrieWithHead:trie2.trieHead intoNode:atNode1];
    XCTAssertEqualObjects(@"7", [trie1 nodeForKey:@"abapax"].value);
}

-(void)testNoOverwriteAddValue {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:NO];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    [trie1 addValue:@"4" forKey:@"abc"];
    XCTAssertEqualObjects(@"3", [trie1 nodeForKey:@"abc"].value);
}

-(void)testNoOverwriteMergeTrie {
    DJReadWriteTrie *trie1 = [[DJReadWriteTrie alloc] initWithIsOverwrite:NO];
    [trie1 addValue:@"1" forKey:@"a"];
    [trie1 addValue:@"2" forKey:@"ab"];
    [trie1 addValue:@"3" forKey:@"abc"];
    DJReadWriteTrie *trie2 = [[DJReadWriteTrie alloc] initWithIsOverwrite:YES];
    [trie2 addValue:@"5" forKey:@"a"];
    [trie2 addValue:@"6" forKey:@"ab"];
    [trie2 addValue:@"7" forKey:@"abc"];
    [trie1 mergeTrieWithHead:trie2.trieHead intoNode:trie1.trieHead];
    XCTAssertEqualObjects(@"3", [trie1 nodeForKey:@"abc"].value);
}

@end
