## Fix crash when closing a connection before initialization completes

Calling `dispose()` on a connection actor before its internal initialization completed could crash. This was a rare race condition where `dispose()` from an external actor arrived before the connection finished setting up, since Pony's causal messaging provides no ordering guarantee between different senders. The race was unlikely but was observed on macOS arm64 CI.
