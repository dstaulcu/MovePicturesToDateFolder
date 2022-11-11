function Read-FirstBytes {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('FullName', 'FilePath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$Path,        
        
        [Parameter(Mandatory=$true, Position = 1)]
        [int]$Bytes,

        [ValidateSet('ByteArray', 'HexString', 'Base64')]
        [string]$As = 'ByteArray'
    )
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $length = [math]::Min([math]::Abs($Bytes), $stream.Length)
        $buffer = [byte[]]::new($length)
        $null   = $stream.Read($buffer, 0, $length)
        switch ($As) {
            'HexString' { ($buffer | ForEach-Object { "{0:x2}" -f $_ }) -join '' ; break }
            'Base64'    { [Convert]::ToBase64String($buffer) ; break }
            default     { ,$buffer }
        }
    }
    catch { throw }
    finally { $stream.Dispose() }
}

function Read-LastBytes {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias('FullName', 'FilePath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string]$Path,        
        
        [Parameter(Mandatory=$true, Position = 1)]
        [int]$Bytes,

        [ValidateSet('ByteArray', 'HexString', 'Base64')]
        [string]$As = 'ByteArray'
    )
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $length = [math]::Min([math]::Abs($Bytes), $stream.Length)
        $null   = $stream.Seek(-$length, 'End')
        $buffer = for ($i = 0; $i -lt $length; $i++) { $stream.ReadByte() }
        switch ($As) {
            'HexString' { ($buffer | ForEach-Object { "{0:x2}" -f $_ }) -join '' ; break }
            'Base64'    { [Convert]::ToBase64String($buffer) ; break }
            default     { ,[Byte[]]$buffer }
        }
    }
    catch { throw }
    finally { $stream.Dispose() }
}

function get-stringhash
{   

    param($string)
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($string)
    $writer.Flush()
    $stringAsStream.Position = 0
    return Get-FileHash -Algorithm SHA1 -InputStream $stringAsStream | Select-Object -ExpandProperty Hash
}


# $file_path = 'C:\Users\david\documents'  
$file_path = 'C:\Users\david\pictures'

$files = Get-ChildItem -File -Recurse -Path $file_path

$collection = New-Object System.Collections.ArrayList

foreach ($file in $files) {

    $begin = Read-FirstBytes -Path $file.FullName -Bytes 48    # take the first 50 bytes
    $end   = Read-LastBytes -Path $file.FullName -Bytes 1000

    $stringhash = get-stringhash -string $end

    $Algorithm = 'MD5'
    $hash  = [Security.Cryptography.HashAlgorithm]::Create($Algorithm)
    $custom_hash = $hash.ComputeHash($begin + $end)

    $custom_hash = ($custom_hash  | ForEach-Object { "{0:x2}" -f $_ }) -join ''

    $collection.Add(
        [PSCustomObject]@{
            fullname = $file.FullName
            name = $file.Name
            extension = $file.Extension
            size = $file.Length
            custom_hash =  $custom_hash }) | Out-Null
   

}

foreach ($item in $collection | Group-Object -Property custom_hash, size, extension | ?{$_.count -ne 1}) {
    write-host "files sharing custom_hash $($item.Name):"

    $counter = 0
    foreach ($member in $item.group) {
        $counter++
        if ($counter -eq 1) {
            write-host "-$($member.fullname) has size $($member.size) and extension $($member.extension). Keep"
        } else {
            write-host "-$($member.fullname) has size $($member.size) and extension $($member.extension). Delete"
            remove-item -Path $member.fullname -WhatIf
        }
    }
}

