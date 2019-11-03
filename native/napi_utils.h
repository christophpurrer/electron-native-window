#pragma once

#include <node_api.h>

#ifndef NAPI_CHECK
#define NAPI_CHECK(expr) if(expr != napi_ok) napi_throw_error(env, NULL, "N-API call unsuccessful");
#endif // NAPI_CHECK