library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
  
      setView(lng = 144.962916, lat = -37.814190, zoom = 10)
  })
  
  hoursesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(allhouses[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(allhouses,
           Lattitude >= latRng[1] & Lattitude <= latRng[2] &
             Longtitude >= lngRng[1] & Longtitude <= lngRng[2])
  })
  
  observe({
    minPrice <- input$price[1]
    maxPrice <- input$price[2]
    
    minRooms <- input$rooms[1]
    maxRooms <- input$rooms[2]
    
    minYear <- input$year[1]
    maxYear <- input$year[2]
    
    minDistance <- input$distance[1]
    maxDistance <- input$distance[2]
    
    filteredData <- allhouses %>% 
      filter(Rooms >= minRooms,
             Rooms <= maxRooms,
             YearBuilt >= minYear,
             YearBuilt <= maxYear,
             Distance >= minDistance,
             Distance <= maxDistance,
             Price >= minPrice,
             Price <= maxPrice)
    
    colorData <- filteredData[["Price"]]
    
    pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
    
    geoData <- filteredData %>% 
      select(
        address = Address,
        price = Price,
        rooms = Rooms,
        longitude = Longtitude,
        latitude = Lattitude
      )

    maxPrice <- max(geoData[["price"]]) 
    radius <- geoData[["price"]] / maxPrice * 500
    
    leafletProxy("map", data = geoData) %>%
      clearShapes() %>%
      addCircles(radius=radius, 
                 stroke=FALSE, fillOpacity=0.6, layerId = ~address, fillColor=pal(colorData)) %>%
      
      addLegend("bottomleft", pal=pal, values=colorData, title="Price Range",
                layerId="colorLegend")
     
  })
  
  # Show a popup at the given location
  showPopup <- function(address, lat, lng) {
    selectedHouse <- allhouses[allhouses$Address == address,]
    content <- as.character(tagList(
      tags$h4("Price:", dollar(selectedHouse$Price),
      tags$br(),
      sprintf("Address: %s", selectedHouse$Address), tags$br()
    )))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = address)
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showPopup(event$id, event$lat, event$lng)
    })
  })
  
}