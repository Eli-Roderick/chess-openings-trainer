#ifndef RUNNER_WINDOW_PLACEMENT_H_
#define RUNNER_WINDOW_PLACEMENT_H_

#include <windows.h>

// Smallest window size in logical pixels (P13).
constexpr int kMinWindowWidth = 900;
constexpr int kMinWindowHeight = 600;

// Restores the size and position saved by SaveWindowPlacement when it is
// still on a monitor; sets |maximized| if the window was maximized.
void RestoreWindowPlacement(HWND window, bool* maximized);

// Saves the window's normal size, position and maximized state in
// %LOCALAPPDATA%\RepertoireTrainer\window.dat.
void SaveWindowPlacement(HWND window);

#endif  // RUNNER_WINDOW_PLACEMENT_H_
