<h1 align="center">CarbonViewer</h1>
<h2 align="center">A calculator for peatland volume and carbon stock to support area planners and decision makers .</h2>

![MIT License][license-badge]
[![DOI](https://zenodo.org/badge/554694482.svg)](https://zenodo.org/badge/latestdoi/554694482)

[license-badge]: https://badgen.net/badge/License/MIT

**NOTE**: The application supports both the English and Norwegian language. To change the language, click on the `Change language` box and choose `en` for English or `no` for Norwegian. 

**MERK**: Applikasjonen støtter både engelsk og norsk. For å endre språk, klikk på `Endre språk`-boksen og velg `en` for engelsk eller `no` for norsk.

Description of CarbonViewer in [English](#what-is-the-carbonviewer)

Beskrivelse av appen på [Norsk](#hva-er-carbonviewer)

---

## Hva er CarbonViewer

**CarbonViewer** er en [R Shiny](https://shiny.rstudio.com/)-applikasjon som beregner og visualiserer karbonmengde i torvlaget for et gitt areal av myr-naturtyper. Kalkulatoren estimerer det totale karboninnholdet bundet opp i organisk jord som kan frigjøres som atmosfærisk karbondioksid (CO2) dersom arealet blir påvirket. Utbygging i myr kan gi høye klimagassutslipp og formålet med kalkulatoren er å gi beslutningstakere et bedre kunnskapsgrunnlag om karbonet som er bundet opp i torv. Kalkulatoren bør brukes i tidlig planlegging og som et verktøy for å kartlegge jordbundet karbon i myr. Dette for å unngå utbygging i karbonrike områder og minimere klimagassutslipp fra naturinngrep.

## Hvordan bruker jeg denne applikasjonen?

**Merk at et testdatasett er gitt og det er mulig å laste det inn i applikasjonen ved å klikke på "Test app med testdatasett"**

### Lage kartene

**Etter å ha fulgt alle trinnene beskrevet nedenfor, klikk på fanen `Resultater` for å visualisere resultatene**

- I menyen 'volumberegning' må brukeren laste opp en 'zip'-fil som inneholder både en 'shapefil' som avgrenser det aktuelle området og en 'csv'-fil med torvdybder (m), samt koordinater (gitt i UTM 32 N, EPSG:25832) for hvert prøvepunkt tatt i det aktuelle området. En mål for notering av torvdybder vises nedenfor. Torvdybder bør- for best mulig resultat - bli tatt med regelmessige intervaller med maksimum avstand på 20m mellom hvert punkt (for mindre myrarealer bør en avstand på mindre enn 20m benyttes).

**Riktig mål for .csv filen**

<br>


| X   &nbsp; &nbsp; &nbsp;    | Y    &nbsp; &nbsp; &nbsp;    |        Dybde |
|---------|----------|--------------|
|    X1   |	  Y1     |	        1.2  |
|    X2    |	   Y2    |	      1.2  |
|    X3    |	   Y3    |	      2.7  |
|    X4     |	   Y4    |	      2.7  |
|    X5    |	   Y5    |	      3.2  |


<br>

- Brukeren kan deretter klikke på `Last in datasett`. Etter noen sekunder vil applikasjonen interpolere dybdene til hele interesseområdet. et kart over det gitte området med svarte punkter som indikerer hvor torvdybden er målt, og et kart over de interpolerte torvdybdene skal vises. **Merk** at en fremdriftslinje vises nederst til høyre i applikasjonen.

- Etter at volumberegningen er utført, skal estimert totalvolum torv (m3) også vises på topppanelet.

### Beregning av total karbonmengde i området

Det siste trinnet beregner den totale karbonmengden i det aktuelle området. Brukeren kan legge inn egne data med torvegenskaper dersom dette er tilgjengelig. Alternativt velger brukeren å benytte data for karboninnhold fra en innebygd database. Når du klikker på `Torvegenskaper`, tilbys de to alternativene:

- 1) `Standardverdier`: Når dette alternativet er valgt, trenger brukeren kun å velge myrtype for området. Her vil brukeren få flere alternative detaljnivåer for myrtype, gitt den kunnskapen som brukeren innehar om det angitte området. Beregningen av karbonmengden baseres på eksisterende data for **massetetthet**, og **andel organisk materiale** for oppgitt myrtype, samt standardverdi på 0.5 for **andel karboninnhold i organisk materiale** (se artikkel for kilder).

- 2) `Egendefinerte verdier`: Dette alternativet forutsetter at brukeren kjenner verdiene for **massetetthet** (i g/cm3 eller tonn/m3, vanligvis mindre enn 0.2 for myr), **andel organisk materiale** (verdi 0-1) og **andel karboninnhold i organisk materiale** (verdi 0-1) i det aktuelle området eller ønsker å teste datasettet med egne inngangsverdier. Her er det mulig å legge inn egne tall. Når tallene er lagt inn, kan brukeren klikke på "Last inn verdier".

Den totale karbonmengden (kg) i området vises øverst til høyre i applikasjonen.

### Last ned dataene

Når volumet er beregnet, er det mulig å laste ned kartfigurer. Videre vil resultater fra karbonberegningen bli tilgjengelig ved neste steg i kalkulatoren.
I applikasjonen kan brukeren klikke på `Last ned resultater` og `Last ned`. Dette vil returnere en `.zip`-fil som inneholder:

- `map_descriptive.png` : et kart over området med punkter for dybdemål.
- `map_interpolation.png` : et kart med interpolerte torvdybder.
- `interpolation_raster.tif` : et raster av resultatet fra volumberegningen - klar til bruk i enten **QGIS eller ArcGIS!**
- `results.csv` : en csv-fil med resultater fra volum- og karbonberegningene.

---

## What is the CarbonViewer

**CarbonViewer** is a [R Shiny](https://shiny.rstudio.com/) application designed to calculate and visualize the amount of carbon stored in a given peatland area. 
The application estimates the total carbon content in the peat body, which can be used to evaluate the soil carbon storage at any given peatland site and the potential impact land-use change can have on CO2 emission. As development in peatland areas may give cause to high greenhouse gas emissions, the aim of this application is to support area planners with an improved knowledge base of the soil carbon in potentially impacted areas. The application should be applied during early planning phases as a tool to map soil carbon stocks in peatlands, to avoid, reduce or mitigate the impact of development in peatlands areas.

## How to use this application?

**Note that a test dataset is provided and that is is possible to load it in the application by clicking on "Test app with test dataset"**

### Creating the maps

**After following all the steps described below, please click on the `Results` tab to vizualise the results**

- In the menu 'Volume calculation' the user must upload a `zip` file containing both a `shapefile` with the extent of the area of interest and a `csv` file containing peat depth measures (in m) taken at the site with coordinates for each measure (given in UTM 32 N, EPSG:25832). An example template for notation of peat depths is provided below. Peat depth measurements should -for best results- be taken at regular intervals at a maximum distance of 20m between each sample point (if a small peatland area are sampled, less than 20m is needed).

**Example of correct format for the .csv file**


<br>

<br>


| X   &nbsp; &nbsp; &nbsp;    | Y    &nbsp; &nbsp; &nbsp;    |        Dybde |
|---------|----------|--------------|
|    X1   |	  Y1     |	        1.2  |
|    X2    |	   Y2    |	      1.2  |
|    X3    |	   Y3    |	      2.7  |
|    X4     |	   Y4    |	      2.7  |
|    X5    |	   Y5    |	      3.2  |


<br>

<br>



- The user can then click on `Load dataset`. After a few seconds the application will interpolate the depths of the entire area of interest. a map of the given area with black points indicating where peat depth have been measured, and a map of the interpolated peat depths should be displayed. **Note** that a progress bar is displayed on the bottom right of the application.

- After the volume calculation is done the estimated total volume of peat (m3) should also appear on the top panel.

### Calculating the carbon content of the area

The final step lies in calculating the carbon content of the given area. When clicking on `Peat properties`, two options are offered to the user:

- 1) `Default values`: Using this option, the user choose the peatland type of the area. The calculation of the carbon content will then be done using a database of peat properties from Norwegian mires, that contain values for **bulk density** and **fraction organic matter** representing the chosen peatland type, and a set value of 0.5 for **fraction of carbon content in organic matter** (see paper for references).

- 2) `Custom values`: This option requires that the user knows the values of **bulk density** (in g/cm3 or tonne/m3, commonly less than 0.2 for peatlands), **fraction organic matter** (values of 0-1) and **fraction carbon content** (values of 0-1) in the given area, or that the user is interested in testing with specific values. The input values are specified in the three boxes. Once the values are inserted, the user can click on `Load values`.

The total carbon content (kg) of the area will be displayed on the top right panel of this application.

### Download the data

Once the peat volum map is computed, it is possible to download the output maps. The results from the carbon calculation will also be available by completing the next step in the calculator.
In the application, the user can click on `Download results` and `Download`. This will return a `.zip` file containing:

- `map_descriptive.png` : a map of the given area including peat depth measurement points.
- `map_interpolation.png` : a map with interpolated values of peat depths.
- `interpolation_raster.tif` : a raster of the result from the interpolation of volume - ready to use in either **QGIS or ArcGIS!**
- `results.csv` : a csv-file with results from the volume and carbon calculations. 

---

### Author / Forfatter

The application has been created by [Benjamin Cretois](https://www.nina.no/english/Contact/Employees/Employee-info?AnsattID=15849), [Marte Fandrem](https://www.ntnu.no/ansatte/marte.fandrem) and [Magni Olsen Kyrkjeeide](https://www.nina.no/Kontakt/Ansatte/Ansattinformasjon.aspx?AnsattID=12110). This project was funded by Norwegian Research Council under Grant number 282327 and Statnett.

<img src="man/figures/logo_nina.png" alt="drawing" width="100"/>
<img src="man/figures/ntnu.png" alt="drawing" width="100"/>
<img src="man/figures/statnett.png" alt="drawing" width="100"/>


### How to cite us:

Kyrkjeeide, M. O., Fandrem, M., Kolstad, A. L., Bartlett, J., Cretois, B., & Silvennoinen, H. M. (2023). A calculator for local peatland volume and carbon stock to support area planners and decision makers. Carbon Management, 14(1), 2267018.
