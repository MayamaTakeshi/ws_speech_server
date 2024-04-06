open Nact

type msg =
  | WSMessage(string)
  | WSError
  | WSClose

let createSpeechAgent = (parent, wc) =>
  spawn(
    parent,
    (_state, m, _) => {
        switch m {
           | WSMessage(s) => {
             Js.log(`Got ${s}`);
             {wc}
           }
           | WSError => {
             Js.log(`Got error`);
             {wc}
           }
           | WSClose => {
             Js.log(`Got close`);
             {wc}
           }
        }
    }->Js.Promise.resolve,
    _ => {wc}
  );
