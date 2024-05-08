<h1 align="center">CarbonViewer</h1>
<h2 align="center">A calculator for peatland volume and carbon stock to support area planners and decision makers.</h2>

![CC BY-NC-SA 4.0][license-badge]
[![DOI](https://zenodo.org/badge/554694482.svg)](https://zenodo.org/badge/latestdoi/554694482)

[license-badge]: https://badgen.net/badge/License/CC-BY-NC-SA%204.0/green

**NOTE**: The application supports both the English and Norwegian language. To change the language, click on the `Change language` box and choose `en` for English or `no` for Norwegian. 

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

### Author / Forfatter

The application has been created by [Benjamin Cretois](https://www.nina.no/english/Contact/Employees/Employee-info?AnsattID=15849), [Marte Fandrem](https://www.ntnu.no/ansatte/marte.fandrem) and [Magni Olsen Kyrkjeeide](https://www.nina.no/Kontakt/Ansatte/Ansattinformasjon.aspx?AnsattID=12110). This project was funded by Norwegian Research Council under Grant number 282327 and Statnett.

<img src="../man/figures/logo_nina.png" alt="drawing" width="100"/>
<img src="../man/figures/ntnu.png" alt="drawing" width="100"/>
<img src="../man/figures/statnett.png" alt="drawing" width="100"/>


### How to cite us:

Kyrkjeeide, M. O., Fandrem, M., Kolstad, A. L., Bartlett, J., Cretois, B., & Silvennoinen, H. M. (2023). A calculator for local peatland volume and carbon stock to support area planners and decision makers. Carbon Management, 14(1), 2267018.
