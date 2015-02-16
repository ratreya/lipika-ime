/*
 * LipikaIME a user+configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <time.h>
#import "DJLogger.h"
#import "DJLipikaUserSettings.h"

void logGenericBatch(enum DJLogLevel level, NSString *format, va_list variables) {
    // Don't log anything if the current level does not allow it
    enum DJLogLevel currentLevel = [DJLipikaUserSettings loggingLevel];
    if (currentLevel > level) {
        return;
    }
    // Create the formatted log statement
    NSString *severity = [DJLipikaUserSettings logLevelStringForEnum:level];
    NSString *log = [NSString stringWithFormat:@"%@: %@", severity, [[NSString alloc] initWithFormat:format arguments:variables]];
    NSLog(@"%@", log);
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
