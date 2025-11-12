# PPC Converter

PPC Converter je TypeScript nástroj pre konverziu a úpravu videí. Projekt je primárne zameraný na konverziu MP4 videí do AVI formátu.

## Funkcie

- ✅ Konverzia MP4 na AVI formát
- ✅ Zobrazenie informácií o video súboroch
- ✅ Sledovanie progresu konverzie v reálnom čase
- ✅ Podpora pre vlastné nastavenia video a audio kodekov
- ✅ Automatické pomenovanie výstupného súboru

## Inštalácia

```bash
# Klonovanie repozitára
git clone https://github.com/Humming-SvKe/PPC-Converter.git
cd PPC-Converter

# Inštalácia závislostí
npm install

# Build projektu
npm run build
```

### Rýchle spustenie (Windows)

Pre rýchle spustenie na Windows použite startup skript:

```cmd
START.bat
```

Tento skript automaticky:
- Skontroluje inštaláciu Node.js
- Nainštaluje závislosti (ak chýbajú)
- Zostaví TypeScript kód
- Zobrazí návod na použitie

Môžete ho tiež použiť priamo s video súborom:

```cmd
START.bat video.mp4
START.bat video.mp4 output.avi
```

## Použitie

### Konverzia MP4 na AVI

Základná konverzia s automatickým pomenovaním výstupu:

```bash
npm run convert video.mp4
```

Konverzia s vlastným názvom výstupného súboru:

```bash
npm run convert video.mp4 output.avi
```

### Zobrazenie informácií o videu

```bash
npm run convert -- --info video.mp4
```

Tento príkaz zobrazí:
- Formát a kodek videa
- Trvanie
- Veľkosť súboru
- Rozlíšenie
- Snímkovú frekvenciu (FPS)
- Audio kodek a vlastnosti

## Technické detaily

### Závislosti

- **ffmpeg-static**: Statický build ffmpeg pre spracovanie videa
- **ffprobe-static**: Nástroj pre získavanie metadát videa
- **fluent-ffmpeg**: Node.js rozhranie pre ffmpeg
- **TypeScript**: Type-safe vývoj

### Predvolené kodeky pre AVI

- Video: libxvid
- Audio: libmp3lame

## Programatické použitie

Môžete použiť PPC Converter ako knižnicu vo vašich vlastných TypeScript/Node.js projektoch:

```typescript
import { convertMP4ToAVI, getVideoInfo } from './src/index';

// Konverzia videa s callback funkciou pre progress
const outputPath = await convertMP4ToAVI({
  inputPath: 'input.mp4',
  outputPath: 'output.avi',
  onProgress: (progress) => {
    console.log(`Progress: ${progress.percent}%`);
    console.log(`FPS: ${progress.currentFps}`);
  }
});

console.log(`Video konvertované: ${outputPath}`);

// Získanie informácií o videu
const info = await getVideoInfo('video.mp4');
console.log(info);
```

### Rozšírené možnosti konverzie

```typescript
await convertMP4ToAVI({
  inputPath: 'input.mp4',
  outputPath: 'output.avi',
  videoCodec: 'libxvid',      // Video kodek
  audioCodec: 'libmp3lame',   // Audio kodek
  videoBitrate: '1000k',      // Video bitrate
  audioBitrate: '128k',       // Audio bitrate
  onProgress: (progress) => {
    // Callback pre sledovanie progresu
  }
});
```

## Dokumentácia

Podrobnejšiu dokumentáciu nájdete v súbore [docs/usage.md](docs/usage.md).

## Testovanie

Pre vytvorenie testovacieho videa:

```bash
./node_modules/ffmpeg-static/ffmpeg -f lavfi -i testsrc=duration=5:size=320x240:rate=25 -f lavfi -i sine=frequency=1000:duration=5 -pix_fmt yuv420p -c:v libx264 -preset ultrafast sample/test_video.mp4 -y
```

Následne otestujte konverziu:

```bash
npm run convert sample/test_video.mp4
```

## Riešenie problémov

**Chyba: Input file does not exist**
- Skontrolujte, či je cesta k vstupnému súboru správna
- Použite absolútne cesty alebo relatívne cesty od root adresára projektu

**Chyba: Output file already exists**
- Zmažte existujúci výstupný súbor alebo zadajte iný názov

**Chyba: Input file must be MP4 format**
- Konvertor momentálne podporuje len MP4 vstupné súbory
- Skontrolujte, či má súbor príponu .mp4

## Licencia

Tento projekt je vyvíjaný a udržiavaný komunitou.

## Autor

Humming-SvKe

## Prispievanie

Príspevky sú vítané! Neváhajte otvoriť issue alebo pull request.
