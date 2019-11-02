#include <node.h>

namespace native
{

void OpenNativeWindow(const v8::FunctionCallbackInfo<v8::Value> &args)
{
  args.GetReturnValue().Set(v8::String::NewFromUtf8(args.GetIsolate(), "1"));
}

void Initialize(v8::Local<v8::Object> exports)
{
  NODE_SET_METHOD(exports, "openNativeWindow", OpenNativeWindow);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native