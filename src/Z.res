type synthArgs = {
  engine: string,
  voice: string,
  text: string
};

let parseSynthArgs = (str: string): option<synthArgs> => {
  try {
    let parsed = Js.Json.parseExn(str);
    let someObj = Js.Json.decodeObject(parsed);

    switch someObj {
    | Some(obj) =>
      switch ((
        Js.Dict.get(obj, "engine"),
        Js.Dict.get(obj, "voice"),
        Js.Dict.get(obj, "text"),
      )) {
      | (Some(engineJson), Some(voiceJson), Some(textJson)) =>
        switch ((Js.Json.decodeString(engineJson), Js.Json.decodeString(voiceJson), Js.Json.decodeString(textJson))) {
        | (Some(engine), Some(voice), Some(text)) =>
          Some({engine, voice, text})
        | _ => None
        }
      | _ => None
      }
    | _ => None
    }
  } catch {
    | _ => None
  };
};

let mystr = `{"engine": "gss", "voice": "James", "text": "hello world"}`;
Js.log(parseSynthArgs(mystr));

