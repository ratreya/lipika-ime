/*
 * LipikaIME a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DJReverseMapping.h"

@implementation DJReverseMapping

-(id)initWithScheme:(DJInputMethodScheme*)parentScheme {
    self = [super init];
    if (self == nil) return self;
    scheme = parentScheme;
    reverseTrie = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value {
    
}

-(void)createClassMappingWithPreKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    
}

-(void)startClassDefinitionWithName:(NSString*)className {
    
}

-(void)endClassDefinition {
    
}

-(void)onDoneParsingAtLine:(int)lineNumber {
    
}

@end
