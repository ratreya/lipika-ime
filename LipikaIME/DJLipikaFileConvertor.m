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

#import "DJLipikaFileConvertor.h"
#import "DJLipikaBufferManager.h"
#import "DJLipikaUserSettings.h"
#import "DJLogger.h"
#import <Cocoa/Cocoa.h>

@implementation DJLipikaFileConvertor

+(void) convert {
    // Display the input file dialog
    NSOpenPanel* inputChoice = [NSOpenPanel openPanel];
    [inputChoice setCanChooseFiles:YES];
    [inputChoice setAllowsMultipleSelection:NO];
    [inputChoice setTitle:@"Choose input file..."];
    [inputChoice setPrompt:@"Choose"];
    [NSApp activateIgnoringOtherApps:YES];
    [inputChoice makeKeyAndOrderFront:self];
    [inputChoice beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelCancelButton) {
            return;
        }
        NSURL* fileURL = [[inputChoice URLs] objectAtIndex:0];
        logDebug(@"Chosen input file: %@", fileURL);
        // Read file contents
        NSError *error;
        NSString* contents = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
            [NSAlert alertWithError:error];
            return;
        }
        NSArray* lines = [contents componentsSeparatedByString:@"\r"];
        // Open output file and convert
        NSString *outputFileName = [[fileURL path] stringByAppendingPathExtension:@"out"];
        logDebug(@"Ouput file: %@", outputFileName);
        if (![[NSFileManager defaultManager] createFileAtPath:outputFileName contents:nil attributes:nil]) {
            logError(@"Unable to create file %@", outputFileName);
            NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil];
            [NSAlert alertWithError:error];
            return;
        }
        NSFileHandle *outputFile = [NSFileHandle fileHandleForWritingAtPath:outputFileName];
        DJLipikaBufferManager *engine = [[DJLipikaBufferManager alloc] init];
        for (NSString *line in lines) {
            NSString *output = [engine outputForInput:line];
            [outputFile writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
            [outputFile writeData:[@"\r"  dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [outputFile closeFile];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"Converted file saved at: %@", outputFileName]];
        [alert setInformativeText:[NSString stringWithFormat:@"Using mapping: %@", [DJLipikaUserSettings schemeName]]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
    }];
}

@end
