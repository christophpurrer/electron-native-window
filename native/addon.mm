#include "napi_utils.h"

#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>
#include <array>
#include <objc/objc-runtime.h>

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
    [window_ setTitle:@"NSWindow"];

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

napi_value MakeNativeWindow(napi_env env, napi_callback_info info) {
  printThreadId("MakeNativeWindow");
  std::array<napi_value, 2> args;
  size_t argc = args.size();
  NAPI_CHECK(napi_get_cb_info(env, info, &argc, args.data(), nullptr, nullptr));

  bool isBuffer = false;
  NAPI_CHECK(napi_is_buffer(env, args[0], &isBuffer));

  void* handleBuffer;
  size_t length;
  NAPI_CHECK(napi_get_buffer_info(env, args[0], &handleBuffer, &length));

  NSView* __weak mainContentView = *reinterpret_cast<NSView * __weak*>(handleBuffer);
  [mainContentView.window setStyleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                              NSWindowStyleMaskResizable | NSWindowStyleMaskFullSizeContentView |
                              NSWindowStyleMaskMiniaturizable];
  mainContentView.window.titlebarAppearsTransparent = YES;
  mainContentView.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
  [view setWantsLayer:YES];
  view.layer.backgroundColor = [[NSColor yellowColor] CGColor];
  [mainContentView.window.contentView addSubview:view];
  [mainContentView.window makeKeyWindow];
  return nullptr;
}

napi_value Initialize(napi_env env, napi_value exports) {
  printThreadId("Initialize");
  register_napi_function(env, exports, "init", Init);
  register_napi_function(env, exports, "openNativeWindow", OpenNativeWindow);
  register_napi_function(env, exports, "makeNativeWindow", MakeNativeWindow);
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
