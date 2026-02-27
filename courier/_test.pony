use "pony_test"
use "pony_check"

actor \nodoc\ Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    // Method tests
    test(Property1UnitTest[String val](_PropertyValidMethodParsesCorrectly))
    test(Property1UnitTest[String val](_PropertyInvalidMethodReturnsNone))
    test(Property1UnitTest[(String val, Bool)](
      _PropertyMethodParseBoundary))

    // Headers tests
    test(Property1UnitTest[(String val, String val)](
      _PropertyHeadersCaseInsensitive))
    test(Property1UnitTest[(String val, String val, String val)](
      _PropertyHeadersSetReplaces))
    test(Property1UnitTest[(String val, String val, String val)](
      _PropertyHeadersAddPreserves))

    // Parser property-based tests
    test(Property1UnitTest[(U16, String val)](
      _PropertyValidStatusLineParsesCorrectly))
    test(Property1UnitTest[String val](
      _PropertyInvalidStatusLineRejected))
    test(Property1UnitTest[Array[(String val, String val)] ref](
      _PropertyHeadersRoundtrip))
    test(Property1UnitTest[USize](
      _PropertyFixedBodyDelivered))
    test(Property1UnitTest[Array[USize] ref](
      _PropertyChunkedBodyDelivered))
    test(Property1UnitTest[(String val, Bool)](
      _PropertyStatusLineBoundary))

    // Parser example-based tests
    test(_TestParserKnownGoodResponses)
    test(_TestIncrementalByteByByte)
    test(_TestSizeLimitStatusLine)
    test(_TestSizeLimitHeaders)
    test(_TestSizeLimitBody)
    test(_TestSizeLimitCloseDelimitedBody)
    test(_TestInvalidContentLength)
    test(_TestInvalidChunkSize)
    test(_TestChunkedWithTrailers)
    test(_TestHTTP10Version)
    test(_TestInvalidVersion)
    test(_TestNoBodyHead)
    test(_TestNoBody204)
    test(_TestNoBody304)
    test(_TestCloseDelimitedBody)
    test(_TestContentLengthZero)
    test(_TestContentLengthAndChunked)
    test(_TestDuplicateContentLength)
    test(_TestDataAfterError)
    test(_Test1xxSkipped)
    test(_TestMultiple1xx)

    // Serializer property-based tests
    test(Property1UnitTest[String val](
      _PropertySerializerContainsMethod))
    test(Property1UnitTest[String val](
      _PropertySerializerContainsPath))
    test(Property1UnitTest[String val](
      _PropertySerializerAutoHost))
    test(Property1UnitTest[USize](
      _PropertySerializerAutoContentLength))

    // Serializer example-based tests
    test(_TestSerializerKnownGood)
    test(_TestSerializerHostWithPort)
    test(_TestSerializerHostDefaultPort)
    test(_TestSerializerUserHostTakesPrecedence)
    test(_TestSerializerUserContentLengthTakesPrecedence)
    test(_TestSerializerNoBody)
