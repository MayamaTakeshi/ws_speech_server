open Types

type cmd = 
  | StartSpeechSynth(cmdArgs)
  | StartSpeechRecog(cmdArgs)
  | Unknown

@scope("JSON") @val external decode_json: string => 'a = "parse"

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
