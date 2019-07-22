#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-6

# チェック対象ユーザ定義
$user_CDBF01=@('CCOM','CEMUSR','CEUCOM','CMRUSR','EIREF','FANA','FCOM','FFICOM','FPTUSR','FREF','FUSR','OUSR','WCCUSR','WUSR')
$input1 = "C:\Users\linxu\Desktop\work\作業\20190425本番機info\整理後\info\dba_tab_privs_CDBF01.csv"
$input2 = "C:\Users\linxu\Desktop\imp_2\info7\dba_tab_privs_CDBF01.csv"
$output = "C:\Users\linxu\Desktop\work\作業\IMP結果検証\grant_privs.sql"

$csv1 = Import-Csv $input1 -Encoding Default
$csv2 = Import-Csv $input2 -Encoding Default

$target1 = $csv1 | Where-Object {$_.OWNER -in $user_CDBF01} | Select-Object -Property GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE
$target2 = $csv2 | Where-Object {$_.OWNER -in $user_CDBF01} | Select-Object -Property GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE

$result = Compare-Object -ReferenceObject $target1 -DifferenceObject $target2

$text = ""
$result | ForEach-Object -Process {
    $text += "ALTER SESSION SET CURRENT_SCHEMA=" + $_.InputObject.GRANTOR + ";`n";
    $text += "grant " + $_.InputObject.PRIVILEGE + " on " + $_.InputObject.OWNER + "." + $_.InputObject.TABLE_NAME + " to " + $_.InputObject.GRANTEE + ";`n";
}

# PowerShell 5.1対応のため(PowerShell6以後、Out-Fileも日本語出力可)
[System.IO.File]::WriteAllText($output,$text,[System.Text.Encoding]::GetEncoding('shift-jis'))

