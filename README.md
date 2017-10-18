## Overview
This package defines an R function called `ceden_query()` which helps in working with web services that interface with the CEDEN (California Environmental Data Exchange Network) database. It handles user authentication, retrieves data specified by the query parameters, and returns the data formatted in an R data frame (which can be used for analysis within R, or written to an external file, such as a .csv file).

## Instructions
This section describes how to install the function, and how to use the function to construct a query of the CEDEN database.

### Installation
To install the function, run the following lines of code:
``` 
install.packages('devtools')
library(devtools)
install_github('daltare/cedenTools')
library(cedenTools)
```

Alternatively, you can save the *ceden_query.R* file (in the *R* folder) to your computer, then run the following code (NOTE: this assumes the file is saved in your home directory; to save the file in a different location, replace `~` with the path to the location where you saved the file):

```
source('~/ceden_query.R')
```

### Function Parameters
There are five possible arguments to the `ceden_query()` function, including:
* `service` (required): A text string representing one of the 15 CEDEN advanced query tool services. The string is composed of the three following components:
    *  "CEDEN"
    * One of the following: "Benthic", "Habitat", "Tissue", "Toxicity", "WaterQuality"
    * One of the following: "MonitoringStationsList", "ParameterCountsList", "ResultsList" <br>

For example: *CEDENBenthicMonitoringStationsList*. For more information about the available services, see the documentation for the CEDEN web services.

* `query_parameters` (required): The query string (in plain text). This includes everything after the `?queryParams={` statement, except the closing `}` of the query string. For information on how to construct a query string, see the documentation for the CEDEN web services.
* `base_URI` (required): The base part of the URL for all CEDEN web services (e.g.,"https://cedenwebservices.waterboards.ca.gov"), including a port number if required (use ":9267" if on the State Water Board network).
* `userName` (optional): The user name for your CEDEN web services account. You can enter this through the function, or if you leave this argument blank the function will look for this information in a variable called `ceden_userName` within the environment variables defined for your account.
* `password` (optional): The password for your CEDEN web services account. You can enter this through the function, or if you leave this argument blank the function will look for this information in a variable called `ceden_password` within the environment variables defined for your account.

## Example Function Call
This is an example of a CEDEN web services query using this function within R:

```
 data.download <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"county":"Sacramento","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"},{"county":"San Joaquin","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"}]')
```

The above statement will return all of the records of E. coli monitoring in Sacramento and San Joaquin counties from 6/1/2014 through 7/1/2014. To be more precise, it returns all records from the *cedenwaterqualityresultslist* service where:
* *county* is *Sacramento* AND *parameter* is *E. coli.* AND *sampleDate* is greater than or equal to *6/1/2014* AND *sampleDate* is less than or equal to *7/1/2014*
     
     OR
* *county* is *San Joaquin* AND *parameter* is *E. coli.* AND *sampleDate* is greater than or equal to *6/1/2014* AND *sampleDate* is less than or equal to *7/1/2014*

The results will be returned to an R data frame in the variable called `data.download`. To write this data to a text document called `Output.csv` in your home directory, use the R code below (you can change the location of the file by replacing the `~` with a new path, and you can change the filename by changing `Output.csv` to a different name):

```
write.csv(data.download, file = '~/Output.csv', row.names = FALSE)
```

## Example Application
An example of an application that uses this function to access and visualize data is available at: https://daltare.shinyapps.io/ceden_web_services_test/

## More Example Function Calls
Here are some additional examples of calls to the `ceden_query()` function:

```
# Examples ----
test1 <- ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{"sampleDateMin":"1/1/2015","sampleDateMax":"4/1/2015"}],"top":200')
test2 <- ceden_query(service = 'cedenwaterqualityparametercountslist', query_parameters = '"filter":[{"stationCode":"204ALP100"}],"top":100')
test3 <- ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{}]')
test4 <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"stationCode":"204ALP100"}],"top":100')
test5 <- ceden_query(service = 'cedentoxicitymonitoringstationslist', query_parameters = '"filter":[{"county":"San Joaquin"}]')
test6 <- ceden_query(service = 'cedentoxicityparametercountslist', query_parameters = '"filter":[{"stationCode":"531SJC503"}]')
test7 <- ceden_query(service = 'cedentoxicityresultslist', query_parameters = '"filter":[{"stationCode":"531SJC503"}]')
```