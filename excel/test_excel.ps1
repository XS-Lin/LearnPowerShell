# 動作検証環境： windows10 powershell5.1 excel2019
# Excelにイメージを挿入サンプル
$excelPath = "C:\Users\linxu\Desktop\testPS.xlsx"
$sheetName = "TestPS"
$imgPath = "C:\Users\linxu\Desktop\error_dummy.PNG"

$excel = New-Object -ComObject Excel.Application

$excel.Visible = $false # default false
$excel.DisplayAlerts = $false # default true

$book = $null
$sheet = $null

if (-Not (Test-Path $excelPath -PathType Leaf)) {
    $book = $excel.WorkBooks.Add()
    $sheet = $book.ActiveSheet
    $sheet.name = $sheetName
}
else {
    $book = $excel.WorkBooks.Open($excelPath)
    $sheet = $book.Sheets($sheetName)
}
# https://docs.microsoft.com/ja-jp/office/vba/api/excel.shapes.addpicture
$sheet.Shapes.AddPicture($imgPath,$true, $true, $sheet.Range("B2:E10").Left, $sheet.Range("B2:E10").Top,  $sheet.Range("B2:E10").Width, $sheet.Range("B2:E15").Height) | Out-Null
$sheet.Shapes.AddPicture($imgPath,$true, $true, 100, 100, -1, -1) | Out-Null
$excel.ActiveWorkbook.SaveAS($excelPath)
$book.Close()
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null

