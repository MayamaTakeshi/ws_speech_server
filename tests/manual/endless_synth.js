const { WebSocket } = require('ws')
const Speaker = require('speaker')
const DtmfDetectionStream = require('dtmf-detection-stream')

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

ws.on('open', function open() {
  send_start_speech_synth()
})

const dds = new DtmfDetectionStream({format})

dds.on('dtmf', data => {
  console.log('dtmf', data)
  if(data.digit == 'D') {
    // last digit. ask for speech synth again
    send_start_speech_synth()
  }
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
    dds.write(data)
  } else {
    console.log('received: %s', data)
  }
})
