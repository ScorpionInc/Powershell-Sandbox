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

# Returns array of files in the specified(or cwd) path that have non "$DATA" additional data streams(ads).
function Get-ADS([string]$path='.\'){
    $entries = @();
    Get-ChildItem -Path "$($path)" -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $file_entry = [PSCustomObject]@{
            Mode=$_.Mode
            IsContainer=$_.PSIsContainer
            Target=$_.Target
            CreationTime=$_.CreationTime
            LastAccessTime=$_.LastAccessTime
            LastWriteTime=$_.LastWriteTime
            Length=$_.Length
            Path=$_.PSPath
            Name=$_.Name
            Extension=($_.Extension).Replace('.','')
        };
        Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue | Select-Object PSChildName,Stream,Length | Where-Object -Property Stream -NE ':$DATA' | Select-Object Length,PSChildName | ForEach-Object {
            $entry = Clone-Object($file_entry);
            $entry.Length = $_.Length;
            $entry.Name = $_.PSChildName;
            $entries += ($entry);
        } | Out-Null;
    } | Out-Null;
    return($entries);
}
# Returns some properties of all files and folders as well as their additional data streams(ads) as an Array of Objects.
function Get-ChildItemAll([string]$path='.\'){
 $entries = @();
 Get-ChildItem -Path "$($path)" -Force -ErrorAction SilentlyContinue | ForEach-Object {
  $file_entry = [PSCustomObject]@{
   Mode=$_.Mode
   IsContainer=$_.PSIsContainer
   Target=$_.Target
   CreationTime=$_.CreationTime
   LastAccessTime=$_.LastAccessTime
   LastWriteTime=$_.LastWriteTime
   Length=$_.Length
   Path=$_.PSPath
   Name=$_.Name
   Extension=($_.Extension).Replace('.','')
  };
  $entries += ($file_entry);
  Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue | Select-Object PSChildName,Stream,Length | Where-Object -Property Stream -NE ':$DATA' | Select-Object Length,PSChildName | ForEach-Object {
   $entry = Clone-Object($file_entry);
   $entry.Length = $_.Length;
   $entry.Name = $_.PSChildName;
   $entries += ($entry);
  } | Out-Null;
 } | Out-Null;
 return($entries);
}
# Returns array of objects containing information about all File's with ADS['s] not "$DATA".
function Get-ADSRecurse([string]$path='.\'){
    $entries = @();
    Get-ChildItem -Path "$($path)" -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $file_entry = [PSCustomObject]@{
            Mode=$_.Mode
            IsContainer=$_.PSIsContainer
            Target=$_.Target
            CreationTime=$_.CreationTime
            LastAccessTime=$_.LastAccessTime
            LastWriteTime=$_.LastWriteTime
            Length=$_.Length
            Path=$_.PSPath
            Name=$_.Name
            Extension=($_.Extension).Replace('.','')
        };
        Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue | Select-Object PSChildName,Stream,Length | Where-Object -Property Stream -NE ':$DATA' | Select-Object Length,PSChildName | ForEach-Object {
            $entry = Clone-Object($file_entry);
            $entry.Length = $_.Length;
            $entry.Name = $_.PSChildName;
            $entries += ($entry);
        } | Out-Null;
    } | Out-Null;
    return($entries);
}
# Returns some properties of all files and folders as well as additional data streams(ads) as an Object for this path and it's subdirs.
function Get-ChildItemAllRecurse([string]$path='.\'){
    # *WARNING* Can be memory intensive!
    $entries = @();
    $next = (Get-ChildItemAll $path);
    $checkmes = New-Object System.Collections.ArrayList;
    $checkmes.AddRange($next);
    while($checkmes.Length -gt 0){
        $next = $checkmes[0];
        $checkmes.RemoveAt(0) | Out-Null;
        $entries += $next;
        if($next.IsContainer){
            #Write-Host "[DEBUG]: Get-ChildItemAllRecurse Adding children of path: '" + $next.Path + "'.";#Debugging
            $next = @(Get-ChildItemAll ($next.Path));
            $checkmes.AddRange($next);
        }
    }
    return $entries;
}

# Prints common propertied from Get-ChildItemAll results in a table format.
function ll([string]$path='.\'){(Get-ChildItemAll "$($path)") | Format-Table -Property Mode,LastWriteTime,Length,Name;}
function llr([string]$path='.\'){
    $gciar = (Get-ChildItemAllRecurse "$($path)");
    Foreach ($i in $gciar){
        $i.Path = Resolve-Path -relative $i.Path;
    }
    $gciar | Format-Table -Property Mode,LastWriteTime,Length,Path;
}

# Add missing registry PS-Drives
New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null;
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null;
New-PSDrive -PSProvider Registry -Name HKCC -Root HKEY_CURRENT_CONFIG -ErrorAction SilentlyContinue | Out-Null;
