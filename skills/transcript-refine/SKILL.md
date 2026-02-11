---
name: transcript-refine
description: Refine raw transcript markdown into structured publishable notes using Gemini and a prompt template (e.g., Obsidian Inbox/Youtube Transcript prompt). Use after ASR/transcription.
---

# Transcript Refine

Apply a formatting/quality prompt to raw transcript markdown.

## Command

```bash
bash scripts/refine_with_gemini.sh \
  --prompt-file "$HOME/Documents/ObsidianVault/Inbox/Youtube Transcript prompt.md" \
  "/path/to/raw_transcript.md"
```

## Notes

- Default model: `gemini-3-pro-preview`
- Default output: `<input>_Gemini整理.md`
- Keep this step separate from ASR for reuse across platforms.
