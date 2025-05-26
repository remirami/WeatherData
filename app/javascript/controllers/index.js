import { Application } from "@hotwired/stimulus"
import RainFilterController from "./rain_filter_controller"

const application = Application.start()
application.register("rain-filter", RainFilterController)

export { application }