# Troubleshooting Guide

## Quick Fixes for Common Issues

### 🔴 Problem 1: Backend - psycopg2 Module Not Found

**Error Message**:
```
ModuleNotFoundError: No module named 'psycopg2'
```

**Solution**:
```powershell
# Go to backend directory
cd pick_wizard\backend

# Activate venv
.\venv\Scripts\Activate.ps1

# Install missing package
pip install psycopg2-binary

# Restart backend
cd ..\deployment\scripts
.\run_all.ps1
```

**Or use the fix script**:
```powershell
cd pick_wizard\deployment\scripts
.\fix_backend.ps1
```

---

### 🔴 Problem 2: Flutter - Visual Studio Toolchain Not Found

**Error Message**:
```
Error: Unable to find suitable Visual Studio toolchain
```

**Quick Solution: Use Chrome (Recommended)**

Chrome is now the default target. Just run:
```powershell
.\run_all.ps1
```

Flutter will automatically use Chrome.

**Manual Run**:
```powershell
cd pick_wizard\mobile_app
flutter run -d chrome
```

**Alternative Solutions**:

1. **Install Visual Studio 2022** (for Windows desktop app)
   - Download: https://visualstudio.microsoft.com/downloads/
   - Select: "Desktop development with C++"
   - Select: "Windows 10/11 SDK"

2. **Use Android Emulator**
   - Install Android Studio
   - Create AVD (Android Virtual Device)
   - Run: `flutter run`

---

### 🔴 Problem 3: PowerShell Execution Policy

**Error Message**:
```
cannot be loaded because running scripts is disabled
```

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### 🔴 Problem 4: Port Already in Use

**Error Message**:
```
Address already in use
```

**Solution**:
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill process (replace PID)
Stop-Process -Id <PID> -Force

# Or use stop script
.\stop_all.ps1
```

---

### 🔴 Problem 5: Flutter Not Found

**Error Message**:
```
flutter : The term 'flutter' is not recognized
```

**Solution**:
```powershell
# Add Flutter to PATH (temporary)
$env:PATH += ";C:\flutter\bin"

# Or install Flutter
# Download: https://docs.flutter.dev/get-started/install/windows
```

---

## Complete Setup Checklist

### First Time Setup

1. **Python Environment**
   ```powershell
   cd pick_wizard\backend
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   pip install psycopg2-binary  # Important!
   ```

2. **Flutter Dependencies**
   ```powershell
   cd pick_wizard\mobile_app
   flutter pub get
   ```

3. **Test Run**
   ```powershell
   cd pick_wizard\deployment\scripts
   .\run_all.ps1
   ```

---

## Development Workflow

### Daily Development

```powershell
# Start everything
cd pick_wizard\deployment\scripts
.\run_all.ps1

# Backend only
.\dev_start.ps1 backend

# Frontend only
.\dev_start.ps1 frontend

# Stop everything
.\stop_all.ps1
```

### Hot Reload (Flutter)

While Flutter is running:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### Backend Auto-reload

Uvicorn automatically reloads when you save files.

---

## Useful Commands

### Check Status

```powershell
# Check if backend is running
curl http://localhost:8000/docs

# Check Flutter devices
flutter devices

# Check Python packages
pip list

# Check Flutter packages
flutter pub deps
```

### Clean & Rebuild

```powershell
# Backend
cd pick_wizard\backend
Remove-Item -Recurse -Force venv
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
pip install psycopg2-binary

# Flutter
cd pick_wizard\mobile_app
flutter clean
flutter pub get
```

---

## Environment Variables

Create `.env` file in `pick_wizard/backend/`:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/luckyai645
SECRET_KEY=your-secret-key-here
DEBUG=True
```

---

## Getting Help

1. Run `flutter doctor` for Flutter issues
2. Check logs in terminal windows
3. Refer to `README.md` for detailed documentation
4. Check `.cursor/code_change_log.md` for recent changes

---

**Last Updated**: 2026-01-05 17:00:00 EST

