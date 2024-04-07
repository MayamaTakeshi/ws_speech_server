open Types

module Synther = {
  type t = {
    wc: wsconn,
    ss_stream: option<stream>
  }

  let make = (wc) => {
    wc,
    ss_stream: None
  }

  let start = (synther, args) => {
    switch synther.ss_stream {
    | None => {...synther, ss_stream: None}
    | Some(sss) => {...synther, ss_stream: Some(sss)}
    }
  }
}
