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

@class DJInputMethodScheme;

@interface DJForwardMapping : NSObject {
    // These regular expressions have dynamic elements per scheme
    NSRegularExpression* classDefinitionExpression;
    NSRegularExpression* classKeyExpression;
    NSRegularExpression* wildcardValueExpression;

    int currentLineNumber;
    DJInputMethodScheme *scheme;
    BOOL isProcessingClassDefinition;
    NSString* currentClassName;
    NSMutableDictionary* currentClass;

    // Input as NSString to DJParseTreeNode
    NSMutableDictionary *parseTree;
    // Class name as NSString to NSMutableDictionary of NSString to DJParseTreeNode
    NSMutableDictionary *classes;
}

@property NSMutableDictionary *parseTree;
@property NSMutableDictionary *classes;

-(id)initWithScheme:(DJInputMethodScheme*)parentScheme;
-(void)createMappingWithLine:(NSString*)line lineNumber:(int)lineNumber;
-(void)onDoneParsingAtLine:(int)lineNumber;

-(NSString*)classNameForInput:(NSString*)input;
-(NSMutableDictionary*)classForName:(NSString*)className;

@end
