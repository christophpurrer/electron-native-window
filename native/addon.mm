#include <node.h>
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
    
void OpenNativeWindow(const v8::FunctionCallbackInfo<v8::Value> &args)
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
}

void Initialize(v8::Local<v8::Object> exports)
{
    NODE_SET_METHOD(exports, "openNativeWindow", OpenNativeWindow);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, Initialize)

}
