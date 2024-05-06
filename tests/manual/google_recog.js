const { WebSocket } = require('ws')
const Speaker = require('speaker')
const fs = require('fs')
const wav = require('wav')
const au = require('@mayama/audio-utils')

const file = fs.createReadStream('../artifacts/how_are_you.16000hz.wav')
const reader = new wav.Reader()

reader.on('format', function (format) {
  const speaker = new Speaker(format)

  // We need to write some initial silence to the speaker to avoid scratchyness/gaps
  const size = 320 * 16
  console.log("writing initial silence to speaker", size)
  data = au.gen_silence(format.audioFormat, format.signed, size)
  speaker.write(data)

  const ws = new WebSocket('ws://0.0.0.0:8080')

  ws.on('error', console.error)

  const send_start_speech_recog = () => {
      console.log("sending start_speech_recog")
      ws.send(JSON.stringify({
        cmd: "start_speech_recog",
        args: {
          sampleRate: format.sampleRate,
          engine: "gsr",
          language: "en-US",
        }})
      )
  }

  ws.on('open', function open() {
    send_start_speech_recog()

    setInterval(() => {
      const size = format.sampleRate / 8000 * 320
      var data = reader.read(size)
      if(data) {
        /*
        if(data.length != size) {
          console.log("unexpected data length")
          const diff = size - data.length
          const silence = au.gen_silence(format.audioFormat, format.signed, diff)
          data = Buffer.concat([data, silence])
        }
        */
        ws.send(data, true) 
        speaker.write(data)
      } else {
        const silence = au.gen_silence(format.audioFormat, format.signed, size)
        ws.send(silence, true)
      }
    }, 20)
  })

  ws.on('message', function message(data, isBinary) {
    if(isBinary) {
      console.log("Unexpected binary message")
    } else {
      var d = JSON.parse(data)
      console.log('received:', JSON.stringify(d, null, 2))
      if(d.evt == 'speech') {
        process.exit(0)
      }
    }
  })

})

file.pipe(reader)

