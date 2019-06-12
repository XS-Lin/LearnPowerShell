# 
# 機能
#   起動後、shift+alt+sキー押下の場合、画面キャプチャーを取得し、指定フォルダに保存
#   TODO: 指定ファイル名パターンで複数イメージ保存
#   TODO: イメージ形式変更できるようにする
#   TODO: ホットキー変更できるようにする
# 
$picName = "clip.png"
$picFolder = "C:\Users\linxu\Desktop\project\LearnPowerShell\other\pic"

set-variable -name WH_KEYBOARD_LL -value 13 -option constant
set-variable -name WM_KEYDOWN -value 0x0100 -option constant
set-variable -name WM_KEYUP -value 0x0101 -option constant
set-variable -name WM_SYSKEYDOWN -value 0x0104 -option constant
set-variable -name WM_SYSKEYUP -value 0x0105 -option constant
set-variable -name VK_SHIFT -value 0x10 -option constant
set-variable -name VK_CONTROL -value 0x11 -option constant
set-variable -name VK_MENU -value 0x12 -option constant
set-variable -name VK_S -value 0x53 -option constant

Add-Type -AssemblyName System.Runtime.InteropServices
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition "public delegate System.IntPtr HookProc(int nCode, System.IntPtr wParam, System.IntPtr lParam);"
$source = @"
[DllImport("user32.dll")]
public static extern IntPtr SetWindowsHookEx(int idHook, IntPtr lpfn, IntPtr hMod, uint dwThreadId);
[DllImport("user32.dll")]
public static extern bool UnhookWindowsHookEx(IntPtr hhk);
[DllImport("user32.dll")]
public static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
[DllImport("user32.dll")]
public static extern short GetKeyState(int nVirtKey);
[DllImport("kernel32.dll")]
public static extern IntPtr GetModuleHandle(string lpModuleName);
"@
$Win32Api = Add-Type -Name "Win32Api" -MemberDefinition $source -PassThru

$moduleHandle = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.BaseAddress
$hookId = [System.IntPtr]::Zero

[HookProc] $hookproc = {
    param (
        [int] $nCode,
        [System.IntPtr] $wParam,
        [System.IntPtr] $lParam
    )
    Write-Host "nCode=$nCode,wParam=$wParam,lParam=$lParam"
    if (($nCode -ge 0))
    {
        if ([System.IntPtr]::Equals($wParam, [System.IntPtr]$WM_KEYDOWN))
        {
            $vkCode = [System.Runtime.InteropServices.Marshal]::ReadInt32($lParam);
            #Write-Host "$vkCode"
        } elseif ([System.IntPtr]::Equals($wParam, [System.IntPtr]$WM_SYSKEYDOWN)) {
            $vkCode = [System.Runtime.InteropServices.Marshal]::ReadInt32($lParam);
            #Write-Host "$vkCode"
            if(($Win32Api::GetKeyState($VK_SHIFT) -lt 0) -and ($vkCode -eq $VK_S)) {
                [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")
                Start-Sleep -Milliseconds 500
                $bitmap = [Windows.Forms.Clipboard]::GetImage()
                $picPath = Join-Path $picFolder $picName
                #Write-Host "$picPath"
                $bitmap.Save($picPath,[System.Drawing.Imaging.ImageFormat]::Png)
            }
        } else {
            
        }
        
    }
    $Win32Api::CallNextHookEx($hookId,$nCode,$wParam,$lParam)
}

$hookprocHandler = [System.Runtime.InteropServices.Marshal]::GetFunctionPointerForDelegate($hookproc)
$hookId = $Win32Api::SetWindowsHookEx($WH_KEYBOARD_LL,$hookprocHandler,$moduleHandle,0)

# 参考情報
# https://hinchley.net/articles/creating-a-key-logger-via-a-global-system-hook-using-powershell/
# https://support.microsoft.com/ja-jp/help/2909958/exceptions-in-windows-powershell-other-dynamic-languages-and-dynamical
# https://docs.microsoft.com/en-us/windows/desktop/api/libloaderapi/nf-libloaderapi-getmodulehandlea
# https://docs.microsoft.com/ja-jp/dotnet/api/system.diagnostics.processmodule.baseaddress?view=netframework-4.8#System_Diagnostics_ProcessModule_BaseAddress
# https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
# https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwindowshookexa
# https://docs.microsoft.com/ja-jp/windows/desktop/inputdev/wm-keydown
# https://stackoverflow.com/questions/54236696/how-to-capture-global-keystrokes-with-powershell