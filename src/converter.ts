import ffmpeg from 'fluent-ffmpeg';
import ffmpegStatic from 'ffmpeg-static';
import ffprobeStatic from 'ffprobe-static';
import * as path from 'path';
import * as fs from 'fs';

// Set the path to the ffmpeg and ffprobe binaries
if (ffmpegStatic) {
  ffmpeg.setFfmpegPath(ffmpegStatic);
}
if (ffprobeStatic && ffprobeStatic.path) {
  ffmpeg.setFfprobePath(ffprobeStatic.path);
}

/**
 * Options for video conversion
 */
export interface ConversionOptions {
  inputPath: string;
  outputPath?: string;
  videoBitrate?: string;
  audioBitrate?: string;
  videoCodec?: string;
  audioCodec?: string;
  onProgress?: (progress: { percent: number; currentFps: number; targetSize: number }) => void;
}

/**
 * Convert MP4 video to AVI format
 * @param options Conversion options
 * @returns Promise that resolves with the output file path
 */
export function convertMP4ToAVI(options: ConversionOptions): Promise<string> {
  return new Promise((resolve, reject) => {
    const { inputPath, outputPath, videoBitrate, audioBitrate, videoCodec, audioCodec, onProgress } = options;

    // Validate input file
    if (!fs.existsSync(inputPath)) {
      return reject(new Error(`Input file does not exist: ${inputPath}`));
    }

    // Check if input file is MP4
    const inputExt = path.extname(inputPath).toLowerCase();
    if (inputExt !== '.mp4') {
      return reject(new Error(`Input file must be MP4 format, got: ${inputExt}`));
    }

    // Determine output path
    const finalOutputPath = outputPath || inputPath.replace(/\.mp4$/i, '.avi');

    // Check if output file already exists
    if (fs.existsSync(finalOutputPath)) {
      return reject(new Error(`Output file already exists: ${finalOutputPath}`));
    }

    // Create ffmpeg command
    const command = ffmpeg(inputPath);

    // Set video codec (default: libxvid for AVI)
    command.videoCodec(videoCodec || 'libxvid');

    // Set audio codec (default: libmp3lame for AVI)
    command.audioCodec(audioCodec || 'libmp3lame');

    // Set bitrates if provided
    if (videoBitrate) {
      command.videoBitrate(videoBitrate);
    }
    if (audioBitrate) {
      command.audioBitrate(audioBitrate);
    }

    // Set output format to AVI
    command.format('avi');

    // Add progress handler if provided
    if (onProgress) {
      command.on('progress', (progress: any) => {
        onProgress({
          percent: progress.percent || 0,
          currentFps: progress.currentFps || 0,
          targetSize: progress.targetSize || 0,
        });
      });
    }

    // Handle errors
    command.on('error', (err: Error) => {
      reject(new Error(`Conversion failed: ${err.message}`));
    });

    // Handle completion
    command.on('end', () => {
      resolve(finalOutputPath);
    });

    // Save to output file
    command.save(finalOutputPath);
  });
}

/**
 * Get video information
 * @param filePath Path to the video file
 * @returns Promise with video metadata
 */
export function getVideoInfo(filePath: string): Promise<ffmpeg.FfprobeData> {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(filePath)) {
      return reject(new Error(`File does not exist: ${filePath}`));
    }

    ffmpeg.ffprobe(filePath, (err, metadata) => {
      if (err) {
        return reject(err);
      }
      resolve(metadata);
    });
  });
}
