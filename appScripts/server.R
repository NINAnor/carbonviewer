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
    print(input$selected_language)
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(input$selected_language, session)
  })
  
  #######################
  # PREPARE THE DATASET #
  #######################
  BASE=paste0("/home/rstudio/app", "/", session$token)
  dir.create(BASE)
  
  # State variable to know whether a folder has been uploaded
  df_reactive <- reactiveValues()
  
  values <- reactiveValues(
    upload_state = NULL
  )
  
  observeEvent(input$unzip, {
    values$upload_state <- 'uploaded'
  })
  
  observeEvent(input$reset, {
    values$upload_state <- 'reset'
  })
  
  # ! PRIMARY PART !
  # Unzip the file and return the dataframe used for the calculations
  # and the plots
  observeEvent(values$upload_state, {

    # Default upload_state value
    if(is.null(values$upload_state)){
      return(NULL)
    }
    
    # If a file has been uploaded
    else if (values$upload_state == 'uploaded') {
    
      if (is.null(input$upload_zip$datapath)) {
        print_error_incompatible_file()
      }
      else {
        # unzip the file
        unzip (input$upload_zip$datapath, exdir = file.path(BASE))
      
        shp_file <- list.files(BASE, pattern = '.shp', recursive = TRUE)
        prj_file <- list.files(BASE, pattern = '.prj', recursive = TRUE)
        csv_file <- list.files(BASE, pattern = '.csv', recursive = TRUE)
        
        # Check if there is both a shapefile and a CSV
        if (length(shp_file) == 0){
          print_no_shp()
        }
        else if (length(prj_file) == 0){
          print_no_prj()
        }
        else if (length(csv_file) == 0){
          print_no_csv()
        }
        else{
          
          shp <- open_shapefile(paste0(BASE, "/", shp_file))
                                
          # Check if the shapefile has a CRS / IF NOT WE ASSUME THAT THE CRS
          # IS 25832 AS SPECIFIED ON THE README
          if (is.na(st_crs(shp))) {
            print("The object does not have a CRS, assigning a CRS")
            shp <- shp %>% st_set_crs(25832)
            } 
          else {
            print("The object has a CRS")
          }
          
          df <- open_csv(paste0(BASE, "/", csv_file)) 
          names(df) <- tolower(names(df))
          
          # Check that the CSV contains the necessary columns (x,y, dybde)
          necessary_columns <- c("x","y","dybde")
          
          if (sum(names(df) %in% necessary_columns) != 3){
            print_error_csv_columns()
          }
          else{
            dfs <- transform_to_sf(df) %>% st_set_crs(st_crs(shp))
            dfs <- dfs %>% st_transform(25832)
            shp <- shp %>% st_transform(25832)
            
            # Interpolation (take only "sp" objects, hence the conversion)
            shp_sp <- as(shp, Class='Spatial')
            dfsp <- as(dfs, Class="Spatial")
            interp <- interpolation(shp_sp, dfsp)
            
            # Fill the DF reactive
            df_reactive$shape <- shp
            df_reactive$points <- dfs
            df_reactive$results_volume <- interp[[1]]
            df_reactive$interpolation_raster <- interp[[2]]
          }
        }
      }
    }
    
    # If the reset button has been pushed
    else if (values$upload_state == 'reset') {
      session$reload()
      return(NULL)}
  })
  
  ############################
  # CALCULATE CARBON CONTENT #
  ############################
  # Choice for of the general peatland types
  output$specific_peatland_type <- renderUI({
    
    if(input$g_peatland_type == 'bog'){
      ch = c("Unspecified bog / Uspesifisert nedb??rsmyr" = "unknown", "Raised bog / H??gmyr" = "raised bog", "Oceanic bog / Atlantisk h??gmyr" = "oceanic bog")
    }
    if(input$g_peatland_type == 'fen'){
      ch = c("Unspecified fen / Uspesifisert jordvannsmyr" = "unknown", "Poor fen / Fattig myr" = "poor fen", "Intermediate fen / Intermedi??r myr" = "intermediate fen", "Rich fen / Rik myr" = "rich fen")
      
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
    
    # Isolate Soil Organic Matter and Bulk Density values, group them by SAMPLE ID2 (because
    # the sampling has been replicated) and summarise.
    df_num <- df_read %>% 
      dplyr::select(`SAMPLE ID2`, perc_SOM = `% SOM`, BD = `BD (t/m3)`) %>% 
      group_by(`SAMPLE ID2`) %>% 
      summarise(across(.fns = list(mean =~ mean(., na.rm=TRUE))))
    
    # Isolate the peatland types and add the info to the df containing the numeric
    # info of the site.
    df_info <- df_read %>% 
      dplyr::select(`SAMPLE ID2`, `General Peatland Type`, `Specific Peatland Type`) %>% 
      group_by(`SAMPLE ID2`) %>% 
      unique()
    df = full_join(df_num, df_info, by = "SAMPLE ID2") %>% drop_na()
    
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
    req(input$run_values_custom || input$run_values_gran_data)
    
    if(input$run_values_custom){
      c_stock <- df_reactive$results_volume[1,2] * input$organicmatter * input$bulkdensity * input$carboncontent * 1000
    }
    else if (input$run_values_gran_data){
      req(df_reactive$gran_data)
      df <- df_reactive$gran_data()
      c_stock <- df_reactive$results_volume[1,2] * mean(df$perc_SOM_mean / 100) * mean(df$BD_mean) * 0.5 * 1000
    }
    c_stock <- round(c_stock, 0)
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
      tag.map.title, i18n$t(HTML("Kart over omr??det"))
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
    interp_map <- tm_shape(df_reactive$interpolation_raster) +
      tm_raster(title = i18n$t("Dybde")) +
      tm_layout(title= i18n$t("Kart med interpolerte torvdybder"),
                legend.position = c("left", "top"))
    tmap_save(interp_map, "map_interpolation.png")
  })
  
  # Write the descriptive map
  shot_d_map <- reactive({
    d_map <- tm_shape(df_reactive$shape) + 
      tm_polygons() +
      tm_shape(df_reactive$points) +
      tm_dots() +
      tm_layout(title= i18n$t("Kart over omr??det"))
    tmap_save(d_map, "map_descriptive.png")
    
    })
  
  # Write the raster
  write_raster <- reactive({
    writeRaster(df_reactive$interpolation_raster, "interpolation_raster", format = "GTiff")
  })
  
  result_csv <- reactive({
    
    results <- df_reactive$results_volume %>% mutate(units = "m3")
    area <- tibble(Description = "area", Results = df_reactive$area, units = "m2")
    c_stock <- tibble(Description = "carbon_stock", Results = df_reactive$c_stock, units = "Kg")
    results <- rbind(results, area, c_stock)

    write.csv(results, "results.csv")
    
  })
    
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    
    filename = function() {paste("results-", Sys.Date(), ".zip", sep="")},
    
    content = function(file) {
      
      setwd(BASE)
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
