# -----------------------------------------------------------------------------
# オラクルデータベースを接続のサンプル
#   DataSet使用
#   DataAdapter使用
#   SELECT文実行
# 補足
#   詳細はSystem.Data.Datasetおよびodp.net参照
#   https://docs.microsoft.com/ja-jp/dotnet/api/system.data.dataset?view=netframework-4.8
# 注意
#   データベース接続など設定が必要なので、以下のコードは使い方の例です。
#   そのまま実行しないでください。
# -----------------------------------------------------------------------------

Add-Type -AssemblyName System.Data.OracleClient

$ConnectionString = "Data Source=192.168.56.102:1521/orcl01;User ID=system;Password=ora;Integrated Security=false;"
$OraCon = New-Object System.Data.OracleClient.OracleConnection($ConnectionString)

$target = $args[0]
if ( ($null -eq $target ) -or ( $target  -eq "" ) ) { exit }

$strSQL = @"
select * from dba_objects where object_name = `'$target`'
"@
#Write-Host $strSQL 
$data = New-Object System.Data.OracleClient.OracleDataAdapter($strSQL, $OraCon)
$dtSet = New-Object System.Data.DataSet
[void]$data.Fill($dtSet)
if ($dtSet.Tables.Count -eq 0) { exit }

$ownerList = @()
foreach ($row in $dtSet.Tables[0]) {
    $ownerList += $row[0]
}

if ( -not $ownerList.Contains($args[1])) { 
    sqlplus.exe system/ora@192.168.56.102:1521/orcl01 $args[2] $args[1]
} else {
    Write-Host "Target table " + $args[1] + "." + $args[0] + " already exists!"
}

$query = "select count(*) from " + $args[1] + "." + $args[0]
$data1 = New-Object System.Data.OracleClient.OracleDataAdapter($query, $OraCon)
$dtSet1 = New-Object System.Data.DataSet
[void]$data1.Fill($dtSet1)
if ($dtSet1.Tables.Count -eq 0) { exit }
$count = $dtSet1.Tables[0].Rows[0][0]

if (($null -ne $args[3]) -and ($count -eq 0)) {
    if (-not (Test-Path $args[3] -PathType Leaf)) {
        $args[3] -match "objects_(?<sid>CDB.*?)_imp(?<dir1>.*?)_info(?<dir2>.*?).ctl" | Out-Null
        $text = ""
        $text += "OPTIONS(SKIP=1)`r`n"
        $text += "LOAD DATA`r`n"
        $text += "INFILE 'C:\Users\linxu\Desktop\imp_" + $Matches["dir1"] + "\info" + $Matches["dir2"] + "\objects_"+$Matches["sid"]+".csv'`r`n"
        $text += "INTO TABLE $($Matches["sid"])_$($Matches["dir1"])$($Matches["dir2"]).objects`r`n"
        $text += "APPEND`r`n"
        $text += "FIELDS TERMINATED BY ','`r`n"
        $text += "(OWNER,OBJECT_NAME,SUBOBJECT_NAME,OBJECT_ID,DATA_OBJECT_ID,OBJECT_TYPE,CREATED,LAST_DDL_TIME,TIMESTAMP,STATUS,TEMPORARY,GENERATED)"
        # $text | Out-File $args[3] -Encoding 932 # powshell 6.2 以後、ページコード使用可能 orz。 ここは汎用のためSystem.IOにする。
        [System.IO.File]::WriteAllText($args[3],$text,[System.Text.Encoding]::GetEncoding('shift-jis'))
    }
    sqlldr.exe system/ora@192.168.56.102:1521/orcl01 $args[3]
} else {
    Write-Host "Data already exists!"
}

$OraCon.close()
$OraCon.Dispose()

#Write-Host "$strSQL"
#Write-Host "$query"
#Write-Host "$count"
# "C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC21_imp2_info4.ctl" -match "objects_(?<sid>CDBC.*?)_imp(?<dir1>.*?)_info(?<dir2>.*?).ctl"
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBC01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC01_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBC11_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC11_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBC21_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC21_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBC31_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC31_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBC41_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC41_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBE01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBE01_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBE11_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBE11_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBF01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBF01_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBF02_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBF02_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBH01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBH01_imp2_info4.ctl
# C:\Users\linxu\Desktop\project\LearnPowerShell\database\oracle_db_sample.ps1 OBJECTS CDBW01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBW01_imp2_info4.ctl
