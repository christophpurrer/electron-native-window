// hello.cc
#include <node.h>
#include <string>
using namespace std;

namespace native
{

using v8::FunctionCallbackInfo;
using v8::Isolate;
using v8::Local;
using v8::Object;
using v8::String;
using v8::Value;

void OpenNativeWindow(const FunctionCallbackInfo<Value> &args)
{
  args.GetReturnValue().Set(String::NewFromUtf8(args.GetIsolate(), "1"));
}

void Initialize(Local<Object> exports)
{
  NODE_SET_METHOD(exports, "openNativeWindow", OpenNativeWindow);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native