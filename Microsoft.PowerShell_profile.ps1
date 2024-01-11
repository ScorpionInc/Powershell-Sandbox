# Modified from source:
#https://stackoverflow.com/questions/9204829/deep-copying-a-psobject
#https://stackoverflow.com/a/62559171
function Clone-Object($InputObject){
 <#
  .SYNOPSIS
  Use the serializer to create an independent copy of an object, useful when using an object as a template
 #>
 [System.Management.Automation.PSSerializer]::Deserialize(
  [System.Management.Automation.PSSerializer]::Serialize(
   $InputObject
  )
 );
}

# Returns some properties of all files and folders as well as additional data streams(ads) as an Object.
function Get-ChildItemAll([string]$path='.\'){
 $entries = @();
 Get-ChildItem -Path "$($path)" -Force | ForEach-Object {
  $file_entry = [PSCustomObject]@{
   Mode=$_.Mode
   PSIsContainer=$_.PSIsContainer
   Target=$_.Target
   CreationTime=$_.CreationTime
   LastAccessTime=$_.LastAccessTime
   LastWriteTime=$_.LastWriteTime
   Length=$_.Length
   Name=$_.Name
   Extension=($_.Extension).Replace('.','')
  };
  $entries += $file_entry;
  Get-Item $_.FullName -Force -Stream * | Select-Object PSChildName,Stream,Length | Where-Object -Property Stream -NE ':$DATA' | Select-Object Length,PSChildName | ForEach-Object {
   $entry = Clone-Object($file_entry);
   $entry.Length = $_.Length;
   $entry.Name = $_.PSChildName;
   $entries += $entry;
  } | Out-Null;
 } | Out-Null;
 return($entries);
}

# Prints common propertied from Get-ChildItemAll results in a table format.
function ll([string]$path='.\'){(Get-ChildItemAll "$($path)") | Format-Table -Property Mode,LastWriteTime,Length,Name;}

# Add missing registry PS-Drives
New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
New-PSDrive -PSProvider Registry -Name HKCC -Root HKEY_CURRENT_CONFIG
