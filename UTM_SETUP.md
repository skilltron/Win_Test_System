# UTM Setup for Win_Test_System

## Quick Setup

### Step 1: Set Up UTM Windows VM

1. Open UTM
2. Create new Windows VM (follow standard Windows VM setup)
3. **Enable Shared Directory** in VM settings:
   - Go to VM settings → Sharing
   - Add shared directory pointing to your Mac projects folder
   - Note the drive letter (usually Z:)

### Step 2: Install Required Tools in Windows VM

#### Git
```cmd
# Download and install from: https://git-scm.com/download/win
```

#### Flutter (for Flutter projects)
```cmd
# Download from: https://flutter.dev/docs/get-started/install/windows
# Extract and add to PATH
```

#### Node.js (for Node.js projects)
```cmd
# Download from: https://nodejs.org/
# Install with default options
```

#### Python (for Python projects)
```cmd
# Download from: https://www.python.org/downloads/
# Install with "Add Python to PATH" checked
```

### Step 3: Clone Win_Test_System in VM

```cmd
git clone https://github.com/BiochemIQGenomics/Win_Test_System.git
cd Win_Test_System
```

### Step 4: Run Setup

**Using CMD/Terminal:**
```cmd
setup_and_test.bat
```

**Using PowerShell:**
```powershell
.\setup_and_test.ps1
```

## Usage

### Test a Project from GitHub

```cmd
test_project.bat https://github.com/user/repo.git
```

### Test a Project from Shared Folder

```cmd
# If project is in shared folder at Z:\project-name
cd Z:\project-name
test_project.bat .
```

### Test Current Directory

```cmd
cd C:\path\to\project
test_project.bat .
```

## Automated Workflow

### Option 1: Test from GitHub

```cmd
cd Win_Test_System
test_project.bat https://github.com/BiochemIQGenomics/Name_Generator.git
```

### Option 2: Test from Shared Folder

1. **On Mac**: Project is in shared folder
2. **In Windows VM**:
   ```cmd
   cd Z:\project-name
   C:\path\to\Win_Test_System\test_project.bat .
   ```

### Option 3: Copy to VM First

```cmd
cd Win_Test_System
copy_to_utm.bat projects\name-generator
```

Then in VM:
```cmd
cd Z:\name-generator
test_project.bat .
```

## Troubleshooting

### "Git not found"
- Install Git for Windows
- Restart terminal after installation

### "Flutter/Node.js/Python not found"
- Install the required tool
- Add to PATH if needed
- Restart terminal

### "Shared folder not accessible"
- Check UTM shared folder settings
- Verify drive letter mapping
- Restart VM if needed

### "Project clone failed"
- Check internet connection
- Verify repository URL
- Check Git credentials if private repo

## Advanced Usage

### Adapt Existing Tests

```cmd
adapt_tests.bat
```

This scans all projects and adapts their test files to Win_Test_System format.

### Custom Test Scripts

You can add custom test scripts to `adapted_tests/` directory and they will be available for use.
