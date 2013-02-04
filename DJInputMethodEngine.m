#import "DJInputMethodEngine.h"
#include <AppKit/AppKit.h>

@implementation DJInputMethodEngine

@synthesize scheme;

-(id)initWithScheme:(DJInputMethodScheme*)inputScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    scheme = inputScheme;
    currentNode = nil;
    return self;
}

-(DJParseOutput *)executeWithInput:(NSString*)input {
    DJParseOutput* output = [self executeInternalForInput:input];
    if (output == nil || [output isFinal] || [output isPreviousFinal]) {
        currentOutput = nil;
    }
    if (output == nil) {
        // Invalid input sequence beep
        NSBeep();
    }
    return output;
}

-(DJParseOutput *)executeInternalForInput:(NSString*)input {
    if ([input length] != 1) {
        [NSException raise:@"Number of characters in input not one" format:@"Expected one but input had %ld characters", [input length]];
    }
    DJParseOutput* result = [DJParseOutput alloc];
    if (currentNode == nil) {
        // Look for mapping at root of tree
        currentNode = [self getOutputForInput:input tree:[scheme parseTree]];
        // We don't have a mapping for the input
        if (currentNode == nil) {
            return nil;
        }
    }
    else {
        // Look for mapping at current level of the tree
        DJParseTreeNode* nextNode = [self getOutputForInput:input tree:[currentNode next]];
        if (nextNode == nil) {
            // Everything until now is good; we are resetting to root of tree
            result.isPreviousFinal = YES;
            // Search at root of tree
            nextNode = [self getOutputForInput:input tree:[scheme parseTree]];
            // We don't have a mapping for the input
            if (nextNode == nil) {
                return nil;
            }
            else {
                currentNode = nextNode;
            }
        }
        else {
            currentNode = nextNode;
        }
    }
    result.output = currentNode.output;
    // If there cannot be another modification
    if (currentNode.next == nil) {
        result.isFinal = YES;
        currentNode = nil;
    }
    return result;
}

-(DJParseTreeNode*)getOutputForInput:(NSString*)input tree:(NSMutableDictionary*)map {
    // First check if input in a regular mapping
    DJParseTreeNode* nextNode = [map valueForKey:input];
    if (nextNode != nil) {
        if (currentOutput == nil) {
            return nextNode;
        }
        else {
            DJParseTreeNode* output = [DJParseTreeNode alloc];
            if ([nextNode output] != nil) {
                output.output = [NSString stringWithFormat:currentOutput, [nextNode output]];
            }
            output.next = nextNode.next;
            return output;
        }
    }
    // Check if input is a class mapping
    NSString* className = [scheme getClassNameForInput:input];
    if (className != nil) {
        // See if a class name mapping exists
        nextNode = [map valueForKey:className];
        if (nextNode != nil) {
            if (currentOutput == nil) {
                // We have to store [nextNode output] until we have a final output from the class mappings
                currentOutput = [nextNode output];
            }
            else {
                // If already exists then replace the previoud wildcard with the new wildcard expression
                currentOutput = [NSString stringWithFormat:currentOutput, [nextNode output]];
            }
            // Get the wildcard replacement
            NSMutableDictionary* classTree = [scheme getClassForName:className];
            return [self getOutputForInput:input tree:classTree];
        }
    }
    return nil;
}

@end
