open Types
open Commands

@send external read: (stream, int) => 'buffer = "read"

@send external send: (wsconn, 'buffer, bool) => unit = "send"

@send external enqueue: (stream, string) => unit = "enqueue"

@send external destroy: stream => unit = "destroy"

module Synther = {
  type t = {
    wc: wsconn,
    stream_factory: stream_factory,
    intId: Js.Nullable.t<Js.Global.intervalId>,
    stream: option<stream>,
  }

  let make = (wc, stream_factory) => {
    wc: wc,
    stream_factory: stream_factory,
    intId: Js.Nullable.null,
    stream: None,
  }

  let createStream = (st, args: synthArgs) => {
    let stream = st.stream_factory({
        "uuid": "fake-uuid",
        "engine": args.engine,
        "type": "synth",
        "format": {
          sampleRate: args.sampleRate,
          bitDepth: 16,
          channels: 1,
        },
      })
    Js.log2("stream", stream)
    let bytes = (args.sampleRate / 8000) * 320
    let intId = Js.Global.setInterval(() => {
      let data = read(stream, bytes)
      Js.log2("interval", data)
      send(st.wc, data, true)
    }, 20)
    enqueue(stream, args.text)
    {...st, stream: Some(stream), intId: Js.Nullable.return(intId)}
  }

  let destroyStream = synther => {
    switch synther.stream {
    | Some(sss) =>
      destroy(sss)

      switch Js.Nullable.toOption(synther.intId) {
      | Some(id) =>
        Js.log("intervalId found. Clearing it")
        Js.Global.clearInterval(id)
        {...synther, stream: None, intId: Js.Nullable.null}
      | None =>
        Js.log("intervalId not found")
        {...synther, stream: None}
      }
    | None => synther
    }
  }

  let start = (synther, args) => {
    synther->destroyStream->createStream(_, args)
  }

  let stop = synther => {
    Js.log("synther stop")
    destroyStream(synther)
  }
}
