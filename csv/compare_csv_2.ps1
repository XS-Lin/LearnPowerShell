#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-6
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-6

# チェック対象ユーザ定義
$user_CDBF01=@('CCOM','CEMUSR','CEUCOM','CMRUSR','EIREF','FANA','FCOM','FFICOM','FPTUSR','FREF','FUSR','OUSR','WCCUSR','WUSR')
$input1 = "C:\Users\linxu\Desktop\work\作業\20190425本番機info\整理後\info\objects_CDBF01.csv"
$input2 = "C:\Users\linxu\Desktop\imp_2\info7\objects_CDBF01.csv"

$csv1 = Import-Csv $input1 -Encoding Default
$csv2 = Import-Csv $input2 -Encoding Default

$target1 = $csv1 | Where-Object { ($_.OWNER -in $user_CDBF01) -and ($_.STATUS -eq "VALID") } | Select-Object -Property OWNER,OBJECT_NAME,OBJECT_TYPE
$target2 = $csv2 | Where-Object { ($_.OWNER -in $user_CDBF01) -and ($_.STATUS -eq "INVALID") } | Select-Object -Property OWNER,OBJECT_NAME,OBJECT_TYPE

Compare-Object -ReferenceObject $target2 -DifferenceObject $target1 -ExcludeDifferent -IncludeEqual


