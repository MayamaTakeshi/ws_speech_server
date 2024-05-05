const { WebSocket } = require('ws')
const Speaker = require('speaker')

const sampleRate = 16000

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
        engine: "gss",
        voice: "en-US-Standard-G",
        language: "en-US",
        text: 'hello world'
      }})
    )
}

const send_start_speech_recog = () => {
    console.log("sending start_speech_recog")
    ws.send(JSON.stringify({
      cmd: "start_speech_recog",
      args: {
        sampleRate,
        engine: "gsr",
        language: "en-US",
      }})
    )
}

ws.on('open', function open() {
  send_start_speech_synth()
  send_start_speech_recog()
})

ws.on('message', function message(data, isBinary) {
  if(isBinary) {
    s.write(data)
    ws.send(data, isBinary)
  } else {
    var d = JSON.parse(data)
    console.log('received:', d)
    process.exit(0)
  }
})
