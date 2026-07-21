# Privacy

SPEAKEX is designed for local dictation by default. Optional AI features (the
OpenAI Cloud speech model, AI text correction, and the translator) send data
to OpenAI's API and must be explicitly enabled — they are off until you enter
an OpenAI API key.

## Data that stays on the Mac by default

- With the local (Parakeet) speech model, microphone audio is processed
  locally and is not sent to a transcription API.
- Successful transcripts, timing statistics, corrections, and preferences are
  stored under `~/Library/Application Support/SPEAKEX`.
- Your OpenAI API key, if entered, is stored in a file with owner-only
  permissions under `~/Library/Application Support/SPEAKEX`, never in
  UserDefaults or the Keychain.
- Diagnostic logs are stored under `~/Library/Logs` and avoid transcript text.
- Pending audio is kept only as a crash-recovery safeguard and is removed after
  it has been handled.
- The speech model is cached by FluidAudio under
  `~/Library/Application Support/FluidAudio/Models`.

## Data sent to OpenAI (only when you enable it)

- **OpenAI Cloud speech model**: the recorded audio for each dictation is
  uploaded to OpenAI's transcription API.
- **Text correction (AI)** and **Translator**: the transcribed text (not
  audio) is sent to OpenAI's chat completions API for correction or
  translation.

These features are controlled from the panel and the menu bar; both stay
locked until an OpenAI API key is entered, and can be turned off at any time.

## Network access

Beyond the optional OpenAI calls above, SPEAKEX uses the network only to
download the speech model through FluidAudio and to check the public GitHub
releases endpoint for updates. The installer downloads the application from
the same public repository. It has no account system, advertising, analytics,
or telemetry of its own.

## macOS permissions

- **Microphone** records speech while dictation is active.
- **Accessibility** inserts the resulting text into the focused field.
- **Input Monitoring** observes the configured global hotkey.
