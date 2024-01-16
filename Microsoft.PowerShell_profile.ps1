# Save the current Text Encoding settings and switch session to UTF-8.
$originalOutputEncoding = $OutputEncoding; $originalConsoleEncoding = [Console]::OutputEncoding;
try{
    $targetOutputEncoding = [System.Text.Encoding]::UTF8;
    $OutputEncoding = $targetOutputEncoding;
    [Console]::OutputEncoding = $targetOutputEncoding;
} Catch {}

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

#https://stackoverflow.com/a/25682508
function IIf($If, $Then, $Else) {
    If ($If -IsNot "Boolean") {$_ = $If}
    If ($If) {If ($Then -is "ScriptBlock") {&$Then} Else {$Then}}
    Else {If ($Else -is "ScriptBlock") {&$Else} Else {$Else}}
}

function Test-IsWindows(){
    [System.Environment]::OSVersion.Platform -ieq "Win32NT"
}
#Get current username
function Get-CurrentUsername(){
    # If Windows get from security token as environment variables can be modified.
    if(Test-IsWindows){
        # Windows Only
        $name = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name);
        $name.substring($name.LastIndexOf('\') + 1)
    } else {
        [Environment]::UserName
    }
}
Set-Alias Get-Username Get-CurrentUsername | Out-Null;

# ANSI Color Code Function(s)
$ANSIEscape = "$([char]27)";
$ANSIEnd = [string]"$ANSIEscape[0m";
enum ANSIFGColors {
    None    = 0
    Black   = 30
    Red     = 91
    Green   = 92
    Yellow  = 93
    Blue    = 94
    Magenta = 95
    Cyan    = 96
    White   = 97
}
enum ANSIBGColors {
    None    = 0
    Black   = 40
    Red     = 41
    Green   = 42
    Yellow  = 103
    Blue    = 44
    Magenta = 105
    Cyan    = 46
    White   = 107
}
# Returns ANSI Code as a String to set text color foreground and background in supporting terminal(s).
function Get-ANSIColorString([ANSIFGColors]$ForegroundColor=[ANSIFGColors]::None, [ANSIBGColors]$BackgroundColor=[ANSIBGColors]::None){
    if($ForegroundColor -eq [ANSIFGColors]::None ){ return ""; }
    $colorStr = [string]"$ANSIEscape[$($ForegroundColor.value__)";
    if($BackgroundColor -ne [ANSIBGColors]::None ){
        $colorStr += ";$($BackgroundColor.value__)";
    }
    $colorStr += "m";
    return $colorStr;
}
# Example: ConvertTo-ANSIColoredText "Text to be colored." Cyan Red
function ConvertTo-ANSIColoredText([string]$StringToColor="", [ANSIFGColors]$ForegroundColor=[ANSIFGColors]::None, [ANSIBGColors]$BackgroundColor=[ANSIBGColors]::None){
    return "$(Get-ANSIColorString $ForegroundColor $BackgroundColor)$($StringToColor)$($ANSIEnd)"
}

# Returns the count of characters in a row of the terminal(if possible).
function Get-HostUIWidth{
    # Returns count of 0 on failure.
    return([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width - 1));
}
# Converts string pattern, into a string as wide as the host UI(if possible).
function ConvertTo-HostWideString([string]$Pattern="#"){
    $UI_Width = (Get-HostUIWidth);
    $string = "";
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($UI_Width / $Pattern.Length)); $i++){
        $string = $string + $Pattern;
    }
    $remainder = $UI_Width - $string.Length;
    for($i = 0; $i -lt $remainder; $i++){
        $string = $string + $Pattern[$i];
    }
    return($string);
}
# Converts string with customizable prefix, suffix and spacer to a string centered on host UI(if possible).
function ConvertTo-HostCenteredString
{
    param([string]$Message="", [string]$Prefix="", [string]$Suffix="", [string]$Spacer=" ")
    $UI_Width         = (Get-HostUIWidth);
    $UI_HalfWidth     = ($UI_Width / 2);
    $Message_HalfWidth= ($Message.Length / 2);
    $Left_Buffer      = ($UI_HalfWidth - $Message_HalfWidth) - $Prefix.Length;
    $Right_Buffer     = ($UI_HalfWidth - $Message_HalfWidth) - $Suffix.Length;
    $string = $Prefix;
    if($Spacer.Length -ile 0){
        # Prevent divide by zero.
        $Spacer = " ";
    }
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($Left_Buffer / $Spacer.Length)); $i++)
    {
        $string = $string + "$($Spacer)";
    }
    $string = $string + "$($Message)";
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($Right_Buffer / $Spacer.Length)); $i++)
    {
        $string = $string + "$($Spacer)";
    }
    # Do Rounding offset at the end
    if($Right_Buffer -ne [Math]::Floor($Right_Buffer)){
        $string += $Spacer[0];
    }
    $string = $string + $Suffix;
    <#
    Write-Host "UIW: $($UI_Width)";#Debugging
    Write-Host "UIHW: $($UI_HalfWidth)";#Debugging
    Write-Host "MHW: $($Message_HalfWidth)";#Debugging
    Write-Host "Left: $($Left_Buffer)`t Right: $($Right_Buffer)";#Debugging
    Write-Host "Result: $($string.Length)";#Debugging
    #>
    return $string
}
# Writes lines with optional custom prefix, suffix and spacer to Host/Console.
function Write-HostCentered{
    # Variable(s)
    $Prefix = "";
    $Suffix = "";
    $Spacer = " ";
    $Lines  = @();
    # Process all function arguments
    $pargs = @();
    # Split string inputs into multiple entries by New line character(s).
    foreach($a in $args){
        if($a.GetType().Name -eq "String"){
            $mLines = $a.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries);
            foreach($l in $mLines){
                $pargs += $l.Trim();
            }
            continue;
        }
        $pargs += $a;
    }
    # Process flags being passed to specify optional settings like prefix, suffix, and spacer.
    $skip = 0;
    for($i = 0; $i -lt $pargs.Length; $i++){
        if($skip -igt 0){
            $skip = $(($skip - 1));
            continue;
        }
        if($pargs[$i] -ieq "-Prefix"){
            $skip = $(($skip + 1));
            $Prefix = "$($pargs[$(($i+1))])";
            continue;
        }
        if($pargs[$i] -ieq "-Suffix"){
            $skip = $(($skip + 1));
            $Suffix = "$($pargs[$(($i+1))])";
            continue;
        }
        if($pargs[$i] -ieq "-Spacer"){
            $skip = $(($skip + 1));
            $Spacer = "$($pargs[$(($i+1))])";
            continue;
        }
        $Lines += "$($pargs[$i])";
    }
    # Execute Task(s)
    foreach($line in $Lines){
        $nextString = (ConvertTo-HostCenteredString "$($line)" -Prefix "$($Prefix)" -Suffix "$($Suffix)" -Spacer "$($Spacer)");
        Write-Host "$($nextString)";
    }
}

# Returns array of files in the specified(or cwd) path that have non "$DATA" additional data streams(ads).
function Get-ADS{
    $entries = @();
    if($args.Count -le 0){
        $args += ".\";
    }
    foreach($path in $args){
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
    }
    return($entries);
}
# Returns some properties of all files and folders as well as their additional data streams(ads) as an Array of Objects.
function Get-ChildItemAll{
    $entries = @();
    if($args.Count -le 0){
        $args += ".\";
    }
    foreach($path in $args){
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
    }
    return($entries);
}

# Returns array of objects containing information about all File's with ADS['s] not "$DATA".
function Get-ADSRecurse(){
    $entries = @();
    if($args.Count -le 0){
        $args += ".\";
    }
    foreach($path in $args){
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
    }
    return($entries);
}
# Returns some properties of all files and folders as well as additional data streams(ads) as an Object for this path and it's subdirs.
function Get-ChildItemAllRecurse{
    # *WARNING* Can be quite memory intensive!
    $entries = @();
    $next = (Get-ChildItemAll "$($args)");
    $checkmes = New-Object System.Collections.ArrayList;
    $checkmes.AddRange($next);
    while($checkmes.Length -gt 0){
        $next = $checkmes[0];
        $checkmes.RemoveAt(0) | Out-Null;
        $entries += $next;
        if($next.IsContainer){
            #Write-Host "[DEBUG]: Get-ChildItemAllRecurse Adding children of path: '" + $next.Path + "'.";#Debugging
            $next = @(Get-ChildItemAll "$($next.Path)");
            $checkmes.AddRange($next);
        }
    }
    return $entries;
}

# Prints common propertied from Get-ChildItemAll results in a table format.
function ll{
    # Declare Variable(s)
    $isRecursive=$False;
    $paths=@();
    # Process Function Arguments / Parameters
    if($args.Count -le 0){
        $args += ".\";
    }
    foreach($a in $args){
        if($a -ieq "-r" -or $a -ieq "/r"){
            $isRecursive=$True;
            continue;
        }
        $paths += $a;
    }
    # Execute
    if($isRecursive){
        $gciar = (Get-ChildItemAllRecurse "$($paths)");
        Foreach ($i in $gciar){
            $i.Path = Resolve-Path -relative $i.Path;
        }
        $gciar | Format-Table -Property Mode,LastWriteTime,Length,Path;
    } else {
        (Get-ChildItemAll "$($paths)") | Format-Table -Property Mode,LastWriteTime,Length,Name;
    }
}

# Creates empty-file of name: $args[$i] if not exists.
function Touch-File{
    foreach($a in $args){
        If(!(Test-Path -Path "$($a)")){
			New-Item -Path "$($a)" -Force
		}
    }
}
Set-Alias touch "Touch-File"

Set-Variable -Name GET_FILEHASH_ALGOS -Value @("SHA1", "SHA256", "SHA384", "SHA512", "MACTripleDES", "MD5", "RIPEMD160") -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
function Get-FileHashes([string]$filepath, [string[]]$algos = $Global:GET_FILEHASH_ALGOS, [bool]$beQuiet = $false){
    if(-not (Test-Path $filepath)){
        return @();
    }
    foreach($algo in $algos){
        #(&{If($beQuiet){"SilentlyContinue"} Else {"Continue"}})
        Get-FileHash -Algorithm "$($algo)" -Path "$($filepath)" -ErrorAction (IIf $beQuiet SilentlyContinue Contine)
    }
}
function Get-AllFileHashes([string]$path, [string[]]$algos = $Global:GET_FILEHASH_ALGOS, [bool]$doRecursive = $false, [bool]$beQuiet = $true){
    Get-ChildItem -Force -ErrorAction (IIf $beQuiet SilentlyContinue Contine) -Path "$($path)" (IIF $doRecursive -Recurse) | ForEach-Object {
        Get-FileHashes "$($_)" ($algos) $beQuiet
    }
}

# Add missing registry PS-Drives
New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null;
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null;
New-PSDrive -PSProvider Registry -Name HKCC -Root HKEY_CURRENT_CONFIG -ErrorAction SilentlyContinue | Out-Null;

# Define and Display Profile Banner.
# Text-Art Sourced/Modified from: https://emojicombos.com/scorpion-ascii-art
$BANNER = @(
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2840,[char]0x28f4,[char]0x28f6,[char]0x28f6,[char]0x28f6,[char]0x2866,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28a0,[char]0x28ff,[char]0x28e7,[char]0x28dd,[char]0x281b,[char]0x281b,[char]0x280b,[char]0x28be,[char]0x28ff,[char]0x28e6,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28e0,[char]0x2859,[char]0x283f,[char]0x285f,[char]0x280b,[char]0x2880,[char]0x28c0,[char]0x28c0,[char]0x28cc,[char]0x28fd,[char]0x28ef,[char]0x2877,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x2801,[char]0x2810,[char]0x2809,[char]0x2808,[char]0x28bb,[char]0x28f7,[char]0x287b,[char]0x28ff,[char]0x2807,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28e9,[char]0x28f6,[char]0x28e7,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2880,[char]0x28f8,[char]0x28ff,[char]0x283f,[char]0x289b,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28ff,[char]0x28ef,[char]0x28f7,[char]0x28f6,[char]0x28e6,[char]0x28e0,[char]0x287e,[char]0x28a1,[char]0x28fe,[char]0x28bf,[char]0x287f,[char]0x28ff,[char]0x28e6,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2880,[char]0x28e0,[char]0x287f,[char]0x283b,[char]0x28c6,[char]0x28d8,[char]0x28b8,[char]0x28ff,[char]0x28fb,[char]0x28fe,[char]0x28ff,[char]0x2877,[char]0x28db,[char]0x2835,[char]0x289f,[char]0x28f1,[char]0x287e,[char]0x28fb,[char]0x28f7,[char]0x28ff,[char]0x28b6,[char]0x28e4,[char]0x28f4,[char]0x28e4,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x28f8,[char]0x281f,[char]0x28e1,[char]0x28e4,[char]0x28e4,[char]0x28ec,[char]0x28ff,[char]0x28e3,[char]0x28c5,[char]0x28ff,[char]0x287f,[char]0x28f7,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28de,[char]0x280b,[char]0x28d0,[char]0x28fb,[char]0x280f,[char]0x28dc,[char]0x281b,[char]0x28bf,[char]0x28ff,[char]0x28fd,[char]0x28f7,[char]0x28c4,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2880,[char]0x2847,[char]0x2890,[char]0x28ff,[char]0x2881,[char]0x2874,[char]0x283d,[char]0x28f7,[char]0x28fe,[char]0x287f,[char]0x283b,[char]0x28f7,[char]0x28f9,[char]0x285b,[char]0x283f,[char]0x283f,[char]0x28ed,[char]0x28dc,[char]0x285b,[char]0x2803,[char]0x2800,[char]0x2839,[char]0x2824,[char]0x2800,[char]0x2818,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28f7,[char]0x000a,
[char]0x2810,[char]0x2809,[char]0x2800,[char]0x2808,[char]0x28ff,[char]0x28b8,[char]0x28c7,[char]0x28b0,[char]0x287e,[char]0x283f,[char]0x283f,[char]0x281b,[char]0x281b,[char]0x280b,[char]0x2865,[char]0x28be,[char]0x2803,[char]0x28cd,[char]0x2809,[char]0x283f,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28f0,[char]0x28ff,[char]0x283f,[char]0x281f,[char]0x289b,[char]0x284b,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28fa,[char]0x2898,[char]0x284f,[char]0x28b8,[char]0x281f,[char]0x2800,[char]0x2890,[char]0x28ed,[char]0x28bb,[char]0x283f,[char]0x28ff,[char]0x280f,[char]0x2801,[char]0x2808,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x283f,[char]0x280b,[char]0x2800,[char]0x2880,[char]0x28fe,[char]0x2807,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2808,[char]0x2801,[char]0x2800,[char]0x28f9,[char]0x2839,[char]0x28c6,[char]0x28a0,[char]0x28ff,[char]0x28ff,[char]0x28c4,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2820,[char]0x281f,[char]0x2801,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2818,[char]0x2801,[char]0x2800,[char]0x287e,[char]0x2838,[char]0x28ff,[char]0x28df,[char]0x28ff,[char]0x28f7,[char]0x28f6,[char]0x28f6,[char]0x28e4,[char]0x28c0,[char]0x28c0,[char]0x28c0,[char]0x28c0,[char]0x28c0,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x28bb,[char]0x28b8,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x287f,[char]0x281f,[char]0x283f,[char]0x281b,[char]0x281f,[char]0x2809,[char]0x2803,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2819,[char]0x281b,[char]0x281b,[char]0x2809,[char]0x283a,[char]0x2837,[char]0x28a6,[char]0x2836,[char]0x2837,[char]0x280a,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800
);
$COMPUTER_INFO = (Get-ComputerInfo);
ConvertTo-HostWideString "#";
Write-HostCentered " " -Prefix "#" -Suffix "#"
Write-HostCentered "$($BANNER -join '')" -Prefix "#" -Suffix "#"
Write-HostCentered " " -Prefix "#" -Suffix "#"
Write-HostCentered "Welcome back, \\$([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName+"\"+(Get-Username))." -Prefix "#" -Suffix "#";
Write-HostCentered "$($COMPUTER_INFO.CsDomain) $(Get-Date)" -Prefix "#" -Suffix "#";
Write-HostCentered " " -Prefix "#" -Suffix "#"
ConvertTo-HostWideString "#";

# Add Aliases
Set-Alias netcat "ncat"
