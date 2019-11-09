#pragma once

#include <node_api.h>
#include <thread>
#include <iostream>

#ifndef NAPI_CHECK
#define NAPI_CHECK(expr) if(expr != napi_ok) napi_throw_error(env, NULL, "N-API call unsuccessful");
#endif // NAPI_CHECK

void register_napi_function(napi_env env, napi_value exports, const char* utf8name, napi_callback func_cb) {
  napi_value func_object;
  NAPI_CHECK(napi_create_function(env, NULL, 0, func_cb, NULL, &func_object));
  NAPI_CHECK(napi_set_named_property(env, exports, utf8name, func_object));
}

void printThreadId(const char* context) {
  std::cout << context << " {thread: " << std::this_thread::get_id() << " }" << std::endl;
}