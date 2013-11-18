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

@interface DJInputSchemeFactory : NSObject {
    // Internal instance variable
    DJInputMethodScheme* scheme;
    NSArray* linesOfScheme;
    int currentLineNumber;
}

@property DJInputMethodScheme* scheme;

+(DJInputMethodScheme*)inputSchemeForSchemeFile:(NSString*)filePath;

-(id)initWithSchemeFile:(NSString*)filePath;

@end
