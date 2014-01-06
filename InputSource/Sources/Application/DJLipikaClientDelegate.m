/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLipikaClientDelegate.h"
#import "DJLogger.h"

enum {NS32BitNotFound = 0x7fffffff};

@implementation DJLipikaClientDelegate

-(id)initWithClient:(id<IMKTextInput>)theClient {
    self = [super init];
    if (!self) return self;
    client = theClient;
    isDocumentAccessSupported = [client supportsProperty:kTSMDocumentSupportDocumentAccessPropertyTag];
    // Assume client is 64-bit but try to determine if 32-bit
    is32BitApplication = NO;
    NSRunningApplication *clientProcess;
    NSArray *potentialClients = [NSRunningApplication runningApplicationsWithBundleIdentifier:[client bundleIdentifier]];
    if (potentialClients.count >= 1) {
        // Assuming all processes from the bundle will be of the same architecture
        clientProcess = potentialClients[0];
        if ([clientProcess executableArchitecture] == NSBundleExecutableArchitectureI386 || [clientProcess executableArchitecture] == NSBundleExecutableArchitecturePPC) {
            is32BitApplication = YES;
        }
    }
    logDebug(@"Initiating session with client: %@; is32BitApplication: %@; isDocumentAccessSupported: %@", [clientProcess bundleIdentifier], is32BitApplication?@"YES":@"NO", isDocumentAccessSupported?@"YES":@"NO");
    return self;
}

-(BOOL)isDocumentAccessSupported {
    return isDocumentAccessSupported;
}

-(NSDictionary *)textAttributesAtCurrentPosition {
    NSRect rect = NSMakeRect(0, 0, 0, 0);
    return [client attributesForCharacterIndex:0 lineHeightRectangle:&rect];
}

-(void)insertTextAtCurrentPosition:(NSString *)text {
    NSRange replacementRange = [self currentPositionRange];
    [client insertText:text replacementRange:replacementRange];
}

-(void)replaceTextAtCurrentSelection:(NSString *)text {
    [client insertText:text replacementRange:[client selectedRange]];
}

-(void)setMarkedText:(NSAttributedString *)text withReplacementOffset:(int)offset {
    NSRange replacementRange = [client selectedRange];
    replacementRange.location -= offset;
    replacementRange.length += offset;
    [client setMarkedText:text selectionRange:NSMakeRange(text.length, 0) replacementRange:replacementRange];
}

-(void)clearMarkedText {
    [client setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:[self currentPositionRange]];
}

-(NSString *)previousTextOfLength:(unsigned long)length withOffset:(int)offset {
    NSString *previousText = nil;
    NSRange currentPosition = [client selectedRange];
    currentPosition.location -= offset;
    if (currentPosition.location > 0) {
        unsigned long delta = MIN(currentPosition.location, length);
        previousText = [[client attributedSubstringFromRange:NSMakeRange(currentPosition.location - delta, delta)] string];
    }
    return previousText;
}

-(NSRange)selectedRange {
    NSRange range = [client selectedRange];
    if (is32BitApplication) {
        if (range.location == NS32BitNotFound) range.location = NSNotFound;
        if (range.length == NS32BitNotFound) range.length = NSNotFound;
    }
    return range;
}

-(NSRange)currentPositionRange {
    NSRange notFoundRange;
    if (is32BitApplication) {
        notFoundRange = NSMakeRange(NS32BitNotFound, NS32BitNotFound);
    }
    else {
        notFoundRange = NSMakeRange(NSNotFound, NSNotFound);
    }
    return notFoundRange;
}

@end
