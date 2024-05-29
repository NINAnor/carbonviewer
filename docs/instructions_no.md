<h1 align="center">CarbonViewer</h1>
<h2 align="center">A calculator for peatland volume and carbon stock to support area planners and decision makers.</h2>

![CC BY-NC-SA 4.0][license-badge]
[![DOI](https://zenodo.org/badge/554694482.svg)](https://zenodo.org/badge/latestdoi/554694482)

[license-badge]: https://badgen.net/badge/License/CC-BY-NC-SA%204.0/green

**NOTE**: The application supports both the English and Norwegian language. To change the language, click on the `Change language` box and choose `en` for English or `no` for Norwegian. 

---

## Hva er CarbonViewer

**CarbonViewer** er en [R Shiny](https://shiny.rstudio.com/)-applikasjon som beregner og visualiserer karbonmengde i torvlaget for et gitt areal av myr. Kalkulatoren estimerer det totale karboninnholdet bundet opp i organisk jord som kan frigjøres som atmosfærisk karbondioksid (CO2) dersom arealet blir drenert. Drenering av myr gir høye klimagassutslipp og formålet med kalkulatoren er å gi beslutningstakere et bedre kunnskapsgrunnlag om karbonmengden som er bundet opp i myr som kan bli berørt i utbyggingsprosjekter. Kalkulatoren bør brukes tidlig i arealplanlegging og som et verktøy for å kartlegge karbonlageret i myr. Dette for å unngå utbygging i karbonrike områder og minimere klimagassutslipp fra naturinngrep.

## Hvordan bruke CarbonViewer?


### 1. Importer Data

Last opp en zip-file som inneholder en shape-fil med polygon av det aktuelle området og en csv-fil med torvdybder i cm fra samme område. Pass på at koordinater X og Y for hver av torvdybdemållingene i csv-filen har samme koordinatsystem som shape-filen. Alle koordinatsystemer kan brukes, men merk at appen endrer dataene til ETRS89 UTM Zone 33N for beregningene.

***Brukerveiledning:** Klikk på Last opp data. Dra og slipp eller finn zip-filen som inneholder shape-fil og csv-fil. Shape-filen må inkludere følgende filer: .shp, .shx, .dbf, and .prj. csv-filen må inkludere følgende kolonner: X, Y, and torvdybde_cm.*

**Mappestruktur:**

```{text}
/dataset.zip
├── torvdybder.csv              
├── prosjektomrade.dbf              
├── prosjektomrade.prj
├── prosjektomrade.shp
└── prosjektomrade.shx
```

**Example of correct format for the .csv file:**
| X &nbsp; &nbsp; &nbsp;| Y &nbsp; &nbsp; &nbsp;| torvdybde_cm  |
|-----------------------|-----------------------|---------------|
| X1                    | Y1                    | 120           |
| X2                    | Y2                    | 120           |
| X3                    | Y3                    | 270           |
| X4                    | Y4                    | 270           |
| X5                    | Y5                    | 320           |

### 2. Beregn torvvolum

Det totale torvvolumet i området blir beregnet ved å interpolere torvdybdemålingene med Inverse Distance Weighting (IDW) (se [Peat Depth Interpolation](#peat-depth-interpolation)). **Merk at et testdatasett er gitt for uttesting av beregninger: “Beregn med testdata”.**

Dette steget resulterer i:
- Et kart med punkter som viser hvor torvdybdemålingene er tatt i felt *(se Kart og Resultater -fanen).*
- Et kart som viser raster (*1x1 m*) med interpolerte torvdybder *(se Kart og Resultater-fanen).*
- Arealet for området (*m2*) og totalt torvvolum (*m3*) i området *(se Kart og Resultater-fanen).*
- Grafer som viser påvirkningen av power parameter på interpoleringsresultatet *(se Power evalueringsgrafer).*

***Brukerveiledning:** Klikk på Last ned resultater. Vent til fremdriftsindikatoren er ferdig. Se resultatene under Kart og Resultater- og Power evalueringsgrafer-fanene. **Valgfritt**: Endre power-parameter i Kart og Resultater-fanen.*

### 3. Beregn karboninnhold

**Totalt karboninnhold** beregnes ved å multiplisere karboninnhold i jord (SOC) med det totale torvvolumet i området. SOC beregnes ved å bruke massetetthet (Bulk Density (BD)), organisk materiale i jord (SOM) og andel karboninnhold i organisk materiale (se [Carbon Content Caluclation](#carbon-content-calculation)). Appen gir brukeren valget mellom å beregne med **Standardverdier** eller **Egendefinerte verdier**. **Standardverdier** er basert på en [Database](https://github.com/NINAnor/carbonviewer/blob/main/data/gran_dataset.csv) med torvegenskaper fra norske myrer, og har en angitt verdi på 0,5 for andel karboninnhold i organisk jord. Hvis brukeren velger **Egendefinerte verdier**, krever det en verdi for massetetthet (BD, i g/cm3 eller tonn/m3, vanligvis mindre enn 0,2 for torv), organisk materiale (SOM) og andel karboninnhold i organisk jord (typisk 0,5), helst fra området som undersøkes. 

Dette steget gir en verdi for **gjennomsnitt** og **standardavvik** for det totale karboninnholdet beregnet for området *(tonn C)* og vises under Kart og Resultater-fanen.

***Brukerveiledning:** Trykk på Beregn karboninnhold. Velg mellom Standardverdier og Egendefinerte verdier. Trykk på Last verdier. Se resultatet under Kart og Resultater-fanen.* 

- *Standardverdier: Velg myrtype som gjelder for ditt område. Trykk på Last verdier.* 
- *Egendefinerte verdier: Sett inn massetetthet (BD; in g/cm3 eller tonn/m3), organisk materiale (SOM; Verdi mellom 0-1) og andel karboninnhold i organisk jord (verdi mellom 0-1, typisk 0,5) for ditt område. Trykk på Last verdier.*

### 4. Eksporter resultater

Resultatene for torvvolum og karbonberegninger kan eksporteres som zip-fil.

Zip-filen inneholder følgende filer:

```{text}
/Downloads/carbonviewer-results-date.zip
├── carbonviewer_resultater.csv              
├── carbonviewer_resultater.txt
├── kart_over_omradet.png
├── kart_torvdybder.png
└── raster_interpolerte_torvdybder.tif
```

***Brukerveiledning:** Trykk på Last ned resultater > Download.*

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

### Author / Forfatter

The application has been created by [Benjamin Cretois](https://www.nina.no/english/Contact/Employees/Employee-info?AnsattID=15849), [Marte Fandrem](https://www.ntnu.no/ansatte/marte.fandrem) and [Magni Olsen Kyrkjeeide](https://www.nina.no/Kontakt/Ansatte/Ansattinformasjon.aspx?AnsattID=12110). This project was funded by Norwegian Research Council under Grant number 282327 and Statnett.

<img src="../man/figures/logo_nina.png" alt="drawing" width="100"/>
<img src="../man/figures/ntnu.png" alt="drawing" width="100"/>
<img src="../man/figures/statnett.png" alt="drawing" width="100"/>


### How to cite us:

Kyrkjeeide, M. O., Fandrem, M., Kolstad, A. L., Bartlett, J., Cretois, B., & Silvennoinen, H. M. (2023). A calculator for local peatland volume and carbon stock to support area planners and decision makers. Carbon Management, 14(1), 2267018.
