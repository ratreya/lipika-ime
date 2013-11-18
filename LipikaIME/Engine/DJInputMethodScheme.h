/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJForwardMapping.h"
#import "DJReverseMapping.h"

@interface DJInputMethodScheme : NSObject {
    // These regular expressions have dynamic elements per scheme
    NSRegularExpression* classDefinitionExpression;
    NSRegularExpression* classKeyExpression;
    NSRegularExpression* wildcardValueExpression;

    NSString *schemeFilePath;
    NSString *name;
    NSString *version;
    BOOL usingClasses;
    NSString *classOpenDelimiter;
    NSString *classCloseDelimiter;
    NSString *wildcard;
    NSString *stopChar;
    
    BOOL isProcessingClassDefinition;
    NSString* currentClassName;
    
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
