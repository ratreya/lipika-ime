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
