## ui.R ##

# HEADER -----------------------------------------------------------------------------------------
header <- shinydashboard::dashboardHeader(title = "CarbonViewer",
  tags$li(
    a(
      strong(i18n$t("ABOUT")),
      height = 40,
      href = "https://github.com/NINAnor/carbonviewer",
      title = "",
      target = "_blank"
    ),
    class = "dropdown"
  )
)

# SIDEBAR -----------------------------------------------------------------------------------------
sidebar <- shinydashboard::dashboardSidebar(
  sidebarMenu(
    shiny.i18n::usei18n(i18n),
      selectInput('selected_language',
                    i18n$t("Skift språk"),
                    choices = i18n$get_languages(),
                    selected = i18n$get_key_translation(),
                    ),
    
    menuItem(i18n$t("Bruksanvisning"), tabName = "instruction", icon = icon("comment")),
    
    menuItem(i18n$t("Last opp data"), tabName = "upload", icon = icon('download'),
                fileInput(inputId = "upload_zip",
                           label = i18n$t(shiny::HTML("Last opp en zip-fil")),
                          accept = ".zip")
             ),

    menuItem(i18n$t("Volumberegning"), tabName = "calculation", icon = icon('cog'),
                actionButton(inputId = "unzip", label = i18n$t("Beregn")),
                actionButton(inputId = "test", label = i18n$t("Beregn med testdata")),
                actionButton(inputId = "reset", label = i18n$t("Nullstille"))
             ),
    
    menuItem(i18n$t("Beregn karboninnhold"), tabName = "carbonchar", icon = icon('keyboard'),

      tags$b(i18n$t("Torvegenskaper")),   
 
      menuItem(i18n$t("Standardverdier"), tabName = "df_values", icon = icon('keyboard'),
             selectInput(inputId = "g_peatland_type", 
                         label = i18n$t(shiny::HTML("Hovedmyrtype")),
                         choices = c("Unknown / Ukjent" = "unknown",
                                     "Bog / Nedbørsmyr" = "bog",
                                     "Fen / Myr" = "fen")),
             
             uiOutput("specific_peatland_type"),
             
             actionButton(inputId = "run_values_gran_data",
                          label = i18n$t("Last verdier"))
      ),
             
             
      menuItem(i18n$t("Egendefinerte verdier"), tabName = "custom_values", icon = icon('keyboard'),
             numericInput(inputId = "bulkdensity",
                       label = i18n$t(shiny::HTML("Massetetthet")),
                       value = 0.1,
                       step = 0.01
             ),
             numericInput(inputId = "organicmatter",
                          label = i18n$t(shiny::HTML("Organisk materiale")),
                          value = 0.95, 
                          step = 0.01
             ),
             numericInput(inputId = "carboncontent",
                          label = i18n$t(shiny::HTML("Karboninnhold")),
                          value = 0.5,
                          step = 0.01
             ),
             actionButton(inputId = "run_values_custom",
                          label = i18n$t("Last verdier"))
            )
    ),
    
    menuItem(i18n$t("Kart resultater"), tabName = "tables", icon = icon("th")
             ),
    
    menuItem(i18n$t("Power evalueringsgrafer"), tabName = "powersetting", icon = icon('hand-fist')
             ),
    
    menuItem(i18n$t("Last ned resultater"), tabName = "download", icon = icon("file-export"),
      downloadButton("downloadData", shiny::HTML("Download"))
    )
  ),
  hr(),
  i18n$t("App laget med"), emo::ji("heart"), i18n$t("av IPN-GRAN-teamet."),
  br(),
  br(),
  "Carbonviewer v. 1.0.0"
)

# BODY ------------------------------------------------------------------------------------------------
body <- shinydashboard::dashboardBody(
  
  customTheme,
  
  tabItems(
    
    tabItem(
      tabName = "instruction",
      fluidRow(
        box(includeMarkdown("/home/rstudio/app/instructions.md"), width = 10)
      )
    ),
    
    tabItem(tabName = "tables",
            fluidRow(
              box(sliderInput(inputId = "power", i18n$t("Power verdi"),
                              min = 1, max = 6, value = 1), width = 6, height = 100),
              box(p(i18n$t("Kraftparameteren er satt til sin optimale verdi og brukes til å beregne både volumet av torv og mengden karbon som finnes i området. Likevel er det mulig å endre den for å passe bedre ens formål.")), 
                  width = 6, height = 100, background = "red"),
              infoBoxOutput("areaBox"),
              infoBoxOutput("volumeBox"),
              infoBoxOutput("carbonBox"),
              box(leafletOutput("descriptive_map"), width = 12),
              box(leafletOutput("interpolation_map"), width = 12)
            )),
    
    tabItem(tabName = "powersetting",
            fluidRow(
              box(plotOutput("maeVSpower"), width = 6),
              box(plotOutput("volumeVSpower"), width = 6),
            ))
  )
)

# Put them together into a dashboardPage
ui = shinydashboard::dashboardPage(
  title = "CarbonViewer",
  header,
  sidebar,
  body
)

