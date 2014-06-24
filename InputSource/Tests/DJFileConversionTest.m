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
#import "DJGoogleSchemeFactory.h"

@interface DJConversionController (test)
-(void)convertFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath withEngine:(DJStringBufferManager *)engine isReverseMapping:(BOOL)isReverseMapping;
@end

@interface DJStringBufferManager (test)
-(id)initWithEngine:(DJInputMethodEngine *)myEngine;
@end

@interface DJInputMethodEngine (test)
-(id)initWithScheme:(id<DJInputMethodScheme>)inputScheme;
@end

@interface DJFileConversionTest : XCTestCase

@end

@implementation DJFileConversionTest

- (void)testLipikaForwardConversion {
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

-(void)testLipikaReverseConversion {
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

-(void)testGoogleForwardConversion {
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans.out";
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./InputSource/Tests/Schemes/SA_ITRANS.scm"];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJConversionController *controller = [[DJConversionController alloc] init];
    [controller convertFileFromPath:@"./InputSource/Tests/Control/DhatupaaTaSvara.itrans" toPath:outputFile withEngine:engine isReverseMapping:NO];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"॥अथ॑ पाणिनीयधातुपा॒ठः॥");
}

-(void)testGoogleReverseConversion {
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans";
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./InputSource/Tests/Schemes/SA_ITRANS.scm"];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJConversionController *controller = [[DJConversionController alloc] init];
    [controller convertFileFromPath:@"./InputSource/Tests/Control/DhatupaaTaSvara.txt" toPath:outputFile withEngine:engine isReverseMapping:YES];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"||atha\\' paaNiniiyadhaatupaa\\_ThaH||");
}

-(void)testReverseMappingOverrite {
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:@"./InputSource/Tests/Schemes/SA_ITRANS.scm"];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJSimpleReverseMapping *mappings = [engine reverseMappings];
    DJParseOutput *output = [mappings inputForOutput:@"हर्षे"];
    XCTAssertEqualObjects(output.input, @"She");
}

@end
