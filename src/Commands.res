type synthArgs = {
  sampleRate: int,
  engine: string,
  voice: string,
  text: string,
}

let checkSynthArgs = args => {
  try {
    switch (Js.Dict.get(args, "sampleRate"), Js.Dict.get(args, "engine"), Js.Dict.get(args, "voice"), Js.Dict.get(args, "text")) {
    | (Some(sampleRateJson), Some(engineJson), Some(voiceJson), Some(textJson)) =>
      switch (
        Js.Json.decodeNumber(sampleRateJson),
        Js.Json.decodeString(engineJson),
        Js.Json.decodeString(voiceJson),
        Js.Json.decodeString(textJson),
      ) {
      | (Some(sampleRate), Some(engine), Some(voice), Some(text)) => Some({
          sampleRate: Belt.Int.fromFloat(sampleRate),
          engine,
          voice,
          text
        })
      | _ => None
      }
    | _ => None
    }
  } catch {
  | _ => None
  }
}

type recogArgs = {
  sampleRate: int,
  engine: string,
  language: string,
}

let checkRecogArgs = args => {
  try {
    switch (Js.Dict.get(args, "sampleRate"), Js.Dict.get(args, "engine"), Js.Dict.get(args, "language")) {
    | (Some(sampleRateJson), Some(engineJson), Some(languageJson)) =>
      switch (Js.Json.decodeNumber(sampleRateJson), Js.Json.decodeString(engineJson), Js.Json.decodeString(languageJson)) {
      | (Some(sampleRate), Some(engine), Some(language)) => Some({
          sampleRate: Belt.Int.fromFloat(sampleRate),
          engine,
          language
        })
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
  | StopSpeechSynth
  | StopSpeechRecog
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
    } else if c == "stop_speech_synth" {
      StopSpeechSynth
    } else if c == "stop_speech_recog" {
      StopSpeechRecog
    } else {
      Unknown
    }
  | _ => Unknown
  }
}
