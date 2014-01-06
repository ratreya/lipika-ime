/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJLogger.h"
#import "DJLipikaUserSettings.h"

// Dictionary of batchId to NSArray of messages
static NSMutableDictionary *messageMap = nil;
static NSString *currentBatchId = nil;

void logGenericBatch(enum DJLogLevel level, NSString *format, va_list variables) {
    // Don't log anything if the current level does not allow it
    enum DJLogLevel currentLevel = [DJLipikaUserSettings loggingLevel];
    if (currentLevel > level) {
        return;
    }
    // Create the formatted log statement
    NSString *severity = [DJLipikaUserSettings logLevelStringForEnum:level];
    NSString *log = [NSString stringWithFormat:@"%@: %@", severity, [[NSString alloc] initWithFormat:format arguments:variables]];

    // Local variabel to avoid concurrent modification
    NSString *batchId = currentBatchId;
    if (batchId) {
        // Allocate messageMap once
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            messageMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        });

        NSMutableArray *messages = [messageMap objectForKey:batchId];
        if (!messages) {
            messages = [[NSMutableArray alloc] initWithCapacity:1];
        }
        [messages addObject:log];
        // Flush messages if batch is leaked
        if (messages.count > 1000) {
            NSLog(@"%@", [messages componentsJoinedByString:@"\n"]);
            messages = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [messageMap setObject:messages forKey:batchId];
    }
    else {
        NSLog(@"%@", log);
    }
}

void logDebug(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    logGenericBatch(DJ_DEBUG, format, args);
    va_end(args);
}

void logWarning(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    logGenericBatch(DJ_WARNING, format, args);
    va_end(args);
}

void logError(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    logGenericBatch(DJ_ERROR, format, args);
    va_end(args);
}

void logFatal(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    logGenericBatch(DJ_FATAL, format, args);
    va_end(args);
}

NSString *startBatch() {
    currentBatchId = getUUIDString();
    return currentBatchId;
}

NSArray *endBatch(NSString *batchId) {
    if (!messageMap || ![messageMap objectForKey:batchId]) return nil;
    currentBatchId = nil;
    NSArray *messages = [messageMap objectForKey:batchId];
    [messageMap removeObjectForKey:batchId];
    NSLog(@"%@", [messages componentsJoinedByString:@"\n"]);
    return messages;
}

NSString *getUUIDString() {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)(string);
}
