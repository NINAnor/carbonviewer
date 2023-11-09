# Use the rocker image as a base image
FROM rocker/geospatial

RUN apt-get update -qq && \
    apt-get install -qq libxt-dev r-cran-cairo

RUN install2.r --error \
    --deps TRUE \
    shiny \ 
    shinydashboard \
    shinyBS \
    xml2 \
    DT \
    leaflet \
    rintrojs \
    plotly \
    dashboardthemes \
    starsExtra

RUN R -e "devtools::install_github('hadley/emo')"
RUN R -e "devtools::install_github('Appsilon/shiny.i18n')"

COPY . ./home/rstudio/app/

# Change the user settings
RUN mkdir -p ./home/rstudio/.config/rstudio/
RUN cp ./home/rstudio/app/rstudio-prefs.json ./home/rstudio/.config/rstudio/

CMD Rscript ./home/rstudio/app/app.R



