#!powershell
# This file is NOT part of Ansible
#
# Copyright 2020, Modified By: Kani Eren <kanieren@gmail.com>
#

# WANT_JSON
# POWERSHELL_COMMON

# TODO: This module is not idempotent (it will always unzip and report change)

$ErrorActionPreference = "Stop"

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$src = Get-AnsibleParam -obj $params -name "src" -type "path" -failifempty $true
$dest = Get-AnsibleParam -obj $params -name "dest" -type "path" -failifempty $true
$filename = Get-AnsibleParam -obj $params -name "filename" -type "String" -failifempty $true
$days = Get-AnsibleParam -obj $params -name "days" -type "int" -failifempty $false

$result = @{
    changed = $false
    src = $src -replace '\$',''
}

Function Create-Zip($src, $dest, $filename) {
	try {
 		$path = $dest
		$tempPath = "C:\Windows\Temp\DataTemp"
		If(Test-path $tempPath) {Remove-item $tempPath -Recurse}
		
        if ($days -eq $null) {
           $files = Get-ChildItem -Path $src -Recurse -File
        } 
        else {
		  $result.olderthan = $days
          $days = $days*-1
          $LastWrite = (get-date).AddDays($days)
		  $files = Get-ChildItem -Path $src -Recurse -File | Where-Object {$_.LastWriteTime -le $LastWrite}     
        }
		
		If(-Not (Test-path $path)) { New-Item $path -Type Directory}
		
		
		New-Item $tempPath -Type Directory
		
		Add-Type -assembly "system.io.compression.filesystem"
		foreach($file in $files)
		{
		  Copy-Item $file.FullName -destination $tempPath
		}
		
		$zipTo = "{0}\{1}" -f $path,$filename
		If(Test-path $zipTo) {Remove-item $zipTo}
		
		[io.compression.zipfile]::CreateFromDirectory($tempPath, $zipTo)
		
		Remove-item $tempPath -Recurse
		
        $result.dest = $zipTo
		$result.changed = $true
		} catch {
			$result.msg = $($_.Exception.Message)
			Exit-Json -obj $result
		}
	}

If (-Not (Test-Path -LiteralPath $src)) {
    Fail-Json -obj $result -message "File '$src' does not exist."
}

try {
    Create-Zip -src $src -dest $dest -filename $filename
} catch {
    Fail-Json -obj $result -message "Error zipping '$src' to '$dest'!. Exception: $($_.Exception.Message)"
}

Exit-Json $result
