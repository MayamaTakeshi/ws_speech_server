open Types
open Commands

module Recoger = {
  type t = {
    wc: wsconn,
    stream: option<stream>,
  }

  let make = wc => {
    wc: wc,
    stream: None,
  }

  let start = (recoger, _args: recogArgs) => {
    switch recoger.stream {
    | None => {...recoger, stream: None}
    | Some(srs) => {...recoger, stream: Some(srs)}
    }
  }

  let stop = recoger => {
    recoger
  }

  // Need to call sr_stream.end() and this will call writable._final in our stream
}
