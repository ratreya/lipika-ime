/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2017 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"

@implementation OrderedDictionary

-(id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self != nil)
    {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        array = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

-(void)setObject:(id)anObject forKey:(id)aKey {
    if (![dictionary objectForKey:aKey])
    {
        [array addObject:aKey];
    }
    [dictionary setObject:anObject forKey:aKey];
}

-(void)removeObjectForKey:(id)aKey {
    [dictionary removeObjectForKey:aKey];
    [array removeObject:aKey];
}

-(NSUInteger)count {
    return [dictionary count];
}

-(id)objectForKey:(id)aKey {
    return [dictionary objectForKey:aKey];
}

-(NSEnumerator *)keyEnumerator {
    return [array objectEnumerator];
}

@end
