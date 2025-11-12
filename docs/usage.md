# Usage Documentation

This document provides usage instructions for PPC Converter.

## PPC Converter - MP4 to AVI Video Converter

PPC Converter is a TypeScript-based video conversion tool that allows you to convert MP4 videos to AVI format.

### Installation

1. Install dependencies:
```bash
npm install
```

2. Build the project:
```bash
npm run build
```

### Usage

#### Converting MP4 to AVI

To convert an MP4 video to AVI format:

```bash
npm run convert <input.mp4> [output.avi]
```

**Examples:**

```bash
# Convert video.mp4 to video.avi (automatic naming)
npm run convert video.mp4

# Convert video.mp4 to custom output name
npm run convert video.mp4 converted_video.avi
```

#### Getting Video Information

To get information about a video file:

```bash
npm run convert -- --info <video_file>
```

**Example:**

```bash
npm run convert -- --info video.mp4
```

This will display:
- Video format and codec information
- Duration
- File size
- Resolution
- Frame rate
- Audio codec and properties

### Features

- **MP4 to AVI Conversion**: Convert MP4 videos to AVI format with high quality
- **Progress Tracking**: Real-time progress indication during conversion
- **Video Information**: Display detailed video metadata
- **Automatic Output Naming**: If no output file is specified, automatically generates an output filename

### Technical Details

The converter uses:
- **ffmpeg**: Industry-standard video processing tool
- **fluent-ffmpeg**: Node.js interface for ffmpeg
- **TypeScript**: Type-safe development

Default codecs used for AVI conversion:
- Video: libxvid
- Audio: libmp3lame

### Programmatic Usage

You can also use the converter as a library in your own TypeScript/Node.js projects:

```typescript
import { convertMP4ToAVI, getVideoInfo } from 'ppc-converter';

// Convert a video
const outputPath = await convertMP4ToAVI({
  inputPath: 'input.mp4',
  outputPath: 'output.avi',
  onProgress: (progress) => {
    console.log(`Progress: ${progress.percent}%`);
  }
});

// Get video information
const info = await getVideoInfo('video.mp4');
console.log(info);
```

### Troubleshooting

**Error: Input file does not exist**
- Make sure the input file path is correct
- Use absolute paths or relative paths from the project root

**Error: Output file already exists**
- Delete the existing output file or specify a different output name

**Error: Input file must be MP4 format**
- The converter currently only supports MP4 input files
- Verify your file has the .mp4 extension
