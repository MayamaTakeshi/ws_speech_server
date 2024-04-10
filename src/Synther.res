open Types

@new @module("dtmf-generation-stream") external makeDtmfGenerationStream : ('a, 'b) => stream = "DtmfGenerationStream";

@send external read: (stream, int) => 'buffer = "read"

@send external send: (wsconn, 'buffer, bool) => unit = "send"

@send external enqueue: (stream, string) => unit = "enqueue"

module Synther = {
  type t = {
    wc: wsconn,
    intId: Js.Nullable.t<Js.Global.intervalId>,
    stream: option<stream>
  }

  let make = (wc) => {
    wc,
    intId: Js.Nullable.null,
    stream: None
  }

  let createStream = (st, args) => {
    let stream = makeDtmfGenerationStream({
      "sampleRate": 8000,
      "bitDepth": 16,
      "channels": 1,
    }, {
      "stay_alive": true,
    })
    let intId = Js.Global.setInterval(() => {
      //let data = %raw(`stream.read(320)`)
      let data = read(stream, 320)
      Js.log2("interval", data)
      send(st.wc, data, true)
    }, 20)
    //enqueue(stream, args["text"])
    let _ = %raw(`stream.enqueue(args["text"])`)
    {...st, stream: Some(stream), intId: Js.Nullable.return(intId)}
  }

  let destroyStream = (synther) => {
    switch synther.stream {
    | Some(sss) =>
      let _ = %raw(`sss.destroy()`) // %%raw() is not working so I am using %raw()

      switch (Js.Nullable.toOption(synther.intId)) {
      | Some(id) =>
        Js.log("intervalId found. Clearing it")
        Js.Global.clearInterval(id);
        {...synther, stream: None, intId: Js.Nullable.null}
      | None =>
        Js.log("intervalId not found")
        {...synther, stream: None}
      }
    | None =>
      synther 
    }
  }

  let start = (synther, args) => {
    synther 
    -> destroyStream
    -> createStream(_, args)
  }

  let stop = (synther) => {
    Js.log("synther stop")
    destroyStream(synther)
  }
}
