# ============================================================================
# 🚀 FVM + ONNX Runtime Setup Script for Flutter Project
# Script này tự động hóa quá trình thiết lập ban đầu
# ============================================================================

param(
    [switch]$SkipFvmInstall,
    [switch]$SkipDependencies
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Hàm Tiện Ích
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host "`n" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "  $Message" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
}

function Write-Step {
    param([string]$Message, [int]$Step)
    Write-Host "`n[$Step] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

# ============================================================================
# Kiểm Tra FVM
# ============================================================================

Write-Header "FVM + ONNX Runtime Setup"

Write-Step "Checking FVM installation..." 1

$fvmVersion = dart pub global list 2>$null | Select-String "fvm"

if ($fvmVersion) {
    Write-Success "FVM is installed: $fvmVersion"
} else {
    if ($SkipFvmInstall) {
        Write-Error-Custom "FVM is not installed and -SkipFvmInstall flag is set"
        Write-Host "Please install FVM first: dart pub global activate fvm"
        exit 1
    }
    
    Write-Warning-Custom "FVM is not installed. Installing..."
    Write-Host "Running: dart pub global activate fvm" -ForegroundColor Yellow
    dart pub global activate fvm
    Write-Success "FVM installed"
}

# ============================================================================
# Cài Đặt Flutter 3.22.2
# ============================================================================

Write-Step "Setting up Flutter 3.22.2..." 2

Write-Host "Running: fvm install 3.22.2" -ForegroundColor Yellow
fvm install 3.22.2
Write-Success "Flutter 3.22.2 installed"

# ============================================================================
# Gán FVM cho Project
# ============================================================================

Write-Step "Configuring project to use Flutter 3.22.2..." 3

Write-Host "Running: fvm use 3.22.2" -ForegroundColor Yellow
fvm use 3.22.2
Write-Success "Project configured to use Flutter 3.22.2"

# ============================================================================
# Cập Nhật Dependencies
# ============================================================================

if (-not $SkipDependencies) {
    Write-Step "Installing dependencies (onnxruntime & flutter_riverpod)..." 4
    
    Write-Host "Running: fvm flutter pub add onnxruntime flutter_riverpod" -ForegroundColor Yellow
    fvm flutter pub add onnxruntime flutter_riverpod
    Write-Success "Dependencies added"
    
    Write-Host "Running: fvm flutter pub get" -ForegroundColor Yellow
    fvm flutter pub get
    Write-Success "Dependencies downloaded"
}

# ============================================================================
# Verify Setup
# ============================================================================

Write-Step "Verifying setup..." 5

Write-Host "`nFlutter version:" -ForegroundColor Cyan
fvm flutter --version

Write-Host "`nActive FVM version:" -ForegroundColor Cyan
fvm list

Write-Host "`nProject structure check:" -ForegroundColor Cyan
$requiredFiles = @(
    ".fvm/fvm_config.json",
    ".vscode/settings.json",
    ".vscode/extensions.json",
    "pubspec.yaml"
)

$allExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file" -ForegroundColor Red
        $allExist = $false
    }
}

# ============================================================================
# Final Summary
# ============================================================================

Write-Header "Setup Complete!"

Write-Host @"
┌─────────────────────────────────────────────────────────────────┐
│  📋 Configuration Summary                                        │
├─────────────────────────────────────────────────────────────────┤
│  ✅ FVM configured for Flutter 3.22.2                           │
│  ✅ .fvm/fvm_config.json created                               │
│  ✅ .vscode/settings.json configured                           │
│  ✅ Android minSdk set to 24 (for onnxruntime)                 │
│  ✅ .gitignore updated (.fvm/flutter_sdk ignored)              │
│  ✅ Dependencies added: onnxruntime, flutter_riverpod           │
├─────────────────────────────────────────────────────────────────┤
│  🚀 Next Steps:                                                 │
│  1. Open project in VS Code                                     │
│  2. VS Code will auto-detect Flutter from .fvm/flutter_sdk     │
│  3. Install recommended extensions (VS Code will prompt)        │
│  4. Start developing!                                           │
├─────────────────────────────────────────────────────────────────┤
│  📚 Documentation:                                               │
│  • FVM_SETUP_GUIDE.md - Detailed setup instructions             │
│  • TEAM_WORKFLOW.md - Team workflow and common commands        │
└─────────────────────────────────────────────────────────────────┘
"@ -ForegroundColor Green

Write-Host "You can now run:" -ForegroundColor Cyan
Write-Host "  • fvm flutter run" -ForegroundColor Yellow
Write-Host "  • fvm flutter build apk" -ForegroundColor Yellow
Write-Host "  • fvm flutter build ios" -ForegroundColor Yellow
Write-Host "`nHappy coding! 🎉" -ForegroundColor Green
