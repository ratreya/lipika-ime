/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2014 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <XCTest/XCTest.h>
#import "DJConversionController.h"

@interface DJConversionController (test)
-(void)convertFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath withEngine:(DJStringBufferManager *)engine isReverseMapping:(BOOL)isReverseMapping;
@end

@interface DJFileConversionTest : XCTestCase

@end

@implementation DJFileConversionTest

- (void)testForwardConversion {
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans.out";
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] init];
    [engine changeToSchemeWithName:@"ITRANS" forScript:@"Devanagari" type:DJ_LIPIKA];
    DJConversionController *controller = [[DJConversionController alloc] init];
    [controller convertFileFromPath:@"./InputSource/Tests/Control/DhatupaaTaSvara.itrans" toPath:outputFile withEngine:engine isReverseMapping:NO];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"॥अथ॑ पाणिनीयधातुपा`ठः॥");
}

-(void)testReverseConversion {
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans";
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] init];
    [engine changeToSchemeWithName:@"ITRANS" forScript:@"Devanagari" type:DJ_LIPIKA];
    DJConversionController *controller = [[DJConversionController alloc] init];
    [controller convertFileFromPath:@"./InputSource/Tests/Control/DhatupaaTaSvara.txt" toPath:outputFile withEngine:engine isReverseMapping:YES];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"||atha' paaNiniiyadhaatupaa_ThaH||");
}

@end
