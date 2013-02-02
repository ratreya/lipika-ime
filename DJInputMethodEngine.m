#import "DJInputMethodEngine.h"

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
        currentNode = [self getOutputForInput:input tree:[currentNode next]];
        if (currentNode == nil) {
            // Everything until now is good; we are resetting to root of tree
            result.isPreviousFinal = YES;
            // Search at root of tree
            currentNode = [self getOutputForInput:input tree:[scheme parseTree]];
            // We don't have a mapping for the input
            if (currentNode == nil) {
                return nil;
            }
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
    if ([map valueForKey:input] != nil) {
        return [map valueForKey:input];
    }
    // Check if input is a class mapping
    NSString* className = [scheme getClassNameForInput:input];
    if (className != nil) {
        // See if a class name mapping exists
        DJParseTreeNode* classNode = [map valueForKey:className];
        if (classNode != nil) {
            // Get the wildcard replacement
            NSMutableDictionary* classTree = [scheme getClassForName:className];
            DJParseTreeNode* replacement = [self getOutputForInput:input tree:classTree];
            DJParseTreeNode* output = [DJParseTreeNode alloc];
            output.output = [NSString stringWithFormat:[classNode output], replacement];
            output.next = classNode.next;
        }
    }
    return nil;
}

@end
