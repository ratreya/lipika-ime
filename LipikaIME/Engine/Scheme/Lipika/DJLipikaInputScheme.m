/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaInputScheme.h"
#import "DJLipikaForwardMapping.h"
#import "DJLipikaReverseMapping.h"
#import "DJLipikaUserSettings.h"

@implementation DJLipikaInputScheme

-(NSString*)schemeFilePath {
    
}

-(NSString*)stopChar {
    return [DJLipikaUserSettings lipikaSchemeStopChar];
}

-(DJLipikaForwardMapping*)forwardMappings {
    
}

-(DJLipikaReverseMapping*)reverseMappings {
    
}


@end
