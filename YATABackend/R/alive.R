alive = function(.req, .res) {
   .res$set_status_code(200)
   .res$set_content_type("text/plain")
   .res$set_body("OK")
}
