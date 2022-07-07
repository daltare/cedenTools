## \*\*\*\* NOTE: THIS PACKAGE IS NO LONGER FUNCTIONAL \*\*\*\*

**This package is no longer being actively maintained, and the CEDEN web services which it relies on are no longer available, so it's no longer functional. It is made available here for reference only.**

**However, the CEDEN data is now available to access via an API or bulk download from the California Open Data Portal, at the following pages:**

-   [**Chemistry**](https://data.ca.gov/dataset/surface-water-chemistry-results)
-   [**Habitat**](https://data.ca.gov/dataset/surface-water-habitat-results)
-   [**Tissue**](https://data.ca.gov/dataset/surface-water-aquatic-organism-tissue-sample-results)
-   [**Toxicity**](https://data.ca.gov/dataset/surface-water-toxicity-results)
-   [**Benthic**](https://data.ca.gov/dataset/surface-water-benthic-macroinvertebrate-results)
-   [**Sampling Locations**](https://data.ca.gov/dataset/surface-water-sampling-location-information)

**An example of how to use the CA Open Data Portal's API to access the resources listed above is available [here](https://gist.github.com/daltare/2de1517ad1e315c4b1cad01278de96dd). You can also find an example of how to download filtered (or complete) csv files using persistent links for the above resources [here](https://gist.github.com/daltare/a934669c8933c3ebd955f18dfb198456).**

------------------------------------------------------------------------

## Package Overview

This package defines an R function called `ceden_query()` which helps in working with web services that interface with the [CEDEN (California Environmental Data Exchange Network) database](http://www.ceden.org/). It handles user authentication, retrieves data specified by the query parameters, and returns the data formatted in an R data frame (which can be used for analysis within R, or written to an external file, such as a .csv file).

A second function, `ceden_query_csv()` is also available and is virtually identical to the `ceden_query()` function, but can handle large requests than `ceden_query()`. `ceden_query_csv()` requests data from the API in csv format instead of JSON. As a result, there could possibly be some slight differences in the format of the data returned by the two functions. The installation and usage instructions are the same for the two functions.

## Instructions

This section describes how to install the package, and how to use it to construct a query of the CEDEN database via the CEDEN web services.

### Installation

To install and load the package, run the following lines of code:

    install.packages('devtools')
    devtools::install_github('daltare/cedenTools')
    library(cedenTools)

Alternatively, you can save the *ceden_query.R* file (in the *R* folder) to your computer, then run the following code (NOTE: this assumes the file is saved in your home directory; to save the file in a different location, replace `~` with the path to the location where you saved the file):

    source('~/ceden_query.R')

### Function Parameters

There are six possible arguments to the `ceden_query()` function, including: \* `service` (required): A text string representing one of the 15 CEDEN advanced query tool services. The string is composed of the three following components: \* "CEDEN" \* One of the following: "Benthic", "Habitat", "Tissue", "Toxicity", "WaterQuality" \* One of the following: "MonitoringStationsList", "ParameterCountsList", "ResultsList" <br>

    For example: *CEDENBenthicMonitoringStationsList*. For more information about the available services, see the [CEDEN web services documentation](/CEDEN%20Web%20Services%20-%20External%20Web%20Services%20Users%20Guide%20-%200.4.docx).

-   `query_parameters` (required): The query string (in plain text). This includes everything after the `?queryParams={` statement, except the closing `}` of the query string. Can consist of `filter` (including Max, Min, Not, IsNull, IsNotNull), `orderBy`, `Top`, `Skip`, and/or `Distinct` statements. For information on how to construct a query string, see the [CEDEN web services documentation](/CEDEN%20Web%20Services%20-%20External%20Web%20Services%20Users%20Guide%20-%200.4.docx).
-   `base_URI` (required): The base part of the URL for all CEDEN web services (e.g., https<nolink>://cedenwebservices.waterboards.ca.gov), including a port number if required (use *:9267* if on the State Water Board network). Defaults to: https<nolink>://cedenwebservices.waterboards.ca.gov:9267
-   `userName` (optional): The user name for your CEDEN web services account (NOTE: if you don't already have an account, you can [send a message to David Altare](mailto:david.altare@waterboards.ca.gov) to request one). You can enter this through the function, or if you leave this argument blank the function will look for this information in a variable called `ceden_userName` within the environment variables defined for your account.
-   `password` (optional): The password for your CEDEN web services account (NOTE: if you don't already have an account, you can [send a message to David Altare](mailto:david.altare@waterboards.ca.gov) to request one). You can enter this through the function, or if you leave this argument blank the function will look for this information in a variable called `ceden_password` within the environment variables defined for your account.
-   `errorMessages_out` (optional): When set to `TRUE`, if there is an error with the authentication or the query request (inclduing when there is simply no data returned that meets the query parameters), the function will attempt to return a data frame with information about the error (including where the error occured, the HTTP code returned, and any messages about the API response). When set to `FALSE`, the function will simply return `NA` on an error. Defaults to `TRUE`.

### Errors

The function attempts to return an R data frame in all cases, even if the authentication or query is unsuccessful, or if no data is returned because no records satisfy the query parameters. If the function encounters an error which it recognizes, a dataframe will be returned with information about the error. This dataframe includes three columns, regardless of the error type: \* `Result`: The status of the authentication or query request where the problem was encountered (successful or unsuccessful). \* `HTTP.Code`: The HTTP status code returned by the request (e.g., `200`, `400`, `401`, `404`, etc.). In general, a `200` code indicates success, a `400` code indicates that there is a problem with the request, a `401` code indicates that authentication was unsuccessful, and a `404` code likely indicates a problem with the connection to the base URL. \* `API.Message`: Any additional messages about the response from the API, if available.

To disable this output and simply return an `NA` on an error, set the `errorMessages_out` parameter to `FALSE`.

## Example Function Call

This is an example of a CEDEN web services query using this function within R:

     data.download <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"county":"Sacramento","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"},{"county":"San Joaquin","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"}]')

The above statement will return all of the records of E. coli monitoring in Sacramento and San Joaquin counties from 6/1/2014 through 7/1/2014. To be more precise, it returns all records from the *cedenwaterqualityresultslist* service where: \* *county* is *Sacramento* AND *parameter* is *E. coli.* AND *sampleDate* is greater than or equal to *6/1/2014* AND *sampleDate* is less than or equal to *7/1/2014*

     OR

-   *county* is *San Joaquin* AND *parameter* is *E. coli.* AND *sampleDate* is greater than or equal to *6/1/2014* AND *sampleDate* is less than or equal to *7/1/2014*

The results will be returned to an R data frame in the variable called `data.download`. To write this data to a text document called `Output.csv` in your home directory, use the R code below (you can change the location of the file by replacing the `~` with a new path, and you can change the filename by changing `Output.csv` to a different name):

    write.csv(data.download, file = '~/Output.csv', row.names = FALSE)

## Example Application

An example of an application that uses this function to access and visualize data is available at: <https://daltare.shinyapps.io/ceden_web_services_test/>

## More Example Function Calls

Here are some additional examples of calls to the `ceden_query()` function:

    # Examples ----
    test1 <- ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{"sampleDateMin":"1/1/2015","sampleDateMax":"4/1/2015"}],"top":200')
    test2 <- ceden_query(service = 'cedenwaterqualityparametercountslist', query_parameters = '"filter":[{"stationCode":"204ALP100"}],"top":100')
    test3 <- ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{}]')
    test4 <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"stationCode":"204ALP100"}],"top":100')
    test5 <- ceden_query(service = 'cedentoxicitymonitoringstationslist', query_parameters = '"filter":[{"county":"San Joaquin"}]')
    test6 <- ceden_query(service = 'cedentoxicityparametercountslist', query_parameters = '"filter":[{"stationCode":"531SJC503"}]')
    test7 <- ceden_query(service = 'cedentoxicityresultslist', query_parameters = '"filter":[{"stationCode":"531SJC503"}]')

## Accessing CEDEN Web-Services Without Code

To access the CEDEN web services without use of a programming language such as R, one alternative option is to use a service such as the [Restlet Client for Chrome](https://chrome.google.com/webstore/detail/restlet-client-rest-api-t/aejoelaoggembcahagimdiliamlcdmfm?hl=en "Restlet Client"). To use the Restlet client with this web service, you first need to get authorization, by using the POST method and entering a URL such as the following (insert your own user name and password):

    https://cedenwebservices.waterboards.ca.gov:9267/Auth/?provider={"credentials"}&userName={"yourUserNameHere"}&password={"yourPasswordHere"}

In the *Response* section at the bottom of the page, you should see a message saying *200 OK* that is highlighted in green.

Then, you can execute a query with the following steps: \* Use the GET method \* Under the Headers section, add an `Accept` header, and enter a type of `text/csv` \* Enter a query URL, such as the example below:

    https://cedenwebservices.waterboards.ca.gov:9267/cedenwaterqualityresultslist/?queryParams={"filter":[{"county":"Sacramento","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"}]}

You should again see a message in the *Response* section at the bottom of the page saying *200 OK* highlighted in green. To output the data, you can click the *Download* button (towards the bottom right side of the page).
