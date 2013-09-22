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

#import "DJInputMethodScheme.h"

@implementation DJInputMethodScheme

@synthesize schemeFilePath;
@synthesize name;
@synthesize version;
@synthesize usingClasses;
@synthesize classOpenDelimiter;
@synthesize classCloseDelimiter;
@synthesize wildcard;
@synthesize stopChar;

-(id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    // Set default values
    wildcard = @"*";
    stopChar = @"\\";
    usingClasses = YES;
    classOpenDelimiter = @"{";
    classCloseDelimiter = @"}";
    return self;
}

-(void)onStartParsingAtLine:(int)lineNumber {
    if (!forwardMappings) forwardMappings = [[DJForwardMapping alloc] initWithScheme:self];
    if (!reverseMappings) reverseMappings = [[DJReverseMapping alloc] initWithScheme:self];
}

-(void)createMappingWithLine:(NSString*)line lineNumber:(int)lineNumber {
    [forwardMappings createMappingWithLine:line lineNumber:lineNumber];
    [reverseMappings createMappingWithLine:line lineNumber:lineNumber];
}

-(void)onDoneParsingAtLine:(int)lineNumber {
    [forwardMappings onDoneParsingAtLine:lineNumber];
    [reverseMappings onDoneParsingAtLine:lineNumber];
}

-(DJForwardMapping*)forwardMappings {
    return forwardMappings;
}

-(DJReverseMapping*)reverseMappings {
    return nil;
}

@end
