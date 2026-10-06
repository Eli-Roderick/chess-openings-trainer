#include "window_placement.h"

#include <shlobj.h>

#include <fstream>
#include <string>

namespace {

// The file holding the saved WINDOWPLACEMENT, or empty when unknown.
std::wstring PlacementFile(bool create_directory) {
  PWSTR base = nullptr;
  if (FAILED(::SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr,
                                    &base))) {
    return L"";
  }
  std::wstring dir = std::wstring(base) + L"\\RepertoireTrainer";
  ::CoTaskMemFree(base);
  if (create_directory) {
    ::CreateDirectoryW(dir.c_str(), nullptr);
  }
  return dir + L"\\window.dat";
}

}  // namespace

void RestoreWindowPlacement(HWND window, bool* maximized) {
  *maximized = false;
  const std::wstring path = PlacementFile(false);
  if (path.empty()) {
    return;
  }
  std::ifstream in(path, std::ios::binary);
  WINDOWPLACEMENT placement{};
  if (!in.read(reinterpret_cast<char*>(&placement), sizeof(placement)) ||
      placement.length != sizeof(placement)) {
    return;
  }
  // Only where a monitor still shows it (a screen may have been removed).
  if (::MonitorFromRect(&placement.rcNormalPosition,
                        MONITOR_DEFAULTTONULL) == nullptr) {
    return;
  }
  *maximized = placement.showCmd == SW_SHOWMAXIMIZED;
  // Hidden until the first Flutter frame (FlutterWindow shows it).
  placement.showCmd = SW_HIDE;
  ::SetWindowPlacement(window, &placement);
}

void SaveWindowPlacement(HWND window) {
  WINDOWPLACEMENT placement{};
  placement.length = sizeof(placement);
  if (!::GetWindowPlacement(window, &placement)) {
    return;
  }
  const std::wstring path = PlacementFile(true);
  if (path.empty()) {
    return;
  }
  std::ofstream out(path, std::ios::binary | std::ios::trunc);
  out.write(reinterpret_cast<const char*>(&placement), sizeof(placement));
}
