# 関数名:
#   Excelにイメージを挿入ファンクション
# 使用例:
#   ."function_add_pic_to_excel.ps1"
#   Add-Picture-To-Excel-By-Path pic.png test.xlsx
# 動作検証環境：
#   Windows 10
#   Powershell 5.1
#   Excel 2019
function Add-Picture-To-Excel-By-Path {
    param (
        [string]$pictureFilePath,
        [string]$excelFilePath,
        [string]$sheetName = "", # デフォルト：現在のシート(ActiveSheet)使用 
        [string]$range = "", # デフォルト:"A1", 設定例:"A1"、"A1:H20"
        [string]$useRangeSize = "False" # デフォルト:False-画像のサイズ使用,True-指定のrangeサイズ使用
    )

    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false # default false
    $excel.DisplayAlerts = $false # default true
    
    $book = $null
    $sheet = $null    
    if (-Not (Test-Path $excelFilePath -PathType Leaf)) {
        $book = $excel.WorkBooks.Add()
        $sheet = $book.ActiveSheet
        $sheet.name = $sheetName
    }
    else {
        $book = $excel.WorkBooks.Open($excelFilePath)
        $sheet = $book.Sheets($sheetName)
        if ($null -eq $sheet) {
            Write-Error "Sheet:$sheetName dose not exist."
            return
        }
    }

    $targetRange = $sheet.Range($(if([String]::IsNullOrEmpty($range)) { "A1" } else { $range }))
    try {
        $isUseRangeSize = [System.Convert]::ToBoolean($useRangeSize) 
    } catch [FormatException] {
        $isUseRangeSize = $false
    }
    # https://docs.microsoft.com/ja-jp/office/vba/api/excel.shapes.addpicture
    $sheet.Shapes.AddPicture($pictureFilePath,$true, $true,
        $targetRange.Left, 
        $targetRange.Top, 
        $(if($isUseRangeSize){$targetRange.Width}else{-1}),
        $(if($isUseRangeSize){$targetRange.Height}else{-1})) | Out-Null
    $excel.ActiveWorkbook.SaveAS($excelFilePath)

    $book.Close()
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
}

# UnitTest  
# Add-Picture-To-Excel-By-Path "C:\Users\linxu\Desktop\error_dummy.PNG" "C:\Users\linxu\Desktop\testPS.xlsx" TestPS A2:F20 False