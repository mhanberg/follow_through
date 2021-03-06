import { Socket } from "phoenix";

const channelTokenTag = document.querySelector("meta[name='channel_token']");
const socket = channelTokenTag
  ? new Socket("/socket", {
      params: {
        token: channelTokenTag.content
      },
      logger(kind, msg, data) {
        if (process.env.MIX_ENV === "dev") {
          console.log(`${kind}: ${msg}`, data); // eslint-disable-line no-console
        }
      }
    })
  : { connect() {} };

socket.connect();

export default socket;
