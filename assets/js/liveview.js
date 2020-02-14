// Enable Phoenix LiveView
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import Hooks from "./liveview_hooks"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect()
