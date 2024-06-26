const { WebSocket } = require('ws')
const Speaker = require('speaker')
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

const language = '300:2500'
const voice = '5' // tone duration

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
        engine: "bfsk-ss",
        voice,
        language,
        text: '<speak><prosody rate="5ms">hello world</prosody><break time="500ms"/></speak>',
        times: 1,
      }})
    )
}

const send_start_speech_recog = () => {
    console.log("sending start_speech_recog")
    ws.send(JSON.stringify({
      cmd: "start_speech_recog",
      args: {
        sampleRate,
        engine: "bfsk-sr",
        language,
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
  */
  if(isBinary) {
    speaker.write(data)
    ws.send(data, isBinary)
  } else {
    console.log('received: %s', data)
    var d = JSON.parse(data)
    if(d.evt == "speech") {
      send_start_speech_synth()
    }
  }
})
