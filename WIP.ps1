# Create Key if it doesn't exist.
gci -Force HKCU:\Console
New-Item HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -ErrorAction SilentlyContinue
# Overwrite FaceName Property with name of our desired font.
# Lucida Console
New-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe FaceName -type STRING -value "Wingdings" -Force
# Define default values (if not set already)
New-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe FontFamily -type DWORD -value 0x00000036 -ErrorAction SilentlyContinue
New-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe FontSize -type DWORD -value 0x000c0000 -ErrorAction SilentlyContinue
New-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe FontWeight -type DWORD -value 0x00000190 -ErrorAction SilentlyContinue

# ISE Only
$psISE.Options.FontName = "Wingdings";
$psISE.Options.FontName = "Lucida Console";

# Code Sourced from: https://stackoverflow.com/a/21967566
function Get-Shortcut {
  param(
    $path = $null
  )
  $obj = New-Object -ComObject WScript.Shell
  if ($path -eq $null) {
    $pathUser = [System.Environment]::GetFolderPath('StartMenu')
    $pathCommon = $obj.SpecialFolders.Item('AllUsersStartMenu')
    $path = dir $pathUser, $pathCommon -Filter *.lnk -Recurse 
  }
  if ($path -is [string]) {
    $path = dir $path -Filter *.lnk
  }
  $path | ForEach-Object { 
    if ($_ -is [string]) {
      $_ = dir $_ -Filter *.lnk
    }
    if ($_) {
      $link = $obj.CreateShortcut($_.FullName)
      $info = @{}
      $info.Hotkey = $link.Hotkey
      $info.TargetPath = $link.TargetPath
      $info.LinkPath = $link.FullName
      $info.Arguments = $link.Arguments
      $info.Target = try {Split-Path $info.TargetPath -Leaf } catch { 'n/a'}
      $info.Link = try { Split-Path $info.LinkPath -Leaf } catch { 'n/a'}
      $info.WindowStyle = $link.WindowStyle
      $info.IconLocation = $link.IconLocation
      New-Object PSObject -Property $info
    }
  }
}

function Set-Shortcut {
  param(
  [Parameter(ValueFromPipelineByPropertyName=$true)]
  $LinkPath,
  $Hotkey,
  $IconLocation,
  $Arguments,
  $TargetPath
  )
  begin {
    $shell = New-Object -ComObject WScript.Shell
  }
  process {
    $link = $shell.CreateShortcut($LinkPath)
    $PSCmdlet.MyInvocation.BoundParameters.GetEnumerator() |
      Where-Object { $_.key -ne 'LinkPath' } |
      ForEach-Object { $link.$($_.key) = $_.value }
    $link.Save()
  }
}
