// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

import "phoenix_html";
import LiveSocket from "phoenix_live_view";

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import "../css/app.css";

import socket from "./socket";

const liveSocket = new LiveSocket("/live");
liveSocket.connect();

const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
window.socket = socket;
