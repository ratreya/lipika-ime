/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import "DJInputMethodScheme.h"
#import "DJGoogleForwardMapping.h"
#import "DJGoogleReverseMapping.h"

@interface DJGoogleInputScheme : NSObject<DJInputMethodScheme> {
    // These regular expressions have dynamic elements per scheme
    NSRegularExpression *classDefinitionExpression;
    NSRegularExpression *classKeyExpression;
    NSRegularExpression *wildcardValueExpression;

    NSString *schemeFilePath;
    NSString *name;
    NSString *version;
    BOOL usingClasses;
    NSString *classOpenDelimiter;
    NSString *classCloseDelimiter;
    NSString *wildcard;
    NSString *stopChar;
    double fingerprint;
    
    BOOL isProcessingClassDefinition;
    NSString *currentClassName;

    DJGoogleForwardMapping *forwardMappings;
    DJGoogleReverseMapping *reverseMappings;
}

@property NSString *schemeFilePath;
@property NSString *name;
@property NSString *version;
@property BOOL usingClasses;
@property NSString *classOpenDelimiter;
@property NSString *classCloseDelimiter;
@property NSString *wildcard;
@property NSString *stopChar;
@property double fingerprint;

-(void)onStartParsingAtLine:(int)lineNumber;
-(void)createMappingWithLine:(NSString *)line lineNumber:(int)lineNumber;
-(void)onDoneParsingAtLine:(int)lineNumber;

-(DJGoogleForwardMapping *)forwardMappings;
-(DJGoogleReverseMapping *)reverseMappings;

@end
