#' Download CEDEN data via an API
#'
#' This function provides an interface with CEDEN web services to perform queries and programatically download data.
#' 
#' @param service The CEDEN web service. For each category of monitoring data (Benthic, Habitat, Tissue, Toxicity, WaterQuality"), there are three types of data available (MonitoringStationsList, ParameterCountsList, ResultsList)
#' @param query_parameters The query string
#' @param base_URI The base URL. Defaults to: https://testcedenwebservices.waterboards.ca.gov:9267
#' @param userName User Name for CEDEN web services
#' @param password Password for CEDEN web services
#' 
#' @return This function returns a data frame with the data specified in the service and query_parameters arguments
#' 
#' @keywords CEDEN California API
#' @examples 
#' ceden_query(service = 'cedenwaterqualitymonitoringstationslist', query_parameters = '"filter":[{"sampleDateMin":"1/1/2015","sampleDateMax":"4/1/2015"}],"top":1000')
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