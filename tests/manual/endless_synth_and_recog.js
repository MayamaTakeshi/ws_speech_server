const { WebSocket } = require('ws')
const Speaker = require('speaker')

const sampleRate = 8000

const format = {
	sampleRate,
	bitDepth: 16,
	channels: 1
}

const s = new Speaker(format)

const ws = new WebSocket('ws://0.0.0.0:8080')

ws.on('error', console.error)

const send_start_speech_synth = () => {
    console.log("sending start_speech_synth")
    ws.send(JSON.stringify({
      cmd: "start_speech_synth",
      args: {
        sampleRate,
        engine: "dtmf-gen",
        voice: "dtmf",
        text: 'ABCD'
      }})
    )
}

const send_start_speech_recog = () => {
    console.log("sending start_speech_recog")
    ws.send(JSON.stringify({
      cmd: "start_speech_recog",
      args: {
        sampleRate,
        engine: "dtmf-det",
        language: "dtmf",
      }})
    )
}

ws.on('open', function open() {
  send_start_speech_synth()
  send_start_speech_recog()
})

ws.on('message', function message(data, isBinary) {
  /*
  console.log("message", isBinary, data)
  console.log("data.length", data.length)
  console.log("data.buffer.length", data.buffer.length)
  console.log("data.buffer.byteLength", data.buffer.byteLength)
  */
  if(isBinary) {
    s.write(data)
    ws.send(data, isBinary)
  } else {
    console.log('received: %s', data)
    var d = JSON.parse(data)
    if(d.evt == "speech") {
      send_start_speech_synth()
    }
  }
})
