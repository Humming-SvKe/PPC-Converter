@echo off
REM PPC Converter - MP4 to AVI Video Converter
REM Startup script for Windows

echo ========================================
echo PPC Converter - Video Conversion Tool
echo ========================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install dependencies!
        pause
        exit /b 1
    )
    echo.
)

REM Build the TypeScript code
echo Building project...
call npm run build
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Build successful!
echo.

REM Show usage information
echo ========================================
echo Usage:
echo ========================================
echo.
echo Convert MP4 to AVI (automatic naming):
echo   npm run convert video.mp4
echo.
echo Convert MP4 to AVI (custom output):
echo   npm run convert video.mp4 output.avi
echo.
echo Show video information:
echo   npm run convert -- --info video.mp4
echo.
echo ========================================
echo.

REM Check if argument provided
if "%~1"=="" (
    echo No video file provided. Showing help...
    echo.
    call npm run convert
) else (
    REM Run conversion with provided arguments
    call npm run convert %*
)

echo.
pause
