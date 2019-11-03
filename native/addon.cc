#include <node_api.h>

namespace native
{

void OpenNativeWindow(const v8::FunctionCallbackInfo<v8::Value> &args)
{
  args.GetReturnValue().Set(v8::String::NewFromUtf8(args.GetIsolate(), "1"));
}

napi_value Initialize(napi_env env, napi_value exports)
{
  napi_value openNativeWindow;
  if (napi_create_function(env, NULL, 0, OpenNativeWindow, NULL, &openNativeWindow) != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to wrap native function");
  }
  if (napi_set_named_property(env, exports, "openNativeWindow", openNativeWindow) != napi_ok)
  {
    napi_throw_error(env, NULL, "Unable to populate exports");
  }
  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native