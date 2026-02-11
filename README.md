# OpenClaw Audio Pipeline Skills

Three-layer reusable workflow:

1. `audio-ingest` - fetch/download source audio (e.g. Xiaoyuzhou)
2. `audio-transcribe` - chunked ASR transcription to markdown
3. `transcript-refine` - Gemini prompt-based transcript formatting/refinement

## Shared Scripts

- `scripts/xiaoyuzhou_fetch.sh`
- `scripts/audio_transcribe_to_md.sh`
- `scripts/transcript_refine_gemini.sh`

## Skill Entrypoints

- `skills/audio-ingest/scripts/ingest_xiaoyuzhou.sh`
- `skills/audio-transcribe/scripts/transcribe_audio.sh`
- `skills/transcript-refine/scripts/refine_with_gemini.sh`
