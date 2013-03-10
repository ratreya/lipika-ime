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

@interface DJParseOutput : NSObject {
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

@property NSString* output;
@property BOOL isFinal;
@property BOOL isPreviousFinal;

@end
