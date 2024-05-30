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

@module external create_stream_factory: 'a => 'b = "speech-synth-and-recog-stream-factory"

@send external removeAllListeners: wsconn => unit = "removeAllListeners"

let count = ref(0)

let system = start()

let wss = webSocketServer({
  host: config.host,
  port: config.port,
});

let prepare_server = (stream_factory) => {
  onConnection(wss, wc => {
    count := count.contents+1
    Js.log2(`new connection`, count.contents);
    let sa = SpeechAgent.make(system, `sa-${Belt.Int.toString(count.contents)}`, wc, stream_factory)

    onMessage(wc, (m, isBinary) => {
      if !isBinary {
        dispatch(sa, WSString(m))
      } else {
        ()
      }
    });

    onError(wc, (err) => {
      Js.log2("ws error", err)
      Js.log(`ws error ${err}`)
      removeAllListeners(wc)
      dispatch(sa, WSError)
    });

    onClose(wc, () => {
      removeAllListeners(wc)
      dispatch(sa, WSClose)
    });
  });
}

Js.log(config)
create_stream_factory(config)
|> Js.Promise.then_(stream_factory => {
    Js.log2("Promise resolved with stream_factory: ", stream_factory);
    prepare_server(stream_factory)
    Js.Promise.resolve();
  })
|> Js.Promise.catch(error => {
    Js.log("Error occurred: " ++ Js.String.make(error));
    Js.Promise.resolve();
  })
|> ignore; // Ignore the final promise since we're just waiting for completion


