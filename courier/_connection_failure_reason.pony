primitive ConnectionFailedDNS
  """
  DNS resolution failed. No TCP connection was attempted.
  """

primitive ConnectionFailedTCP
  """
  TCP connection failed after DNS resolution succeeded.
  """

primitive ConnectionFailedSSL
  """
  SSL handshake failed after TCP connection succeeded.
  """

primitive ConnectionFailedTimeout
  """
  Connection attempt timed out before completing.
  """

primitive ConnectionFailedTimerError
  """
  Connect timer ASIO event subscription failed.
  """
