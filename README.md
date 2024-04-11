# ws_speech_server

## Overview

WIP. Nothing to see yet.

This is a websocket server app that provides access to speech synth/recog services.

It is mostly a helper for sip-lab to permit it to use google tts/stt, whisper etc during tests.

## Build

- Build: `npm run build`
- Clean: `npm run clean`
- Build & watch: `npm run start`

## reason-nact

We use reason-nact (actually, this is "rescript-nact") however it cannot be used with latest rescript 11 so we will stay with rescript 9.

This means we will not be able to use more recent modules which require rescript 11 like https://github.com/glennsl/rescript-json-combinators.


