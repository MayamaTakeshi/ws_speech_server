open Types

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
    let intId = Js.Global.setInterval(() => {
      Js.log("interval")
    }, 50)
    {...st, stream: Some("abc"), intId: Js.Nullable.return(intId)}
  }

  let destroyStream = (synther) => {
    switch synther.stream {
    | Some(sss) =>
      let _ = %raw(`sss.close()`) // %%raw() is not working so I am using %raw()

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
