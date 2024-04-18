# ws_speech_server

## Overview

This is a websocket server app that provides access to speech synth/recog services.

It is mostly a helper for sip-lab to permit it to use speech synth/recog engines like google tts/stt, whisper etc during tests.

However, at the moment we only support engines 'dtmf-gen' and 'dtmf-det' that are used to simulate speech using DTMF tones.

## Build

- Build: `npm run build`
- Clean: `npm run clean`
- Build & watch: `npm run start`

## Testing

See manual tests [here](https://github.com/MayamaTakeshi/ws_speech_server/tree/main/tests/manual)

## reason-nact

We use reason-nact (actually, this is "rescript-nact") however it cannot be used with latest rescript 11 so we will stay with rescript 9.

This means we will not be able to use more recent modules which require rescript 11 like https://github.com/glennsl/rescript-json-combinators.


