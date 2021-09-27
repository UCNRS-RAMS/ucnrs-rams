// Load all the controllers within this directory and all subdirectories. 
// Controller files must be named *_controller.js.

import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import "@hotwired/turbo-rails"

const application = Application.start()
const context = require.context("controllers", true, /_controller\.[jt]s$/)
application.load(definitionsFromContext(context))
