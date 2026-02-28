use json = "json"

interface val JsonDecoder[A: Any val]
  """
  Interface for converting a parsed `JsonValue` into a typed domain object.

  Implement this interface to define how a specific JSON structure maps to your
  application type. Return `JsonDecodeError` when the JSON doesn't match the
  expected structure.

  ```pony
  use "courier"
  use json = "json"

  class val User
    let name: String
    let age: I64

    new val create(name': String, age': I64) =>
      name = name'
      age = age'

  primitive UserDecoder is JsonDecoder[User]
    fun apply(value: json.JsonValue): (User | JsonDecodeError) =>
      let nav = json.JsonNav(value)
      try
        User(nav("name").as_string()?, nav("age").as_i64()?)
      else
        JsonDecodeError("expected object with string 'name' and integer 'age'")
      end
  ```
  """

  fun apply(value: json.JsonValue): (A | JsonDecodeError)
