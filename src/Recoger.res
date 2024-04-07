open Types

module Recoger = {
  type t = {
    wc: wsconn,
    sr_stream: option<stream>
  }

  let make = (wc) => {
    wc,
    sr_stream: None
  }

  let start = (recoger, args) => {
    switch recoger.sr_stream {
    | None => {...recoger, sr_stream: None}
    | Some(srs) => {...recoger, sr_stream: Some(srs)}
    }
  }

  // Need to call sr_stream.end() and this will call writable._final in our stream
}
