const { execFile } = require("child_process");

function getActiveApp() {
  if (process.platform !== "win32") return Promise.resolve({ name: "Unknown", title: "" });

  const script = `
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
}
public struct RECT {
  public int Left;
  public int Top;
  public int Right;
  public int Bottom;
}
"@
$hwnd = [Win32]::GetForegroundWindow()
$builder = New-Object System.Text.StringBuilder 512
[void][Win32]::GetWindowText($hwnd, $builder, $builder.Capacity)
$pidValue = 0
[void][Win32]::GetWindowThreadProcessId($hwnd, [ref]$pidValue)
$proc = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
$rect = New-Object RECT
[void][Win32]::GetWindowRect($hwnd, [ref]$rect)
[pscustomobject]@{
  name = $proc.ProcessName
  title = $builder.ToString()
  bounds = [pscustomobject]@{
    x = $rect.Left
    y = $rect.Top
    width = [Math]::Max(0, $rect.Right - $rect.Left)
    height = [Math]::Max(0, $rect.Bottom - $rect.Top)
  }
} | ConvertTo-Json -Compress
`;

  return new Promise((resolve) => {
    execFile("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script], { timeout: 2500 }, (error, stdout) => {
      if (error) return resolve({ name: "Unknown", title: "" });
      try {
        resolve(JSON.parse(stdout));
      } catch {
        resolve({ name: "Unknown", title: "" });
      }
    });
  });
}

module.exports = { getActiveApp };
