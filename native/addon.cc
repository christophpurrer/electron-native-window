// hello.cc
#include <node.h>
#include <string>
using namespace std;

namespace demo
{

using v8::FunctionCallbackInfo;
using v8::Isolate;
using v8::Local;
using v8::Object;
using v8::String;
using v8::Value;

void Method(const FunctionCallbackInfo<Value> &args)
{
  args.GetReturnValue().Set(String::NewFromUtf8(args.GetIsolate(), "1"));
}

void Initialize(Local<Object> exports)
{
  NODE_SET_METHOD(exports, "hello", Method);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace demo