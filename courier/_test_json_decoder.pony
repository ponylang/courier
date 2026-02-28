use json = "json"
use "pony_check"
use "pony_test"

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

class \nodoc\ val _Todo
  let id: I64
  let title: String

  new val create(id': I64, title': String) =>
    id = id'
    title = title'

primitive \nodoc\ _TodoDecoder is JsonDecoder[_Todo]
  fun apply(value: json.JsonValue): (_Todo | JsonDecodeError) =>
    let nav = json.JsonNav(value)
    try
      _Todo(nav("id").as_i64()?, nav("title").as_string()?)
    else
      JsonDecodeError(
        "expected object with integer 'id' and string 'title'")
    end

primitive \nodoc\ _AlwaysSucceedDecoder is JsonDecoder[String]
  fun apply(value: json.JsonValue): (String | JsonDecodeError) =>
    "success"

primitive \nodoc\ _AlwaysFailDecoder is JsonDecoder[String]
  fun apply(value: json.JsonValue): (String | JsonDecodeError) =>
    JsonDecodeError("always fails")

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

primitive \nodoc\ _InvalidJsonGen
  fun apply(): Generator[String] =>
    Generators.ascii_printable(
      where min = 0, max = 50
    ).map[String]({(s) => "{{INVALID " + s})

primitive \nodoc\ _ValidJsonGen
  fun apply(): Generator[String] =>
    Generators.one_of[String]([
      "null"
      "true"
      "false"
      "42"
      "-1"
      "3.14"
      "\"hello\""
      "[]"
      "[1,2,3]"
      "{}"
      "{\"a\":1}"
      "{\"a\":\"b\",\"c\":true}"
    ])

// ---------------------------------------------------------------------------
// Property-based tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropertyDecodeJsonParseErrorPropagation is Property1[String val]
  """Invalid JSON always yields JsonParseError, never success or decode error."""
  fun name(): String => "json_decoder/property/parse_error_propagation"

  fun gen(): Generator[String val] => _InvalidJsonGen()

  fun property(sample: String val, h: PropertyHelper) =>
    let response = _MakeJsonResponse(sample)
    match DecodeJson[String](response, _AlwaysSucceedDecoder)
    | let s: String =>
      h.fail("expected JsonParseError, got success: " + s)
    | let err: json.JsonParseError => None
    | let err: JsonDecodeError =>
      h.fail("expected JsonParseError, got JsonDecodeError: " + err.string())
    end

class \nodoc\ iso _PropertyDecodeJsonDecodeErrorPropagation
  is Property1[String val]
  """Valid JSON with always-fail decoder yields JsonDecodeError."""
  fun name(): String => "json_decoder/property/decode_error_propagation"

  fun gen(): Generator[String val] => _ValidJsonGen()

  fun property(sample: String val, h: PropertyHelper) =>
    let response = _MakeJsonResponse(sample)
    match DecodeJson[String](response, _AlwaysFailDecoder)
    | let s: String =>
      h.fail("expected JsonDecodeError, got success: " + s)
    | let err: json.JsonParseError =>
      h.fail("expected JsonDecodeError, got JsonParseError: " + err.string())
    | let err: JsonDecodeError => None
    end

class \nodoc\ iso _PropertyDecodeJsonIdentityDecoder is Property1[String val]
  """Valid JSON with always-succeed decoder yields success."""
  fun name(): String => "json_decoder/property/identity_decoder"

  fun gen(): Generator[String val] => _ValidJsonGen()

  fun property(sample: String val, h: PropertyHelper) =>
    let response = _MakeJsonResponse(sample)
    match DecodeJson[String](response, _AlwaysSucceedDecoder)
    | let s: String => None
    | let err: json.JsonParseError =>
      h.fail("expected success, got JsonParseError: " + err.string())
    | let err: JsonDecodeError =>
      h.fail("expected success, got JsonDecodeError: " + err.string())
    end

// ---------------------------------------------------------------------------
// Example-based tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestJsonDecoderSuccessfulDecode is UnitTest
  """Valid JSON matching the decoder schema decodes to the expected type."""
  fun name(): String => "json_decoder/successful_decode"

  fun apply(h: TestHelper) =>
    let value = json.JsonObject
      .update("id", I64(1))
      .update("title", "test")
    match _TodoDecoder(value)
    | let todo: _Todo =>
      h.assert_eq[I64](1, todo.id)
      h.assert_eq[String val]("test", todo.title)
    | let err: JsonDecodeError =>
      h.fail("expected success: " + err.string())
    end

class \nodoc\ iso _TestJsonDecoderMissingField is UnitTest
  """JSON missing a required field yields JsonDecodeError."""
  fun name(): String => "json_decoder/missing_field"

  fun apply(h: TestHelper) =>
    let value = json.JsonObject
      .update("id", I64(1))
    match _TodoDecoder(value)
    | let todo: _Todo =>
      h.fail("expected JsonDecodeError for missing 'title'")
    | let err: JsonDecodeError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    end

class \nodoc\ iso _TestJsonDecoderWrongType is UnitTest
  """JSON with a field of the wrong type yields JsonDecodeError."""
  fun name(): String => "json_decoder/wrong_type"

  fun apply(h: TestHelper) =>
    let value = json.JsonObject
      .update("id", "not_a_number")
      .update("title", "test")
    match _TodoDecoder(value)
    | let todo: _Todo =>
      h.fail("expected JsonDecodeError for wrong type on 'id'")
    | let err: JsonDecodeError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    end

class \nodoc\ iso _TestDecodeJsonValidJson is UnitTest
  """Full pipeline: valid JSON response decodes to typed domain object."""
  fun name(): String => "decode_json/valid_json"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("{\"id\": 42, \"title\": \"hello\"}")
    match DecodeJson[_Todo](response, _TodoDecoder)
    | let todo: _Todo =>
      h.assert_eq[I64](42, todo.id)
      h.assert_eq[String val]("hello", todo.title)
    | let err: json.JsonParseError =>
      h.fail("expected success, got JsonParseError: " + err.string())
    | let err: JsonDecodeError =>
      h.fail("expected success, got JsonDecodeError: " + err.string())
    end

class \nodoc\ iso _TestDecodeJsonInvalidJson is UnitTest
  """Non-JSON body yields JsonParseError through DecodeJson."""
  fun name(): String => "decode_json/invalid_json"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("not json {{")
    match DecodeJson[_Todo](response, _TodoDecoder)
    | let todo: _Todo =>
      h.fail("expected JsonParseError")
    | let err: json.JsonParseError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    | let err: JsonDecodeError =>
      h.fail("expected JsonParseError, got JsonDecodeError: " + err.string())
    end

class \nodoc\ iso _TestDecodeJsonWrongStructure is UnitTest
  """Valid JSON with wrong structure yields JsonDecodeError through DecodeJson."""
  fun name(): String => "decode_json/wrong_structure"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("[1, 2, 3]")
    match DecodeJson[_Todo](response, _TodoDecoder)
    | let todo: _Todo =>
      h.fail("expected JsonDecodeError")
    | let err: json.JsonParseError =>
      h.fail("expected JsonDecodeError, got JsonParseError: " + err.string())
    | let err: JsonDecodeError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    end

class \nodoc\ iso _TestJsonDecodeErrorString is UnitTest
  """`JsonDecodeError.string()` returns the error message."""
  fun name(): String => "json_decode_error/string"

  fun apply(h: TestHelper) =>
    let err = JsonDecodeError("msg")
    h.assert_eq[String val]("msg", err.string())
