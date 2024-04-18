# Manual tests

Here we have some tests that you can start manually.

First ensure that ws_speech_server is built and ready:
```
npm i
npm run build
node src/App.bs.js
```

Then in another shell execute any of these test scripts:
```
node endless_synth.js

node endless_recog.js

node endless_synth_and_recog.js
