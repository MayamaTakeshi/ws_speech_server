open Types

@send external read: (stream, int) => 'buffer = "read"

@send external send: (wsconn, 'buffer, bool) => unit = "send"

@send external destroy: stream => unit = "destroy"

@send external removeAllListeners: stream => unit = "removeAllListeners"

@bs.module("@mayama/audio-utils") external gen_silence: (int, bool, int) => 'a = "gen_silence"

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

  let createStream = (st, args: Commands.synthArgs) => {
    let stream = st.stream_factory({
        "uuid": "fake-uuid",
        "engine": args.engine,
        "type": "synth",
        "format": {
          audioFormat: 1, // LINEAR16
          sampleRate: args.sampleRate,
          bitDepth: 16,
          channels: 1,
        },
        "params": Js.Dict.fromArray(
          [
            ("language", Js.Json.string(args.language)),
            ("voice", Js.Json.string(args.voice)),
            ("text", Js.Json.string(args.text)),
            ("times", Js.Json.number(args.times)),
          ])
          -> Js.Json.object_

    })
    Js.log2("stream", stream)
    let bytes = (args.sampleRate / 8000) * 640
    let speakCompleteSent = ref(false)
    let intId = Js.Global.setInterval(() => {
      let data = read(stream, bytes)
      //Js.log2("interval", data)
      if(data) {
        send(st.wc, data, true)
      } else {
        if (!speakCompleteSent.contents) {
          let msg = `{"evt": "synth_complete"}`
          Js.log(msg)
          send(st.wc, msg, false)
          speakCompleteSent := true
        }

        let silence = gen_silence(1, true, bytes)
        //Js.log2("sending silence", silence)
        send(st.wc, silence, true)
      }
    }, 20)
    {...st, stream: Some(stream), intId: Js.Nullable.return(intId)}
  }

  let destroyStream = synther => {
    switch synther.stream {
    | Some(s) => 
      removeAllListeners(s)

      destroy(s)

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
