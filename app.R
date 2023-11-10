## app.R ##
source("/home/rstudio/app/appScripts/dependancies.R")
source("/home/rstudio/app/appScripts/global.R")
source("/home/rstudio/app/appScripts/custom_theme.R")
source("/home/rstudio/app/appScripts/ui.R")
source("/home/rstudio/app/appScripts/server.R")

options(shiny.maxRequestSize=100*1024^2)
options(warn = -1)

app <- shinyApp(ui = ui, server = server)
sessionInfo()
runApp(app, host ="0.0.0.0", port = 8999, launch.browser = TRUE)
