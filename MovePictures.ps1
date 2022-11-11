$SourceDir = "C:\Apps\Pictures"
$DestParentDir = "C:\Users\david\Pictures"

$Files = Get-ChildItem -Path $SourceDir -Recurse -File -Exclude "*.ps1" | Sort-Object -Property LastWriteTime

$RandomPrefix = Get-Random -Minimum 100 -Maximum 999

foreach ($File in $Files) {

    write-host "working on file $($file.fullname)..."

    $DateTaken = $file.LastWriteTime.ToString("yyyy-MM")

    $DestDir = "$($DestParentDir)\$($DateTaken)"
    if (!(Test-Path -Path $DestDir)) {
        new-item -ItemType Directory -Path $DestDir | Out-Null
    }
    
    $FileCount = (Get-ChildItem -Path $DestDir -File).count
    $NewFileName = '{0:d4}' -f ($FileCount + 1)
    $NewFileName += "$($file.Extension)"

    move-item -Path $file.FullName -Destination "$($DestDir)\$($RandomPrefix)-$($NewFileName)"

}
