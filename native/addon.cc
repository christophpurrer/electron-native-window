#include "napi_utils.h"
#define WIN32_LEAN_AND_MEAN
#define UNICODE
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <thread>
#include <vector>
#include <windows.h>

struct NativeWindow;
std::vector<std::thread> windowThreads;
int windowCounter = 0;

struct NativeWindow {
	static LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
		switch (message) {
		case WM_DESTROY:
			PostQuitMessage(0);
			windowThreads.erase(windowThreads.begin());
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
			break;
		}
		return 0;
	}

	NativeWindow() {
		std::cout << "NativeWindow" << std::endl;
		init();
	}

	~NativeWindow() {
		hInstance_ = nullptr;
		std::cout << "~NativeWindow" << std::endl;
	}

	int init() {
		hInstance_ = (HINSTANCE)GetModuleHandle(NULL);

		std::wstring windowClassName = L"Messenger" + windowCounter;
		windowCounter++;
		// Register the windows class
		WNDCLASSEX wcex;
		wcex.cbSize = sizeof(WNDCLASSEX);
		wcex.style = CS_HREDRAW | CS_VREDRAW;
		wcex.lpfnWndProc = WndProc;
		wcex.cbClsExtra = 0;
		wcex.cbWndExtra = 0;
		wcex.hInstance = hInstance_;
		wcex.hIcon = LoadIcon(hInstance_, IDI_APPLICATION);
		wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
		wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
		wcex.lpszMenuName = NULL;
		wcex.lpszClassName = windowClassName.c_str();
		wcex.hIconSm = LoadIcon(wcex.hInstance, IDI_APPLICATION);

		if (!RegisterClassEx(&wcex)) {
			std::cout << "Call to RegisterClassEx failed!" << std::endl;
			return 1;
		}

		// Store instance handle in our global variable
		HINSTANCE hInst = hInstance_;
		HWND hWnd = CreateWindow(windowClassName.c_str(),
			L"NativeWindow",
			WS_OVERLAPPEDWINDOW,
			CW_USEDEFAULT,
			CW_USEDEFAULT,
			360,
			640,
			NULL,
			NULL,
			hInstance_,
			NULL);

		if (!hWnd) {
			std::cout << "Call to CreateWindow failed!" << std::endl;
			return 1;
		}

		ShowWindow(hWnd, SW_SHOW);
		UpdateWindow(hWnd);

		// Main message loop:
		MSG msg;
		while (GetMessage(&msg, NULL, 0, 0)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		return (int)msg.wParam;
	};

	bool isRunning() {
		return hInstance_;
	}

private:
	HINSTANCE hInstance_ = nullptr;
};

namespace native {
	napi_value OpenNativeWindow(napi_env env, napi_callback_info info) {
		windowThreads.push_back(std::thread([]() { NativeWindow(); }));
		return nullptr;
	}

	napi_value Initialize(napi_env env, napi_value exports) {
		napi_value openNativeWindow;
		NAPI_CHECK(napi_create_function(env, NULL, 0, OpenNativeWindow, NULL, &openNativeWindow));
		NAPI_CHECK(napi_set_named_property(env, exports, "openNativeWindow", openNativeWindow));
		return exports;
	}

	NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
