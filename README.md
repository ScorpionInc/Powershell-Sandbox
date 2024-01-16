# Powershell-Sandbox
An area to save/share powershell scripts.

To edit CUCH powershell profile use:
> notepad.exe $PROFILE.CurrentUserCurrentHost

To set CUCH powershell profile use: (one-liner)
> If(!(Test-Path $profile.CurrentUserCurrentHost)){ New-Item -Path $profile.CurrentUserCurrentHost -Force }; Invoke-WebRequest https://github.com/ScorpionInc/Powershell-Sandbox/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $profile.CurrentUserCurrentHost; . $profile;
