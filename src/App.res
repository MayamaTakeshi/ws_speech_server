open Nact
open SpeechAgent
open Types

type webSocketOptions = {
  port: int,
  // Add other options as needed
};

type wsserver

@new @module("ws") external webSocketServer : webSocketOptions => wsserver = "WebSocketServer";

@send external onConnection: (wsserver, @as("connection") _, @uncurry (wsconn => unit)) => unit = "on"

@send external onMessage: (wsconn, @as("message") _, @uncurry (('a, bool) => unit)) => unit = "on"
@send external onError: (wsconn, @as("error") _, @uncurry ('err => unit)) => unit = "on"
@send external onClose: (wsconn, @as("close") _, @uncurry (unit => unit)) => unit = "on"

let count = ref(0)

let system = start()

let wss = webSocketServer({
  port: 8080
});

onConnection(wss, wc => {
  count := count.contents+1
  Js.log2(`new connection`, count.contents);
  let sa = createSpeechAgent(system, `sa-${Belt.Int.toString(count.contents)}`, wc)

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

