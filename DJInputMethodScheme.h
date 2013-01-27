#import <Foundation/Foundation.h>

@interface DJInputMethodScheme : NSObject {
@private
    NSString* schemeFileName;
    NSMutableDictionary* parseTree;
}

@property (retain) NSMutableDictionary* parseTree;

-(void)initWithSchemeFile:(NSString*) filePath;

@end
