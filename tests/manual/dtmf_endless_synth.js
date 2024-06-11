const { WebSocket } = require('ws')
const Speaker = require('speaker')
const DtmfDetectionStream = require('dtmf-detection-stream')
const au = require('@mayama/audio-utils')

const audioFormat = 1
const sampleRate = 8000
const signed = true

const format = {
  audioFormat,
	sampleRate,
	bitDepth: 16,
	channels: 1,
  signed,
}

const speaker = new Speaker(format)

// We need to write some initial silence to the speaker to avoid scratchyness/gaps
const size = 320 * 16
console.log("writing initial silence to speaker", size)
data = au.gen_silence(audioFormat, signed, size)
speaker.write(data)

const ws = new WebSocket('ws://0.0.0.0:8080')

ws.on('error', console.error)

const send_start_speech_synth = () => {
    console.log("sending start_speech_synth")
    ws.send(JSON.stringify({
      cmd: "start_speech_synth",
      args: {
        sampleRate,
        engine: "dtmf-ss",
        voice: "dtmf",
        language: "dtmf",
        text: 'ABCD',
        times: 1,
      }})
    )
}

ws.on('open', function open() {
  send_start_speech_synth()
})

const dds = new DtmfDetectionStream({format})

dds.on('dtmf', data => {
  console.log('dtmf', data)
  if(data.digit == 'd') {
    // last digit. ask for speech synth again
    send_start_speech_synth()
  }
})

ws.on('message', function message(data, isBinary) {
  /*
  console.log("message", isBinary, data)
  */
  if(isBinary) {
    speaker.write(data)
    dds.write(data)
  } else {
    console.log('received: %s', data)
  }
})
