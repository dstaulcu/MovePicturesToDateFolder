$drawing = get-ChildItem -Path "C:\Windows\Microsoft.NET\Framework64" -recurse -Filter "*system.drawing.dll" 
if ($drawing) {
    $assemblyfile_drawing = $drawing | sort-object VersionInfo.ProductVersion -Descending | Select-Object -First 1 -ExpandProperty FullName
    Write-Host "loading assemply $assemblyfile_drawing"
    [reflection.assembly]::loadfile($assemblyfile_drawing) | Out-Null
} else {
    write-host "System.drawing assembly not available, exiting"
}

$sourcepath = "C:\Users\David\Documents\Pictures"
$destpath = "C:\Users\David\Pictures\"

$jpg = Get-ChildItem -path $sourcepath -recurse -filter *.jpg
If ($jpg) {
    foreach ($file in $jpg) {
        $foo=New-Object -TypeName system.drawing.bitmap -ArgumentList $file.fullname
        write-host $file.FullName
        $date = $null
        $date = $foo.GetPropertyItem(36867).value[0..9]
        if ($date -eq $Null) {
            $strYear = $file.LastWriteTime.Year
            $DateTaken = $file.LastWriteTime.ToString("yyyy-MM-dd")
            $DateTaken = $DateTaken -replace "-",""
        } else {
            $arYear = [Char]$date[0],[Char]$date[1],[Char]$date[2],[Char]$date[3]
            $arMonth = [Char]$date[5],[Char]$date[6]
            $arDay = [Char]$date[8],[Char]$date[9]
            $strYear = [String]::Join("",$arYear)
            $strMonth = [String]::Join("",$arMonth) 
            $strDay = [String]::Join("",$arDay)
            $DateTaken = $strYear + $strMonth + $strDay
        }
        $TargetPath = $destpath + $DateTaken
        $foo.dispose()
        If (Test-Path $TargetPath) {
            Move-Item $file.FullName -destination $TargetPath -force
        } Else {
            New-Item $TargetPath -Type Directory
            Move-Item $file.FullName -destination $TargetPath -force
        }
    }
}


# 
# Following block of text moves *.mov files
#
$mov = Get-ChildItem -path $sourcepath -recurse -filter *.mov
If ($mov) {
    foreach ($file in $mov) {
        write-host $file.FullName
        $TargetPath = $destpath + $file.LastWriteTime.ToString('yyyyMMdd')
        $foo.dispose()
        If (Test-Path $TargetPath) {
            Move-Item $file.FullName -destination $TargetPath -force
        } Else {
            New-Item $TargetPath -Type Directory
            Move-Item $file.FullName -destination $TargetPath -force
        }
    }
}



# 
# Following block of text moves *.wmv files
# 
$wmv = Get-ChildItem -path $sourcepath -recurse -filter *.wmv
If ($wmv) {
    foreach ($file in $wmv) {
        write-host $file.FullName
        $TargetPath = $destpath + $file.LastWriteTime.ToString('yyyyMMdd')
        $foo.dispose()
        If (Test-Path $TargetPath) {
            Move-Item $file.FullName -destination $TargetPath -force
        } Else {
            New-Item $TargetPath -Type Directory
            Move-Item $file.FullName -destination $TargetPath -force
        }
    }
}


# 
# Following block of text moves *.png files
# 
$png = Get-ChildItem -path $sourcepath -recurse -filter *.png
If ($png) {
    foreach ($file in $png) {
        write-host $file.FullName
        $TargetPath = $destpath + $file.LastWriteTime.ToString('yyyyMMdd')
        $foo.dispose()
        If (Test-Path $TargetPath) {
            Move-Item $file.FullName -destination $TargetPath -force
        } Else {
            New-Item $TargetPath -Type Directory
            Move-Item $file.FullName -destination $TargetPath -force
        }
    }
}

# 
# Following block of text moves *.mp4 files
# 
$mp4 = Get-ChildItem -path $sourcepath -recurse -filter *.mp4
If ($mp4) {
    foreach ($file in $mp4) {
        write-host $file.FullName
        $TargetPath = $destpath + $file.LastWriteTime.ToString('yyyyMMdd')
        $foo.dispose()
        If (Test-Path $TargetPath) {
            Move-Item $file.FullName -destination $TargetPath -force
        } Else {
            New-Item $TargetPath -Type Directory
            Move-Item $file.FullName -destination $TargetPath -force
        }
    }
}

# remove any folders which are now empty
$folders = Get-ChildItem -path $sourcepath -Recurse | ?{ $_.PSIsContainer }
foreach ($folder in $folders) {

    if ($folder.getfiles().count -eq 0) {
        Remove-Item -Path $folder.FullName
    }

    if ($folder.getfiles().count -eq 1) {
        if ($folder.GetFiles().name -eq ".picasa.ini") {
            Remove-Item -Path $folder.FullName -Force -Recurse
        }
    }


}
