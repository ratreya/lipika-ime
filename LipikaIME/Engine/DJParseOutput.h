/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>

@interface DJParseOutput : NSObject {
    NSString* input;
    NSString* output;
    /*
     * If this is true then the output is final and will not be changed anymore.
     * Else the above output could be replaced by subsequent outputs until
     * a final output is encountered.
     */
    BOOL isFinal;
    /*
     * If this is true then all outputs before this is final and will not be changed anymore.
     * Else the previous outputs could be replaced by subsequent outputs until a final output
     * is encountered.
     */
    BOOL isPreviousFinal;
}

@property NSString* input;
@property NSString* output;
@property BOOL isFinal;
@property BOOL isPreviousFinal;

+(DJParseOutput*)sameInputOutput:(NSString*)input;

@end
