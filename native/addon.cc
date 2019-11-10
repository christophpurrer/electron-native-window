#include "napi_utils.h"
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#include <atomic>
#include <iostream>
#include <string>
#include <thread>
#include <windows.h>

namespace native
{

struct NativeWindow
{
	static LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
	{
		switch (message)
		{
		case WM_DESTROY:
			PostQuitMessage(0);
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
			break;
		}
		return 0;
	}

	NativeWindow()
	{
		std::cout << "NativeWindow" << std::endl;
		HINSTANCE hInstance = (HINSTANCE)GetModuleHandle(NULL);

		// Register the windows class with unique className to allow multiWindow support
		std::wstring windowClassName = L"Messenger" + std::to_wstring(windowCounter_++);
		WNDCLASSEX wcex;
		wcex.cbSize = sizeof(WNDCLASSEX);
		wcex.style = CS_HREDRAW | CS_VREDRAW;
		wcex.lpfnWndProc = WndProc;
		wcex.cbClsExtra = 0;
		wcex.cbWndExtra = 0;
		wcex.hInstance = hInstance;
		wcex.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
		wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
		wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
		wcex.lpszMenuName = NULL;
		wcex.lpszClassName = windowClassName.c_str();
		wcex.hIconSm = LoadIcon(wcex.hInstance, IDI_APPLICATION);

		if (!RegisterClassEx(&wcex))
		{
			std::cout << "Call to RegisterClassEx failed!" << std::endl;
			return;
		}

		// Store instance handle in our global variable
		HWND hWnd_ = CreateWindow(windowClassName.c_str(),
								  L"NativeWindow",
								  WS_OVERLAPPEDWINDOW,
								  CW_USEDEFAULT,
								  CW_USEDEFAULT,
								  360,
								  640,
								  NULL,
								  NULL,
								  hInstance,
								  NULL);

		if (!hWnd_)
		{
			std::cout << "Call to CreateWindow failed!" << std::endl;
			return;
		}

		ShowWindow(hWnd_, SW_SHOW);
		UpdateWindow(hWnd_);

		// start main message loop
		if (hWnd_)
		{
			MSG msg;
			while (GetMessage(&msg, NULL, 0, 0))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
	};

	~NativeWindow()
	{
		std::cout << "~NativeWindow" << std::endl;
	}

private:
	static std::atomic<int> windowCounter_;
};
std::atomic<int> NativeWindow::windowCounter_{0};

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{
	// TODO: Clean up nativeWindow threads
	new std::thread(([]() { NativeWindow nativeWindow; }));
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

} // namespace native
