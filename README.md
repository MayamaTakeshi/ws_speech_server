# ws_speech_server

## Overview

This is a websocket server app that provides access to speech synth/recog services.

It is mostly a helper for sip-lab to permit it to use speech synth/recog engines like google tts/stt, whisper etc during tests.

However, at the moment we only support engines 'dtmf-gen' and 'dtmf-det' that are used to simulate speech using DTMF tones.

## Build

- Build: `npm run build`
- Clean: `npm run clean`
- Build & watch: `npm run start`

## Starting
```
node src/App.bs.js
```

## Commands
The ws_speech_server supports the following commands that are sent as JSON on the WebSocket connection:
  - start_speech_synth
  - start_speech_recog

Ex:
```
{
  cmd: "start_speech_synth",
  args: {
    sampleRate: 8000, // 8000 | 16000 | 32000 | 44100 | 48000
    engine: "dtmf-gen",
    voice: "dtmf",
    text: '1234' // any DTMF tones: 0123456789abcd*#
  }
}

{
  cmd: "start_speech_recog",
  args: {
    sampleRate: 8000, // 8000 | 16000 | 32000 | 44100 | 48000
    engine: "dtmf-det",
    language: "dtmf",
  }
}
```

## Events

The ws_speech_server will emit the following events:

  - speak_complete (when cmd start_speech_synth reaches the end of audio output)
  - speech (when cmd start_speech_recog detects speech)

Ex:
```
{"evt": "speak_complete"}

{"evt": "speech", "data": {"transcript":"ABCD","timestamp":0.46}}
```

## Testing

See manual tests [here](https://github.com/MayamaTakeshi/ws_speech_server/tree/main/tests/manual)

## reason-nact

We use reason-nact (actually, this is "rescript-nact") however it cannot be used with latest rescript 11 so we will stay with rescript 9.

This means we will not be able to use more recent modules which require rescript 11 like https://github.com/glennsl/rescript-json-combinators.


