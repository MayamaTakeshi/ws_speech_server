type webSocketOptions = {
  port: int,
  // Add other options as needed
};

type wsserver
@new @module("ws") external webSocketServer : webSocketOptions => wsserver = "WebSocketServer";

type wsconn
@send external onConnection: (wsserver, @as("connection") _, @uncurry (wsconn => unit)) => unit = "on"

@send external onMessage: (wsconn, @as("message") _, @uncurry (string => unit)) => unit = "on"

let wss = webSocketServer({
  port: 8080
});

type state = {
  wc: wsconn,
};

type connectionMap = Belt.Map.Int.t<state>; // Use Belt.Map.Int.t for int keys

let connections: connectionMap = Belt.Map.Int.empty; // Initialize an empty map

let count = ref(0);

let addConnection = (wc: wsconn): int => {
  let id = count.contents;
  count := id + 1;
  connections = Belt.Map.Int.set(connections, id, {wc: wc});
  id;
};

let getConnection = (id: int): option<state> => {
  Belt.Map.Int.get(connections, id);
};
onConnection(wss, wc => {
  Js.log("new connection");
  let id = addConnection(wc);

  onMessage(wc, m => {
    Js.log(`got message=${m} from ${id}`);
  });
});

