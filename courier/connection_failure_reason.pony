type ConnectionFailureReason is
  ( ConnectionFailedDNS
  | ConnectionFailedTCP
  | ConnectionFailedSSL
  | ConnectionFailedTimeout
  | ConnectionFailedTimerError )
  """
  Reason a connection attempt failed, delivered via `on_connection_failure()`.
  """
