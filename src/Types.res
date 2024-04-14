type stream = string
type wsconn

type cmdArgs = Js.Dict.t<string>

type stream_module

type engine = {
  module_: string,
  config: Js.Json.t,
  name: string,
  type_: string,
  m: stream_module
}

type format = {
  sampleRate: int,
  bitDepth: int,
  channels: int,
}

type stream_factory = string => string => string => format => stream

