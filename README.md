<h1 align="center">CarbonViewer</h1>
<h2 align="center">A calculator for peatland volume and carbon stock to support area planners and decision makers.</h2>

![CC BY-NC-SA 4.0][license-badge]
[![DOI](https://zenodo.org/badge/554694482.svg)](https://zenodo.org/badge/latestdoi/554694482)

[license-badge]: https://badgen.net/badge/License/CC-BY-NC-SA%204.0/green

**NOTE**: The application supports both the English and Norwegian language. To change the language, click on the `Change language` box and choose `en` for English or `no` for Norwegian. 

---

## What is CarbonViewer?

**CarbonViewer** is a [R Shiny](https://shiny.rstudio.com/) application designed to calculate and visualize the amount of carbon stored in a given peatland area. The application estimates the total carbon content in the peat body, which can be used to evaluate the soil carbon storage at any given peatland site and the potential impact land-use change can have on CO2 emission. As drainage of peatland areas results in high greenhouse gas emissions, the aim of this application is to support area planners with an improved knowledge base of the soil carbon stock in peatlands considered for development. The application should be used early in planning as a tool to map soil carbon stocks in peatlands, and hence, to avoid, reduce or mitigate the impact of development in peatlands areas.

## How to use CarbonViewer?


### 1. Import Data

Upload a zip-file containing a shapefile of the study area and a csv-file with peat depth measurements in cm from the same area. Ensure that the X and Y coordinates of the peat depths measurements in the csv-file match the coordinate system of the shapefile. All coordinate systems are supported, but note that the application converts the data to ETRS89 UTM Zone 33N for the calculations.

***User Action:** Click on Upload Data. Drag and drop or browse for the zip-file containing the shapefile and csv-file.* 
- *The shapefile must include the following files: .shp, .shx, .dbf, and .prj.* 
- *The csv-file must include the following columns: X, Y, and peat_depth_cm.*

**Folder structure:**

```{text}
/dataset.zip
├── peat_depth_samples.csv              
├── study_area.dbf              
├── study_area.prj
├── study_area.shp
└── study_area.shx
```


**Example of correct format for the .csv file:**
| X &nbsp; &nbsp; &nbsp;| Y &nbsp; &nbsp; &nbsp;| peat_depth_cm |
|-----------------------|-----------------------|---------------|
| X1                    | Y1                    | 120           |
| X2                    | Y2                    | 120           |
| X3                    | Y3                    | 270           |
| X4                    | Y4                    | 270           |
| X5                    | Y5                    | 320           |

### 2. Calculate Peat Volume

The total volume of peat in the study area is calculated by interpolating the peat depth measurements using Inverse Distance Weighting (IDW) (see [Peat Depth Interpolation](#peat-depth-interpolation)). **Note that a test dataset is provided to test the calculations: “Calculate with testdata”.**

This step results in:
- A map with points representing the location of the peat depth measurements in the field *(see Map results tab).*
- A map displaying a raster (*1x1 m*) with the interpolated peat depths *(see Map results tab).*
- A value for the study area (*m2*) and the total volume of peat (*m3*) in the study area *(see Map results tab).*
- Graphs showing the influence of the power parameter on the interpolation results *(see Power evaluation graphs tab).*

***User Action:** Click on Load dataset. Wait for the progress bar to finish. View the results in the Map results and Power evaluation graphs tabs. **Optional**: Customize the Power parameter in the Map Results tab.*

### 3. Calculate the Carbon Content 

The **Total Carbon Content** is calculated by multiplying the Soil Organic Carbon (SOC) with the total volume of peat in the study area. The SOC is calculated using the peat properties Bulk Density (BD), Soil Organic Matter (SOM), and the Carbon content fraction (see [Carbon Content Caluclation](#carbon-content-calculation)). The application allows the user to either choose **default** values for the peat properties or **customize** the values. The **default** values are based on a [Database](https://github.com/NINAnor/carbonviewer/blob/main/data/gran_dataset.csv) of peat properties from Norwegian mires, and a set value of 0.5 for the fraction of carbon content in organic matter. If the user chooses to **customize** the values, it is required to know the values of bulk density (in g/cm3 or tonne/m3, commonly less than 0.2 for peatlands), organic matter fraction (SOM) and carbon content fraction for the study area (typically 0.5).  

This step results in a value for the **mean** and **standard deviation** of the total carbon content in the study area *(tons C)* displayed in the Map results tab.

***User Action:** Click on Carbon content calculation. Choose between Default values or Custom values for the peat properties. Click on Load values. View the results in the Map results tab.* 

- *Default values: Choose the peatland type of the area. Click on Load values.* 
- *Custom values: Insert the values of Bulk Density (in g/cm3 or tonne/m3), Soil Organic Matter fraction (values of 0-1), and the fraction of carbon content in organic matter (values of 0-1) in the given area. Click on Load values.*

### 4. Export Results

The results of the volume and carbon calculations can be exported as a zip-file.

The zip-file contains the following files:

```{text}
/Downloads/carbonviewer-results-date.zip
├── carbonviewer_results.csv              
├── carbonviewer_results.txt
├── map_study_area.png
├── map_peat_depths.png
└── raster_interpolated_peat_depths.tif
```

***User Action:** Click on Download results > Download.*

---

## Overview of Methods

A brief overview of the methods used in the application is provided below. For a more detailed description, please refer to Kyrkjeeide, M. O. et al. (2023).

### Peat Depth Interpolation
The peat depth measurements from field survey (*csv-file*) are extrapolated to the entire study area extent (*shp-file*) using Inverse Distance Weighting (IDW). IDW assumes that nearby observations are more alike than those further away. For instance, a peat measurement taken at a 10 *m* distance has a greater influence on the estimated value of a raster pixel cell than a measurement taken at a 50 *m* distance. The degree of this influence is controlled by the power parameter. A power of 1 assigns an equal weight to all points, resulting in a smoother interpolated raster. Increasing the power value reduces the influence of distant sample points on the estimated value. 

**Optimal value of the Power parameter:**

The application identifies the optimal power parameter using a cross-validation approach, comparing the results of an IDW interpolation method with those of a Kriging interpolation method. The power parameter is varied between 1 and 6, and the Mean Absolute Error (MAE) is calculated for each value. The power parameter with the lowest MAE is chosen as the default value. You can also choose to use a custom value for the power parameter by sliding the bar in the "Map Result" Section. The influence of the power on the results is shown in the graphs located in "Power Evaluation Graphs" section.

### Carbon Content Calculation

The **Total Carbon Content (TCC)** of the study area is calculated by multiplying the SOC with the total volume of peat in the study area, where the SOC is calculated using the peat properties Bulk Density (BD), Soil Organic Matter (SOM), and the SOM:SOC conversion factor.

TCC = SOC * v

where:
- **SOC** = BD * SOM * 0.5
- **v** = peat volume (m3) calculated by the interpolation of peat depth measurements
- **BD** = dry Bulk Density (t m−3 or g cm−3)
- **SOM** = Soil Organic Matter fraction
- **0.5** = SOM:SOC conversion factor, value can range from 0 to 1, but the default value is set to 0.5

The peat volume of the study area is calculated by the interpolation of the peat depth measurements (Step 2). The other peat properties, **Bulk Density**, **Soil Organic Matter fraction**, and the SOM:SOC conversion factor, are either set to default values or can be customized by the user (Step 3). 

---

### Author

The application has been created by [Benjamin Cretois](https://www.nina.no/english/Contact/Employees/Employee-info?AnsattID=15849), [Marte Fandrem](https://www.ntnu.no/ansatte/marte.fandrem) and [Magni Olsen Kyrkjeeide](https://www.nina.no/Kontakt/Ansatte/Ansattinformasjon.aspx?AnsattID=12110). This project was funded by Norwegian Research Council under Grant number 282327 and Statnett.

<img src="man/figures/logo_nina.png" alt="drawing" width="100"/>
<img src="man/figures/ntnu.png" alt="drawing" width="100"/>
<img src="man/figures/statnett.png" alt="drawing" width="100"/>


### How to cite us:

Kyrkjeeide, M. O., Fandrem, M., Kolstad, A. L., Bartlett, J., Cretois, B., & Silvennoinen, H. M. (2023). A calculator for local peatland volume and carbon stock to support area planners and decision makers. Carbon Management, 14(1), 2267018.