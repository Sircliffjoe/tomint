import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import UserFormController from "./user_form_controller"
application.register("user-form", UserFormController)
