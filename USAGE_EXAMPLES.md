# Win_Test_System Usage Examples

## Basic Usage

### Test a Project from GitHub

**CMD/Terminal:**
```cmd
test_project.bat https://github.com/BiochemIQGenomics/Name_Generator.git
```

**PowerShell:**
```powershell
.\test_project.ps1 https://github.com/BiochemIQGenomics/Name_Generator.git
```

### Test a Local Project

```cmd
test_project.bat C:\path\to\project
```

### Test Current Directory

```cmd
cd C:\path\to\project
test_project.bat .
```

## Advanced Usage

### Pull and Test in One Command

```cmd
pull_and_test.bat https://github.com/user/repo.git
```

This will:
1. Clone the repository
2. Detect project type
3. Build the project
4. Run tests
5. Adapt any existing test files

### Adapt Existing Tests

```cmd
adapt_tests.bat
```

Scans all projects in `projects/` directory and adapts their test files to Win_Test_System format.

### Run All Adapted Tests

```cmd
run_all_tests.bat
```

Runs all tests that have been adapted from projects.

## UTM Integration

### Copy Project to UTM Shared Folder

```cmd
copy_to_utm.bat projects\name-generator
```

This copies the project to the UTM shared folder (usually Z:\) for easy access in the VM.

### Workflow: Mac → UTM → Test

1. **On Mac**: Project is in shared folder
2. **In Windows VM**:
   ```cmd
   cd Z:\project-name
   C:\path\to\Win_Test_System\test_project.bat .
   ```

## Project-Specific Examples

### Flutter Project (reaction-modeler)

```cmd
test_project.bat https://github.com/user/reaction-modeler.git
```

System will:
- Detect Flutter project
- Run `flutter pub get`
- Build with `flutter build windows --release`
- Test the executable

### Node.js Project (PDF_Helper)

```cmd
test_project.bat https://github.com/user/PDF_Helper.git
```

System will:
- Detect Node.js project
- Run `npm install`
- Build (if Electron, uses electron-builder)
- Test the output

### Python Project (name-generator)

```cmd
test_project.bat https://github.com/BiochemIQGenomics/Name_Generator.git
```

System will:
- Detect Python project
- Find build script (build_windows_exe_automated.py)
- Build executable with PyInstaller
- Test the executable

## Batch Testing Multiple Projects

Create a file `test_projects.txt`:
```
https://github.com/user/project1.git
https://github.com/user/project2.git
C:\local\project3
```

Then run:
```cmd
for /f %%i in (test_projects.txt) do test_project.bat %%i
```

## Customization

### Add Custom Test Scripts

1. Place test scripts in `adapted_tests/`
2. Name them: `projectname_test.bat` or `projectname_test.ps1`
3. Run with `run_all_tests.bat`

### Modify Test Behavior

Edit `test_project.bat` or `test_project.ps1` to:
- Change build commands
- Add custom test steps
- Modify project detection logic

## Troubleshooting

### "Project type not detected"
- Check if project has standard files (pubspec.yaml, package.json, etc.)
- Manually specify project type in test script

### "Build failed"
- Check if required tools are installed (Flutter/Node.js/Python)
- Verify project dependencies
- Check build logs for errors

### "Tests not found"
- Run `adapt_tests.bat` to adapt existing tests
- Or create custom test scripts in `adapted_tests/`
