#import <Foundation/Foundation.h>

@interface DJInputMethodScheme : NSObject {
@private
    NSString* schemeFilePath;
    // Input as NSString to DJParseTreeNode
    NSMutableDictionary* parseTree;
    // Class name as NSString to NSMutableDictionary of NSString to DJParseTreeNode
    NSMutableDictionary* classes;
    NSString* name;
    NSString* version;
    BOOL usingClasses;
    NSString* classOpenDelimiter;
    NSString* classCloseDelimiter;
    NSString* wildcard;
    NSString* stopChar;
}

@property NSMutableDictionary* parseTree;
@property NSString* name;
@property NSString* version;
@property BOOL usingClasses;
@property NSString* classOpenDelimiter;
@property NSString* classCloseDelimiter;
@property NSString* wildcard;
@property NSString* stopChar;

-(id)initWithSchemeFile:(NSString*)filePath;
-(NSString*)getClassNameForInput:(NSString*)input;
-(NSMutableDictionary*)getClassForName:(NSString*)className;

@end
