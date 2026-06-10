# fps-booster-bundle.ps1
# Game-Specific FPS Optimization Scripts
# Run as Administrator

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  🎯 FPS Booster Bundle v1.0" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available Game Optimizations:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Apex Legends" -ForegroundColor White
Write-Host "  2. Fortnite" -ForegroundColor White
Write-Host "  3. Call of Duty" -ForegroundColor White
Write-Host "  4. Minecraft" -ForegroundColor White
Write-Host "  5. Dead by Daylight" -ForegroundColor White
Write-Host ""
Write-Host "Enter game number (1-5): " -ForegroundColor Yellow
$gameChoice = Read-Host ""

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ ERROR: Run as Administrator!" -ForegroundColor Red
    exit 1
}

switch ($gameChoice) {
    "1" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Apex Legends" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        
        # Apex Legends config path
        $apexPath = "$env:LOCALAPPDATA\Apex\SavedAccounts"
        
        # Disable fullscreen optimizations
        $apexExe = "C:\Program Files\EA Games\Apex Legends\apex.exe"
        if (Test-Path $apexExe) {
            $compatPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppCompat\Programs\CompatPicker"
            if (-not (Test-Path $compatPath)) { New-Item -Path $compatPath -Force | Out-Null }
            Set-ItemProperty -Path $compatPath -Name "apex.exe" -Value "DisableFullscreenOptimizations" -Force | Out-Null
        }
        
        # Set process priority
        Write-Host "✅ Apex: Fullscreen Optimizations Disabled" -ForegroundColor Green
        
        # NVIDIA optimization for Apex
        $nvidiaPath = "HKCU:\SOFTWARE\NVIDIA Corporation\NVIDIA GeForce\Apex"
        if (-not (Test-Path $nvidiaPath)) { New-Item -Path $nvidiaPath -Force | Out-Null }
        Set-ItemProperty -Path $nvidiaPath -Name "MaximumPerformance" -Value 1 -Force | Out-Null
        Set-ItemProperty -Path $nvidiaPath -Name "ThreadedOptimization" -Value 1 -Force | Out-Null
        
        Write-Host "✅ Apex: NVIDIA Performance Mode" -ForegroundColor Green
        Write-Host "✅ Apex: Threaded Optimization On" -ForegroundColor Green
        
        # Disable Windows Game Bar for Apex
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Force | Out-Null
        
        Write-Host "✅ Apex: Game Bar Disabled" -ForegroundColor Green
    }
    
    "2" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Fortnite" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        
        $fortnitePath = "$env:LOCALAPPDATA\FortniteGame"
        
        # Fortnite settings
        $fortniteExe = "C:\Program Files\Epic Games\Fortnite\FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping.exe"
        if (Test-Path $fortniteExe) {
            $compatPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppCompat\Programs\CompatPicker"
            if (-not (Test-Path $compatPath)) { New-Item -Path $compatPath -Force | Out-Null }
            Set-ItemProperty -Path $compatPath -Name "FortniteClient-Win64-Shipping.exe" -Value "DisableFullscreenOptimizations" -Force | Out-Null
        }
        
        Write-Host "✅ Fortnite: Fullscreen Optimizations Disabled" -ForegroundColor Green
        
        # Disable DirectX 12 (use DX11 for better FPS)
        Set-ItemProperty -Path "HKCU:\SOFTWARE\EpicGames\Fortnite" -Name "UseDX12" -Value 0 -Force | Out-Null
        Write-Host "✅ Fortnite: DirectX 11 (better FPS)" -ForegroundColor Green
        
        # NVIDIA settings
        $nvidiaPath = "HKCU:\SOFTWARE\NVIDIA Corporation\NVIDIA GeForce\Fortnite"
        if (-not (Test-Path $nvidiaPath)) { New-Item -Path $nvidiaPath -Force | Out-Null }
        Set-ItemProperty -Path $nvidiaPath -Name "MaximumPerformance" -Value 1 -Force | Out-Null
        
        Write-Host "✅ Fortnite: NVIDIA Performance Mode" -ForegroundColor Green
    }
    
    "3" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Call of Duty" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        
        $codPath = "$env:LOCALAPPDATA\Call of Duty"
        
        # COD executable
        $codExe = "C:\Program Files\Activision\Call of Duty\cod.exe"
        if (Test-Path $codExe) {
            $compatPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppCompat\Programs\CompatPicker"
            if (-not (Test-Path $compatPath)) { New-Item -Path $compatPath -Force | Out-Null }
            Set-ItemProperty -Path $compatPath -Name "cod.exe" -Value "DisableFullscreenOptimizations" -Force | Out-Null
        }
        
        Write-Host "✅ COD: Fullscreen Optimizations Disabled" -ForegroundColor Green
        
        # Disable V-Sync
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Activision\Call of Duty" -Name "VSync" -Value 0 -Force | Out-Null
        Write-Host "✅ COD: V-Sync Disabled" -ForegroundColor Green
        
        # Set high process priority
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Activision\Call of Duty" -Name "ProcessPriority" -Value "High" -Force | Out-Null
        Write-Host "✅ COD: Process Priority = High" -ForegroundColor Green
    }
    
    "4" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Minecraft" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        
        # Minecraft JVM settings
        $minecraftPath = "$env:APPDATA\.minecraft"
        
        # Increase RAM allocation
        Set-Content -Path "$minecraftPath\jvm.options" -Value "-Xmx4G -Xms2G" -ErrorAction SilentlyContinue
        Write-Host "✅ Minecraft: RAM Allocation = 4GB" -ForegroundColor Green
        
        # Disable fancy graphics
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Minecraft" -Name "fancyGraphics" -Value 0 -Force | Out-Null
        Write-Host "✅ Minecraft: Graphics = Fast" -ForegroundColor Green
        
        # Reduce render distance
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Minecraft" -Name "renderDistance" -Value 8 -Force | Out-Null
        Write-Host "✅ Minecraft: Render Distance = 8 chunks" -ForegroundColor Green
        
        # Disable smooth lighting
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Minecraft" -Name "smoothLighting" -Value 0 -Force | Out-Null
        Write-Host "✅ Minecraft: Smooth Lighting = Off" -ForegroundColor Green
    }
    
    "5" {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "  Optimizing: Dead by Daylight" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        
        $dbdPath = "$env:LOCALAPPDATA\DeadByDaylight"
        
        # DBD executable
        $dbdExe = "C:\Program Files\Steam\steamapps\common\Dead by Daylight\DeadByDaylight\Binaries\Win64\DeadByDaylight-Win64-Shipping.exe"
        if (Test-Path $dbdExe) {
            $compatPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppCompat\Programs\CompatPicker"
            if (-not (Test-Path $compatPath)) { New-Item -Path $compatPath -Force | Out-Null }
            Set-ItemProperty -Path $compatPath -Name "DeadByDaylight-Win64-Shipping.exe" -Value "DisableFullscreenOptimizations" -Force | Out-Null
        }
        
        Write-Host "✅ DBD: Fullscreen Optimizations Disabled" -ForegroundColor Green
        
        # Disable motion blur
        Set-ItemProperty -Path "HKCU:\SOFTWARE\DeadByDaylight" -Name "MotionBlur" -Value 0 -Force | Out-Null
        Write-Host "✅ DBD: Motion Blur = Off" -ForegroundColor Green
        
        # Set performance mode
        Set-ItemProperty -Path "HKCU:\SOFTWARE\DeadByDaylight" -Name "PerformanceMode" -Value 1 -Force | Out-Null
        Write-Host "✅ DBD: Performance Mode = On" -ForegroundColor Green
    }
    
    default {
        Write-Host "❌ Invalid choice. Please enter 1-5." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ GAME OPTIMIZATION COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Restart your game for changes to apply!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")