use json = "json"
use "pony_test"

primitive \nodoc\ _MakeJsonResponse
  fun apply(body_str: String): HTTPResponse val =>
    let body: Array[U8] val = body_str.array()
    HTTPResponse(HTTP11, 200, "OK", recover val Headers end, body)

// ---------------------------------------------------------------------------
// Example-based tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _TestResponseJsonValidObject is UnitTest
  """Valid JSON object body parses to expected structure."""
  fun name(): String => "response_json/valid_object"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("{\"name\": \"Alice\", \"age\": 30}")
    match ResponseJson(response)
    | let value: json.JsonValue =>
      match value
      | let obj: json.JsonObject =>
        try
          match obj("name")?
          | let s: String => h.assert_eq[String val]("Alice", s)
          else h.fail("name should be a string")
          end
          match obj("age")?
          | let n: I64 => h.assert_eq[I64](30, n)
          else h.fail("age should be an integer")
          end
        else
          h.fail("key access should not error")
        end
      else
        h.fail("should parse as JsonObject")
      end
    | let err: json.JsonParseError =>
      h.fail("should not fail: " + err.string())
    end

class \nodoc\ iso _TestResponseJsonValidArray is UnitTest
  """Valid JSON array body parses correctly."""
  fun name(): String => "response_json/valid_array"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("[1, 2, 3]")
    match ResponseJson(response)
    | let value: json.JsonValue =>
      match value
      | let arr: json.JsonArray =>
        h.assert_eq[USize](3, arr.size())
      else
        h.fail("should parse as JsonArray")
      end
    | let err: json.JsonParseError =>
      h.fail("should not fail: " + err.string())
    end

class \nodoc\ iso _TestResponseJsonInvalid is UnitTest
  """Invalid JSON body returns JsonParseError."""
  fun name(): String => "response_json/invalid"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("not json {{")
    match ResponseJson(response)
    | let value: json.JsonValue =>
      h.fail("should fail on invalid JSON")
    | let err: json.JsonParseError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    end

class \nodoc\ iso _TestResponseJsonEmptyBody is UnitTest
  """Empty body returns JsonParseError."""
  fun name(): String => "response_json/empty_body"

  fun apply(h: TestHelper) =>
    let response = _MakeJsonResponse("")
    match ResponseJson(response)
    | let value: json.JsonValue =>
      h.fail("empty body should fail to parse")
    | let err: json.JsonParseError =>
      h.assert_true(err.message.size() > 0, "error should have a message")
    end
