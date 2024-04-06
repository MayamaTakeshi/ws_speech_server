open Nact
open SpeechAgent

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

let system = start()

let wss = webSocketServer({
  port: 8080
});

onConnection(wss, wc => {
  Js.log("new connection");
  let sa = createSpeechAgent(system, wc)

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

