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

#import <Foundation/Foundation.h>
#import "DJForwardMapping.h"
#import "DJReverseMapping.h"

@interface DJInputMethodScheme : NSObject {
    NSString *schemeFilePath;
    NSString *name;
    NSString *version;
    BOOL usingClasses;
    NSString *classOpenDelimiter;
    NSString *classCloseDelimiter;
    NSString *wildcard;
    NSString *stopChar;
    
    DJForwardMapping *forwardMappings;
    DJReverseMapping *reverseMappings;
}

@property NSString *schemeFilePath;
@property NSString *name;
@property NSString *version;
@property BOOL usingClasses;
@property NSString *classOpenDelimiter;
@property NSString *classCloseDelimiter;
@property NSString *wildcard;
@property NSString *stopChar;

-(void)onStartParsingAtLine:(int)lineNumber;
-(void)createMappingWithLine:(NSString*)line lineNumber:(int)lineNumber;
-(void)onDoneParsingAtLine:(int)lineNumber;

-(DJForwardMapping*)forwardMappings;
-(DJReverseMapping*)reverseMappings;

@end
