/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

@interface OrderedDictionary : NSMutableDictionary {
    NSMutableDictionary *dictionary;
    NSMutableArray *array;
}

-(id)initWithCapacity:(NSUInteger)capacity;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(void)removeObjectForKey:(id)aKey;
-(NSUInteger)count;
-(NSEnumerator *)keyEnumerator;

@end
