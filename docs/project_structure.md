```
\carbonviewer
├── .github
    ├── workflows
        deploy.yml          # Github action for deployment
├── appScripts
    ├── custom_theme.R      # Custom theme for the app 
    ├── dependancies.R      # Required packages and translation object (i18n)
    ├── global.R            # Global variables
    ├── server.R            # Server side of the app
    ├── ui.R                # User interface of the app
├── data                    # Data folder
    ├── gran_dataset.zip    # gran dataset with peat properties for norwegian mires
├── docs
    ├── changelog.md         # Changelog for the app
    ├── project_structure.md # Project structure
    ├── instructions.md            # instructions for the app (main body app)
├── man
    ├── figures             # Figures for the documentation
        ├── interpolation
        ├── ln.png
        ├── logo_nina.png
        ├── ntnu.png
        ├── statnett.png
├── Rscripts 
    ├── exploration.R       # IDW interpolation (stand-alone)
├── test                    # Test data
    ├── csv_only.zip
    ├── invalid_csv.zip
    ├── invalid_shp.zip
    ├── shp_no_proj_file.zip
    ├── test_dataset_cm.zip
├── .gitignore              # Files to ignore
├── app.R                   # Main file for the app: runApp('/home/rstudio/app')
├── carbonviewer.Rproj      # R project file
├── docker-compose.yaml     # Docker compose file for the app
├── Dockerfile              # Dockerfile for the app
├── LICENSE                 # License for the app
├── README.md               # Readme file for the app (exact same as instructions.md)
├── rstudio-prefs.json      # Rstudio preferences
├── translation.json        # Language translation dictionairy for the app read into 
```

