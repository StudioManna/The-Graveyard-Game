@echo off
set unityExecutable=C:\Program Files\Unity\Hub\Editor\2022.3.4f1\Editor\Unity.exe
set projectDirectory=D:\dev\gamedev\GDFG Game Jam July 2023

IF NOT EXIST "%unityExecutable%" (
    echo Unity Not Installed, or incorrect unityExecutable variable
    pause
    exit /b
)

IF NOT EXIST "%projectDirectory%" (
    echo Incorrect project directory. Check projectDirectory variable, and be sure not to use quotation marks.
    pause
    exit /b
)

IF NOT EXIST "%projectDirectory%\Build\version.txt" (
    echo No version file. Add version.txt to the Build folder with the correct Semantic Versioning number.
    pause
    exit /b
)

for /f "delims=" %%i in ('git log -1 --format^="%%s"') do set "commit_message=%%i"

set /p version=<"%projectDirectory%\Build\version.txt"

if %commit_message%==%version% (
    echo Version is the same as the last git commit. Please use Semantic Versioning
    pause
    exit /b
)

echo:

echo Removing previous build folders
rmdir "%projectDirectory%\Build\Build" /s /q
rmdir "%projectDirectory%\Build\TemplateData" /s /q
del "%projectDirectory%\Build\index.html"
echo Previous build removed

echo:

echo Starting WebGL Build. May take a few minutes.
cmd /S /C ""%unityExecutable%" -quit -batchmode -nographics -projectProject "%projectDirectory%" -executeMethod WebGLBuilder.build"
echo Build Complete
echo:
echo Committing v%version% to GitHub
cd "%projectDirectory%\Build"
cmd /C "git add . & git commit -m %version% & git push"
echo Commit successful
pause
exit /b 0