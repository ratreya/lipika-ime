/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaSchemeFactory.h"

@implementation DJLipikaSchemeFactory

+(DJLipikaInputScheme*)inputSchemeForScript:script scheme:scheme {
    // Parse one file at a time
    @synchronized(self) {
        DJLipikaSchemeFactory *factory = [[DJLipikaSchemeFactory alloc] initWithScript:script scheme:scheme];
        return [factory scheme];
    }
}

+(NSArray*)availableScripts {
    return [DJLipikaSchemeFactory fileInSubdirectory:@"Script" withExternsion:@".map"];
}

+(NSArray*)availableSchemes {
    return [DJLipikaSchemeFactory fileInSubdirectory:@"Script" withExternsion:@".tlr"];
}

-(id<DJInputMethodScheme>)scheme {
    return scheme;
}

+(NSArray*)fileInSubdirectory:(NSString*)subDirectory withExternsion:(NSString*)extension {
    NSError *error;
    NSString *schemesDirectory = [NSString stringWithFormat:@"%@/Contents/Resources/Schemes", [[NSBundle mainBundle] bundlePath]];
    NSString *path = subDirectory? [schemesDirectory stringByAppendingPathComponent:subDirectory] : schemesDirectory;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        [NSException raise:@"Error accessing schemes directory" format:@"Error accessing schemes directory: %@", [error localizedDescription]];
    }
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '%@'", extension]]];
    NSMutableArray* names = [[NSMutableArray alloc] initWithCapacity:0];
    [files enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        [names addObject:[obj stringByDeletingPathExtension]];
    }];
    return names;
}

-(id)initWithScript:script scheme:scheme {

}

@end
