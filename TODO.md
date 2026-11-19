# TODO

## A store for each response

A template can add to its routed node's response, like a cookie, through the render context's `routed_node`. But it has nowhere to keep a value for the rest of the render. A component's context is a copy, so a value it puts there never reaches its parent.

Raindeer's `FormTokens` works around this. A browser without a `form_key` cookie is given a new key with `routed_node.set_cookie` when the page's first form renders. Each later form on the page finds that key by reading back the `Set-Cookie` header the routed node already has. It works, and the response stays the source of truth, but it's parsing a header to get a value back.

A store on the routed node for its response, like `routed_node.response_store[:form_key]`, would let FormTokens keep the key there and set the cookie from it. Anything else a page decides while rendering could use it too.
