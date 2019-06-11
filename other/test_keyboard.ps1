# 参考情報
# https://hinchley.net/articles/creating-a-key-logger-via-a-global-system-hook-using-powershell/

# 機能
#   起動後、shift+alt+sキー押下の場合、画面キャプチャーを取得し、指定フォルダに保存
# 
$picFolder = "\pic"
$hotKey = "shift+alt+s" # 「+」は区切り文字として使用
set-variable -name WH_KEYBOARD_LL -value 13 -option constant
set-variable -name WM_KEYDOWN -value 0x0100 -option constant
$source = @"
[DllImport("user32.dll")]
public static extern IntPtr SetWindowsHookEx(int idHook, IntPtr lpfn, IntPtr hMod, uint dwThreadId);
[DllImport("user32.dll")]
public static extern bool UnhookWindowsHookEx(IntPtr hhk);
[DllImport("user32.dll")]
public static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
[DllImport("kernel32.dll")]
public static extern IntPtr GetModuleHandle(string lpModuleName);
"@
$Win32Api = Add-Type -Name Win32Api -MemberDefinition $source -PassThru
$Win32Api::GetModuleHandle([System.Diagnostics.Process]::GetCurrentProcess().MainModule.ModuleName)


#Add-Type -TypeDefinition @"
#using System;
#using System.IO;
#using System.Diagnostics;
#using System.Runtime.InteropServices;
#using System.Windows.Forms;
#
#namespace KeyLogger {
#  public static class Program {
#    private const int WH_KEYBOARD_LL = 13;
#    private const int WM_KEYDOWN = 0x0100;
#
#    private const string logFileName = "log.txt";
#    private static StreamWriter logFile;
#
#    private static HookProc hookProc = HookCallback;
#    private static IntPtr hookId = IntPtr.Zero;
#
#    public static void Main() {
#      logFile = File.AppendText(logFileName);
#      logFile.AutoFlush = true;
#
#      hookId = SetHook(hookProc);
#      Application.Run();
#      UnhookWindowsHookEx(hookId);
#    }
#
#    private static IntPtr SetHook(HookProc hookProc) {
#      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
#      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
#    }
#
#    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);
#
#    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
#      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
#        int vkCode = Marshal.ReadInt32(lParam);
#        logFile.WriteLine((Keys)vkCode);
#      }
#
#      return CallNextHookEx(hookId, nCode, wParam, lParam);
#    }
#
#    [DllImport("user32.dll")]
#    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);
#
#    [DllImport("user32.dll")]
#    private static extern bool UnhookWindowsHookEx(IntPtr hhk);
#
#    [DllImport("user32.dll")]
#    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
#
#    [DllImport("kernel32.dll")]
#    private static extern IntPtr GetModuleHandle(string lpModuleName);
#  }
#}
#"@ -ReferencedAssemblies System.Windows.Forms
#
#[KeyLogger.Program]::Main();

#Add-Type -TypeDefinition @"
#using System;
#using System.IO;
#using System.Diagnostics;
#using System.Runtime.InteropServices;
#using System.Windows.Forms;
#
#namespace KeyLogger {
#  public static class Program {
#    private const int WH_KEYBOARD_LL = 13;
#    private const int WM_KEYDOWN = 0x0100;
#
#    private static HookProc hookProc = HookCallback;
#    private static IntPtr hookId = IntPtr.Zero;
#
#    [StructLayout(LayoutKind.Sequential)]
#    public class KBDLLHOOKSTRUCT {
#      public uint vkCode;
#      public uint scanCode;
#      public KBDLLHOOKSTRUCTFlags flags;
#      public uint time;
#      public UIntPtr dwExtraInfo;
#    }
#
#    [Flags]
#    public enum KBDLLHOOKSTRUCTFlags : uint {
#      LLKHF_EXTENDED = 0x01,
#      LLKHF_INJECTED = 0x10,
#      LLKHF_ALTDOWN = 0x20,
#      LLKHF_UP = 0x80,
#    }
#
#    public static void Main() {
#      hookId = SetHook(hookProc);
#      Application.Run();
#      UnhookWindowsHookEx(hookId);
#    }
#
#    private static IntPtr SetHook(HookProc hookProc) {
#      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
#      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
#    }
#
#    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);
#
#    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
#      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
#
#        KBDLLHOOKSTRUCT kbd = (KBDLLHOOKSTRUCT) Marshal.PtrToStructure(lParam, typeof(KBDLLHOOKSTRUCT));
#        Console.WriteLine(kbd.scanCode); // write scan code to console
#
#        if (kbd.scanCode == 55) { return (IntPtr)1; }
#      }
#
#      return CallNextHookEx(hookId, nCode, wParam, lParam);
#    }
#
#    [DllImport("user32.dll")]
#    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);
#
#    [DllImport("user32.dll")]
#    private static extern bool UnhookWindowsHookEx(IntPtr hhk);
#
#    [DllImport("user32.dll")]
#    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
#
#    [DllImport("kernel32.dll")]
#    private static extern IntPtr GetModuleHandle(string lpModuleName);
#  }
#}
#"@ -ReferencedAssemblies System.Windows.Forms
#
#[KeyLogger.Program]::Main();