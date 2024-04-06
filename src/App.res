type webSocketOptions = {
  port: int,
  // Add other options as needed
};

type wsserver
type wsconn

@new @module("ws") external webSocketServer : webSocketOptions => wsserver = "WebSocketServer";

@send external onConnection: (wsserver, @as("connection") _, @uncurry (wsconn => unit)) => unit = "on"

@send external onMessage: (wsconn, @as("message") _, @uncurry (string => unit)) => unit = "on"
@send external onError: (wsconn, @as("error") _, @uncurry ('err => unit)) => unit = "on"
@send external onClose: (wsconn, @as("close") _, @uncurry (unit => unit)) => unit = "on"

let wss = webSocketServer({
  port: 8080
});

onConnection(wss, wc => {
  Js.log("new connection");

  onMessage(wc, m => {
    Js.log(`got message=${m}`);
  });

  onError(wc, err => {
    Js.log(`got err=${err}`);
  });

  onClose(wc, () => {
    Js.log(`got close`);
  });
});

