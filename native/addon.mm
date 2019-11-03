#include "napi_utils.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface WindowDelegate : NSObject <NSWindowDelegate> @end

@implementation WindowDelegate

-(void)buttonClicked:(id)sender {
    NSWindow* window = [[NSWindow alloc]
                        initWithContentRect:NSMakeRect(200, 200, 200, 200)
                        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |      NSWindowStyleMaskResizable
                        backing:NSBackingStoreBuffered
                        defer:NO];
    [window setBackgroundColor:[NSColor redColor]];
    [window makeKeyAndOrderFront:NULL];
}

@end

namespace native
{

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{
    // Setup window
    NSWindow* window = [[NSWindow alloc]
                        initWithContentRect:NSMakeRect(100, 100, 720, 1280)
                        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                        backing:NSBackingStoreBuffered
                        defer:NO];
    [window makeKeyAndOrderFront:NULL];
    
    // ... and its delegate
    WindowDelegate* windowDelegate = [WindowDelegate new];
    [window setDelegate:windowDelegate];
    
    // add a button
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 200, 100)];
    [button setTitle:@"Open Window"];
    [button setTarget:windowDelegate];
    [button setAction:@selector(buttonClicked:)];
    [window.contentView addSubview:button];
    return nullptr;
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
