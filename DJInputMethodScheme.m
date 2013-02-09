#import "DJInputMethodScheme.h"
#import "DJParseTreeNode.h"

@implementation DJInputMethodScheme

@synthesize parseTree;
@synthesize name;
@synthesize version;
@synthesize wildcard;
@synthesize stopChar;
@synthesize usingClasses;
@synthesize classOpenDelimiter;
@synthesize classCloseDelimiter;

NSString *const VERSION = @"version";
NSString *const NAME = @"name";
NSString *const STOP_CHAR = @"stop-char";
NSString *const CLASS_DELIMITERS = @"class-delimiters";
NSString *const WILDCARD = @"wildcard";

-(id)initWithSchemeFile:(NSString*)filePath {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    parseTree = [NSMutableDictionary dictionaryWithCapacity:0];
    classes = [NSMutableDictionary dictionaryWithCapacity:0];
    currentLineNumber = 0;
    isProcessingClassDefinition = NO;

    // Set default values
    wildcard = @"*";
    stopChar = @"\\";
    usingClasses = YES;
    classOpenDelimiter = @"{";
    classCloseDelimiter = @"}";

    // Read contents of the Scheme file
    NSLog(@"Parsing scheme file: %@", filePath);
    schemeFilePath = filePath;
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:schemeFilePath];
    if (handle == nil) {
        NSLog(@"Failed to open file %@ for reading", schemeFilePath);
        return nil;
    }
    NSData* dataBuffer = [handle readDataToEndOfFile];
    NSString* data = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
    linesOfScheme = [data componentsSeparatedByString:@"\n"];

    @try {
        [self parseHeaders];
    }
    @catch (NSException* exception) {
        NSLog(@"Error parsing scheme file: %@; %@", filePath, [exception reason]);
        return nil;
    }
    @try {
        [self parseMappings];
    }
    @catch (NSException* exception) {
        NSLog(@"Error parsing scheme file: %@; %@", filePath, [exception reason]);
        return nil;
    }
    
    if (isProcessingClassDefinition) {
        NSLog(@"Error parsing scheme file: %@; One or more class(es) not closed", filePath);
    }

    return self;
}

-(void)parseHeaders {
    // Regular expressions for matching header items
    NSError* error;
    NSString *const headerPattern = @"^\\s*(.*\\S)\\s*:\\s*(.*\\S)\\s*$";
    NSRegularExpression* headerExpression = [NSRegularExpression regularExpressionWithPattern:headerPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid header regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    NSString *const usingClassesPattern = @"^\\s*using\\s+classes\\s*$";
    NSRegularExpression* usingClassesExpression = [NSRegularExpression regularExpressionWithPattern:usingClassesPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid using classes regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    NSString *const classesDelimiterPattern = @"^\\s*(\\S)\\s*(\\S)\\s*$";
    NSRegularExpression* classesDelimiterExpression = [NSRegularExpression regularExpressionWithPattern:classesDelimiterPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid classes delimiter expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }

    // Parse out the headers
    for (NSString* line in linesOfScheme) {
        // For empty lines move on
        if ([line length] <=0 ) {
            currentLineNumber++;
            continue;
        }
        NSLog(@"Parsing line: %@", line);
        if ([headerExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            NSString* key = [headerExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
            NSString* value = [headerExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
            NSLog(@"Parsed header. Key: %@; Value: %@", key, value);
            if ([key isEqualToString:VERSION]) {
                version = value;
            }
            else if ([key isEqualToString:NAME]) {
                name = value;
            }
            else if ([key isEqualToString:STOP_CHAR]) {
                stopChar = value;
            }
            else if ([key isEqualToString:WILDCARD]) {
                wildcard = value;
            }
            else if ([key isEqualToString:CLASS_DELIMITERS]) {
                if (![classesDelimiterExpression numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])]) {
                    [NSException raise:@"Invalid class delimiter value" format:@"Invalid value: %@ at line %d", value, currentLineNumber + 1];
                }
                classOpenDelimiter = [classesDelimiterExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$1"];
                classCloseDelimiter = [classesDelimiterExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$2"];
            }
            else {
                [NSException raise:@"Invalid key" format:@"Invalid key: %@ at line %d", key, currentLineNumber + 1];
            }
        }
        else if ([usingClassesExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            NSLog(@"Parsed using classes");
            usingClasses = YES;
        }
        else {
            NSLog(@"Done parsing headers");
            break;
        }
        currentLineNumber++;
    }
    NSLog(@"Headers end at: %d", currentLineNumber + 1);
}

-(void)parseMappings {
    // Regular expressions for matching mapping items
    NSError* error;
    NSString *const simpleMappingPattern = @"^\\s*(\\S+)\\s+(\\S+)\\s*$";
    NSRegularExpression* simpleMappingExpression = [NSRegularExpression regularExpressionWithPattern:simpleMappingPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid simple mapping expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }
    NSString *const classDefinitionPattern = [NSString stringWithFormat:@"^\\s*class\\s+(\\S+)\\s+\\%@\\s*$", classOpenDelimiter];
    NSRegularExpression* classDefinitionExpression = [NSRegularExpression regularExpressionWithPattern:classDefinitionPattern options:0 error:&error];
    if (error != nil) {
        [NSException raise:@"Invalid class definition expression" format:@"Regular expression error: %@", [error localizedDescription]];
    }

    for (; currentLineNumber<[linesOfScheme count]; currentLineNumber++) {
        NSString* line = linesOfScheme[currentLineNumber];
        // For empty lines move on
        if ([line length] <=0 ) continue;
        NSLog(@"Parsing line: %@", line);
        if ([simpleMappingExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            NSLog(@"Found mapping expression");
            NSString* key = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
            NSString* value = [simpleMappingExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$2"];
            if (isProcessingClassDefinition) {
                NSLog(@"Adding to class: %@", currentClassName);
                [self parseMappingForTree:currentClass key:key value:value];
            }
            else {
                NSLog(@"Adding to main parse tree");
                [self parseMappingForTree:parseTree key:key value:value];
            }
        }
        else if ([classDefinitionExpression numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])]) {
            NSLog(@"Found beginning of class definition");
            isProcessingClassDefinition = YES;
            currentClassName = [classDefinitionExpression stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"$1"];
            currentClass = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSLog(@"Class name: %@", currentClassName);
        }
        else if ([line isEqualToString:classCloseDelimiter]) {
            NSLog(@"Found end of class definition");
            isProcessingClassDefinition = NO;
            [classes setValue:currentClass forKey:currentClassName];
        }
        else {
            [NSException raise:@"Invalid line" format:@"Invalid line %d", currentLineNumber+1];
        }
    }
}

NSRegularExpression* classKeyExpression;
NSRegularExpression* wildcardValueExpression;

-(void)parseMappingForTree:(NSMutableDictionary*)tree key:(NSString*)key value:(NSString*)value {
    NSError* error;
    if (classKeyExpression == nil) {
        /*
         * We only support one class per mapping
         */
        NSString *const classKeyPattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S+)\\%@(\\S*)\\s*$", classOpenDelimiter, classCloseDelimiter];
        classKeyExpression = [NSRegularExpression regularExpressionWithPattern:classKeyPattern options:0 error:&error];
        if (error != nil) {
            [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
        }
    }
    if (wildcardValueExpression == nil) {
        /*
         * And hence only one wildcard value
         */
        NSString *const wildcardValuePattern = [NSString stringWithFormat:@"^\\s*(\\S*)\\%@(\\S*)\\s*$", wildcard];
        wildcardValueExpression = [NSRegularExpression regularExpressionWithPattern:wildcardValuePattern options:0 error:&error];
        if (error != nil) {
            [NSException raise:@"Invalid class key regular expression" format:@"Regular expression error: %@", [error localizedDescription]];
        }
    }
    // Holds the list of inputs
    NSMutableArray* path;
    // Output with format elemets
    NSString* output;
    if ([classKeyExpression numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])]) {
        NSLog(@"Found class mapping");
        // Parse the key
        NSString* preClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$1"];
        NSString* className = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$2"];
        NSString* postClass = [classKeyExpression stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@"$3"];
        NSLog(@"Parsed key with pre-class: %@; class: %@", preClass, className);
        if ([postClass length]) {
            [NSException raise:@"Class mapping not suffix" format:@"Class mapping: %@ has invalid suffix: %@ at line: %d", className, postClass, currentLineNumber];
        }
        if ([classes valueForKey:className] == nil) {
            [NSException raise:@"Unknown class" format:@"Unknown class name: %@ at line: %d", className, currentLineNumber];
        }
        // Create path from key
        path = [self getPathForKey:preClass];
        [path addObject:className];
        // Parse the value; may not have wildcards in it
        if ([wildcardValueExpression numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])]) {
            NSString* preWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$1"];
            NSString* postWildcard = [wildcardValueExpression stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@"$2"];
            NSLog(@"Parsed value with pre-wildcard: %@; post-wildcard: %@", preWildcard, postWildcard);
            output = [NSString stringWithFormat:@"%@%%@%@", preWildcard, postWildcard];
        }
        else {
            output = value;
        }
    }
    else {
        NSLog(@"Found key: %@; value: %@", key, value);
        path = [self getPathForKey:key];
        output = value;
    }
    // Merge path into the parseTree and set the output
    NSMutableDictionary* currentNode = tree;
    for (int i = 0; i < [path count]; i++) {
        NSString* input = path[i];
        BOOL isLast = (i == [path count] - 1);
        DJParseTreeNode* node = [currentNode valueForKey:input];
        if (node == nil) {
            node = [DJParseTreeNode alloc];
            if (!isLast) {
                node.next = [[NSMutableDictionary alloc] initWithCapacity:1];
            }
            [currentNode setValue:node forKey:input];
        }
        if (isLast) {
            if (node.output != nil) {
                NSLog(@"Warning! Value: %@ for key: %@ being replaced by value: %@", node.output, key, output);
            }
            node.output = output;
        }
        else {
            // Make a next node if it is nil
            if (node.next == nil) {
                node.next = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            currentNode = node.next;
        }
    }
}

-(NSMutableArray*)getPathForKey:(NSString*)key {
    NSRange theRange = {0, 1};
    NSMutableArray* array = [NSMutableArray array];
    for ( NSInteger i = 0; i < [key length]; i++) {
        theRange.location = i;
        [array addObject:[key substringWithRange:theRange]];
    }
    return array;
}

-(NSString *)getClassNameForInput:(NSString*)input {
    for (NSString* className in [classes keyEnumerator]) {
        NSMutableDictionary* classMap = [classes valueForKey:className];
        if ([classMap objectForKey:input] != nil) {
            return className;
        }
    }
    return nil;
}

-(NSMutableDictionary *)getClassForName:(NSString *)className {
    return [classes valueForKey:className];
}

@end
