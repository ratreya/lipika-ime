/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJGoogleForwardMapping.h"
#import "DJGoogleInputScheme.h"
#import "DJParseTreeNode.h"
#import "DJLogger.h"

@implementation DJGoogleForwardMapping

-(id)initWithScheme:(DJGoogleInputScheme*)parentScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = parentScheme;
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

-(void)createClassWithName:(NSString *)className {
    NSMutableDictionary *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        currentClass = [NSMutableDictionary dictionaryWithCapacity:0];
        [classes setObject:currentClass forKey:className];
    }
    else {
        [NSException raise:@"Class redefined" format:@"Redefining existing class with name: %@", className];
    }
}

-(void)createSimpleMappingForClass:(NSString *)className key:(NSString *)key value:(NSString *)value {
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    newNode.output = value;
    NSMutableDictionary *currentClass;
    if (!(currentClass = [classes objectForKey:className])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    [self addMappingForTree:currentClass key:key newNode:newNode];
}

-(void)createClassMappingWithPreKey:(NSString *)preKey className:(NSString *)className isWildcard:(BOOL)isWildcard preValue:(NSString *)preValue postValue:(NSString *)postValue {
    [self createClassMappingForTree:parseTree preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
}

-(void)createClassMappingForClass:(NSString *)containerClass preKey:(NSString *)preKey className:(NSString *)className isWildcard:(BOOL)isWildcard preValue:(NSString *)preValue postValue:(NSString *)postValue {
    NSMutableDictionary *currentClass;
    if (!(currentClass = [classes objectForKey:containerClass])) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", containerClass];
    }
    [self createClassMappingForTree:currentClass preKey:preKey className:className isWildcard:isWildcard preValue:preValue postValue:postValue];
}

-(void)createClassMappingForTree:(NSMutableDictionary*)tree preKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue {
    NSMutableDictionary* classTree = [classes valueForKey:className];
    if (classTree == nil) {
        [NSException raise:@"Unknown class" format:@"Unknown class name: %@", className];
    }
    // Parse the value; may not have wildcards in it
    DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
    if (isWildcard) {
        // Output is nil and format is applied to all outputs of its subtree
        NSString* format = [NSString stringWithFormat:@"%@%%@%@", preValue, postValue];
        // Set the formated output tree as this node's subtree
        newNode.next = [self applyFormat:format toTree:classTree];
    }
    else {
        newNode.output = preValue;
        // Append the named parse tree as-is since there is no wildcard formatting
        newNode.next = classTree;
    }
    [self addMappingForTree:tree key:preKey newNode:newNode];
}

-(NSMutableDictionary*)applyFormat:(NSString*)format toTree:(NSMutableDictionary*)classTree {
    NSMutableDictionary* newTree = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (NSString* key in [classTree keyEnumerator]) {
        DJParseTreeNode* node = [classTree valueForKey:key];
        if (node != nil) {
            DJParseTreeNode* newNode = [[DJParseTreeNode alloc] init];
            if (node.output != nil) {
                newNode.output = [NSString stringWithFormat:format, node.output];
            }
            if (node.next != nil) {
                newNode.next = [self applyFormat:format toTree:node.next];
            }
            [newTree setValue:newNode forKey:key];
        }
    }
    return newTree;
}

-(NSString *)classNameForInput:(NSString*)input {
    for (NSString* className in [classes keyEnumerator]) {
        NSMutableDictionary* classMap = [classes valueForKey:className];
        if ([classMap objectForKey:input] != nil) {
            return className;
        }
    }
    return nil;
}

-(NSDictionary *)classForName:(NSString *)className {
    return [classes valueForKey:className];
}

@end
