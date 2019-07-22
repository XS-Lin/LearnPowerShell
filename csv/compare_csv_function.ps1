function CreateScript_GRANT {
    param (
        [string]$sid,
        [string]$path_old,
        [string]$path_new
    )
    $user=@('CCOM','CEMUSR','CEUCOM','CMRUSR','EIREF','FANA','FCOM','FFICOM','FPTUSR','FREF','FUSR','OUSR','WCCUSR','WUSR')
    $target1 = Import-Csv $path_old -Encoding Default | Where-Object {$_.OWNER -in $user} | Select-Object -Property GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE
    $target2 = Import-Csv $path_new -Encoding Default | Where-Object {$_.OWNER -in $user} | Select-Object -Property GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE 
    Compare-Object -ReferenceObject $target1 -DifferenceObject $target2 | ForEach-Object -Process {
            $text += "ALTER SESSION SET CURRENT_SCHEMA=" + $_.InputObject.GRANTOR + ";`n";
            $text += "GRANT " + $_.InputObject.PRIVILEGE + " ON " + $_.InputObject.OWNER + "." + $_.InputObject.TABLE_NAME + " TO " + $_.InputObject.GRANTEE + ";`n";
        }
    return $text
}

