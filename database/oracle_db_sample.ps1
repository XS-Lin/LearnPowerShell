# -----------------------------------------------------------------------------
# オラクルデータベースを接続のサンプル
#   DataSet使用
#   DataAdapter使用
#   SELECT文実行
# 補足
#   詳細はSystem.Data.Datasetおよびodp.net参照
#   https://docs.microsoft.com/ja-jp/dotnet/api/system.data.dataset?view=netframework-4.8
#   https://www.oracle.com/technetwork/jp/topics/dotnet/index-085163-ja.html
# 注意
#   データベース接続など設定が必要なので、以下のコードは使い方の例です。
#   そのまま実行しないでください。
# -----------------------------------------------------------------------------

Add-Type -AssemblyName System.Data.OracleClient

$ConnectionString = "Data Source=192.168.56.102:1521/orcl01;User ID=system;Password=ora;Integrated Security=false;"
$OraCon = New-Object System.Data.OracleClient.OracleConnection($ConnectionString)
$dtSet = New-Object System.Data.DataSet

$target = $args[0]
if ( ($null -eq $target ) -or ( $target  -eq "" ) ) { exit }

$strSQL = @"
select * from dba_objects where object_name = `'$target`'
"@
#Write-Host $strSQL 
$data = New-Object System.Data.OracleClient.OracleDataAdapter($strSQL, $OraCon)
[void]$data.Fill($dtSet)
if ($dtSet.Tables.Count -eq 0) { exit }

$ownerList = @()
foreach ($row in $dtSet.Tables[0]) {
    $ownerList += $row[0]
}

if ( -not $ownerList.Contains($args[1])) { 
    sqlplus.exe system/ora@192.168.56.102:1521/orcl01 $args[2] $args[1]
} else {
    Write-Host "Target already exists!"
}

$query = "select count(*) from "
$oraCmd = New-Object Oracle.DataAccess.Client.OracleCommand 
if ($null -ne $args[3]) {
    sqlldr.exe system/ora@192.168.56.102:1521/orcl01 $args[3]
} else {
    Write-Host "Data already exists!"
}

# .\oracle_db_sample.ps1 OBJECTS CDBC01_24 @C:\Users\linxu\Desktop\work\作業\info対照\loader\create_table.sql C:\Users\linxu\Desktop\work\作業\info対照\loader\objects_CDBC21_imp2_info4.ctl

$OraCon.close()
$OraCon.Dispose()