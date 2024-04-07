open Types

module Synther = {
  type t = {
    wc: wsconn,
    intId: Js.Global.intervalId,
    ssStream: option<stream>
  }

  let make = (wc) => {
    wc,
    intId: ref(Js.Nullable.null),
    ssStream: None
  }

  let createStream = (st, args) => {
    let intId = Js.Nullable.return(Js.Global.setInterval(() => {
      Js.log("interval")
    }, 50))
    {...st, intId}
  }

  let destroyStream = (st) => {
    switch st.ssStream {
    | Some(sss) =>
      let _ = %raw(`sss.close()`) // %%raw() is not working so I am using %raw()
      {...st, ssStream: None}
    | None =>
      st
    }
  }

  let start = (synther, args) => {
    synther 
    -> destroyStream
    -> createStream(_, args)
  }
}
