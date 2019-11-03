#include <node_api.h>

namespace native
{

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{ 
	return nullptr;
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