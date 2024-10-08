open Types
//open Commands

@send external write: (stream, 'data) => unit = "write"

@send external end: stream => unit = "end"

@send external onSpeech: (stream, @as("speech") _, @uncurry ('data => unit)) => unit = "on"

@send external send: (wsconn, 'buffer, bool) => unit = "send"

@send external onMessage: (wsconn, @as("message") _, @uncurry ('buffer => bool => unit)) => unit = "on"

@send external removeAllListeners: stream => unit = "removeAllListeners"

@val external randomUUID: unit => string = "crypto.randomUUID"

module Recoger = {
  type t = {
    wc: wsconn,
    stream_factory: stream_factory,
    stream: option<stream>,
  }

  let make = (wc, stream_factory) => {
    wc: wc,
    stream_factory: stream_factory,
    stream: None,
  }

  let createStream = (st, args: Commands.recogArgs) => {
    let stream = st.stream_factory({
        "uuid": randomUUID(),
        "engine": args.engine,
        "type": "recog",
        "format": {
          audioFormat: 1, // LINEAR16
          sampleRate: args.sampleRate,
          bitDepth: 16,
          channels: 1,
        },
        //"params": RecogParams({"language": args.language}),
        //"params": Js.Dict.fromArray([("language", args.language)]),
        //"params": Js.Json.object_(Js.Dict.fromArray([("language", Js.Json.string(args.language)) ]))
        "params": Js.Dict.fromArray([("language", Js.Json.string(args.language))])
                   -> Js.Json.object_
      })
    Js.log2("stream", stream)
    onSpeech(stream, (data) => {
      Js.log2("onSpeech", data)
      send(st.wc, `{"evt": "speech", "data": ` ++ Js.Json.stringify(data) ++ `}`, false)
    })
    onMessage(st.wc, (data, isBinary) => {
      //Js.log3("onMessage", data, isBinary)
      if isBinary {
        write(stream, data)
      } else {
        ()
      }
    })
    {...st, stream: Some(stream)}
  }

  let destroyStream = recoger => {
    switch recoger.stream {
    | Some(s) => 
      removeAllListeners(s)

      end(s) // this will call writable._final in our stream
      {...recoger, stream: None}
    | None => recoger
    }
  }

  let start = (recoger, args) => {
    recoger->destroyStream->createStream(_, args)
  }

  let stop = recoger => {
    Js.log("recoger stop")
    destroyStream(recoger)
  }
}
