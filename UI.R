library(leaflet)
library(shinyWidgets)

vars <- c(
  "1 room" = 1,
  "2 rooms" = 2,
  "3 rooms" = 3,
  "4 rooms" = 4,
  "5 rooms" = 5,
  "6 rooms" = 6,
  "7 rooms" = 7,
  "8 rooms" = 8,
  "9 rooms" = 9,
  "10+ rooms" = 10
)
navbarPage("Melbourne Housing", id="nav",
          
           tabPanel("Interactive map",
                    div(class="outer",
                          
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                  
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", 
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 350, height = "auto",
                                      
                                        h2("Filters"),
                                        noUiSliderInput(inputId = "price", label = "Price Range", format = wNumbFormat(decimals = 0,
                                                                                                              thousand = ",",
                                                                                                              prefix = ""), min = 185000, max = 2070000, step = 10000, value = c(185000, 2070000)),
                                  
                                        noUiSliderInput(inputId = "rooms", label = "Number of Rooms", format =wNumbFormat(decimals = 0,
                                                                                                                  thousand = ",",
                                                                                                                  prefix = ""), min = 1, max = 12, step = 1, value = c(2, 4)),
                                        
                                        noUiSliderInput(inputId = "year", label = "Build Year",  format = wNumbFormat(decimals = 0,
                                                                                                             thousand = "",
                                                                                                             prefix = ""), min = 1830, max = 2018, step = 1, value = c(1990, 2000)),
                                    
                                        noUiSliderInput(inputId = "distance", label = "Distance to CBD", format = wNumbFormat(decimals = 1,
                                                                                                                     thousand = ",",
                                                                                                                     prefix = ""), min = 0, max = 50, step = 0.5, value = c(0, 10))
                        ),
                        
                        
                        tags$div(id="cite",
                                 'Data compiled for ', tags$em('xxx'), ' by CSML1000 Group2'
                        )
                    )
           )
          
          
)