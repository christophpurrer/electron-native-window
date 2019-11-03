#include "napi_utils.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NativeWindow : NSObject
@end

@implementation NativeWindow
NSWindow* window_;

-(void)buttonClicked:(NSButton*)sender {
    @autoreleasepool {
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"Click me"];
        [alert setInformativeText:@"Don't be shy"];
        [alert addButtonWithTitle:@"Okay"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:window_ completionHandler:^(NSModalResponse returnCode) {}];
    }
}

- (id)init {
    @autoreleasepool {
        // Setup window
        window_ = [[NSWindow alloc]
                   initWithContentRect:NSMakeRect(100, 100, 360, 640)
                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                   backing:NSBackingStoreBuffered
                   defer:NO];
        
        // add a button
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 100, 50)];
        [button setTitle:@"Open Window"];
        [button setTarget:self];
        [button setAction:@selector(buttonClicked:)];
        [window_.contentView addSubview:button];
        
        // show it
        [window_ makeKeyAndOrderFront:NULL];
    }
    return self;
}
@end

static void NativeWindowFinalize(napi_env env, void* object, void* hint) {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
        auto window = (__bridge_transfer NativeWindow*)object;
#pragma clang diagnostic pop
    }
}

namespace native
{

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{
    auto nativeWindow = [NativeWindow new];
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

napi_value Initialize(napi_env env, napi_value exports)
{
    napi_value openNativeWindow;
    NAPI_CHECK(napi_create_function(env, NULL, 0, OpenNativeWindow, NULL, &openNativeWindow));
    NAPI_CHECK(napi_set_named_property(env, exports, "openNativeWindow", openNativeWindow));
    return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

}
