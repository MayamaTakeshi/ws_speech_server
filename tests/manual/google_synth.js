const { WebSocket } = require('ws')
const Speaker = require('speaker')
const au = require('@mayama/audio-utils')

const audioFormat = 1
const sampleRate = 16000
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
const size = 320 * 64
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
        engine: "google-ss",
        voice: "en-US-Standard-G",
        language: "en-US",
        text: 'hello world',
        times: 2,
      }})
    )
}

ws.on('open', function open() {
  send_start_speech_synth()
})

ws.on('message', function message(data, isBinary) {
  if(isBinary) {
    speaker.write(data)
    ws.send(data, isBinary)
  } else {
    var d = JSON.parse(data)
    console.log('received:', JSON.stringify(d, null, 2))
    if(d.evt == 'synth_complete') {
      setTimeout(() => {
        process.exit(0)
      }, 3000)
    }
  }
})
