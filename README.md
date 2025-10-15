# PPC Converter (portable)

Jeden spúšťací súbor: `START.bat`.

Pri prvom spustení:
- skontroluje internet a dostupné nástroje (PowerShell/curl),
- automaticky stiahne a pripraví **FFmpeg** do `binaries/` (repo je malé naschvál; binárky sa sťahujú až pri prvom behu),
- vytvorí priečinky `input/`, `output/`, `logs/`, `binaries/`, `temp/`,
- dávkovo skonvertuje všetky `.mp4` z `input/` do `.avi` v `output/`.

## Použitie
1. Stiahni ZIP repozitára a rozbaľ (alebo git clone).
2. Spusť `START.bat` (dvojklik).
3. Pri prvom behu sa stiahne FFmpeg a pripraví prostredie.
4. Vlož `.mp4` súbory do `input/` a spusti znova (ak už nebeží).
5. Hotové videá sú v `output/`. Log: `logs/ffmpeg.log`.
