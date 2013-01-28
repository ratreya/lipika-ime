#import <Foundation/Foundation.h>

@interface DJParseTreeNode : NSObject {
@private
    NSString* output;
    NSMutableDictionary* next;
}

@property NSString* output;
/*
 * key is either a NSString with the next character or NSString of the class name.
 * If next character is not found then check if its class exists.
 */
@property NSMutableDictionary* next;

@end
