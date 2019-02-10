import { Socket } from "phoenix";

let socket = new Socket("/socket", {
  params: {
    token: document.querySelector("meta[name='channel_token']").content
  },
  logger: function(kind, msg, data) {
    console.log(`${kind}: ${msg}`, data);
  }
});

socket.connect();

export default socket;
