library(leaflet)

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
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h2("Select Number of Rooms"),
                                      
                                      selectInput("rooms", "rooms", vars)
                
                        ),
                        tags$div(id="cite",
                                 'Data compiled for ', tags$em('xxx'), ' by CSML1000 Group2'
                        )
                    )
           )
          
          
)