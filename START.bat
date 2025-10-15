@echo off
setlocal EnableDelayedExpansion

REM === PPC Converter START script ===
REM - Checks and prepares dependencies (FFmpeg; optionally .NET/DirectX) automatically
REM - Creates working folders
REM - Converts all MP4 from input/ to AVI in output/

REM ---------- Paths ----------
set "SCRIPT_DIR=%~dp0"
set "BIN_DIR=%SCRIPT_DIR%binaries"
set "TMP_DIR=%SCRIPT_DIR%temp"
set "LOG_DIR=%SCRIPT_DIR%logs"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM ---------- Helpers ----------
where powershell >nul 2>&1 && (set "HAS_PS=1") || (set "HAS_PS=0")
where curl >nul 2>&1 && (set "HAS_CURL=1") || (set "HAS_CURL=0")
ping -n 1 8.8.8.8 >nul 2>&1 && (set "HAS_NET=1") || (set "HAS_NET=0")

echo.
echo ==============================================
echo PPC Converter - Startup checks
echo ==============================================

REM Ensure working folders
if not exist "%SCRIPT_DIR%input"  mkdir "%SCRIPT_DIR%input"
if not exist "%SCRIPT_DIR%output" mkdir "%SCRIPT_DIR%output"

REM Download helper: :download <URL> <DEST>
:download
if "%~1"=="" exit /b 1
if "%~2"=="" exit /b 1
set "DL_URL=%~1"
set "DL_OUT=%~2"
echo [INFO] Downloading: %DL_URL%
if "%HAS_PS%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try{Invoke-WebRequest -Uri '%DL_URL%' -OutFile '%DL_OUT%' -UseBasicParsing -TimeoutSec 300}catch{Write-Output $_.Exception.Message; exit 2}"
  if exist "%DL_OUT%" exit /b 0
)
if "%HAS_CURL%"=="1" (
  curl -L -o "%DL_OUT%" "%DL_URL%"
  if exist "%DL_OUT%" exit /b 0
)
bitsadmin /transfer PPCDownload /priority FOREGROUND "%DL_URL%" "%DL_OUT%" >nul 2>&1
if exist "%DL_OUT%" exit /b 0
exit /b 1

REM Unzip helper (prefers PowerShell): :unzip <ZIP> <DESTDIR>
:unzip
if "%~1"=="" exit /b 1
if "%~2"=="" exit /b 1
if "%HAS_PS%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Expand-Archive -Path '%~1' -DestinationPath '%~2' -Force" 2>nul
  if exist "%~2" exit /b 0
)
tar -xf "%~1" -C "%~2%" 2>nul
if exist "%~2" exit /b 0
exit /b 1

REM ---------- FFmpeg detection/install ----------
set "FFMPEG_CMD="
where ffmpeg >nul 2>&1 && (for /f "delims=" %%A in ('where ffmpeg') do set "FFMPEG_CMD=%%~fA")
if not defined FFMPEG_CMD if exist "%BIN_DIR%\ffmpeg.exe" set "FFMPEG_CMD=%BIN_DIR%\ffmpeg.exe"

if not defined FFMPEG_CMD (
  echo [INFO] FFmpeg not found. Attempting automatic install...
  if "%HAS_NET%"=="1" (
    REM Try package manager (silent). If this fails, fall back to portable ZIP.
    where winget >nul 2>&1 && (
      echo [INFO] Trying winget install (Gyan.FFmpeg / FFmpeg.FFmpeg)...
      winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements >nul 2>&1 || ^
      winget install -e --id FFmpeg.FFmpeg --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
    )

    where ffmpeg >nul 2>&1 && (for /f "delims=" %%A in ('where ffmpeg') do set "FFMPEG_CMD=%%~fA")

    if not defined FFMPEG_CMD (
      echo [INFO] Downloading portable FFmpeg (essentials ZIP)...
      set "FFZIP=%TMP_DIR%\ffmpeg.zip"
      call :download "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.zip" "%FFZIP%"
      if exist "%FFZIP%" (
        set "FFEXTR=%TMP_DIR%\ffmpeg_unpack"
        if exist "%FFEXTR%" rmdir /s /q "%FFEXTR%" >nul 2>&1
        mkdir "%FFEXTR%" >nul 2>&1
        call :unzip "%FFZIP%" "%FFEXTR%"
        for /r "%FFEXTR%" %%I in (ffmpeg.exe) do (
          copy /y "%%~fI" "%BIN_DIR%\ffmpeg.exe" >nul
          set "FFMPEG_CMD=%BIN_DIR%\ffmpeg.exe"
          goto :ff_ready
        )
      )
    )
  ) else (
    echo [WARN] No internet connection; cannot download FFmpeg automatically.
  )
)

:ff_ready
if not defined FFMPEG_CMD (
  echo [ERROR] FFmpeg is required but could not be installed automatically.
  echo Place ffmpeg.exe into "%BIN_DIR%" and run this script again.
  goto :end
)

echo [OK] FFmpeg ready at: %FFMPEG_CMD%

REM Optional checks (not required for batch conversion)
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release >nul 2>&1 || echo [INFO] .NET 4.x not detected (not required).
where dxdiag >nul 2>&1 || echo [INFO] DirectX diagnostics not found in PATH (Windows includes DirectX).

echo.
echo ==============================================
echo PPC Converter - Batch conversion
echo Input:  "%SCRIPT_DIR%input"
echo Output: "%SCRIPT_DIR%output"
echo ==============================================

if not exist "%SCRIPT_DIR%input\*.mp4" (
  echo [INFO] Place MP4 files into the "input" folder and run START.bat again.
  goto :end
)

for %%f in ("%SCRIPT_DIR%input\*.mp4") do (
  echo [CONVERT] "%%~nxf" -> "output\%%~nf.avi"
  "%FFMPEG_CMD%" -y -i "%%f" -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 160k "output\%%~nf.avi" >> "%LOG_DIR%\ffmpeg.log" 2>&1
)

echo.
echo [DONE] Conversion completed. Check the "output" folder.
echo Logs: "%LOG_DIR%\ffmpeg.log"

:end
echo.
pause
exit /b 0
