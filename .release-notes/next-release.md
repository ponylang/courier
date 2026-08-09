## Add opt-in redirect following

Courier can now follow HTTP redirects transparently. Redirect following is off by default — wrap an `HTTPClientConnection` in a `RedirectFollower` to opt in.

The follower sits in the callback path and handles redirect hops internally. The actor's response callbacks see only the final response; redirect responses and their bodies never reach user code. Same-origin redirects reuse the existing TCP connection. Cross-origin redirects use a `RedirectConnectionFactory` the actor provides to create a new one.

Security rules are applied before any hop: an `https`-to-`http` downgrade is refused, and on a cross-origin hop the `Authorization`, `Cookie`, `Proxy-Authorization`, `Host`, and `Referer` headers are stripped. A redirect that cannot be followed — too many hops, `Location` missing or unparseable, or an insecure downgrade — arrives at `on_redirect_error` on `RedirectFollowerNotify`.

