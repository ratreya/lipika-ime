#import "DJInputMethodEngine.h"
#include <AppKit/AppKit.h>

@implementation DJInputMethodEngine

@synthesize scheme;

static NSRegularExpression* whiteSpace;

-(id)initWithScheme:(DJInputMethodScheme*)inputScheme {
    self = [super init];
    if (self == nil) {
        return self;
    }
    NSError* error;
    whiteSpace = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid whitespace regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    scheme = inputScheme;
    currentNode = nil;
    return self;
}

-(DJParseOutput *)executeWithInput:(NSString*)input {
    if ([input length] != 1) {
        [NSException raise:@"Number of characters in input not one" format:@"Expected one but input had %ld characters", [input length]];
    }
    DJParseOutput* result = [DJParseOutput alloc];
    if ([input isEqualToString:[scheme stopChar]] || [whiteSpace numberOfMatchesInString:input options:0 range:NSMakeRange(0, [input length])]) {
        currentNode = nil;
        result.output = input;
        result.isPreviousFinal = YES;
        result.isFinal = YES;
        return result;
    }
    if (currentNode == nil) {
        // Look for mapping at root of tree
        currentNode = [[scheme parseTree] valueForKey:input];
        // We don't have a mapping for the input
        if (currentNode == nil) {
            return nil;
        }
    }
    else {
        // Look for mapping at current level of the tree
        DJParseTreeNode* nextNode = [[currentNode next] valueForKey:input];
        if (nextNode == nil) {
            // Everything until now is good; we are resetting to root of tree
            result.isPreviousFinal = YES;
            // Search at root of tree
            nextNode = [[scheme parseTree] valueForKey:input];
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

@end
