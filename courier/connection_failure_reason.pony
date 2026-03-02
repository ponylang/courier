type ConnectionFailureReason is
  ( ConnectionFailedDNS
  | ConnectionFailedTCP
  | ConnectionFailedSSL )
  """
  Reason a connection attempt failed, delivered via `on_connection_failure()`.
  """
