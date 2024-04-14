open Nact
open SpeechAgent
open Types

let config = %raw(`require('config')`)

type webSocketOptions = {
  host: string,
  port: int,
  // Add other options as needed
};

type wsserver

@new @module("ws") external webSocketServer : webSocketOptions => wsserver = "WebSocketServer";

@send external onConnection: (wsserver, @as("connection") _, @uncurry (wsconn => unit)) => unit = "on"

@send external onMessage: (wsconn, @as("message") _, @uncurry (('a, bool) => unit)) => unit = "on"
@send external onError: (wsconn, @as("error") _, @uncurry ('err => unit)) => unit = "on"
@send external onClose: (wsconn, @as("close") _, @uncurry (unit => unit)) => unit = "on"

@module external load_engines: () => 'a = "./Engines.js"

let count = ref(0)

let system = start()

let wss = webSocketServer({
  host: config.host,
  port: config.port,
});

let prepare_server = (engines) => {
  onConnection(wss, wc => {
    count := count.contents+1
    Js.log2(`new connection`, count.contents);
    let sa = SpeechAgent.make(system, `sa-${Belt.Int.toString(count.contents)}`, wc)

    onMessage(wc, (m, isBinary) => {
      if !isBinary {
        dispatch(sa, WSString(m))
      } else {
        ()
      }
    });

    onError(wc, () => {
      dispatch(sa, WSError)
    });

    onClose(wc, () => {
      dispatch(sa, WSClose)
    });
  });
}

load_engines()
|> Js.Promise.then_(engines => {
    Js.log2("Promise resolved with engines: ", engines);
    prepare_server(engines)
    Js.Promise.resolve();
  })
|> Js.Promise.catch(error => {
    Js.log("Error occurred: " ++ Js.String.make(error));
    Js.Promise.resolve();
  })
|> ignore; // Ignore the final promise since we're just waiting for completion


