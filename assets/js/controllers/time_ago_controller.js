import { Controller } from "stimulus";
import moment from "moment";

export default class extends Controller {
  connect() {
    const time = moment(parseInt(this.data.get("time")));

    this.element.innerHTML = `(${time.fromNow()})`;
    this.element.setAttribute("title", time.format("dddd, MMMM Do YYYY, h:mm:ss A"));
  }
}
