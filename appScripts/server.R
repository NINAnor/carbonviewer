library(sf)

## server.R ##
server <- function(input, output, session){
  
  # So the app doesn't grey out when deployed
  autoInvalidate <- reactiveTimer(10000)
  observe({
    autoInvalidate()
    cat(".")
  })
  
  #####################
  # LANGUAGE SETTINGS #
  #####################
  
  # file with translations
  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(session, input$selected_language)
  })
  
  #######################
  # PREPARE THE DATASET #
  #######################
  BASE=paste0(getwd(), "/", session$token)
  dir.create(BASE)
  
  df_reactive <- reactiveValues()
  df_reactive$c_stock <- "Not computed"
  
  ##### IN CONSTRUCTION ####
  observeEvent(input$unzip, {
    tryCatch({
    unzip (input$upload_zip$datapath, exdir = file.path(BASE))
    
    shp_file <- list.files(BASE, pattern = '.shp', recursive = TRUE)
    csv_file <- list.files(BASE, pattern = '.csv', recursive = TRUE)
    
    shp <- readOGR(paste0(BASE, "/", shp_file)) %>% 
      st_as_sf()
    st_crs(shp) <- 25832
    
    df <- read.csv2(paste0(BASE, "/", csv_file)) 
    dfs <- st_as_sf(x = df,
                    coords = c("x", "y"),
                    crs = "+init=epsg:25832")

    df_reactive$shape <- shp
    df_reactive$points <- dfs
    }, 
    error = function(e) {
      message(e$message)
      showModal(modalDialog(
        title = "Input error",
        "Please upload a dataset before clicking on 'load dataset'. 
        The dataset should be a zip file containing both a shapefile with the extent of the area 
        of interest and a csv file containing peat depth measures (in m) taken at the site with coordinates 
        for each measure (given in UTM 32 N, EPSG:25832)",
        easyClose = TRUE
      ))
      return(0)
    }
    )
    
  })
  
  observeEvent(input$run_upload, {
    
    tryCatch({
    
    interp <- interpolation(BASE)
    df_reactive$results_volume <- interp[[1]]
    df_reactive$interpolation_raster <- interp[[2]]
    }, 
    error = function(e) {
      message(e$message)
      showModal(modalDialog(
        title = "Interpolation error",
        "Please make sure the uploaded dataset respect the required format. 
        The dataset should be a zip file containing both a shapefile with the extent of the area 
        of interest and a csv file containing peat depth measures (in m) taken at the site with coordinates 
        for each measure (given in UTM 32 N, EPSG:25832)",
        easyClose = TRUE
      ))
      return(0)
    }
    )
  })
  
  ############################
  # CALCULATE CARBON CONTENT #
  ############################
  # Choice for the user
  output$specific_peatland_type <- renderUI({
    
    if(input$g_peatland_type == 'bog'){
      ch = c("Unspecified bog / Uspesifisert nedbørsmyr" = "unknown", "Raised bog / Høgmyr" = "raised bog", "Oceanic bog / Atlantisk høgmyr" = "oceanic bog")
    }
    if(input$g_peatland_type == 'fen'){
      ch = c("Unspecified fen / Uspesifisert jordvannsmyr" = "unknown", "Poor fen / Fattig myr" = "poor fen", "Intermediate fen / Intermediær myr" = "intermediate fen", "Rich fen / Rik myr" = "rich fen")
      
    }
    if(input$g_peatland_type == "unknown"){
      ch = c("Unknown" = "unknown")
    }
    
    # Choices for the specific type of peatland
    conditionalPanel(condition = "input.g_peatland_type != 'unknown'",
                     selectInput(inputId = "s_peatland_type", 
                                 label = i18n$t(shiny::HTML("Myrtype")),
                                 choices = ch))
  })
  
  # Prepare the GRAN dataset
  df_reactive$gran_data <- reactive({
    req(input$s_peatland_type)
    
    df_read <- fread("/home/rstudio/app/dataset.csv",
                     sep = ";",
                     encoding = "unknown")
    
    df_num <- df_read %>% 
      mutate(perc_SOM = as.numeric(`% SOM`)) %>% 
      mutate(BD = as.numeric(`BD (t/m3)`)) %>% 
      dplyr::select(`SAMPLE ID2`, perc_SOM, BD) %>% 
      group_by(`SAMPLE ID2`) %>% 
      summarise(across(.fns = list(mean =~ mean(., na.rm=TRUE))))
    
    df_info <- df_read %>% 
      dplyr::select(`SAMPLE ID2`, `General Peatland Type`, `Specific Peatland Type`) %>% 
      group_by(`SAMPLE ID2`) %>% 
      unique()
    
    df = full_join(df_num, df_info, by = "SAMPLE ID2") %>% drop_na()
    print(df)
    
    if(input$g_peatland_type != "unknown"){
      
      # Target is one of the specific peatland type
      target = input$s_peatland_type
      
      # IF gtype is "bog" and stype is Unspecified bog, the target is all bog types
      if(input$g_peatland_type == "bog" & target == "unknown"){
        target = c("bog", "raised bog", "oceanic bog")}
      
      # IF gtype is "fen" and stype is Unspecified fen, the target is all bog types
      else if (input$g_peatland_type == "fen" & target == "unknown"){
        target = c("poor fen", "intermediate fen", "rich fen")}
      
      else {
        target = target
      }
      
      df <- df %>% filter(`Specific Peatland Type` %in% target)
    }
    
    return(df)
     })
  
  # Compute the carbon stock based on either the dataset OR the user input
  cstock <- reactive({
    req(df_reactive$results_volume)
    
    if(input$run_values){
      c_stock <- df_reactive$results_volume[1,2] * input$organicmatter * input$bulkdensity * input$carboncontent * 1000
    }
    else{
      req(df_reactive$gran_data)
      df <- df_reactive$gran_data()
      c_stock <- df_reactive$results_volume[1,2] * mean(df$perc_SOM_mean / 100) * mean(df$BD_mean) * 0.5 * 1000
    }
    
    c_stock <- round(c_stock, 2)
    df_reactive$c_stock <- c_stock
    return(c_stock)
  })
  
  output$carbonBox <- renderInfoBox({
    
    req(cstock)
    stock <- cstock()
    
    infoBox(
      i18n$t("Karboninnhold"), HTML(paste(stock, "Kg")), icon = icon("equals"),
      color = "orange"
    )
  })
  
  ######################################
  ### PLOTS FOR INTERPOLATION PANEL ###
  #####################################
  
  ########
  # MAPS #
  ########
  
  # Descriptive map 
  d_map <-reactive({
    
    req(df_reactive$shape)
    req(df_reactive$points)
    
    tag.map.title <- tags$style(HTML("
      .leaflet-control.map-title { 
        transform: translate(-50%,20%);
        position: fixed !important;
        left: 50%;
        text-align: center;
        padding-left: 10px; 
        padding-right: 10px; 
        background: rgba(255,255,255,0.75);
        font-weight: bold;
        font-size: 28px;
      }
    "))
    
    title <- tags$div(
      tag.map.title, i18n$t(HTML("Kart over området"))
    ) 
    
    m <- leaflet() %>% addTiles() %>%
    addPolygons(data=st_transform(df_reactive$shape, 4326), fillOpacity = 0.2,weight = 1.2) %>%
    addCircles(data=st_transform(df_reactive$points, 4326), fillOpacity = 0.7,weight = 1.2, 
               radius = 2,
               color="black") %>% 
    addControl(title, position = "topleft", className="map-title")
    return(m)
  })
  
  # Interpolation map
  interp_map <- reactive({
    
    req(df_reactive$interpolation_raster)
    
    tag.map.title <- tags$style(HTML("
      .leaflet-control.map-title { 
        transform: translate(-50%,20%);
        position: fixed !important;
        left: 50%;
        text-align: center;
        padding-left: 10px; 
        padding-right: 10px; 
        background: rgba(255,255,255,0.75);
        font-weight: bold;
        font-size: 28px;
      }
    "))
    
    title <- tags$div(
      tag.map.title, i18n$t(HTML("Kart med interpolerte torvdybder"))
    )
    
    pal = colorNumeric(palette = "magma", 
                       values(df_reactive$interpolation_raster),  na.color = "transparent",
                       reverse = TRUE)
    
    leaflet() %>% addTiles() %>%
      addRasterImage(df_reactive$interpolation_raster, colors = pal) %>% 
      addLegend(pal = pal, values = values(df_reactive$interpolation_raster),
                title = i18n$t("Dybde")) %>% 
      addControl(title, position = "topleft", className="map-title")
    
  })
    
  
  ###################
  # OUTPUT THE MAPS #
  ###################
  output$descriptive_map <- renderLeaflet({
    req(d_map)
    d_map()
  })
  
  output$interpolation_map <- renderLeaflet({
      req(interp_map)
      interp_map()
  })
  
  # DO THE CALCULATIONS IN THE PASTE0
  output$areaBox <- renderInfoBox({
    
    req(df_reactive$shape)
    area = sum(st_area(df_reactive$shape))
    area_h = round(area, 2)
    df_reactive$area <- area_h
    
    infoBox(
      i18n$t("Areal"), HTML(paste(area_h, "m2")), icon = icon("layer-group"),
      color = "orange"
    )
  })
  
  # DO THE CALCULATIONS IN THE PASTE0
  output$volumeBox <- renderInfoBox({
    
    req(df_reactive$results_volume)
    
    infoBox(
      i18n$t("Volum"), HTML(paste("min:", round(df_reactive$results_volume[2,2],2), "m3", br(),
                           "mean:", round(df_reactive$results_volume[1,2],2), "m3", br(),
                           "max:", round(df_reactive$results_volume[3,2], 2), "m3",  br(),
                           "SD:", round(df_reactive$results_volume[4,2],3), "m3")), icon = icon("shapes"),
      color = "orange"
    )
  })
  
  #############################
  # PREPARE DATA FOR DOWNLOAD #
  #############################
  
  # Write the interpolation map
  shot_interp_map <- reactive({
    
    mapshot( x = interp_map()
             , file = paste0(BASE, "/map_interpolation.png")
             , cliprect = "viewport" # the clipping rectangle matches the height & width from the viewing port
             , selfcontained = FALSE) # when this was not specified, the function for produced a PDF of two pages: one of the leaflet map, the other a blank page.
  })
  
  # Write the descriptive map
  shot_d_map <- reactive({
    
    mapshot( x = d_map()
             , file = paste0(BASE, "/map_descriptive.png")
             , cliprect = "viewport"
             , selfcontained = FALSE) 
    
    
  })
  
  # Write the raster
  write_raster <- reactive({
    
    writeRaster(df_reactive$interpolation_raster, paste0(BASE, "/interpolation_raster"), format = "GTiff")
    
  })
  
  result_csv <- reactive({
    
    results <- df_reactive$results_volume %>% mutate(units = "m3")
    area <- tibble(Description = "area", Results = df_reactive$area, units = "m2")
    c_stock <- tibble(Description = "carbon_stock", Results = df_reactive$c_stock, units = "Kg")
    results <- rbind(results, area, c_stock)

    write.csv(results, paste0(BASE, file  = "/results.csv"))
    
  })
    
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    
    filename = function() {paste("results-", Sys.Date(), ".zip", sep="")},
    
    content = function(file) {
      
      setwd(BASE)
      print(BASE)
      
      shot_interp_map()
      write_raster()
      shot_d_map()
      result_csv()
      
      fs <- c("map_interpolation.png", "interpolation_raster.tif", "map_descriptive.png", "results.csv")
      
      zip(zipfile = file, files = fs)
      contentType = "application/zip"
      
    }
  ) 
  
  ######################
  # ENDING THE SESSION #
  ######################
  session$onSessionEnded(function() {
    unlink(BASE, recursive = TRUE)
  })
}
