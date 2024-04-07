open Types

module Synther = {
  type t = {
    wc: stream,
    ss_stream: option<stream>
  }

  let make = (wc) => {
    wc
  }

  let start = (synther, args) => {
    ()
  }
}
