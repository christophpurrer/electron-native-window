#include "napi_utils.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface OurNSWindow : NSWindow
@end

@implementation OurNSWindow
- (void)dealloc {
  NSLog(@"OurNSWindow dealloc%@", self);
}
@end

@interface NativeWindow : NSWindowController <NSWindowDelegate> {
  OurNSWindow* window_;
}
@end

@implementation NativeWindow

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
    window_ = [[OurNSWindow alloc]
        initWithContentRect:NSMakeRect(100, 100, 360, 640)
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

    // don't release window_ onClose, do it when NativeWindow gets released
    // https://developer.apple.com/documentation/appkit/nswindow/1419662-close?language=objc
    [window_ setReleasedWhenClosed:NO];
      
    // show it
    [window_ makeKeyAndOrderFront:NULL];
  }
  NSLog(@"NativeWindow init%@", self);
  return self;
}

- (void)windowWillClose:(NSNotification*)notification {
  NSLog(@"NativeWindow windowWillClose%@", self);
  CFRelease((__bridge CFTypeRef)self);
}

- (void)dealloc {
  NSLog(@"NativeWindow dealloc%@", self);
}
@end

bool initWasCalled = NO;

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
    NSLog(@"Init(): NSRunLoop mode:%@", [[NSRunLoop currentRunLoop] currentMode]);
    [[NSApplication sharedApplication] run];
    NSLog(@"NSApplication is gone :-( - MUST never happen");
  }];
  return nullptr;
}

napi_value OpenNativeWindow(napi_env env, napi_callback_info info) {
  printThreadId("OpenNativeWindow");
  [[NSRunLoop mainRunLoop] performBlock:^{
    NSLog(@"OpenNativeWindow(): NSRunLoop mode:%@", [[NSRunLoop currentRunLoop] currentMode]);
    CFRetain((__bridge CFTypeRef)[NativeWindow new]);
  }];
  return nullptr;
}

napi_value Initialize(napi_env env, napi_value exports) {
  printThreadId("Initialize");
  register_napi_function(env, exports, "init", Init);
  register_napi_function(env, exports, "openNativeWindow", OpenNativeWindow);
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
