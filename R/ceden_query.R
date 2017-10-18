#' Download CEDEN data via an API
#'
#' This function provides an interface with CEDEN web services to perform queries and programatically download data.
#'
#' @param service A text string representing one of the 15 CEDEN advanced query tool services.
#' For each of the 5 categories of monitoring data (Benthic, Habitat, Tissue, Toxicity, WaterQuality),
#' there are 3 types of data available (MonitoringStationsList, ParameterCountsList, ResultsList). For example:
#' CEDENBenthicMonitoringStationsList
#' @param query_parameters The query string (in plain text). This includes everything after the
#' \code{?queryParams=\{} statement, except the closing \code{\}} of the query string. For information on how
#' to construct a query string, see the documentation for the CEDEN web services.
#' @param base_URI The base part of the URL for all CEDEN web services
#' (e.g.,https://cedenwebservices.waterboards.ca.gov), including a port number if required
#' (use ":9267" if on the State Water Board network). Defaults to:
#' https://testcedenwebservices.waterboards.ca.gov:9267
#' @param userName The user name for your CEDEN web services account. You can enter this through
#' the function, or if you leave this argument blank the function will look for this information
#' in a variable called `ceden_userName` within the environment variables defined for your account.
#' @param password The password for your CEDEN web services account. You can enter this through
#' the function, or if you leave this argument blank the function will look for this information
#' in a variable called `ceden_password` within the environment variables defined for your account.
#'
#' @return This function returns a data frame with the data specified in the \code{service} and \code{query_parameters} arguments.
#'
#' @keywords CEDEN California API
#'
#' @examples
#' All of these examples return the data to a data frame called: data.download
#'
#' # This is the example provided in the CEDEN web services documentation
#' data.download <- ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{"sampleDateMin":"1/1/2015","sampleDateMax":"4/1/2015"}],"top":1000')
#'
#' # Get all of the records of E. coli monitoring in Sacramento and San Joaquin counties from 6/1/2014 through 7/1/2014
#' data.download <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"county":"Sacramento","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"},{"county":"San Joaquin","parameter":"E. coli","sampleDateMin":"6/1/2014","sampleDateMax":"7/1/2014"}]')
#'
#' # Get all water quality results in Sacramento from the year 2014 where the parameter name contains the name Nitrogen (note use of the wildcard /%)
#' data.download <- ceden_query(service = 'cedenwaterqualityresultslist', query_parameters = '"filter":[{"county":"Sacramento","parameter":"/%Nitrogen/%","sampleDateMin":"1/1/2014","sampleDateMax":"12/31/2014"}]', userName = 'user', password = 'password', base_URI = 'https://testcedenwebservices.waterboards.ca.gov')
#'
#' @export
ceden_query <- function(service, query_parameters, base_URI = 'https://testcedenwebservices.waterboards.ca.gov:9267', userName = '', password = '') {

    # Load packages
        function_packages <- c('httr', 'jsonlite', 'dplyr', 'urltools', 'tidyverse')
        check_packages <- function_packages %in% installed.packages()
        for (i in function_packages[check_packages]) {
            library(i, character.only = TRUE)
        }
        for (i in function_packages[!check_packages]) {
            install.packages(i, dependencies = TRUE)
            library(i, character.only = TRUE)
        }

    # Check to see if the user has entered a username and password with the function. If not, get it from the user's environment variables.
        if (userName == '') {
            userName <- Sys.getenv('ceden_userName')
        }
        if (password == '') {
            password <- Sys.getenv('ceden_password')
        }

    # Authorization (send a POST request with the username and password)
        auth_Request <- paste0(base_URI, '/Auth/?provider=credentials&userName=', userName, '&password=', password) # build the string for the request
        auth_Response <- POST(auth_Request) # send the request
        if(auth_Response$status_code != 200) { # Make sure the authentication was successful. If not, stop the function, and report the HTTP errror code to the user.
            stop(paste0('Authentication not successful. HTTP error code: ', auth_Response$status_code))
        }

    # Query (send a GET request with the relevant parameters)
        query_formatted <- url_encode(paste0('{', query_parameters, '}')) # encode the query parameters into a format suitable for HTTP
        query_URI <- paste0(base_URI,'/', service, '/?queryParams=', query_formatted) # build the string for the request
        query_Response <- GET(query_URI) # send the request
        if(query_Response$status_code != 200) { # Make sure the query was successful. If not, stop the function, and return the HTTP error code to the user.
            stop(paste0('query not successful. HTTP error code: ', query_Response$status_code))
        }

    # Convert the results of the request from JSON into a readable format, and format it to an R dataframe
        query_Char <- rawToChar(query_Response$content)
        query_Content <- fromJSON(query_Char)
        query_Results <- query_Content$queryResults
        if (identical(query_Results, list())) { # check to see whether the query returned any data
            query_Results <- 'No Data'
        } else {
            query_Results <- query_Results %>% select(-metadata) # Drop the metadata columns that are included in the data
        }
        return(query_Results) # output the resulting dataframe
}
