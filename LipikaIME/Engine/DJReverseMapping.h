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
#import "DJSchemeMapping.h"
#import "DJParseTreeNode.h"
#import "DJParseOutput.h"

@interface DJReverseTreeNode : DJParseTreeNode {
    /*
     * If output is nil then check in outputMap
     */
    NSMutableDictionary *outputMap;
    /*
     * Mapping of class name to DJReverseTreeNode
     * Fiest check in next and then nextClass
     */
    NSMutableDictionary *nextClass;
}

@property NSDictionary *outputMap;
@property NSMutableDictionary *nextClass;

-(id)init;

@end

@interface DJReverseMapping : NSObject<DJSchemeMapping> {
    DJInputMethodScheme *scheme;
    // Mapping of individual output character to a DJParseTreeNode
    DJReverseTreeNode *reverseTrieHead;
    // Class name as NSString to DJReverseTreeNode trie head
    NSMutableDictionary *classes;
    // Mapping of class name to maximum output size of that class
    NSMutableDictionary *maxOutputSizesPerClass;
    // Overall maximum output size of this scheme
    int maxOutputSize;
}

-(int)maxOutputSize;
-(DJParseOutput*)inputForOutput:(NSString*)output;

@end
