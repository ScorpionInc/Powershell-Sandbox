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

# Returns true when script is being run within the ISE environment.
function Get-IsISE(){
    return (Test-Path variable:global:psISE);
}
# Returns true when Platform is DOS-Based.
function Test-IsWindows(){
    [System.Environment]::OSVersion.Platform -ieq "Win32NT"
}
# Returns current username
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
# Reference: Get-PSReadLineOption(v5.1)
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

# Software Drawing Color Class conversion helper functions
function ConvertFrom-RGB-To-SDC([System.Byte]$r, [System.Byte]$g, [System.Byte]$b){
    # Helper Function
    return [System.Drawing.Color]::FromArgb(255, $r, $g, $b);
}
function ConvertFrom-ARGB-To-SDC([System.Byte]$a, [System.Byte]$r, [System.Byte]$g, [System.Byte]$b){
    # Helper Function
    return [System.Drawing.Color]::FromArgb($a, $r, $g, $b);
}
function ConvertFrom-SWMC-To-SDC([System.Windows.Media.Color] $color){
    # Helper Function
    #return [System.Drawing.ColorConverter]::new().ConvertFromString($color.ToString())
    return (ConvertFrom-ARGB-To-SDC $color.A $color.R $color.G $color.B);
}

# Modified from source: https://stackoverflow.com/a/25229498
function Get-ClosestConsoleColor-SDC([System.Drawing.Color] $color) {
    if ($color.GetSaturation() -lt 0.5) {
        # We have a grayish color
        Switch ([int]($color.GetBrightness() * 3.5)) {
            0{ return [ConsoleColor]::Black; }
            1{ return [ConsoleColor]::DarkGray; }
            2{ return [ConsoleColor]::Gray; }
            default{ return [ConsoleColor]::White; }
        }
    }
    $hue = [int]([Math]::Round($color.GetHue() / 60, [MidpointRounding]::AwayFromZero));
    if ($color.GetBrightness() -lt 0.4) {
        # Dark color
        Switch ($hue) {
            1{  return [ConsoleColor]::DarkYellow; }
            2{  return [ConsoleColor]::DarkGreen; }
            3{  return [ConsoleColor]::DarkCyan; }
            4{  return [ConsoleColor]::DarkBlue; }
            5{  return [ConsoleColor]::DarkMagenta; }
            default{ return [ConsoleColor]::DarkRed; }
        }
    }
    # Bright color
    Switch ($hue) {
        1{  return ConsoleColor.Yellow; }
        2{  return ConsoleColor.Green; }
        3{  return ConsoleColor.Cyan; }
        4{  return ConsoleColor.Blue; }
        5{  return ConsoleColor.Magenta; }
        default{ return ConsoleColor.Red; }
    }
}
function Get-ClosestConsoleColor-SWMC([System.Windows.Media.Color] $color) {
    # Helper Function
    return Get-ClosestConsoleColor-SDC (ConvertFrom-SWMC-To-SDC $color);
}
function Get-ClosestConsoleColor-ARGB([System.Byte]$a, [System.Byte]$r, [System.Byte]$g, [System.Byte]$b){
    # Helper Function
    return Get-ClosestConsoleColor-SDC (ConvertFrom-ARGB-To-SDC $a $r $g $b);
}
function Get-ClosestConsoleColor-RGB([System.Byte]$r, [System.Byte]$g, [System.Byte]$b){
    # Helper Function
    return Get-ClosestConsoleColor-SDC (ConvertFrom-RGB-To-SDC $r $g $b);
}
# Does argument type-checking in order to allow for basic parameter type overloading.
# Returns ConsoleColor nearest to input color.
# Returns [ConsoleColor]0 on error.
function Get-ClosestConsoleColor{
    $argc = $args.Count;
    if($argc -le 0){
        # No Arguments supplied
        Write-Host "[WARN]: Get-ClosestConsoleColor failed due to lack of parameters!";#!Debugging
        return [ConsoleColor]0;
    }elseif($argc -eq 1){
        # Handle one Argument
        if($args[0].GetType() -is [System.Drawing.Color].GetType()){
            return (Get-ClosestConsoleColor-SDC $args[0]);
        }elseif($args[0].GetType() -is [System.Windows.Media.Color].GetType()){
            return (Get-ClosestConsoleColor-SWMC $args[0]);
        }
    }elseif($argc -eq 3){
        # Handle three Arguments
        if(($args[0].GetType() -is [System.Byte].GetType()) -and ($args[1].GetType() -is [System.Byte].GetType()) -and ($args[2].GetType() -is [System.Byte].GetType())){
            return (Get-ClosestConsoleColor-RGB "$($args[0])" "$($args[1])" "$($args[2])");
        }
    }elseif($argc -eq 4){
        # Handle four Arguments
        if(($args[0].GetType() -is [System.Byte].GetType()) -and ($args[1].GetType() -is [System.Byte].GetType()) -and ($args[2].GetType() -is [System.Byte].GetType()) -and ($args[3].GetType() -is [System.Byte].GetType())){
            return (Get-ClosestConsoleColor-ARGB "$($args[0])" "$($args[1])" "$($args[2])" "$($args[3])");
        }
    }#else{
    # Handle unknown number of Argument(s)
    Write-Host "[WARN]: Get-ClosestConsoleColor failed due to either unexpected number of parameters[$($argc)] or bad type(s)!";#!Debugging
    return [ConsoleColor]0;
}

# Returns current terminal foreground color.
function Get-ForegroundColor(){
    if(Get-IsISE){
        $colorContext = $Host.PrivateData.ConsolePaneForegroundColor;
        #Write-Host "[DEBUG]: Before color conversion ISE Foreground color: $($colorContext)";#!Debugging
        $color = (Get-ClosestConsoleColor ([System.Byte]$colorContext.R) ([System.Byte]$colorContext.G) ([System.Byte]$colorContext.B));
        #Write-Host "[DEBUG]: After color conversion ISE Foreground color: $($color)";#!Debugging
        return $color;
    } else {
        $color = (Get-Host).UI.RawUI.ForegroundColor;
        if($color -lt 0){
            return [System.Console]::ForegroundColor;
        }
        return $color;
    }
}
# Returns current terminal background color.
function Get-BackgroundColor(){
    if(Get-IsISE){
        $colorContext = $Host.PrivateData.ConsolePaneBackgroundColor;
        #Write-Host "[DEBUG]: Before color conversion ISE Background color: $($colorContext)";#!Debugging
        $color = (Get-ClosestConsoleColor ([System.Byte]$colorContext.R) ([System.Byte]$colorContext.G) ([System.Byte]$colorContext.B));
        #Write-Host "[DEBUG]: After color conversion ISE Background color: $($color)";#!Debugging
        return $color;
    } else {
        $color = (Get-Host).UI.RawUI.BackgroundColor;
        if($color -lt 0){
            return [System.Console]::BackgroundColor;
        }
        return $color;
    }
}

# Saw many implementations for something like this but decided to roll my own.
# e.g. Write-HostColorsString "Johnson&fb& && &fb&John's Sons'&b&" -FGColors @("Green", "Yellow") -BGColors @("Black", "DarkBlue", "DarkRed")
Set-Variable -Name CONSOLECOLOR_VALUES -Value ([ConsoleColor]::GetValues([ConsoleColor])) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name CONSOLE_DEFAULT_FOREGROUND -Value ([ConsoleColor]::White) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
Set-Variable -Name CONSOLE_DEFAULT_BACKGROUND -Value ([ConsoleColor]::DarkBlue) -Option Constant -Scope Global -Force -ErrorAction SilentlyContinue;
function Write-HostColorsString([string[]]$Text, [ConsoleColor[]]$FGColors = @($Global:CONSOLE_DEFAULT_FOREGROUND), [ConsoleColor[]]$BGColors = @($Global:CONSOLE_DEFAULT_BACKGROUND), [char]$FGMarker = 'f', [char]$BGMarker = 'b', [char]$ColorDelimiter = '&'){
    $blocks = @();
    if($ColorDelimiter.Length -le 0){
        Write-Error "Write-HostColorsString is missing required value for character $ColorDelimiter.";#!Debugging
        return $Text;
    }
    foreach($line in $Text){
        if($line.Length -le 0){
            continue;
        }
        $split_lines = $line.split("$($ColorDelimiter)");
        for($s = 0; $s -lt $split_lines.Count; $s++){
            if(($s -le 0) -and ($split_lines[$s].Length -le 0)){
                # Skip First empty block on each line.
                # this is to catch entries with markers at the very beginning.
                # e.g. &f&String
                continue;
            }
            if(($s -ge ($split_lines.Count - 1)) -and ($split_lines[$s].Length -le 0)){
                # Skip Last empty block on each line.
                # this is to catch entries with markers at the very end.
                # e.g. String&f&
                continue;
            }
            $blocks += $split_lines[$s];
        }
    }
    if($FGMarker -eq $BGMarker){
        Write-Error "Write-HostColorsString requires $FGMarker and $BGMarker to be unique characters.";#!Debugging
        return $Text;
    }
	if($FGColors.Count -le 0){
		$currentFG = (Get-ForegroundColor)
	} else {
		$currentFG = $FGColors[0];
	}
	if($BGColors.Count -le 0){
		$currentBG = (Get-BackgroundColor)
	} else {
		$currentBG = $BGColors[0];
	}
    for($b = 0; $b -lt $blocks.Count; $b++){
        $wasBlockAValidMarker = $true
        foreach($char in $blocks[$b].ToCharArray()){
            if(($char -ne $FGMarker) -and ($char -ne $BGMarker)){
                $wasBlockAValidMarker = $false;
                break;
            }
        }
        if($blocks[$b].Length -le 0){
            $wasBlockAValidMarker = $false;
            $blocks[$b] = "$($ColorDelimiter)";
        }
        if($wasBlockAValidMarker){
            # Process Marker
            foreach($char in $blocks[$b].ToCharArray()){
                if($char -eq $FGMarker){
                    if($FGColors.Count -le 0){ continue; }
                    $currentIndex = $FGColors.IndexOf($currentFG);
                    if(($currentIndex -lt 0) -or ($currentIndex -ge $(($FGColors.Count - 1)))){
                        $currentFG = $FGColors[0];
                    } else {
                        $currentFG = $FGColors[$(($currentIndex + 1))];
                    }
                }elseif($char -eq $BGMarker){
                    if($BGColors.Count -le 0){ continue; }
                    $currentIndex = $BGColors.IndexOf($currentBG);
                    if(($currentIndex -lt 0) -or ($currentIndex -ge ($BGColors.Count - 1))){
                        $currentBG = $BGColors[0];
                    } else {
                        $currentBG = $BGColors[$(($currentIndex + 1))];
                    }
                }else{
                    #How did you get here?!?
                    break;
                }
            }
            continue;
        } else {
            # Output Text Block
            $hasMoreBlocks = ($(($b + 1)) -lt $blocks.Count);
            if($hasMoreBlocks){
                Write-Host -ForegroundColor "$($currentFG)" -BackgroundColor "$($currentBG)" -Separator '' -NoNewline $blocks[$b]
            }else{
                Write-Host -ForegroundColor "$($currentFG)" -BackgroundColor "$($currentBG)" -Separator '' $blocks[$b]
            }
        }
    }
}
# Returns the length of the Text without color markers.
# e.g. Get-ColorsStringLength "Johnson&fb& && &fb&John's Sons'&b&"
function Get-ColorsStringLength([string[]]$Text = @(), [char]$FGMarker = 'f', [char]$BGMarker = 'b', [char]$ColorDelimiter = '&'){
    $blocks = @();
    $counter = 0;
    foreach($line in $Text){
        $line_length = $line.ToCharArray().Length;
        if(($ColorDelimiter.Length -le 0) -or ($line_length -le 0)) {
            $counter = $(($counter + $line_length));
            continue;
        }
        $split_lines = $line.split("$($ColorDelimiter)");
        foreach($sline in $split_lines){
            if($sline.Length -le 0){
                continue;
            }
            $blocks += $sline;
        }
    }
    if(($ColorDelimiter.Length -le 0) -or ($FGMarker -eq $BGMarker)) {
        return $counter;
    }
    for($b = 0; $b -lt $blocks.Count; $b++){
        $wasBlockAValidMarker = $true;
        foreach($char in $blocks[$b].ToCharArray()){
            if(($char -ne $FGMarker) -and ($char -ne $BGMarker)){
                $wasBlockAValidMarker = $false;
                break;
            }
        }
        if($blocks[$b].Length -le 0){
            $wasBlockAValidMarker = $false;
            $blocks[$b] = "$($ColorDelimiter)";
        }
        if($wasBlockAValidMarker){
            # Ignore Marker(s)
        } else {
            # Output Text Block
            $counter = $(($counter + $blocks[$b].Length));
        }
    }
    return $counter;
}

# Returns the count of characters in a row of the terminal(if possible).
function Get-HostUIWidth{
    # Returns count of 0 on failure.
    return([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width - 1));
}
# Converts string pattern, into a string as wide as the host UI(if possible).
function ConvertTo-HostWideString([string]$Pattern="#", [char]$FGMarker = 'f', [char]$BGMarker = 'b', [char]$ColorDelimiter = '&'){
    $UI_Width = (Get-HostUIWidth);
    $Pattern_Length = (Get-ColorsStringLength -FGMarker $FGMarker -BGMarker $BGMarker -ColorDelimiter $ColorDelimiter -Text $Pattern);
    $string = "";
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($UI_Width / $Pattern_Length)); $i++){
        $string = $string + $Pattern;
    }
    $remainder = $UI_Width - $string.Length;
    for($i = 0; $i -lt $remainder; $i++){
        $string = $string + $Pattern[$i];
    }
    return($string);
}
# Converts string with customizable prefix, suffix and spacer to a string centered on host UI(if possible).
function ConvertTo-HostCenteredString([string]$Message="", [string]$Prefix = "", [string]$Suffix = "", [string]$Spacer = (""+[char]0x2800), [char]$FGMarker = 'f', [char]$BGMarker = 'b', [char]$ColorDelimiter = '&')
{
    $UI_Width         = (Get-HostUIWidth);
    $UI_HalfWidth     = ($UI_Width / 2);
    $Message_Width    = (Get-ColorsStringLength -FGMarker $FGMarker -BGMarker $BGMarker -ColorDelimiter $ColorDelimiter -Text $Message);
    $Message_HalfWidth= ($Message_Width / 2);
    $Prefix_Width     = (Get-ColorsStringLength -FGMarker $FGMarker -BGMarker $BGMarker -ColorDelimiter $ColorDelimiter -Text $Prefix);
    $Left_Buffer      = ($UI_HalfWidth - $Message_HalfWidth) - $Prefix_Width;
    $Suffix_Width     = (Get-ColorsStringLength -FGMarker $FGMarker -BGMarker $BGMarker -ColorDelimiter $ColorDelimiter -Text $Suffix);
    $Right_Buffer     = ($UI_HalfWidth - $Message_HalfWidth) - $Suffix_Width;
    $Spacer_Width     = (Get-ColorsStringLength -FGMarker $FGMarker -BGMarker $BGMarker -ColorDelimiter $ColorDelimiter -Text $Spacer);
    $string = $Prefix;
    if($Spacer.Length -ile 0){
        # Prevent divide by zero.
        $Spacer = (""+[char]0x2800);
    }
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($Left_Buffer / $Spacer_Width)); $i++)
    {
        $string = $string + "$($Spacer)";
    }
    $string = ($string + "$($Message)");
    for($i = 0; $i -lt [Math]::Max(0, [Math]::Floor($Right_Buffer / $Spacer_Width)); $i++)
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
    Write-Host "Message: '$($Message)'[$($Message.Length)].";#Debugging
    Write-Host "MW: $($Message_Width)";#Debugging
    Write-Host "MHW: $($Message_HalfWidth)";#Debugging
    Write-Host "PW: $($Prefix_Width)`t SW: $($Suffix_Width) `t SS: $($Spacer_Width)";#Debugging
    Write-Host "Left: $($Left_Buffer)`t Right: $($Right_Buffer)";#Debugging
    Write-Host "(PW + Left + MW + Right + SW) Result: $($string.Length)";#Debugging
    #>
    return $string
}
# Writes lines with optional custom prefix, suffix and spacer to Host/Console.
function Write-HostCentered([string]$Prefix = "", [string]$Suffix = "", [string]$Spacer = (""+[char]0x2800), [ConsoleColor[]]$FGColors = @($Global:CONSOLE_DEFAULT_FOREGROUND), [ConsoleColor[]]$BGColors = @($Global:CONSOLE_DEFAULT_BACKGROUND), [char]$FGMarker = 'f', [char]$BGMarker = 'b', [char]$ColorDelimiter = '&', [string[]]$Lines = @()){
    # Pre-processing
    $Processed_Lines = @();
    # Split string inputs into multiple entries by NewLine character(s).
    foreach($a in $Lines){
        if($a.GetType().Name -eq "String"){
            $mLines = $a.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries);
            foreach($l in $mLines){
                $Processed_Lines += $l.Trim();
            }
            continue;
        }
        $Processed_Lines += $a;
    }
    # Execute Task(s)
    foreach($line in $Processed_Lines){
        $nextString = (ConvertTo-HostCenteredString -Message "$($line)" -Prefix "$($Prefix)" -Suffix "$($Suffix)" -Spacer "$($Spacer)" -FGMarker "$($FGMarker)" -BGMarker "$($BGMarker)" -ColorDelimiter "$($ColorDelimiter)");
        Write-HostColorsString -Text "$($nextString)" -FGColors ($FGColors) -BGColors ($BGColors) -FGMarker "$($FGMarker)" -BGMarker "$($BGMarker)" -ColorDelimiter "$($ColorDelimiter)";
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
function Write-HostProfileBanner(){
    # Text-Art Sourced/Modified from: https://emojicombos.com/scorpion-ascii-art
    $BANNER = @(
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2840,[char]0x28f4,[char]0x28f6,[char]0x28f6,[char]0x28f6,[char]0x2866,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28a0,[char]0x28ff,[char]0x28e7,[char]0x28dd,[char]0x281b,[char]0x281b,[char]0x280b,[char]0x28be,[char]0x28ff,[char]0x28e6,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28e0,[char]0x2859,[char]0x283f,[char]0x285f,[char]0x280b,"&fff&",[char]0x2880,[char]0x28c0,"&ff&",[char]0x28c0,[char]0x28cc,[char]0x28fd,[char]0x28ef,[char]0x2877,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x2801,"&ff&",[char]0x2810,"&f&",[char]0x2809,[char]0x2808,"&ff&",[char]0x28bb,[char]0x28f7,[char]0x287b,[char]0x28ff,[char]0x2807,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28e9,[char]0x28f6,[char]0x28e7,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2880,[char]0x28f8,[char]0x28ff,[char]0x283f,[char]0x289b,[char]0x2840,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28ff,[char]0x28ef,[char]0x28f7,[char]0x28f6,[char]0x28e6,[char]0x28e0,[char]0x287e,[char]0x28a1,[char]0x28fe,[char]0x28bf,[char]0x287f,[char]0x28ff,[char]0x28e6,[char]0x2840,"&ffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2880,[char]0x28e0,[char]0x287f,[char]0x283b,[char]0x28c6,[char]0x28d8,[char]0x28b8,[char]0x28ff,[char]0x28fb,[char]0x28fe,[char]0x28ff,[char]0x2877,[char]0x28db,[char]0x2835,[char]0x289f,[char]0x28f1,[char]0x287e,[char]0x28fb,[char]0x28f7,[char]0x28ff,[char]0x28b6,[char]0x28e4,[char]0x28f4,[char]0x28e4,"&fffffffff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,"&f&",[char]0x28f8,[char]0x281f,[char]0x28e1,[char]0x28e4,[char]0x28e4,[char]0x28ec,[char]0x28ff,[char]0x28e3,[char]0x28c5,[char]0x28ff,[char]0x287f,[char]0x28f7,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28de,[char]0x280b,[char]0x28d0,[char]0x28fb,[char]0x280f,[char]0x28dc,[char]0x281b,[char]0x28bf,[char]0x28ff,[char]0x28fd,[char]0x28f7,[char]0x28c4,"&ffff&",[char]0x2800,[char]0x000a,
        [char]0x2800,"&f&",[char]0x2880,[char]0x2847,[char]0x2890,[char]0x28ff,[char]0x2881,[char]0x2874,[char]0x283d,[char]0x28f7,[char]0x28fe,[char]0x287f,[char]0x283b,[char]0x28f7,[char]0x28f9,[char]0x285b,[char]0x283f,[char]0x283f,[char]0x28ed,[char]0x28dc,[char]0x285b,[char]0x2803,[char]0x2800,[char]0x2839,[char]0x2824,[char]0x2800,[char]0x2818,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28f7,"&ffff&",[char]0x000a,
        "&f&",[char]0x2810,[char]0x2809,[char]0x2800,[char]0x2808,[char]0x28ff,[char]0x28b8,[char]0x28c7,[char]0x28b0,[char]0x287e,[char]0x283f,[char]0x283f,[char]0x281b,[char]0x281b,[char]0x280b,[char]0x2865,[char]0x28be,[char]0x2803,[char]0x28cd,[char]0x2809,[char]0x283f,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28f0,[char]0x28ff,[char]0x283f,[char]0x281f,[char]0x289b,[char]0x284b,"&fff&",[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28fa,[char]0x2898,[char]0x284f,[char]0x28b8,[char]0x281f,[char]0x2800,[char]0x2890,[char]0x28ed,[char]0x28bb,[char]0x283f,[char]0x28ff,[char]0x280f,[char]0x2801,[char]0x2808,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x283f,[char]0x280b,[char]0x2800,[char]0x2880,[char]0x28fe,[char]0x2807,"&fff&",[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2808,[char]0x2801,[char]0x2800,[char]0x28f9,[char]0x2839,[char]0x28c6,[char]0x28a0,[char]0x28ff,[char]0x28ff,[char]0x28c4,[char]0x2840,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2820,[char]0x281f,[char]0x2801,"&fff&",[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2818,[char]0x2801,[char]0x2800,[char]0x287e,[char]0x2838,[char]0x28ff,[char]0x28df,[char]0x28ff,[char]0x28f7,[char]0x28f6,[char]0x28f6,[char]0x28e4,"&f&",[char]0x28c0,[char]0x28c0,[char]0x28c0,[char]0x28c0,[char]0x28c0,"&fff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x28bb,[char]0x28b8,[char]0x28ff,[char]0x28ff,[char]0x28ff,[char]0x28ff,"&f&",[char]0x287f,[char]0x281f,[char]0x283f,[char]0x281b,[char]0x281f,[char]0x2809,[char]0x2803,"&fff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x000a,
        [char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,"&f&",[char]0x2819,[char]0x281b,[char]0x281b,[char]0x2809,"&f&",[char]0x283a,[char]0x2837,[char]0x28a6,[char]0x2836,[char]0x2837,[char]0x280a,"&fff&",[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800,[char]0x2800
    );
    $COMPUTER_INFO = (Get-ComputerInfo);
    $BANNER_BORDER = "#";
    $BANNER_FOREGROUND_PALETTE = @("White","Yellow","DarkYellow","Red","DarkRed");
    $BANNER_BACKGROUND_PALETTE = @("Black");
    $BANNER_HWS = (ConvertTo-HostWideString $BANNER_BORDER);
    Write-Host -ForegroundColor $BANNER_FOREGROUND_PALETTE[0] -BackgroundColor $BANNER_BACKGROUND_PALETTE[0] $BANNER_HWS;
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines " ";
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines "$($BANNER -join '')";
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines " ";
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines "Welcome back, \\$([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName+"\"+(Get-Username)).";
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines "$($COMPUTER_INFO.CsDomain) $(Get-Date)";
    Write-HostCentered -Prefix $BANNER_BORDER -Suffix $BANNER_BORDER -FGColors ($BANNER_FOREGROUND_PALETTE) -BGColors ($BANNER_BACKGROUND_PALETTE) -Lines " ";
    Write-Host -ForegroundColor $BANNER_FOREGROUND_PALETTE[0] -BackgroundColor $BANNER_BACKGROUND_PALETTE[0] $BANNER_HWS;
}
Write-HostProfileBanner;

# Add Aliases
Set-Alias netcat "ncat"
Set-Alias unzip "Expand-Archive"
