# ============================================================================
# fps-booster-bundle-v2.ps1
# Safe FPS Helper Bundle v2
# Windows PowerShell 5.1 / Windows 10-11
#
# Support this project:
#   PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD
#   GitHub: https://github.com/anon2k24-design
#   Sponsor: https://github.com/sponsors/anon2k24-design
# ============================================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run this script as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms

$LogPath = ".\fps-booster-v2-log.csv"
$RevertPath = ".\fps-booster-v2-revert.ps1"
$LayersPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$ChangeLog = @()

function Add-Change {
    param($Type, $Path, $Name, $OldValue, $NewValue)

    $script:ChangeLog += [PSCustomObject]@{
        Timestamp = Get-Date
        Type      = $Type
        Path      = $Path
        Name      = $Name
        OldValue  = $OldValue
        NewValue  = $NewValue
    }

    try {
        $script:ChangeLog | Export-Csv $LogPath -NoTypeInformation -Encoding UTF8
    } catch {}
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Get-RegistryValueSafe {
    param(
        [string]$Path,
        [string]$Name
    )
    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch {
        return $null
    }
}

function Set-RegistryDwordSafe {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    Ensure-RegistryPath -Path $Path
    $oldValue = Get-RegistryValueSafe -Path $Path -Name $Name
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
    Add-Change -Type "Registry" -Path $Path -Name $Name -OldValue $oldValue -NewValue $Value
}

function Set-RegistryStringSafe {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    Ensure-RegistryPath -Path $Path
    $oldValue = Get-RegistryValueSafe -Path $Path -Name $Name
    New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value $Value -Force | Out-Null
    Add-Change -Type "Registry" -Path $Path -Name $Name -OldValue $oldValue -NewValue $Value
}

function Find-GameExe {
    param([string[]]$CandidatePaths)

    foreach ($path in $CandidatePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

function Pick-ExeFile {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Select game executable"
    $dialog.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
    $dialog.Multiselect = $false

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    }

    return $null
}

function Set-FullscreenOptimizationsDisabled {
    param([string]$ExePath)

    if (-not (Test-Path $ExePath)) {
        return $false
    }

    Set-RegistryStringSafe -Path $LayersPath -Name $ExePath -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE"
    return $true
}

function Remove-FullscreenOptimizationTweak {
    param([string]$ExePath)

    if (-not (Test-Path $LayersPath)) {
        return $false
    }

    $oldValue = Get-RegistryValueSafe -Path $LayersPath -Name $ExePath
    if ($null -ne $oldValue) {
        Remove-ItemProperty -Path $LayersPath -Name $ExePath -ErrorAction SilentlyContinue
        Add-Change -Type "Registry" -Path $LayersPath -Name $ExePath -OldValue $oldValue -NewValue $null
        return $true
    }

    return $false
}

function Disable-GameBarCapture {
    Set-RegistryDwordSafe -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
    Set-RegistryDwordSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
    Set-RegistryDwordSafe -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0
    Set-RegistryDwordSafe -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "HistoricalCaptureEnabled" -Value 0
}

function Restore-GameBarDefaults {
    Set-RegistryDwordSafe -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 1
    Set-RegistryDwordSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1
    Set-RegistryDwordSafe -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1
    Set-RegistryDwordSafe -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "HistoricalCaptureEnabled" -Value 1
}

function Write-RevertScript {
    $lines = @()
    $lines += '# Auto-generated revert script for FPS Booster Bundle v2'
    $lines += '$ErrorActionPreference = "SilentlyContinue"'
    $lines += 'Write-Host "Reverting FPS Booster v2 changes..." -ForegroundColor Yellow'

    foreach ($entry in $script:ChangeLog) {
        if ($entry.Type -eq "Registry") {
            $path = $entry.Path.Replace("'", "''")
            $name = $entry.Name.Replace("'", "''")
            $old = $entry.OldValue

            if ($null -eq $old -or $old -eq "") {
                $lines += "Remove-ItemProperty -Path '$path' -Name '$name' -ErrorAction SilentlyContinue"
            } elseif ("$old" -match '^\d+$') {
                $lines += "New-ItemProperty -Path '$path' -Name '$name' -PropertyType DWord -Value $old -Force | Out-Null"
            } else {
                $escaped = "$old".Replace("'", "''")
                $lines += "New-ItemProperty -Path '$path' -Name '$name' -PropertyType String -Value '$escaped' -Force | Out-Null"
            }
        }
    }

    $lines += 'Write-Host "Revert complete." -ForegroundColor Green'
    Set-Content -Path $RevertPath -Value $lines -Encoding UTF8
}

function Show-MinecraftAdvice {
    Write-Host ""
    Write-Host "Minecraft launcher tuning:" -ForegroundColor Cyan
    Write-Host "  1. Open Minecraft Launcher" -ForegroundColor White
    Write-Host "  2. Go to Installations" -ForegroundColor White
    Write-Host "  3. Pick your profile" -ForegroundColor White
    Write-Host "  4. Open More Options" -ForegroundColor White
    Write-Host "  5. Edit JVM Arguments" -ForegroundColor White
    Write-Host ""
    Write-Host "Suggested starting point for 16 GB RAM:" -ForegroundColor Yellow
    Write-Host '  -Xms2G -Xmx4G' -ForegroundColor Green
    Write-Host ""
}

$games = @{
    "1" = @{ Name = "Apex Legends"; Paths = @(
        "C:\Program Files\EA Games\Apex Legends\apex.exe",
        "C:\Program Files (x86)\Steam\steamapps\common\Apex Legends\apex.exe",
        "D:\SteamLibrary\steamapps\common\Apex Legends\apex.exe"
    )}
    "2" = @{ Name = "Fortnite"; Paths = @(
        "C:\Program Files\Epic Games\Fortnite\FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping.exe",
        "D:\Epic Games\Fortnite\FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping.exe"
    )}
    "3" = @{ Name = "Call of Duty"; Paths = @(
        "C:\Program Files\Call of Duty\cod.exe",
        "C:\Program Files (x86)\Call of Duty\cod.exe"
    )}
    "4" = @{ Name = "Minecraft"; Paths = @() }
    "5" = @{ Name = "Dead by Daylight"; Paths = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Dead by Daylight\DeadByDaylight\Binaries\Win64\DeadByDaylight-Win64-Shipping.exe",
        "C:\Program Files\Steam\steamapps\common\Dead by Daylight\DeadByDaylight\Binaries\Win64\DeadByDaylight-Win64-Shipping.exe",
        "D:\SteamLibrary\steamapps\common\Dead by Daylight\DeadByDaylight\Binaries\Win64\DeadByDaylight-Win64-Shipping.exe"
    )}
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  FPS Booster Bundle v2" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Support this project:" -ForegroundColor Cyan
Write-Host "PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD" -ForegroundColor White
Write-Host "GitHub: https://github.com/anon2k24-design" -ForegroundColor White
Write-Host "Sponsor: https://github.com/sponsors/anon2k24-design" -ForegroundColor White
Write-Host ""
Write-Host "1. Apex Legends" -ForegroundColor White
Write-Host "2. Fortnite" -ForegroundColor White
Write-Host "3. Call of Duty" -ForegroundColor White
Write-Host "4. Minecraft" -ForegroundColor White
Write-Host "5. Dead by Daylight" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter game number (1-5)"
if (-not $games.ContainsKey($choice)) {
    Write-Host "ERROR: Invalid choice." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$selectedGame = $games[$choice]
$gameName = $selectedGame.Name
$exePath = $null

Write-Host ""
Write-Host "Selected: $gameName" -ForegroundColor Cyan

if ($gameName -eq "Minecraft") {
    Show-MinecraftAdvice
} else {
    $exePath = Find-GameExe -CandidatePaths $selectedGame.Paths

    if (-not $exePath) {
        Write-Host "Executable not found in common locations." -ForegroundColor Yellow
        $browse = Read-Host "Browse for the EXE manually? (Y/N)"
        if ($browse -match '^[Yy]') {
            $exePath = Pick-ExeFile
        }
    }

    if ($exePath) {
        Write-Host "Target EXE: $exePath" -ForegroundColor Green
        Write-Host ""
        Write-Host "1. Disable Fullscreen Optimizations" -ForegroundColor White
        Write-Host "2. Remove Fullscreen Optimization tweak" -ForegroundColor White
        Write-Host "3. Skip EXE tweak" -ForegroundColor White
        $exeAction = Read-Host "Choose EXE action (1-3)"

        switch ($exeAction) {
            "1" {
                if (Set-FullscreenOptimizationsDisabled -ExePath $exePath) {
                    Write-Host "Applied fullscreen optimization compatibility flag." -ForegroundColor Green
                } else {
                    Write-Host "Could not apply tweak." -ForegroundColor Yellow
                }
            }
            "2" {
                if (Remove-FullscreenOptimizationTweak -ExePath $exePath) {
                    Write-Host "Removed fullscreen optimization compatibility flag." -ForegroundColor Green
                } else {
                    Write-Host "No compatibility flag found to remove." -ForegroundColor Yellow
                }
            }
            default {
                Write-Host "Skipped EXE compatibility tweak." -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "No EXE selected." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Game Bar / capture options:" -ForegroundColor Cyan
Write-Host "1. Disable Game Bar capture-related settings" -ForegroundColor White
Write-Host "2. Restore Game Bar capture defaults" -ForegroundColor White
Write-Host "3. Skip" -ForegroundColor White
$gbChoice = Read-Host "Choose option (1-3)"

switch ($gbChoice) {
    "1" {
        Disable-GameBarCapture
        Write-Host "Disabled Game Bar capture-related settings." -ForegroundColor Green
    }
    "2" {
        Restore-GameBarDefaults
        Write-Host "Restored Game Bar capture defaults." -ForegroundColor Green
    }
    default {
        Write-Host "Skipped Game Bar changes." -ForegroundColor Yellow
    }
}

Write-RevertScript

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  DONE" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Log file: $LogPath" -ForegroundColor White
Write-Host "Revert file: $RevertPath" -ForegroundColor White
Write-Host ""
Write-Host "Support this project:" -ForegroundColor Cyan
Write-Host "PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD" -ForegroundColor White
Write-Host "GitHub: https://github.com/anon2k24-design" -ForegroundColor White
Write-Host "Sponsor: https://github.com/sponsors/anon2k24-design" -ForegroundColor White
Write-Host ""
Write-Host "Restart the game before testing FPS / frametime changes." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"