---
name: audio-transcribe
description: Transcribe local audio files into markdown transcripts with chunking for stability. Use when users need ASR from audio files (podcasts, recordings, videos converted to audio), especially on constrained machines.
---

# Audio Transcribe

Convert audio files into transcript markdown with segmented ASR.

## Command

```bash
bash scripts/transcribe_audio.sh \
  --model base \
  --chunk-seconds 300 \
  --out-dir "$HOME/Documents/ObsidianVault/Inbox/Transcripts" \
  "/path/to/audio.m4a"
```

## Notes

- Default model: `base`
- Default chunking: 300s
- Output: `<audio_name>_逐字稿.md`
- For formatting/cleanup, use `transcript-refine`.
