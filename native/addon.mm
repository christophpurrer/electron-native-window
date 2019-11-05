#include "napi_utils.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
 
@interface NativeWindow : NSObject<NSWindowDelegate> {
  NSWindow* window_;
}
@end

@implementation NativeWindow
bool initWasCalled = NO;

- (void)buttonClicked:(NSButton*)sender {
  @autoreleasepool {
    NSAlert* alert = [NSAlert new];
    [alert setMessageText:@"Click me"];
    [alert setInformativeText:@"Don't be shy"];
    [alert addButtonWithTitle:@"Okay"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window_
                  completionHandler:^(NSModalResponse returnCode){
                  }];
  }
}

- (id)init {
  if (self = [super init]) {
    // Setup window
    window_ =
        [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 360, 640)
                                    styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                                              NSWindowStyleMaskResizable
                                      backing:NSBackingStoreBuffered
                                        defer:NO];
    [window_
        setFrameTopLeftPoint:NSMakePoint(100, [[NSScreen mainScreen] frame].size.height - 100)];
    [window_ setDelegate:self];

    // add a button
    NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 100, 50)];
    [button setTitle:@"Show alert"];
    [button setTarget:self];
    [button setAction:@selector(buttonClicked:)];
    [window_.contentView addSubview:button];

    // show it
    [window_ makeKeyAndOrderFront:NULL];
  }
  NSLog(@"NativeWindow init%@", self);
  return self;
}

- (void)windowWillClose:(NSNotification *)notification {
  // CFRelease((void*)instance); // > this will crash the app
  //window_ = nil;// > this will crash the app
}

- (void)dealloc {
  NSLog(@"NativeWindow dealloc%@", self);
}
@end

namespace native {

napi_value Init(napi_env env, napi_callback_info info) {
  if (initWasCalled) {
    @throw [NSException exceptionWithName:@"InitException"
                                   reason:@"Init() must be called exactly once"
                                 userInfo:nil];
  }
  initWasCalled = YES;
  [[NSRunLoop mainRunLoop] performBlock:^{
    NSApplicationLoad();
    NSLog(@"Init mode:%@", [[NSRunLoop currentRunLoop] currentMode]);
    [[NSApplication sharedApplication] run];
    NSLog(@"NSApplication is gone :-(");
  }];
  return nullptr;
}

napi_value OpenNativeWindow(napi_env env, napi_callback_info info) {
  [[NSRunLoop mainRunLoop] performBlock:^{
    NSLog(@"OpenNativeWindow mode:%@", [[NSRunLoop currentRunLoop] currentMode]);
    CFRetain((__bridge_retained CFTypeRef)[NativeWindow new]);
  }];
  return nullptr;
}

napi_value Initialize(napi_env env, napi_value exports) {
  register_napi_function(env, exports, "init", Init);
  register_napi_function(env, exports, "openNativeWindow", OpenNativeWindow);
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
