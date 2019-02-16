import { Socket } from "phoenix";

const channelTokenTag = document.querySelector("meta[name='channel_token']");
const socket = channelTokenTag
  ? new Socket("/socket", {
      params: {
        token: channelTokenTag.content
      },
      logger(kind, msg, data) {
        console.log(`${kind}: ${msg}`, data);
      }
    })
  : { connect() {} };

socket.connect();

export default socket;
