// 1. Point to the specific Stimulus application instance in 'controllers/application'
// Do NOT use "application" (which is your main app entry point) or "./application"
import { application } from "controllers/application"

// 2. Register controllers using the 'controllers/' namespace so Import Map finds the digested files
import CarouselController from "controllers/carousel_controller"
application.register("carousel", CarouselController)

import CptSearchController from "controllers/cpt_search_controller"
application.register("cpt-search", CptSearchController)

import DropzoneController from "controllers/dropzone_controller"
application.register("dropzone", DropzoneController)

import HelloController from "controllers/hello_controller"
application.register("hello", HelloController)

import NestedFormController from "controllers/nested_form_controller"
application.register("nested-form", NestedFormController)