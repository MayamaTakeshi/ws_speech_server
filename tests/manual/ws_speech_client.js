import WebSocket from 'ws';

const ws = new WebSocket('ws://0.0.0.0:8080');

ws.on('error', console.error);

ws.on('open', function open() {
  setInterval(() => {
  ws.send(JSON.stringify({
    cmd: "start_speech_synth",
    args: {
      engine: "dtmf",
      voice: "dtmf",
      text: "1234"
    }})
  )
  }, 1000)
});

ws.on('message', function message(data) {
  console.log('received: %s', data);
});
