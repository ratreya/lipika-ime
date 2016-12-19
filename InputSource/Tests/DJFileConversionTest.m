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
#import "DJLipikaSchemeFactory.h"
#import "DJGoogleSchemeFactory.h"

@interface DJLipikaSchemeFactory (Test)
+(void)setSchemesDirectory:(NSString *)directory;
@end

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

-(void)setUp {
    [super setUp];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Schemes"];
    [DJLipikaSchemeFactory setSchemesDirectory:filePath];
}

- (void)testLipikaForwardConversion {
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans.out";
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] init];
    [engine changeToSchemeWithName:@"ITRANS" forScript:@"Devanagari" type:DJ_LIPIKA];
    DJConversionController *controller = [[DJConversionController alloc] init];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Control/DhatupaaTaSvara.itrans"];
    [controller convertFileFromPath:filePath toPath:outputFile withEngine:engine isReverseMapping:NO];
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
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Control/DhatupaaTaSvara.txt"];
    [controller convertFileFromPath:filePath toPath:outputFile withEngine:engine isReverseMapping:YES];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"||atha' paaNiniiyadhaatupaa_ThaH||");
}

-(void)testGoogleForwardConversion {
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"CustomSchemes/SA_ITRANS.scm"];
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans.out";
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJConversionController *controller = [[DJConversionController alloc] init];
    filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Control/DhatupaaTaSvara.itrans"];
    [controller convertFileFromPath:filePath toPath:outputFile withEngine:engine isReverseMapping:NO];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"॥अथ॑ पाणिनीयधातुपा॒ठः॥");
}

-(void)testGoogleReverseConversion {
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"CustomSchemes/SA_ITRANS.scm"];
    NSString *outputFile = @"/tmp/DhatupaaTaSvara.itrans";
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJConversionController *controller = [[DJConversionController alloc] init];
    filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Control/DhatupaaTaSvara.txt"];
    [controller convertFileFromPath:filePath toPath:outputFile withEngine:engine isReverseMapping:YES];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outputFile isDirectory:NO]);
    NSString *contents = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\r"];
    XCTAssertEqual(lines.count, 2427);
    XCTAssertEqualObjects(lines[0], @"||atha\\' paaNiniiyadhaatupaa\\_ThaH||");
}

-(void)testReverseMappingOverrite {
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"CustomSchemes/SA_ITRANS.scm"];
    DJGoogleInputScheme *scheme = [DJGoogleSchemeFactory inputSchemeForSchemeFile:filePath];
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] initWithEngine:[[DJInputMethodEngine alloc] initWithScheme:scheme]];
    DJSimpleReverseMapping *mappings = [engine reverseMappings];
    DJParseOutput *output = [mappings inputForOutput:@"हर्षे"];
    XCTAssertEqualObjects(output.input, @"She");
}

@end
