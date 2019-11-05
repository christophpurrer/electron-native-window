#include "napi_utils.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface NativeWindow : NSObject {
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
- (void)dealloc {
  NSLog(@"NativeWindow dealloc%@", self);
}
@end

static void NativeWindowFinalize(napi_env env, void* object, void* hint) {
  @autoreleasepool {
    auto window = (__bridge_transfer NativeWindow*)object;
    NSLog(@"NativeWindowFinalize %@", window);
  }
}

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
  auto nativeWindow = [NativeWindow alloc];
  [[NSRunLoop mainRunLoop] performBlock:^{
    NSLog(@"OpenNativeWindow mode:%@", [[NSRunLoop currentRunLoop] currentMode]);
    CFRetain((__bridge_retained CFTypeRef)[nativeWindow init]);
  }];
  napi_value jsWindow;
  NAPI_CHECK(napi_create_object(env, &jsWindow));
  NAPI_CHECK(napi_wrap(env,
                       jsWindow,
                       (__bridge_retained void*)nativeWindow,
                       &NativeWindowFinalize,
                       nullptr,
                       nullptr));
  return jsWindow;
}

napi_value Initialize(napi_env env, napi_value exports) {
  napi_value init;
  NAPI_CHECK(napi_create_function(env, NULL, 0, Init, NULL, &init));
  NAPI_CHECK(napi_set_named_property(env, exports, "init", init));

  napi_value openNativeWindow;
  NAPI_CHECK(napi_create_function(env, NULL, 0, OpenNativeWindow, NULL, &openNativeWindow));
  NAPI_CHECK(napi_set_named_property(env, exports, "openNativeWindow", openNativeWindow));
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
