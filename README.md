# rSQM
r package doing Simple Quantile Mapping downscaling technique.

# This version did not pass CRAN check, the final(published) version is now on CRAN repository.
See https://cran.r-project.org/web/packages/rSQM/index.html


 Since the workflow is kind of complicated(Don't worry. It's not hard.), this vignette shows you how to run the `rSQM` package to do a downscaling process with CMIP5([Coupled model intercomparison project 5](https://en.wikipedia.org/wiki/Coupled_model_intercomparison_project)) data and observation data. If you want to see more about the data used in this package and APEC climate center, visit our website http://www.apcc21.org.  
  
## Arguments yaml file. 
 This procedure needs many datasets which tend to be large. Therefore, It is recommended to use meticulous directory structure, such as, project directory, observation directory, CMIP5 directory and so on. Before explaining those directories, see below `yaml` formatted file.
```
prjdir: D:/"Your project name"/foo
dbdir: D:/"Your project name"/Database
stndir: $(prjdir)/Observed/"station or regional name recommened"
bnddir: $(prjdir)/gis-boundary
qmapdir: $(prjdir)/Downscale/SQM
syear_obs: 1976     # Starting year of observed data
eyear_obs: 2005     # Ending year of observed data
syear_his: 1976     # Starting year of historical period (GCM)
eyear_his: 2005     # Ending year of historical period (GCM)
syear_scn:         
  - 2010
  - 2040
eyear_scn:
  - 2039
  - 2069
SimAll: FALSE       # Option for simulation all (GCM model, Variable, RCPs) combinations
ModelNames:
  - bcc-csm1-1-m    # Beijing Climate Center,  China Meteorological Administration (128x64)
  - CanESM2         # Canadian Centre for Climate Modelling and Analysis (128x64)
  - CMCC-CMS        # Centro Euro-Mediterraneo per I Cambiamenti Climatici (192x96)
  - CSIRO-Mk3-6-0   # Commonwealth Scientific and Industrial Research Organisation in  collaboration with the Queensland Climate Change Centre of Excellence (192x96)
  - FGOALS-g2       # LASG, Institute of Atmospheric Physics, Chinese Academy of  Sciences; and CESS, Tsinghua University (128x60)
  - HadGEM2-AO      # National Institute of Meteorological Research, Korea Meteorological Administration (192x145)
  - inmcm4          # Institute for Numerical Mathematics (180x120)
  - IPSL-CM5A-LR    # Institut Pierre-Simon Laplace (96x96)
  - MIROC-ESM       # Japan Agency for Marine-Earth Science and Technology, Atmosphere and Ocean Research Institute, and  National Institute for Environmental Studies (128x64)
  - MPI-ESM-LR      # Max Planck Institute for Meteorology (MPI-M) (192x96)
  - NorESM1-M       # Norwegian Climate Centre (144x96)
RcpNames:
  - rcp85           # Representative Concentration Pathway (RCP) 8.5 Scenarios
VarNames:
  - pr              #Precipitation (mm)
  - tasmax          #Max. temperature (C)
  - tasmin          #Min. temperature (C)
NtlCode: KR
stnfile: Station-Info.csv   # Station meta file, name it dishtinguibly in case many regions involved.
bndfile: Korea.shp
OWrite: TRUE
SRadiation: FALSE
```
 You are expected to have some exposure to those arguments, now see each of them one by one. At first, you create a super directory at large memory available path with name distinguishable, date and region are really good things to be written in the name, making your job path distinguishable. In this vignette, I name the name "APCC"(APEC Climate Center). D:/APCC.
```
prjdir: D:/APCC/project # This is your project directory where the downscaled results would be filed up.
dbdir: D:/APCC/Database # This is your database directory where the CMIP5 data needed for the work would be saved.
stndir: $(prjdir)/Observed/Korea # This is the directory to be filed up with observation data. I name it "Korea" in this tutorial
```
 Above three directories(prjdir, dbdir, stndir) must be prepared(created) in advance. That's because we assume you have your own observation data beforehand.
 You need to store station csv file and observation csv file in stndir(station directory). Station file(stnfile) is described in detail below. Observation file should be csv formatted and look like this. Each file name must contain the station ID(eg, ID108).
 
|Year|Mon|Day|Pcp(mm)|Tmax(c)|Tmin(c)|WSpeed(m/s)|RHumidity(fr)|SRad(MJ/m2)|
|:--:|:-:|:-:|:-----:|:-----:|:-----:|:---------:|:-----------:|:---------:|
|1969| 1 | 1 | 0.1   | -3.3  | -11   | 1.5       | 0.727       | 13.9      |
|1969| 1 | 2 | 0     | -6.4  | -12.9 | 1.8       | 0.8         | 12.8      |
|1969| 1 | 3 | 0.1   | -4.2  | -14.4 | 2.6       | 0.813       | 7.75      |
|1969| 1 | 4 | 0     | 0.7   | -10.4 | 2.7       | 0.617       | 16.46     |
|1969| 1 | 5 | 3.9   | -1    | -8.6  | 4.4       | 0.86        | 8.44      |
|1969| 1 | 6 | ...   | ...   | ...   | ...       | ...         | ...       |

 **Note : Day is month day not Julian format, that is, 2017/2/1 works but 2017/2/32 does not.**  
 Header names are not much critical, but the order is. `Year`, `Month`, `Day`, `Precipitation`, `Tasmax`, `Tasmin`, `Wind Speed`, `Relative Humidity`, and `Solar Radiation` should be in this order. Of course, the unit matters too.

```
bnddir: $(prjdir)/gis-boundary # Under development, providing shp. files for further work.
qmapdir: $(prjdir)/Downscale/SQM # This directory will contain final result passed through SQM(Simple Quantile Mapping)
syear_obs: 1976     # Starting year of observed data
eyear_obs: 2005     # Ending year of observed data
syear_his: 1976     # Starting year of historical period (GCM)
eyear_his: 2005     # Ending year of historical period (GCM)
syear_scn:         
  - 2010
  - 2040
eyear_scn:
  - 2039
  - 2069            # Start years and End years of climate change scenario.
SimAll: FALSE       # Option for simulation all (GCM model, Variable, RCPs) combinations
```
 If you put TRUE to SimAll argument, your process runs over all the models including GCMs, RCMs and RCPs. Obviously, takes a long time.
```
ModelNames:
  - bcc-csm1-1-m    # Beijing Climate Center,  China Meteorological Administration (128x64)
  - CanESM2         # Canadian Centre for Climate Modelling and Analysis (128x64)
  - CMCC-CMS        # Centro Euro-Mediterraneo per I Cambiamenti Climatici (192x96)
  - CSIRO-Mk3-6-0   # Commonwealth Scientific and Industrial Research Organisation in  collaboration with the Queensland Climate Change Centre of Excellence (192x96)
  - FGOALS-g2       # LASG, Institute of Atmospheric Physics, Chinese Academy of  Sciences; and CESS, Tsinghua University (128x60)
  - HadGEM2-AO      # National Institute of Meteorological Research, Korea Meteorological Administration (192x145)
  - inmcm4          # Institute for Numerical Mathematics (180x120)
  - IPSL-CM5A-LR    # Institut Pierre-Simon Laplace (96x96)
  - MIROC-ESM       # Japan Agency for Marine-Earth Science and Technology, Atmosphere and Ocean Research Institute, and  National Institute for Environmental Studies (128x64)
  - MPI-ESM-LR      # Max Planck Institute for Meteorology (MPI-M) (192x96)
  - NorESM1-M       # Norwegian Climate Centre (144x96)
RcpNames:
  - rcp85           # Representative Concentration Pathway (RCP) 8.5 Scenarios
```
 Otherwise, FALSE on SimAll, and specify model names you want to use in simulation.
```
VarNames:
  - pr              #Precipitation (mm)
  - tasmax          #Max. temperature (C)
  - tasmin          #Min. temperature (C)
```
 Variable names, pr(precipitation inmm), tasmax/tasmin(max/min temperature in Celcius degree), sfcWind(wind speed in m/s), rhs(relative humidity in fraction, not percentage), rsds(solar radiation in Mega Joule per square meter)
```
NtlCode: KR         
```
 National Code used when downloading clipped CMIP5 data from ADSS(APEC Data Service Syetem). See below tables.  
 
**table1. Available national-level data based on clipped CMIP5 climate change scenario data.**

| Region | Code | xmin | ymin | xmax | ymax |
|:------:|:----:|:----:|:----:|:----:|:----:|
| Bangladesh| BD| 88.03| 20.59| 92.67| 26.63|
| Bhutan| BT| 88.76| 26.71| 92.13| 28.32|
| Burma| MM| 92.19| 9.60| 101.18| 28.54|
| Cambodia| KH| 102.34| 9.91| 107.63| 14.69|
| Chile| CL| -109.46| -55.98| -66.42| -17.51|
| Colombia| CO| -81.73| -4.23| -66.87| 13.39|
| Cuba| CU| -84.96| 19.83| -74.13| 23.59|
| Egypt| EG| 24.70| 21.73| 36.24| 31.67|
| Ethiopia| ET| 33.00| 3.40| 47.99| 14.89|
| Federated States of Micronesia| FM| 138.05| 5.26| 163.03| 11.68|
| Fiji| FJ| -180| -20.68| 180| -12.48|
| India| IN| 68.16| 6.75| 97.40| 35.50|
| Indonesia| ID| 95.01| -11.00| 141.02| 5.90|
| Iran| IR| 44.05| 25.06| 63.32| 39.78|
| Kenya| KE| 33.91| -4.68| 41.90| 4.63|
| Malaysia| MY| 98.94| 0.86| 119.27| 7.36|
| Marshall Islands| MH| 165.26| 4.57| 172.16| 14.66|
| Mongolia| MN| 87.75| 41.57| 119.92| 52.15|
| Nepal| NP| 80.06| 26.36| 88.20| 30.43|
| Philippines| PH| 116.93| 4.61| 126.60| 21.12|
| Pakistan| PK| 60.88| 23.69| 77.84| 37.10|
| Papua New Guinea| PG| 140.84| -11.66| 159.48| -0.88|
| Samoa| WS| -172.80| -14.06| -171.41| -13.43|
| South Korea| KR| 124.61| 33.11| 130.92| 38.61|
| Tanzania| TZ| 29.33| -11.75| 40.44| -0.99|
| Thailand| TH| 97.35| 5.61| 105.64| 20.46|
| Timor-Leste| TL| 124.04| -9.50| 127.34| -8.13|
| Tonga| TO| -176.21| -22.35| -173.70| -15.56|
| Vietnam| VN| 102.15| 8.41| 109.46| 23.39|
| Zambia| ZM| 22.00| -18.08| 33.71| -8.22|

  

  

**table2. Available United State data based on clipped CMIP5 climate change scenario data.**

| Region | Code | xmin | ymin | xmax | ymax |
|:------:|:----:|:----:|:----:|:----:|:----:|
| Alabama | USAL| -88.47| 30.22| -84.89| 35.01|
| Alaska| USAK| -168.12| 54.76| -129.99| 72.69|
| Arizona| USAZ| -114.82| 31.33| -109.04| 37.00|
| Arkansas| USAR| -94.62| 33.00| -89.64| 36.50|
| California| USCA| -124.42| 32.53| -114.13| 42.01|
| Colorado| USCO| -109.06| 36.99| -102.04| 41.01|
| Connecticut| USCT| -73.73| 40.98| -71.79| 42.05|
| Delaware| USDE| -75.79| 38.43| -75.05| 39.84|
| District of Columbia| USDC| -77.12| 38.81| -76.91| 39.00|
| Florida| USFL| -87.64| 24.52| -79.72| 31.00|
| Georgia| USGA| -85.61| 30.36| -80.84| 35.00|
| Hawaii| USHI| -164.71| 18.91| -154.81| 23.58|
| Idaho| USID| -117.24| 41.99| -111.04| 49.00|
| Illinois| USIL| -91.51| 36.97| -87.02| 42.51|
| Indiana| USIN| -88.09| 37.77| -84.79| 41.76|
| Iowa| USIA| -96.64| 40.37| -90.14| 43.50|
| Kansas| USKS| -102.05| 36.99| -94.59| 40.00|
| Kentucky| USKY| -89.57| 36.50| -81.96| 39.15|
| Louisiana| USLA| -94.05| 28.93| -88.82| 33.02|
| Maine| USME| -71.08| 43.06| -66.95| 47.46|
| Maryland| USMD| -79.49| 37.89| -75.05| 39.72|
| Massachusetts| USMA| -73.51| 41.24| -69.93| 42.89|
| Michigan| USMI| -90.42| 41.70| -82.12| 48.30|
| Minnesota| USMN| -97.24| 43.50| -89.49| 49.38|
| Mississippi| USMS| -91.65| 30.17| -88.10| 35.00|
| Missouri| USMO| -95.77| 36.00| -89.10| 40.61|
| Montana| USMT| -116.05| 44.36| -104.04| 49.00|
| Nebraska| USNE| -104.05| 40.00| -95.31| 43.00|
| Nevada| USNV| -120.01| 35.00| -114.04| 42.00|
| New Hampshire| USNH| -72.56| 42.70| -70.60| 45.31|
| New Jersey| USNJ| -75.57| 38.93| -73.89| 41.36|
| New Mexico| USNM| -109.05| 31.33| -103.00| 37.00|
| New York| USNY| -79.76| 40.50| -71.86| 45.02|
| North Carolina| USNC| -84.32| 33.84| -75.46| 36.59|
| North Dakota| USND| -104.05| 45.94| -96.56| 49.00|
| Ohio| USOH| -84.82| 38.40| -78.85| 42.96|
| Oklahoma| USOK| -103.00| 33.62| -94.43| 37.00|
| Oregon| USOR| -124.57| 41.99| -116.46| 46.29|
| Pennsylvania| USPA| -80.52| 39.72| -74.69| 42.27|
| RhodeIsland| USRI| -71.89| 41.15| -71.12| 42.02|
| South Carolina| USSC| -83.35| 32.05| -78.55| 35.22|
| South Dakota| USSD| -104.06| 42.48| -96.44| 45.94|
| Tennessee| USTN| -90.31| 34.98| -81.65| 36.68|
| Texas| USTX| -106.65| 25.84| -93.51| 36.50|
| Utah| USUT| -114.05| 37.00| -109.04| 42.00|
| Vermont| USVT| -73.44| 42.73| -71.47| 45.02|
| Virginia| USVA| -83.67| 36.54| -75.24| 39.47|
| Washington| USWA| -124.76| 45.55| -116.91| 49.00|
| West Virginia| USWV| -82.64| 37.20| -77.72| 40.64|
| Wisconsin| USWI| -92.89| 42.49| -86.25| 47.30|

  
  
*(The countries in above tables are currently supported by APCC through ADSS. We plan to expand the list of supported countries through future updates. If you wish to see support for your country, please place a request by contacting us at *climate.service@apcc21.org)  

  

```
stnfile: Station-Info.csv
```
 'stnfile' is a csv(comma-seperated values) file. This is a kind of meta file over all the station information. One picture is worth a thousand words, see below.

| Lon     | Lat     | Elev | ID    | Ename   | SYear |
|:-------:|:-------:|:----:|:-----:|:-------:|:-----:|
| 126.95  | 37.5667 | 85.8 | ID108 | Seoul   | 1908  |
| 127.3667| 36.3667 | 68.9 | ID133 | Daejeon | 1969  |
| 129.0167| 35.1    | 69.6 | ID159 | Busan   | 1905  |

 Lon, Lat, and Elev are Longitude, Latitude, and Elevation of observatory respectively. And ID is the ID of obvervatory and Ename is the region where it is. SYear is the year the observation starts. There is one more thing you need to be aware of. If you lack of your own observation data so use GHCN observation data, name the stnfile 'Station-Info.csv'. We know it seems to be little awkward. But, the procedure is designed to run with that name over GHCN data.
 
```
bndfile: Korea.shp  # Under development, the shape file for further work.
OWrite: TRUE
```
 Downscaling process is heavy work. That means sometimes you need pause it and go again. Then you put TRUE on OWrite(Overwrite) which make things continue.
```
SRadiation: FALSE
```
 SRadiation(Solar Radiation) is a variable not likely to be. If it is luckily, put TRUE on it.
 
********
# Workflow
 
 Now we complete writing yaml file, that is, necessary arguments are prepared. Before going on, let's review the directories and corresponing data.
```
Your Working Directory(recommended to be in where large amount of disk memory available)
        |
        |  In your working directory, the yaml file which has necessary arguments must be in.
      -------------------
      |                 |
  Database            Project Diretory
      |                           |
 CMIP5 Directory          ---------------------------------------
      |                   |                   |                 |
 CMIP5 scenario data   gis-boundary       Observed          Downscale
downloaded from ADSS      |                   |                 |(final downscaled results)
must have 4073 files.   shape file          KOREA               -------
                       (Under dev.)   (or the region you        |     |
                                       are interested in.)     OBS   SQM
                                              |
                                station meta file and observation csv files
                              for each stations(meteorological observatories)
```

**(If you have any trouble understanding directory structure and observation path, just run rSQMSampleProject() function and see what happens.)**

###0. Write down your project details in yaml format and place it in your working directory
  Set your working directory, say it `D:/rSQMsample`, and create prjdir(`D:/rSQMsample/prj`), dbdir(`D:/rSQMsample/prj/Database`) and stndir(`D:/rSQMsample/prj/Observed/Korea`). If you have your own observation data and station information, let them in stndir.

###1. load library and set working directory
```
>library(rSQM)
>setwd("D:/sampleProject")
```

###2. Set working environment and parameters needed.
```
>EnvList <- SetWorkingEnvironment(envfile = "rSQM.yaml")
```
Let's look into this EnvList file, which is list object containing necessary arguments.

```
>EnvList
$prjdir
[1] "D:/rSQMsample/prj"
$dbdir
[1] "D:/rSQMsample/Database"
$qmapdir
[1] "D:/rSQMsample/prj/Downscale/SQM"
$bnddir
[1] "D:/rSQMsample/prj/gis-boundary"
$stndir
[1] "D:/rSQMsample/prj/Observed/Korea"
$syear_obs
[1] 1976
$eyear_obs
[1] 2005
$syear_his
[1] 1976
$eyear_his
[1] 2005
$syear_scn
[1] 2010 2040
$eyear_scn
[1] 2039 2069
$SimAll
[1] FALSE
$ModelNames
 [1] "bcc-csm1-1-m"  "CanESM2"       "CMCC-CMS"      "CSIRO-Mk3-6-0"
 [5] "FGOALS-g2"     "HadGEM2-AO"    "inmcm4"        "IPSL-CM5A-LR" 
 [9] "MIROC-ESM"     "MPI-ESM-LR"    "NorESM1-M"    
$RcpNames
[1] "rcp85"
$VarNames
[1] "pr"     "tasmax" "tasmin"
$NtlCode
[1] "KR"
$stndir
[1] "D:/rSQMsample/prj/Observed/Korea"
$stnfile
[1] "Station-Info.csv"
$bndfile
[1] "Korea.shp"
$OWrite
[1] TRUE
$SRadiation
[1] FALSE
$cmip5dir
[1] "D:/rSQMsample/Database/cmip5_daily_KR"
```
 The other directories, qmapdir, bnddir, and cmip5dir, are created automatically in right path.

###3. Load Clipped CMIP5 scenario data from ADSS(APCC Data Service System) 
 The CMIP5 data is clipped and served by APEC Climate Center.
```
LoadCmip5DataFromAdss(dbdir = EnvList$dbdir, NtlCode = EnvList$NtlCode)
```
or just type
```
do.call(LoadCmip5DataFromAdss, EnvList)
```
After some little time with pop up logging, the data are located in `D:\rSQMsample\Database\cmip5_daily_KR`. `daily` means the scenario data is daily-scaled and KR standing for the national code.

###(Optional). Load observations from GHCN(Global Historical Climatology Network)
```
 GhcnDailyUpdate(
   NtlCode = EnvList$NtlCode,
   stndir = EnvList$stndir,
   syear_obs = EnvList$syear_obs,
   eyear_obs = EnvList$eyear_obs)
```
or just
```
do.call(GhcnDailyUpdate, EnvList)
```
If there is no your own observation data, [Global Historical Climatology Network](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/global-historical-climatology-network-ghcn) provides world-wide meteorological observations. You can download the data 'GhcnDailyUpdate' function. However, We recommend you that prepare own observation dataset since Ghcn data often has lots of missing values.
When this step is done, the station metafile(named `Station-Info.csv`) and Observations are located in stndir.

###4. Downscale Daily CMIP5 Data
 Now that you have all necessary input data, let's begin downscaling process. This extracts daily time series for every combination of varialbes, GCM models, and RCP scenarios as text format.
```
DailyExtractAll(
  cmip5dir = EnvList$cmip5dir,
  stndir = EnvList$stndir,
  stnfile = EnvList$stnfile,
  qmapdir = EnvList$qmapdir,
  SimAll = EnvList$SimAll,
  ModelNames = EnvList$ModelNames,
  RcpNames = EnvList$RcpNames,
  VarNames = EnvList$VarNames,
  OWrite = EnvList$OWrite)
```
or just
```
do.call(DailyExtractAll, EnvList)
```
After `DailyExtractAll` function is over successfully. For each scenario mode, corresponding directory is created in qmapdir `D:/rSQMsample/prj/Downscale/SQM`. For instance, `CanESM2` model directory is `D:/rSQMsample/prj/Downscale/SQM/CanESM2`. Temporary files are stored in `'model directory'/365adj`, that's because the number of days per year differs from models, so `DailyExtractAll` calls internal logic and adjusts it in 365 days. Those temporary files are used in quantile mapping step at following step.


###5. Bias Correction using Simple Quantile-Mapping (SQM)
```
DailyQMapAll(
  stndir = EnvList$stndir,
  stnfile = EnvList$stnfile,
  qmapdir = EnvList$qmapdir,
  prjdir = EnvList$prjdir,
  SimAll = EnvList$SimAll,
  RcpNames = EnvList$RcpNames,
  VarNames = EnvList$VarNames,
  syear_obs = EnvList$syear_obs,
  eyear_obs = EnvList$eyear_obs,
  syear_his = EnvList$syear_his,
  eyear_his = EnvList$eyear_his,
  syear_scn = EnvList$syear_scn,
  eyear_scn = EnvList$eyear_scn,
  OWrite = EnvList$OWrite,
  SRadiation = EnvList$SRadiation)
```
or just
```
do.call(DailyQMapAll, EnvList)
```
This is the last step apply quantile mapping over the downscaled data. The results are in `D:/rSQMsample/prj/Downscale/SQM/"Model Name"`. Specifically, assumed that we went through abovr steps with station `ID108`, model `CanESM2`, and rcp scenario `rcp45`. Then 4 result generated.
```
ID108_SQM_CanESM2_historical.csv
ID108_SQM_CanESM2_historical_original.csv
ID108_SQM_CanESM2_rcp45.csv
ID108_SQM_CanESM2_rcp45_original.csv
```
"original" implies that "before quantile-mapping". "historical" files are retult over historical period, and "rcp45" files are over future period.

********
### Appendix : Available meteorological variables based on GCMs and RCP scenarios in ADSS.

<table>
<thead> 
<tr>
<th rowspan=2>No</th> 
<th rowspan=2>GCMs</th> 
<th colspan=6>Historical</th> 
<th colspan=6>RCP4.5</th> 
<th colspan=6>RCP8.5</th> 
</tr>
<tr>
<th>PR</th><th>TX</th><th>TN</th><th>WD</th><th>SR</th><th>RH</th><th>PR</th><th>TX</th><th>TN</th><th>WD</th><th>SR</th><th>RH</th><th>PR</th><th>TX</th><th>TN</th><th>WD</th><th>SR</th><th>RH</th> 
</tr>
</thead> 
<tbody>	

<tr> 
<td>1</td> 
<th scope=row>bcc-csm1-1-m</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>2</td> 
<th scope=row>bcc-csm1-1</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>3</td> 
<th scope=row>CanESM2</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>4</td> 
<th scope=row>CCSM4</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>5</td> 
<th scope=row>CESM1-BGC</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>6</td> 
<th scope=row>CESM1-CAM5</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>7</td> 
<th scope=row>CMCC-CM</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>8</td> 
<th scope=row>CMCC-CMS</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>9</td> 
<th scope=row>CNRM-CM5</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>10</td> 
<th scope=row>CSIRO-Mk3-6-0</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>11</td> 
<th scope=row>FGOALS-g2</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>12</td> 
<th scope=row>FGOALS-s2</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>13</td> 
<th scope=row>GFDL-CM3</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>14</td> 
<th scope=row>GFDL-ESM2G</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>15</td> 
<th scope=row>GFDL-ESM2M</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>16</td> 
<th scope=row>HadGEM2-AO</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>17</td> 
<th scope=row>HadGEM2-CC</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>18</td> 
<th scope=row>HadGEM2-ES</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>19</td> 
<th scope=row>inmcm4</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>20</td> 
<th scope=row>IPSL-CM5A-LR</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr> 

<tr> 
<td>21</td> 
<th scope=row>IPSL-CM5A-MR</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>22</td> 
<th scope=row>IPSL-CM5B-LR</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>23</td> 
<th scope=row>MIROC-ESM-CHEM</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr>

<tr> 
<td>24</td> 
<th scope=row>MIROC-ESM</th> 
<td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td><td>O</td>
</tr>

<tr> 
<td>25</td> 
<th scope=row>MIROC5</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr>

<tr> 
<td>26</td> 
<th scope=row>MPI-ESM-LR</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr>

<tr> 
<td>27</td> 
<th scope=row>MPI-ESM-MR</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>28</td> 
<th scope=row>MRI-CGCM3</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 

<tr> 
<td>29</td> 
<th scope=row>NorESM1-M</th> 
<td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td><td>O</td><td>O</td><td>O</td><td>X</td><td>X</td><td>X</td>
</tr> 



</tbody>
</table>


### Additional Remarks

1. A process over this package needs to connect to web server to download required data. This means that unstable internet connectivity fails works.
2. If you have any problem, contact climate.service@apcc21.org


Hope this package would be useful. :)
