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

-(void)testTrieMerging {
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

@end
