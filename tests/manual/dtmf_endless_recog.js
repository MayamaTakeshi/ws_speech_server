const { WebSocket } = require('ws')
const Speaker = require('speaker')
const DtmfGenerationStream = require('dtmf-generation-stream')
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
  send_start_speech_recog()
})

const params = {
  text: '<speak><prosody rate="50ms">1234</prosody><break time="500ms"/></speak>',
  times: Infinity,
}
  
const dgs = new DtmfGenerationStream({format, params})

setInterval(() => {
  var bytes = (sampleRate / 8000) * 320
  var data = dgs.read(bytes)
  ws.send(data, true)
  speaker.write(data)
}, 20)

ws.on('message', function message(data, isBinary) {
  /*
  console.log("message", isBinary, data)
  console.log("data.length", data.length)
  console.log("data.buffer.length", data.buffer.length)
  console.log("data.buffer.byteLength", data.buffer.byteLength)
  */
  if(isBinary) {
    console.log('received unexpected binary', data)
  } else {
    console.log('received: %s', data)
    var d = JSON.parse(data)
  }
})
