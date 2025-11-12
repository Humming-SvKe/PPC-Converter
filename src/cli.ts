#!/usr/bin/env node

import { convertMP4ToAVI, getVideoInfo } from './converter';
import * as path from 'path';

/**
 * Simple CLI for PPC Converter
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('PPC Converter - MP4 to AVI Converter');
    console.log('');
    console.log('Usage:');
    console.log('  npm run convert <input.mp4> [output.avi]');
    console.log('');
    console.log('Examples:');
    console.log('  npm run convert video.mp4');
    console.log('  npm run convert video.mp4 converted.avi');
    console.log('');
    console.log('Options:');
    console.log('  --info <file>    Show video information');
    process.exit(0);
  }

  // Handle --info command
  if (args[0] === '--info' && args[1]) {
    try {
      const info = await getVideoInfo(args[1]);
      console.log('\nVideo Information:');
      console.log('==================');
      console.log(`Format: ${info.format.format_long_name}`);
      console.log(`Duration: ${info.format.duration} seconds`);
      const size = info.format.size ? parseInt(String(info.format.size)) : 0;
      console.log(`Size: ${(size / (1024 * 1024)).toFixed(2)} MB`);
      
      if (info.streams && info.streams.length > 0) {
        const videoStream = info.streams.find(s => s.codec_type === 'video');
        const audioStream = info.streams.find(s => s.codec_type === 'audio');
        
        if (videoStream) {
          console.log(`\nVideo Stream:`);
          console.log(`  Codec: ${videoStream.codec_name}`);
          console.log(`  Resolution: ${videoStream.width}x${videoStream.height}`);
          const fps = videoStream.r_frame_rate ? eval(videoStream.r_frame_rate)?.toFixed(2) : 'N/A';
          console.log(`  FPS: ${fps}`);
        }
        
        if (audioStream) {
          console.log(`\nAudio Stream:`);
          console.log(`  Codec: ${audioStream.codec_name}`);
          console.log(`  Sample Rate: ${audioStream.sample_rate} Hz`);
          console.log(`  Channels: ${audioStream.channels}`);
        }
      }
      console.log('');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('Error getting video info:', errorMessage);
      process.exit(1);
    }
    return;
  }

  // Convert video
  const inputPath = path.resolve(args[0]);
  const outputPath = args[1] ? path.resolve(args[1]) : undefined;

  console.log('PPC Converter - MP4 to AVI');
  console.log('==========================');
  console.log(`Input:  ${inputPath}`);
  console.log(`Output: ${outputPath || inputPath.replace(/\.mp4$/i, '.avi')}`);
  console.log('');

  try {
    const result = await convertMP4ToAVI({
      inputPath,
      outputPath,
      onProgress: (progress) => {
        const percent = progress.percent.toFixed(1);
        const fps = progress.currentFps.toFixed(1);
        process.stdout.write(`\rProgress: ${percent}% | FPS: ${fps}`);
      },
    });

    console.log('');
    console.log('');
    console.log('✓ Conversion completed successfully!');
    console.log(`Output file: ${result}`);
  } catch (error) {
    console.error('');
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error('✗ Conversion failed:', errorMessage);
    process.exit(1);
  }
}

main();
