open Nact
open Commands

type msg =
  | WSString(string)
  | WSError
  | WSClose

type stream = string
type wsconn

type state = {
  wc: wsconn,
  ss_stream: option<stream>,
  sr_stream: option<stream>
}

let processString = (st, s) => {
  let c = decode(s)
  switch c {
  | StartSpeechSynth(args) =>
    switch st {
    | {ss_stream: Some(sss)} => 
      Js.log("sss already in place")
      st
    | {ss_stream: None} => 
      Js.log("sss not set")
      {...st, ss_stream: Some("ss")}
    }
  | StartSpeechRecog(args) =>
    Js.log("StartSpeechRecog")
    st
  | _ => 
    Js.log("Unknown")
    st
  }
}

let createSpeechAgent = (parent, wc) =>
  spawn(
    parent,
    (st, m, _) => {
        switch m {
           | WSString(s) => {
             Js.log(`Got ${s}`);
             processString(st, s)
           }
           | WSError => {
             Js.log(`Got error`);
             st
           }
           | WSClose => {
             Js.log(`Got close`);
             st
           }
        }
    }->Js.Promise.resolve,
    _ => {wc, ss_stream: None, sr_stream: None}
  );
