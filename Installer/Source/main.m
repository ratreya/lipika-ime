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

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *currentUser = @"~/Library/Input Methods/LipikaIME.app";
        NSString *allUsers = @"/Library/Input Methods/LipikaIME.app";
        NSString *bundleId = @"com.daivajnanam.inputmethod.LipikaIME";
        
        NSString *path;
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentUser isDirectory:&isDirectory]) {
            path = currentUser;
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:allUsers isDirectory:&isDirectory]) {
            path = allUsers;
        }
        else {
            NSLog(@"Unable to find LipikaIME at %@ or %@", currentUser, allUsers);
            return -1;
        }
        NSURL *location = [[NSURL alloc] initFileURLWithPath:path isDirectory:isDirectory];
        OSStatus status = TISRegisterInputSource((__bridge CFURLRef)(location));
        if (status == paramErr) {
            NSLog(@"Unable to register input source at %@", location);
            return -1;
        }
        NSDictionary *properties = [NSDictionary dictionaryWithObject:bundleId forKey:(NSString*)kTISPropertyBundleID];
        NSArray *inputlist = (__bridge NSArray *)(TISCreateInputSourceList((__bridge CFDictionaryRef)(properties), YES));
        if (inputlist.count != 1) {
            NSLog(@"Expected 1 but found %ld input source(s) with bundle id: %@", inputlist.count, bundleId);
            return -1;
        }
        status = TISEnableInputSource((__bridge TISInputSourceRef)(inputlist[0]));
        if (status == paramErr) {
            NSLog(@"Failed to enable input source reference: %@", inputlist[0]);
            return -1;
        }
        status = TISSelectInputSource((__bridge TISInputSourceRef)(inputlist[0]));
        if (status == paramErr) {
            NSLog(@"Failed to select input source reference: %@", inputlist[0]);
            return -1;
        }
    }
    return 0;
}
