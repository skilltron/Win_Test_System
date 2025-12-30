# Win_Test_System

A universal Windows testing system that works with any project type. Compatible with both PowerShell and CMD/Terminal.

## Features

- ✅ Works with PowerShell AND CMD/Terminal (no PowerShell required)
- ✅ Auto-detects project type (Flutter, Node.js, Python, Web)
- ✅ Pulls projects from GitHub or local sources
- ✅ Sets up projects in UTM Windows VM
- ✅ Runs automated tests
- ✅ Adapts existing test plans
- ✅ Cross-platform compatible

## Quick Start

### In Windows VM (Terminal/CMD)

```cmd
git clone https://github.com/BiochemIQGenomics/Win_Test_System.git
cd Win_Test_System
setup_and_test.bat
```

### In Windows VM (PowerShell)

```powershell
git clone https://github.com/BiochemIQGenomics/Win_Test_System.git
cd Win_Test_System
.\setup_and_test.ps1
```

## Usage

### Test a Project from GitHub

```cmd
test_project.bat https://github.com/user/repo.git
```

### Test a Local Project

```cmd
test_project.bat C:\path\to\project
```

### Test Current Directory

```cmd
test_project.bat .
```

## Project Types Supported

- **Flutter**: Auto-detects, runs `flutter build windows`, tests executable
- **Node.js**: Auto-detects, runs `npm run build`, tests output
- **Python**: Auto-detects, builds with PyInstaller, tests executable
- **Web**: Auto-detects, tests web server functionality

## Requirements

- Windows 10/11
- Git (for cloning projects)
- Project-specific tools (Flutter/Node.js/Python) installed as needed

## No PowerShell Required

All scripts work with standard CMD/Terminal. PowerShell scripts are optional enhancements.
