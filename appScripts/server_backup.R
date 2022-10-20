## server.R ##
server <- function(input, output, session){
  
  # Will create a folder per session
  #dir.create(paste0("/home/rstudio/app/", session$token))
  dir.create()
  
  # Load the data given the ID of the dataset
  table_reactive = observeEvent(input$run, {
    
    #############################
    # Unpack the data in /data/ #
    #############################
    
    # Need a data directory to store the temporary files & folders
    BASE=paste0("/home/rstudio/app/", session$token)
    
    if(input$ID != ""){
      dataset = RJSONIO::fromJSON(paste0("http://api.gbif.org/v1/dataset/",
                                         input$ID,
                                         "/endpoint"))
      endpoint_url <- dataset[[1]]$url 
      download.file(endpoint_url, destfile=file.path(BASE, "temp.zip"), mode="wb")
      unzip (file.path(BASE, "temp.zip"), exdir = file.path(BASE))
    }
    
    else{
      unzip (input$upload$datapath, exdir = file.path(BASE))
    }
    
    ########################################
    # Initiate empty event & occurrence df #
    ########################################
    event_df <- initiate_event_df()
    occ_df <- initiate_occ_df()
    
    #######################################
    # PROCESS EVENT AND OCCURRENCE TABLES #
    #######################################
    
    # If there is an event.txt file
    ###############################
    if(file.exists(file.path(BASE, "event.txt"))){
      
      ### Event ###
      event_data <- read.csv(file.path(BASE, "event.txt"), sep="\t", encoding = "UTF-8")
      event <- full_join(event_df, event_data) %>% select(c(colnames(event_df)))
      
      # reformat the date
      event$date = as.Date(event$eventDate)
      event$years = as.numeric(format(event$date, format = "%Y"))
      evDate <- event %>% select(eventDate, eventID)
      
      ### Occurrence ###
      occurrence_data <- read.csv(file.path(BASE, "occurrence.txt"), sep="\t", encoding = "UTF-8") 
      occurrence <- full_join(occ_df, occurrence_data) %>% select(c(colnames(occ_df))) %>% 
        full_join(., evDate, by="eventID") %>% 
        drop_na(occurrenceID)
      occurrence$eventDate = as.Date(occurrence$eventDate)
      occurrence$years = format(occurrence$eventDate, format = "%Y")
    }
    
    # If there isn't an event.txt, create it
    ########################################
    else{
      occurrence_data <- read.csv(file.path(BASE, "occurrence.txt"), sep="\t", encoding = "UTF-8") 
      
      ### Create the event table ###
      event <- full_join(event_df, occurrence_data) %>% select(c(colnames(event_df)))
      # reformat the date
      event$date = as.Date(event$eventDate)
      event$years = as.numeric(format(event$date, format = "%Y"))
      evDate <- event %>% select(eventDate, eventID)
      
      ### Create the occurrence table ###
      occurrence <- full_join(occ_df, occurrence_data) %>% select(c(colnames(occ_df))) %>% 
        full_join(., evDate, by="eventID") %>% 
        drop_na(occurrenceID)
      occurrence$eventDate = as.Date(occurrence$eventDate)
      occurrence$years = format(occurrence$eventDate, format = "%Y")
    }
    
    # Get the citation of this dataset
    meta <- read_xml(file.path(BASE, "eml.xml")) %>% as_list()
    output$gbif_citation <- renderText(meta$eml$additionalMetadata$metadata$gbif$citation[[1]])  
    
    out <- list(event, occurrence)
    return(out)
    
  })
  
  ############################
  ### CUSTOM SERVER INPUTS ###
  ############################
  
  # Select a taxonomic group to display
  output$subtaxon <- renderUI({
    choices <- unique(occ()[input$taxon])
    choices <- append(choices, "All", 0)
    selectInput("subT", label = 
                  shiny::HTML("<p><span style='color: white'>Select a taxon:</span></p>"), 
                choices = as.character(unlist(choices)),
                selected = NULL)
  })
  
  output$geography <- renderUI({
    
    geo_cols <- c("country", "stateProvince", "municipality", "locality")
    choice <- geo_cols[ geo_cols %in% colnames(event()) ] 
    # Data is in the "template" sheet so makes ense that all the choices show up!
    
    selectInput("geography",label= shiny::HTML("Select a geographical level"),
                choices = choice)
  })
  
  # Select years to display
  output$years <- renderUI({
    
    y <- event() 
    
    sliderInput("years", 
                label = 
                  shiny::HTML("<p><span style='color: white'>Select years to be vizualised:</span></p>"), 
                min = min(y$years, isolate(input$years), na.rm = TRUE),
                max = max(y$years, isolate(input$years), na.rm = TRUE),
                value = c(min(y$years, isolate(input$years), na.rm = TRUE), 
                          max(y$years, isolate(input$years), na.rm = TRUE)), 
                max(y$years, isolate(input$years), na.rm = TRUE),
                ticks = FALSE,
                step = 1,
                sep = "")
  })
  
  
  ######################
  # Subset the dataset #
  ######################
  
  event <- reactive({as.data.frame(table_reactive()[1])}) 
  occ <- reactive({as.data.frame(table_reactive()[2])}) 
  
  event_subset <- eventReactive(input$years, {
    df <- event()
    df_years_f1 <- df %>% filter(df["years"] >= input$years[1])
    df_years_f1f2 <- df_years_f1 %>% filter(df_years_f1["years"] <= input$years[2])
    return(df_years_f1f2)
  })
  
  occ_subset <- eventReactive(
    {input$subT 
      input$years}, {
        
        if(input$subT == "All"){ 
          df <- occ()
          df_years_f1 <- df %>% filter(df["years"] >= input$years[1])
          df_subset <- df_years_f1 %>% filter(df_years_f1["years"] <= input$years[2])
        }
        
        else{ 
          df_taxon <- occ() %>% filter(occ()[input$taxon] == input$subT)
          df_taxon_years_f1 <- df_taxon %>% filter(df_taxon["years"] >= input$years[1])
          df_subset <- df_taxon_years_f1 %>% filter(df_taxon_years_f1["years"] <= input$years[2])
        }
        return(df_subset)
      })
  
  ######################
  ### SUBMENU TABLES ###
  ######################
  
  # Event table ---------------------------------
  output$eventCheckbox <- renderUI({
    checkboxGroupInput(inputId = "select_var_event", 
                       label = "Select variables:", 
                       choices = names(event()))
  })
  
  # Select columns to print
  df_sel_event <- eventReactive(input$select_var_event, {
    df_sel <- event_subset() %>% select(input$select_var_event)
    return(df_sel)
  })
  
  output$table_event = renderDataTable(df_sel_event())
  
  # Occurrence table -----------------------------
  output$occCheckbox <- renderUI({
    checkboxGroupInput(inputId = "select_var_occ", 
                       label = "Select variables:", 
                       choices = names(occ()))
  })
  
  # Select columns to print
  df_sel_occ <- eventReactive(input$select_var_occ, {
    df_sel <- occ_subset() %>% select(input$select_var_occ)
    return(df_sel)
  })
  
  output$table_occ = renderDataTable(df_sel_occ())
  
  ###############################
  ### SUBMENU OCCURENCE STATS ###
  ###############################
  
  output$sex <- renderPlotly({
    df <- occ_subset() %>% group_by(sex) %>% summarise(n = n()) 
    p <- plot_interactive(df, "sex", "Sex")
    ggplotly(p) })
  
  output$lifestage <- renderPlotly({
    df <- occ_subset() %>% group_by(lifeStage) %>% summarise(n = n()) 
    p <- plot_interactive(df, "lifeStage", "Life stage")
    ggplotly(p) })
  
  output$observation <- renderPlotly({
    df <- occ_subset() %>% group_by(basisOfRecord) %>% summarise(n = n()) 
    p <- plot_interactive(df, "basisOfRecord", "Basis of Record")
    ggplotly(p) })
  
  output$taxon_plot <- renderPlotly({
    df <- occ_subset() %>% group_by(occ_subset()[input$taxon]) %>% summarise(n = n()) 
    p <- plot_interactive(df, input$taxon, "Taxon")
    ggplotly(p) })
  
  ###########################
  ### SUBMENU EVENT STATS ###
  ###########################
  
  output$geography_plot <- renderPlotly({
    df <- event_subset() %>% 
      group_by(event_subset()[input$geography]) %>% 
      summarise(n = n()) 
    p <- plot_interactive(df, input$geography, "")
    ggplotly(p) })
  
  output$uncertainty <- renderPlotly({
    df <- event_subset() %>% group_by(coordinateUncertaintyInMeters) %>% summarise(n = n()) 
    p <- plot_interactive(df, "coordinateUncertaintyInMeters", "Coordinate uncertainty (meters)")
    ggplotly(p) })
  
  output$sampling <- renderPlotly({
    
    sP <- event_subset() %>% select(samplingProtocol)
    
    if (all(is.na(sP))){
      
      df <- occ_subset() %>% group_by(basisOfRecord) %>% summarise(n = n()) 
      p <- plot_interactive(df, "basisOfRecord", "Basis of record")
      ggplotly(p)
    }
    
    else {
      
      # FACET the sampling protocol  
      p <- event_subset() %>% 
        select(samplingProtocol, sampleSizeValue, sampleSizeUnit) %>% 
        drop_na() %>% 
        ggplot(aes(x = sampleSizeValue, fill=samplingProtocol)) +
        geom_density() +
        xlab("Sample size value") +
        ylab("Propotion") +
        theme_classic() + 
        facet_grid(.~samplingProtocol) +
        scale_fill_viridis(option="D", discrete=TRUE) + 
        theme(legend.position = "none")
      ggplotly(p)
    }
  })
  
  
  ################################
  ### SUBMENU OBS THROUGH TIME ###
  ################################
  
  output$months <- renderPlotly({
    df <- df_time(event_subset(), "months")
    p <- plot_interactive(df, "months", "Months")
    ggplotly(p) 
  })
  
  output$days <- renderPlotly({
    df <- df_time(event_subset(), "days")
    p <- plot_interactive(df, "days", "Days of the week")
    ggplotly(p) 
  })
  
  
  ############################
  ### SUBMENU MISSING DATA ### 
  ############################
  
  output$missingEvent <- renderPlotly({
    
    col_events <- event_subset() %>% select(ownerInstitutionCode, dynamicProperties, samplingProtocol, 
                                            sampleSizeValue, sampleSizeUnit, eventDate, eventRemarks,
                                            country, coordinateUncertaintyInMeters, decimalLatitude)
    p <- plot_missing_data(col_events, "Proportion of missing values for the event table")
    ggplotly(p)
  })
  
  output$missingOcc <- renderPlotly({
    
    col_occ <- occ_subset() %>% select(basisOfRecord, individualCount, sex, lifeStage, 
                                       kingdom, phylum, class, order, family, genus)
    p <- plot_missing_data(col_occ, "Proportion of missing values for the occurrence table")
    ggplotly(p)
  })
  
  ###############
  ### MAP TAB ###
  ###############
  
  points <- reactive({
    
    for_map <- event_subset() %>% 
      dplyr::select(lon = decimalLongitude, lat = decimalLatitude, eventDate) %>% 
      drop_na() 
    return(for_map)
    
  })
  
  output$map <- renderLeaflet({ 
    
    leaflet(points()) %>%
      addTiles() %>%
      addCircleMarkers(radius=10,
                       lng= ~lon,
                       lat= ~lat,
                       clusterOptions = markerClusterOptions(),
                       popup = paste("event date: ", points()$eventDate, "<br>"))
  })
  
  ####################
  ### METADATA TAB ###
  ####################
  choices <- eventReactive(input$firstselection, {
    
    if(input$firstselection == "Project"){
      choices = c("Title", "Abstract", "Funding")
    }
    
    else if(input$firstselection == "Methods"){
      choices = c("Study extent","Sampling description", "Control quality", "Method step")
    }
    
    else if(input$firstselection == "Geographical coverage"){
      choices = c("Study area description", "Bounding coordinates")
    }
  })
  
  output$secondselection <- renderUI({
    selectInput("secondselection", " ", choices = choices())
  })
  
  output$metadata <- eventReactive(input$secondselection, {
    
    BASE="/home/rstudio/app/data/"
    meta <- read_xml(file.path(BASE, "eml.xml")) %>% as_list()
    
    if(input$secondselection == "Title"){
      meta$eml$dataset$project$title[[1]]
    }
    else if(input$secondselection == "Abstract"){
      meta$eml$dataset$project$abstract[[1]][[1]]
    }
    else if(input$secondselection == "Funding"){
      meta$eml$dataset$project$funding[[1]]
    }
    else if(input$secondselection == "Study extent"){
      meta$eml$dataset$methods$sampling$studyExtent$description$para[[1]]
    }
    else if(input$secondselection == "Sampling description"){
      meta$eml$dataset$methods$sampling$samplingDescription$para[[1]]
    }
    else if(input$secondselection == "Control quality"){
      meta$eml$dataset$methods$qualityControl$description$para[[1]]
    }
    else if(input$secondselection == "Method step"){
      meta$eml$dataset$methods$methodStep$description$para[[1]]
    }
    else if(input$secondselection == "Study area description"){
      meta$eml$dataset$coverage$geographicCoverage$geographicDescription[[1]]
    }
    else if(input$secondselection == "Bounding coordinates"){
      meta$eml$dataset$coverage$geographicCoverage$boundingCoordinates[[1]]
    }
    else if(input$firstselection == "Intellectual copyrights"){
      meta$eml$dataset$intellectualRights[[1]][[2]][[1]][[1]]
    }
  })
  
  ######################
  # ENDING THE SESSION #
  ######################
  session$onSessionEnded(function() {
    unlink(paste0("/home/rstudio/app/", session$token), recursive = TRUE)
  })
  
}





