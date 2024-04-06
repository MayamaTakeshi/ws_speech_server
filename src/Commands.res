type cmdArgs = Js.Dict.t<string>;

type cmd = 
  | StartSpeechSynth(cmdArgs)
  | StartSpeechRecog(cmdArgs)
  | Unknown

let decode_json = %raw(`function(s) { return JSON.parse(s); }`);

let decode = s => {
  let decoded = decode_json(s)
  switch (Js.Dict.get(decoded, "cmd")) {
  | Some(c) => 
    if c == "start_speech_synth" {
      switch (Js.Dict.get(decoded, "args")) {
      | Some(args) => 
        StartSpeechSynth(args)
      | None =>
        Unknown
      }
    } else if c == "start_speech_recog" {
      switch (Js.Dict.get(decoded, "args")) {
      | Some(args) => 
        StartSpeechRecog(args)
      | None =>
        Unknown
      }
    } else {
      Unknown
    }
  | _ => Unknown
}
}
