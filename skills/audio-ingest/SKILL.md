---
name: audio-ingest
description: Ingest audio or source materials for transcription workflows. Use when users want to fetch/download source content (especially Xiaoyuzhou episodes) into local files before ASR/transcript processing.
---

# Audio Ingest

Use this skill to fetch source files first, then hand off to transcription/refine skills.

## Command

```bash
# xiaoyuzhou: download audio/md/both
bash scripts/ingest_xiaoyuzhou.sh --mode audio "<episode_url_or_id>"
```

## Notes

- Default output: `~/Downloads/Podcast/xiaoyuzhou`
- This skill only handles ingestion/downloading.
- For ASR, use `audio-transcribe`.
