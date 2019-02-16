// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

import "phoenix_html";

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import "../css/app.css";

import socket from "./socket";

const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
window.socket = socket;
