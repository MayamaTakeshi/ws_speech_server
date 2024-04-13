type synthArgs = {
  engine: string,
  voice: string,
  text: string,
}

let checkSynthArgs = args => {
  try {
    switch (Js.Dict.get(args, "engine"), Js.Dict.get(args, "voice"), Js.Dict.get(args, "text")) {
    | (Some(engineJson), Some(voiceJson), Some(textJson)) =>
      switch (
        Js.Json.decodeString(engineJson),
        Js.Json.decodeString(voiceJson),
        Js.Json.decodeString(textJson),
      ) {
      | (Some(engine), Some(voice), Some(text)) => Some({engine: engine, voice: voice, text: text})
      | _ => None
      }
    | _ => None
    }
  } catch {
  | _ => None
  }
}

type recogArgs = {
  engine: string,
  language: string,
}

let checkRecogArgs = args => {
  try {
    switch (Js.Dict.get(args, "engine"), Js.Dict.get(args, "language")) {
    | (Some(engineJson), Some(languageJson)) =>
      switch (Js.Json.decodeString(engineJson), Js.Json.decodeString(languageJson)) {
      | (Some(engine), Some(language)) => Some({engine: engine, language: language})
      | _ => None
      }
    | _ => None
    }
  } catch {
  | _ => None
  }
}

type cmd =
  | StartSpeechSynth(synthArgs)
  | StartSpeechRecog(recogArgs)
  | Unknown

@scope("JSON") @val external decode_json: string => 'a = "parse"

let decode = s => {
  let decoded = decode_json(s)
  switch Js.Dict.get(decoded, "cmd") {
  | Some(c) =>
    if c == "start_speech_synth" {
      switch Js.Dict.get(decoded, "args") {
      | Some(args) =>
        switch checkSynthArgs(args) {
        | Some(synthArgs) => StartSpeechSynth(synthArgs)
        | _ => Unknown
        }
      | None => Unknown
      }
    } else if c == "start_speech_recog" {
      switch Js.Dict.get(decoded, "args") {
      | Some(args) =>
        switch checkRecogArgs(args) {
        | Some(recogArgs) => StartSpeechRecog(recogArgs)
        | _ => Unknown
        }
      | None => Unknown
      }
    } else {
      Unknown
    }
  | _ => Unknown
  }
}
