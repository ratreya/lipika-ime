/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2014 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import "DJConversionController.h"
#import "DJInputSchemeFactory.h"
#import "DJLipikaUserSettings.h"
#import "DJReverseMapping.h"
#import "DJLogger.h"

@interface DJConversionController () {
    NSArray *scripts;
    NSArray *schemes;
    NSArray *scms;
}
@end

@implementation DJConversionController

@synthesize inputFilePath;
@synthesize validInputEncodings;
@synthesize outputFilePath;
@synthesize validOutputEncodings;
@synthesize typeIndex;
@synthesize customMappings;
@synthesize isLipikaMapping;
@synthesize isCustomMapping;

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (!self) return nil;
    manager = [[DJStringBufferManager alloc] init];
    schemes = [DJInputSchemeFactory availableSchemesForType:DJ_LIPIKA];
    scripts = [DJInputSchemeFactory availableScriptsForType:DJ_LIPIKA];
    scms = [DJInputSchemeFactory availableSchemesForType:DJ_GOOGLE];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [isLipikaMapping setState:NSOnState];
    [isCustomMapping setState:NSOffState];
    [customMappings setEnabled:NO];
    [self loadLipikaSelections];
    [customMappings removeAllItems];
    if (![scms count]) {
        [isCustomMapping setEnabled:NO];
    }
    else {
        [customMappings addItemsWithObjectValues:scms];
        [customMappings selectItemWithObjectValue:scms[0]];
    }
}

-(void)loadLipikaSelections {
    if ([[typeIndex selectedCell] tag] == 0) {
        [validInputEncodings removeAllItems];
        [validInputEncodings addItemsWithObjectValues:schemes];
        [validOutputEncodings removeAllItems];
        [validOutputEncodings addItemsWithObjectValues:scripts];
        [validInputEncodings selectItemWithObjectValue: [DJLipikaUserSettings schemeName]];
        [validOutputEncodings selectItemWithObjectValue: [DJLipikaUserSettings scriptName]];
    }
    else {
        [validInputEncodings removeAllItems];
        [validInputEncodings addItemsWithObjectValues:scripts];
        [validOutputEncodings removeAllItems];
        [validOutputEncodings addItemsWithObjectValues:schemes];
        [validInputEncodings selectItemWithObjectValue: [DJLipikaUserSettings scriptName]];
        [validOutputEncodings selectItemWithObjectValue: [DJLipikaUserSettings schemeName]];
    }
}

-(IBAction)selectInputFile:(id)sender {
    // Display the input file dialog
    NSOpenPanel *inputChoice = [NSOpenPanel openPanel];
    [inputChoice setCanChooseFiles:YES];
    [inputChoice setAllowsMultipleSelection:NO];
    [inputChoice setTitle:@"Choose input file..."];
    [inputChoice setPrompt:@"Choose"];
    [NSApp activateIgnoringOtherApps:YES];
    [inputChoice makeKeyAndOrderFront:self];
    [inputChoice beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelCancelButton) {
            return;
        }
        NSURL *fileURL = [[inputChoice URLs] objectAtIndex:0];
        [inputFilePath setStringValue: [fileURL path]];
        [outputFilePath setStringValue: [[fileURL path] stringByAppendingPathExtension:@"out"]];
    }];
}

-(IBAction)changeTypeIndex:(id)sender {
    [self loadLipikaSelections];
}

-(IBAction)changeMappingType:(id)sender {
    if ([sender tag] == 0) {    // Lipika
        [isLipikaMapping setState:NSOnState];
        [isCustomMapping setState:NSOffState];
        [validInputEncodings setEnabled:YES];
        [validOutputEncodings setEnabled:YES];
        [customMappings setEnabled:NO];
    }
    else {  // Google
        [isLipikaMapping setState:NSOffState];
        [isCustomMapping setState:NSOnState];
        [validInputEncodings setEnabled:NO];
        [validOutputEncodings setEnabled:NO];
        [customMappings setEnabled:YES];
    }
}

-(IBAction)convert:(id)sender {
    [self close];
    [self performSelectorInBackground:@selector(convertFile) withObject:self];
}

-(void)convertComplete {
    NSString *outputEncoding = [validOutputEncodings stringValue];
    NSString *inputEncoding = [validInputEncodings stringValue];
    BOOL isLipika = [isLipikaMapping state] == NSOnState;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Output file saved at: %@", [outputFilePath stringValue]]];
    if (isLipika) [alert setInformativeText:[NSString stringWithFormat:@"Converted from %@ to %@", inputEncoding, outputEncoding]];
    else [alert setInformativeText:[NSString stringWithFormat:@"Converted using %@", [customMappings stringValue]]];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert runModal];
}

-(void)convertFile {
    NSString *outputEncoding = [validOutputEncodings stringValue];
    NSString *inputEncoding = [validInputEncodings stringValue];
    BOOL isReverseMapping = [[typeIndex selectedCell] tag];
    NSString *script = isReverseMapping?inputEncoding:outputEncoding;
    NSString *scheme = isReverseMapping?outputEncoding:inputEncoding;
    NSString *scm = [customMappings stringValue];
    NSString *fromPath = [inputFilePath stringValue];
    NSString *toPath = [outputFilePath stringValue];
    BOOL isLipika = [isLipikaMapping state] == NSOnState;
    DJStringBufferManager *engine = [[DJStringBufferManager alloc] init];
    if (isLipika) {
        [engine changeToSchemeWithName:scheme forScript:script type:DJ_LIPIKA];
    }
    else {
        [engine changeToSchemeWithName:scm forScript:nil type:DJ_GOOGLE];
    }
    if ([self convertFileFromPath:fromPath toPath:toPath withEngine:engine isReverseMapping:isReverseMapping])
        [self performSelectorOnMainThread:@selector(convertComplete) withObject:self waitUntilDone:NO];
}

-(BOOL)convertFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath withEngine:(DJStringBufferManager *)engine isReverseMapping:(BOOL)isReverseMapping {
    // Read file contents
    NSError *error;
    NSString *data = [NSString stringWithContentsOfFile:fromPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [[NSAlert alertWithError:error] performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
        return false;
    }
    NSArray *lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    // Open output file and convert
    if (![[NSFileManager defaultManager] createFileAtPath:toPath contents:nil attributes:nil]) {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil];
        [[NSAlert alertWithError:error] performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
        return false;
    }
    NSFileHandle *outputFile = [NSFileHandle fileHandleForWritingAtPath:toPath];
    for (NSString *line in lines) {
        NSString *result;
        if (isReverseMapping) {
            result = [self reverseMap:line withMapper:[engine reverseMappings]];
        }
        else {
            result = [engine outputForInput:line];
            NSString *remaining = [engine flush];
            if (remaining) result = [result stringByAppendingString:remaining];
        }
        [outputFile writeData:[result dataUsingEncoding:NSUTF8StringEncoding]];
        [outputFile writeData:[@"\r" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [outputFile closeFile];
    return true;
}

-(NSString *)reverseMap:(NSString *)line withMapper:(id<DJReverseMapping>)mapper {
    if ([line length] < 1) return @"";
    NSMutableString *output = [[NSMutableString alloc] init];
    int maxMapped = [mapper maxOutputSize];
    int index = (int)[line length];
    do {
        NSString *subOutput = [line substringWithRange:NSMakeRange(MAX(index - maxMapped, 0), MIN(maxMapped, index))];
        DJParseOutput *result = [mapper inputForOutput:subOutput];
        if (result) {
            if ([result input]) [output insertString:[result input] atIndex:0];
            index -= [[result output] length];
        }
        else {
            [output insertString:[subOutput substringFromIndex:[subOutput length] - 1] atIndex:0];
            --index;
        }
    } while (index > 0);
    return output;
}

-(IBAction)cancel:(id)sender {
    [self close];
}

@end
