open Types
open Nact
open Commands
open Synther
open Recoger

type msg =
  | WSString(string)
  | WSError
  | WSClose

type state = {
  wc: wsconn,
  synther: Synther.t,
  recoger: Recoger.t
}

let processString = (st, s) => {
  let c = decode(s)
  switch c {
  | StartSpeechSynth(args) =>
    {...st, synther: Synther.start(st.synther, args)}
  | StartSpeechRecog(args) =>
    {...st, recoger: Recoger.start(st.recoger, args)}
  | _ => 
    Js.log("Unknown")
    st
  }
}

let stop = (st: state) => {
  let _ = Synther.stop(st.synther)
  let _ = Recoger.stop(st.recoger)
  st
}

let createSpeechAgent = (parent, id, wc) =>
  spawn(
    ~name=id,
    parent,
    (st, m, _) => {
        switch m {
           | WSString(s) => {
             Js.log(`Got ${s}`);
             processString(st, s)
           }
           | WSError => {
             Js.log(`Got error`);
             stop(st)
           }
           | WSClose => {
             Js.log(`Got close`);
             stop(st)
           }
        }
    }->Js.Promise.resolve,
    _ => {
      Js.log(`Created ${id}`)
      {wc, synther: Synther.make(wc), recoger: Recoger.make(wc)}
    } 
  );
