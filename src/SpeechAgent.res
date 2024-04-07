open Types
open Nact
open Commands
open Synther
open Recoger

type msg =
  | WSString(string)
  | WSError
  | WSClose

type wsconn

type state = {
  wc: wsconn,
  synther: Synther.t,
  recoger: Recoger.t
}

let processString = (st, s) => {
  let c = decode(s)
  switch c {
  | StartSpeechSynth(args) =>
    Synther.start(st.synther, args)
    st
  | StartSpeechRecog(args) =>
    Recoger.start(st.recoger, args)
    st
  | _ => 
    Js.log("Unknown")
    st
  }
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
             st
           }
           | WSClose => {
             Js.log(`Got close`);
             st
           }
        }
    }->Js.Promise.resolve,
    _ => { 
      Js.log(`Created ${id}`)
      {wc, synther: Synther.make(wc), recoger: Recoger.make(wc)}
    } 
  );
