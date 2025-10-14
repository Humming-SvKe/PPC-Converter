@echo off
REM Spustenie PPC Converter v portable režime
REM Ak PPC.exe nie je dostupné, spustí alternatívny režim...
if exist PPC.exe (
    start PPC.exe
) else (
    echo PPC.exe nebol nájdený. Spúšťam alternatívny režim...
    REM Tu môžeš doplniť príkazy na spustenie iného backendu alebo skriptu
)
pause
