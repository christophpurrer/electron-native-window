#include "napi_utils.h"
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#include <string>
#include <windows.h>

struct NativeWindow
{
  NativeWindow()
  {
    if (createWindow() == S_OK && hWnd_ != NULL && !IsWindowVisible(hWnd_))
    {
      ShowWindow(hWnd_, SW_SHOW);
    }
  }

  ~NativeWindow() = default;

private:
  HWND hWnd_;
  HINSTANCE hInstance_ = NULL;

  HRESULT createWindow()
  {
    if (hInstance_ == NULL)
    {
      hInstance_ = (HINSTANCE)GetModuleHandle(NULL);
    }

    std::wstring windowClassName = L"Messenger";
    // Register the windows class
    WNDCLASS wndClass;
    wndClass.style = CS_HREDRAW | CS_VREDRAW;
    wndClass.lpfnWndProc = NativeWindow::WndProc;
    wndClass.cbClsExtra = 0;
    wndClass.cbWndExtra = 0;
    wndClass.hInstance = hInstance_;
    wndClass.hIcon = NULL;
    wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndClass.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    wndClass.lpszMenuName = NULL;
    wndClass.lpszClassName = windowClassName.c_str();

    if (!RegisterClass(&wndClass))
    {
      DWORD dwError = GetLastError();
      if (dwError != ERROR_CLASS_ALREADY_EXISTS)
      {
        return HRESULT_FROM_WIN32(dwError);
      }
    }

    hWnd_ = CreateWindow(windowClassName.c_str(),
                         L"NativeWindow",
                         WS_OVERLAPPEDWINDOW,
                         CW_USEDEFAULT,
                         CW_USEDEFAULT,
                         1280,
                         720,
                         NULL,
                         NULL,
                         hInstance_,
                         NULL);

    if (hWnd_ == NULL)
    {
      DWORD dwError = GetLastError();
      return HRESULT_FROM_WIN32(dwError);
    }
    return S_OK;
  }

  static LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
  {
    switch (uMsg)
    {
    case WM_CLOSE:
    {
      HMENU hMenu;
      hMenu = GetMenu(hWnd);
      if (hMenu != NULL)
      {
        DestroyMenu(hMenu);
      }
      DestroyWindow(hWnd);
      return 0;
    }

    case WM_DESTROY:
      PostQuitMessage(0);
      break;
    }

    return DefWindowProc(hWnd, uMsg, wParam, lParam);
  }
};

static void NativeWindowFinalize(napi_env env, void *object, void *hint)
{
  auto nativeWindow = reinterpret_cast<NativeWindow *>(object);
  if (nativeWindow)
  {
    delete nativeWindow;
  }
}

namespace native
{

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{
  auto nativeWindow = new NativeWindow{};
  napi_value jsWindow;
  NAPI_CHECK(napi_create_object(env, &jsWindow));
  NAPI_CHECK(napi_wrap(env,
                       jsWindow,
                       reinterpret_cast<void *>(nativeWindow),
                       NativeWindowFinalize,
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

} // namespace native