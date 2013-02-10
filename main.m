#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

// Global server so controllers can access it
IMKServer *server;

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSString* kConnectionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InputMethodConnectionName"];
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        server = [[IMKServer alloc] initWithName:kConnectionName bundleIdentifier:identifier];
        
        // Load the bundle explicitly because the input method is a background only application
        [NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
        // Run everything
        [[NSApplication sharedApplication] run];
    }

    return 0;
}
