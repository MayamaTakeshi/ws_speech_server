# ws_speech_server

## Overview

This is a websocket server app that provides access to speech synth/recog services.

It is mostly a helper for sip-lab to permit it to use speech synth/recog engines like google tts/stt, whisper etc during tests.

At the moment we only support engines 'dtmf-gen', 'dtmf-det', 'gss' and 'gsr'.

## Build

```
npm i
npm run build
cp config/default.js.sample config/default.js # adjust if necessary
```

If the build fails with something like:
```
$ npm run build

> ws_speech_server@1.0.0 build
> npx rescript build                                                                       

rescript: [1/2] src/SpeechAgent.cmj
FAILED: src/SpeechAgent.cmj
                                             
  We've found a bug for you!
  /root/tmp/ws_speech_server/src/SpeechAgent.res:2:6-9
                                             
  1 │ open Types                     
  2 │ open Nact                        
  3 │ //open Commands                                                                      
  4 │ open Synther                  
                                                                                           
  The module or file Nact can't be found.
  - If it's a third-party dependency:                                                      
    - Did you list it in bsconfig.json?                                                    
    - Did you run `rescript build` instead of `rescript build -with-deps`
      (latter builds third-parties)?
  - Did you include the file's directory in bsconfig.json?
                                             
FAILED: cannot make progress due to previous errors.
```
do this:
```
npm run clean
npm run build
```

## Starting
```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/credentials/file
node src/App.bs.js
```

## Commands
The ws_speech_server supports the following commands that are sent as JSON on the WebSocket connection:
  - start_speech_synth
  - start_speech_recog
  - stop_speech_synth
  - stop_speech_recog

Ex:
```
{
  cmd: "start_speech_synth",
  args: {
    sampleRate: 8000, // 8000 | 16000 | 32000 | 44100 | 48000
    engine: "dtmf-gen", // dtmf-gen | gss
    voice: "dtmf",
    language: "dtmf",
    text: '1234',
    times: 1, // number of times the text should be played
  }
}

{
  cmd: "start_speech_recog",
  args: {
    sampleRate: 8000, // 8000 | 16000 | 32000 | 44100 | 48000
    engine: "dtmf-det", // dtmf-det | gsr
    language: "dtmf",
  }
}
```

## Events

The ws_speech_server will emit the following events:

  - synth_complete (when cmd start_speech_synth reaches the end of audio output)
  - speech (when cmd start_speech_recog detects speech)

Ex:
```
{"evt": "synth_complete"}

{"evt": "speech", "data": {"transcript":"abcd","timestamp":0.46}}
```

## Testing

See manual tests [here](https://github.com/MayamaTakeshi/ws_speech_server/tree/main/tests/manual)

## reason-nact

We use reason-nact (actually, this is "rescript-nact") however it cannot be used with latest rescript 11 so we will stay with rescript 9.

This means we will not be able to use more recent modules which require rescript 11 like https://github.com/glennsl/rescript-json-combinators.


