primitive MissingScheme
  """
  URL has no `://` separator or the scheme portion is empty.
  """

primitive UnsupportedScheme
  """
  URL scheme is not `http` or `https`.
  """

primitive MissingHost
  """
  URL has an empty host component.
  """

primitive InvalidPort
  """
  Port is non-numeric, zero, or exceeds 65535.
  """

primitive UserInfoNotSupported
  """
  URL contains userinfo (`user@` or `user:pass@`), which is not supported.
  """
