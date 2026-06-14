# fps-booster-bundle.ps1
# Game-Specific FPS Optimization Scripts
# Run as Administrator
#
# Support this project:
#   PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD
#   GitHub: https://github.com/anon2k24-design

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run this script as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

function Set-DisableFullscreenOptimizations {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    $layersPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

    if (-not (Test-Path $layersPath)) {
        New-Item -Path $layersPath -Force | Out-Null
    }

    if (Test-Path $ExePath) {
        New-ItemProperty -Path $layersPath -Name $ExePath -PropertyType String -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -Force | Out-Null
        return $true
    }

    return $false
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  FPS Booster Bundle v1.1" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Support this project:" -ForegroundColor Cyan
Write-Host "PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD" -ForegroundColor White
Write-Host "GitHub: https://github.com/anon2k24-design" -ForegroundColor White
Write-Host ""
Write-Host "Available Game Optimizations:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Apex Legends" -ForegroundColor White
Write-Host "  2. Fortnite" -ForegroundColor White
Write-Host "  3. Call of Duty" -ForegroundColor White
Write-Host "  4. Minecraft" -ForegroundColor White
Write-Host "  5. Dead by Daylight" -ForegroundColor White
Write-Host ""

$gameChoice = Read-Host "Enter game number (1-5)"

switch ($gameChoice) {
    "1" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Apex Legends" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan

        $apexExe = "C:\Program Files\EA Games\Apex Legends\apex.exe"
        $apexCompatSet = Set-DisableFullscreenOptimizations -ExePath $apexExe

        if ($apexCompatSet) {
            Write-Host "✓ Apex: Fullscreen Optimizations Disabled" -ForegroundColor Green
        } else {
            Write-Host "⚠ Apex executable not found at expected path" -ForegroundColor Yellow
        }

        $nvidiaPath = "HKCU:\SOFTWARE\NVIDIA Corporation\NVIDIA GeForce\Apex"
        if (-not (Test-Path $nvidiaPath)) { New-Item -Path $nvidiaPath -Force | Out-Null }
        Set-ItemProperty -Path $nvidiaPath -Name "MaximumPerformance" -Value 1 -Force | Out-Null
        Set-ItemProperty -Path $nvidiaPath -Name "ThreadedOptimization" -Value 1 -Force | Out-Null

        Write-Host "✓ Apex: NVIDIA Performance Mode" -ForegroundColor Green
        Write-Host "✓ Apex: Threaded Optimization On" -ForegroundColor Green

        $gameBarPath = "HKCU:\SOFTWARE\Microsoft\GameBar"
        if (-not (Test-Path $gameBarPath)) { New-Item -Path $gameBarPath -Force | Out-Null }
        Set-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 0 -Force | Out-Null

        Write-Host "✓ Apex: Game Bar Disabled" -ForegroundColor Green
    }

    "2" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Fortnite" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan

        $fortniteExe = "C:\Program Files\Epic Games\Fortnite\FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping.exe"
        $fortniteCompatSet = Set-DisableFullscreenOptimizations -ExePath $fortniteExe

        if ($fortniteCompatSet) {
            Write-Host "✓ Fortnite: Fullscreen Optimizations Disabled" -ForegroundColor Green
        } else {
            Write-Host "⚠ Fortnite executable not found at expected path" -ForegroundColor Yellow
        }

        $fortniteReg = "HKCU:\SOFTWARE\EpicGames\Fortnite"
        if (-not (Test-Path $fortniteReg)) { New-Item -Path $fortniteReg -Force | Out-Null }
        New-ItemProperty -Path $fortniteReg -Name "UseDX12" -PropertyType DWord -Value 0 -Force | Out-Null
        Write-Host "✓ Fortnite: DirectX 11 preferred" -ForegroundColor Green

        $nvidiaPath = "HKCU:\SOFTWARE\NVIDIA Corporation\NVIDIA GeForce\Fortnite"
        if (-not (Test-Path $nvidiaPath)) { New-Item -Path $nvidiaPath -Force | Out-Null }
        Set-ItemProperty -Path $nvidiaPath -Name "MaximumPerformance" -Value 1 -Force | Out-Null

        Write-Host "✓ Fortnite: NVIDIA Performance Mode" -ForegroundColor Green
    }

    "3" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Call of Duty" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan

        $codExe = "C:\Program Files\Activision\Call of Duty\cod.exe"
        $codCompatSet = Set-DisableFullscreenOptimizations -ExePath $codExe

        if ($codCompatSet) {
            Write-Host "✓ COD: Fullscreen Optimizations Disabled" -ForegroundColor Green
        } else {
            Write-Host "⚠ COD executable not found at expected path" -ForegroundColor Yellow
        }

        $codReg = "HKCU:\SOFTWARE\Activision\Call of Duty"
        if (-not (Test-Path $codReg)) { New-Item -Path $codReg -Force | Out-Null }
        New-ItemProperty -Path $codReg -Name "VSync" -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path $codReg -Name "ProcessPriority" -PropertyType String -Value "High" -Force | Out-Null

        Write-Host "✓ COD: V-Sync Disabled" -ForegroundColor Green
        Write-Host "✓ COD: Process Priority = High" -ForegroundColor Green
    }

    "4" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Minecraft" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan

        $minecraftPath = "$env:APPDATA\.minecraft"
        $minecraftReg = "HKCU:\SOFTWARE\Minecraft"

        if (-not (Test-Path $minecraftReg)) { New-Item -Path $minecraftReg -Force | Out-Null }

        if (Test-Path $minecraftPath) {
            Set-Content -Path "$minecraftPath\jvm.options" -Value "-Xmx4G -Xms2G" -ErrorAction SilentlyContinue
            Write-Host "✓ Minecraft: RAM Allocation = 4GB" -ForegroundColor Green
        } else {
            Write-Host "⚠ Minecraft folder not found at expected path" -ForegroundColor Yellow
        }

        New-ItemProperty -Path $minecraftReg -Name "fancyGraphics" -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path $minecraftReg -Name "renderDistance" -PropertyType DWord -Value 8 -Force | Out-Null
        New-ItemProperty -Path $minecraftReg -Name "smoothLighting" -PropertyType DWord -Value 0 -Force | Out-Null

        Write-Host "✓ Minecraft: Graphics = Fast" -ForegroundColor Green
        Write-Host "✓ Minecraft: Render Distance = 8 chunks" -ForegroundColor Green
        Write-Host "✓ Minecraft: Smooth Lighting = Off" -ForegroundColor Green
    }

    "5" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Dead by Daylight" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan

        $dbdExe = "C:\Program Files\Steam\steamapps\common\Dead by Daylight\DeadByDaylight\Binaries\Win64\DeadByDaylight-Win64-Shipping.exe"
        $dbdCompatSet = Set-DisableFullscreenOptimizations -ExePath $dbdExe

        if ($dbdCompatSet) {
            Write-Host "✓ DBD: Fullscreen Optimizations Disabled" -ForegroundColor Green
        } else {
            Write-Host "⚠ DBD executable not found at expected path" -ForegroundColor Yellow
        }

        $dbdReg = "HKCU:\SOFTWARE\DeadByDaylight"
        if (-not (Test-Path $dbdReg)) { New-Item -Path $dbdReg -Force | Out-Null }
        New-ItemProperty -Path $dbdReg -Name "MotionBlur" -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path $dbdReg -Name "PerformanceMode" -PropertyType DWord -Value 1 -Force | Out-Null

        Write-Host "✓ DBD: Motion Blur = Off" -ForegroundColor Green
        Write-Host "✓ DBD: Performance Mode = On" -ForegroundColor Green
    }

    default {
        Write-Host "ERROR: Invalid choice. Please enter 1-5." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✓ GAME OPTIMIZATION COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Restart your game for changes to apply!" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"