#import "DJParseTreeNode.h"

@implementation DJParseTreeNode

@synthesize output;
@synthesize next;

-(NSString*)description {
    return [NSString stringWithFormat:@"Output: %@; Next: %@", output, [next description]];
}

@end
