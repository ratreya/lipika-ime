/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Cocoa/Cocoa.h>
#import "DJInputMethodScheme.h"
#import "DJSimpleForwardMapping.h"
#import "DJSimpleReverseMapping.h"

@interface DJLipikaInputScheme : NSObject<DJInputMethodScheme> {
    DJSimpleForwardMapping *forwardMapping;
    DJSimpleReverseMapping *reverseMapping;
    NSDictionary *schemeTable;
    NSDictionary *scriptTable;
    NSDictionary *validKeys;
}

-(id)initWithSchemeTable:(NSDictionary*)schemeTable scriptTable:(NSDictionary*)scriptTable imeLines:(NSArray*)imeLines;

@end
