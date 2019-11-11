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
		printThreadId("NativeWindow");
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
		HWND hWnd = CreateWindow(windowClassName.c_str(),
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

		if (!hWnd)
		{
			std::cout << "Call to CreateWindow failed!" << std::endl;
			return;
		}

		ShowWindow(hWnd, SW_SHOW);
		UpdateWindow(hWnd);

		// start main message loop
		if (hWnd)
		{
			MSG msg;
			while (GetMessage(&msg, NULL, 0, 0))
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
		// close window
		DestroyWindow(hWnd);
	};

	~NativeWindow()
	{
		printThreadId("~NativeWindow");
	}

private:
	static std::atomic<int> windowCounter_;
};
std::atomic<int> NativeWindow::windowCounter_{0};

struct WorkerObject
{
	napi_env env_;
	napi_async_work asyncWork_;
	std::thread *thread_ptr;
};

void FreeStdThreadExecute(napi_env env, void *data)
{
	printThreadId("FreeStdThreadExecute");
}

void FreeStdThreadComplete(napi_env env, napi_status status, void *data)
{
	printThreadId("FreeStdThreadComplete");
	auto workerObject = (WorkerObject *)data;
	NAPI_CHECK(status);
	NAPI_CHECK(napi_delete_async_work(env, workerObject->asyncWork_));
	printThreadId("FreeStdThreadComplete > joining std::thread ...");
	workerObject->thread_ptr->join();
	delete workerObject->thread_ptr;
	delete workerObject;
}

napi_value OpenNativeWindow(napi_env env, napi_callback_info info)
{
	printThreadId("OpenNativeWindow");
	auto workerObject = new WorkerObject();
	workerObject->env_ = env;
	napi_value resourceName;
	NAPI_CHECK(napi_create_string_utf8(workerObject->env_, "FreeStdThread", NAPI_AUTO_LENGTH, &resourceName));
	NAPI_CHECK(napi_create_async_work(workerObject->env_, nullptr, resourceName, FreeStdThreadExecute, FreeStdThreadComplete, workerObject, &workerObject->asyncWork_));
	workerObject->thread_ptr = new std::thread([=]() {
		printThreadId("std::thread");
		NativeWindow window;
		NAPI_CHECK(napi_queue_async_work(workerObject->env_, workerObject->asyncWork_));
	});
	return nullptr;
}

napi_value Initialize(napi_env env, napi_value exports)
{
	printThreadId("Initialize");
	napi_value openNativeWindow;
	NAPI_CHECK(napi_create_function(env, NULL, 0, OpenNativeWindow, NULL, &openNativeWindow));
	NAPI_CHECK(napi_set_named_property(env, exports, "openNativeWindow", openNativeWindow));
	return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Initialize)

} // namespace native
