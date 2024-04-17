const { WebSocket } = require('ws')
const Speaker = require('speaker')
const DtmfGenerationStream = require('dtmf-generation-stream')

const sampleRate = 8000

const format = {
	sampleRate,
	bitDepth: 16,
	channels: 1
}

const s = new Speaker(format)

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

const dgs = new DtmfGenerationStream({format})

dgs.enqueue('1234')

setInterval(() => {
  var bytes = (sampleRate / 8000) * 320
  var data = dgs.read(bytes)
  ws.send(data, true)
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
    var d = JSON.parse(data)
    console.log('received: %s', d)
    console.log(d.digit)
  }
})
