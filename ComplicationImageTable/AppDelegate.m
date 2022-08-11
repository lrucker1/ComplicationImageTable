//
//  AppDelegate.m
//  ComplicationImageTable
//
//  Created by Lee Ann Rucker on 8/9/22.
//

#import "AppDelegate.h"
#import "ComplicationTableWindowController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@property (strong) NSMutableArray *windowControllers;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self newWindowWithControllerClass:[ComplicationTableWindowController class]];
}

- (void)newWindowWithControllerClass:(Class)c {
    NSWindowController *controller = [[c alloc] init];
    if (_windowControllers == nil) {
        _windowControllers = [NSMutableArray array];
    }
    [self.windowControllers addObject:controller];
    [controller showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
