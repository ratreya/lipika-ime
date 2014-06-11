/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *path = @"/Library/Input Methods/LipikaIME.app";
        NSString *bundleId = @"com.daivajnanam.inputmethod.LipikaIME";
        
        // Process command line arguments
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        // Defaults
        BOOL remove = NO;
        BOOL enable = NO;
        BOOL select = NO;
        if ([arguments count] != 1) {
            if ([arguments[1] isEqualToString:@"--remove"]) remove = YES;
            else if ([arguments[1] isEqualToString:@"--enable"]) enable = YES;
            else if ([arguments[1] isEqualToString:@"--select"]) select = YES;
            else {
                printf("[ERROR] Unrecognized argument: %s\n", [arguments[1] UTF8String]);
                return -1;
            }
        }
        else {
            printf("[ERROR] You should specify one of --remove or --enable or --select\n");
            return -1;
        }

        OSStatus status;
        if (enable) {
            BOOL isDirectory;
            NSURL *location = [[NSURL alloc] initFileURLWithPath:path isDirectory:isDirectory];
            status = TISRegisterInputSource((__bridge CFURLRef)(location));
            if (status == paramErr) {
                printf("[ERROR] Unable to register input source at %s\n", [path UTF8String]);
                return -1;
            }
        }
        NSDictionary *properties = [NSDictionary dictionaryWithObject:bundleId forKey:(NSString *)kTISPropertyBundleID];
        NSArray *inputlist = (__bridge NSArray *)(TISCreateInputSourceList((__bridge CFDictionaryRef)(properties), YES));
        if (inputlist.count != 1) {
            if (remove) return 0;   // Nothing more to do
            printf("[ERROR] Expected 1 but found %ld input source(s) with bundle id: %s\n", inputlist.count, [bundleId UTF8String]);
            return -1;
        }
        if (remove) {
            status = TISDisableInputSource((__bridge TISInputSourceRef)(inputlist[0]));
            if (status == paramErr) {
                printf("[ERROR] Failed to disable input source reference: %s\n", [inputlist[0] UTF8String]);
                return -1;
            }
        }
        if (enable) {
            status = TISEnableInputSource((__bridge TISInputSourceRef)(inputlist[0]));
            if (status == paramErr) {
                printf("[ERROR] Failed to enable input source reference: %s\n", [inputlist[0] UTF8String]);
                return -1;
            }
        }
        if (select) {
            status = TISSelectInputSource((__bridge TISInputSourceRef)(inputlist[0]));
            if (status == paramErr) {
                printf("[ERROR] Failed to select input source reference: %s\n", [inputlist[0] UTF8String]);
                return -1;
            }
        }
    }
    return 0;
}
