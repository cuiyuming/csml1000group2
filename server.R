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
    
    show(minPrice)
    show(maxPrice)
    show(minRooms)
    show(maxRooms)
    show(minYear)
    show(maxYear)
    show(minDistance)
    show(maxDistance)
    
    filteredData <- allhouses %>% 
      filter(Rooms >= minRooms,
             Rooms <= maxRooms,
             YearBuilt >= minYear,
             YearBuilt <= maxYear,
             Distance >= minDistance,
             Distance <= maxDistance,
             Price >= minPrice,
             Price <= maxPrice)
     
    if(nrow(filteredData) == 0){
      leafletProxy("map", data = NULL) %>%
        clearShapes()
      
      output$scatterDistancePrice <- renderPlot({
        return(NULL)
      })
    
    }else{
      
      
      colorData <- filteredData[["Price"]]
      
      pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
      
      geoData <- filteredData %>% 
        dplyr::select(
          address = Address,
          price = Price,
          rooms = Rooms,
          longitude = Longtitude,
          latitude = Lattitude
        )
      
  
      if (nrow(geoData) > 0){
        maxPrice <- max(geoData[["price"]]) 
        radius <- geoData[["price"]] / maxPrice * 500
        
        leafletProxy("map", data = geoData) %>%
          clearShapes() %>%
          addCircles(radius=radius, 
                     stroke=FALSE, fillOpacity=0.6, layerId = ~address, fillColor=pal(colorData)) %>%
          
          addLegend("bottomleft", pal=pal, values=colorData, title="Price Range",
                    layerId="colorLegend")
      }
      
      output$scatterDistancePrice <- renderPlot({
        # If no houses are in view, don't plot
        if (nrow(filteredData) == 0)
          return(NULL)
        print(xyplot(Price ~ Distance, data = filteredData, xlim = range(allhouses$Distance), ylim = range(allhouses$Price)))
      })
      
    }
    
  })
  
  # Show a popup at the given location
  showPopup <- function(address, lat, lng) {
    selectedHouse <- allhouses[allhouses$Address == address,]
    content <- as.character(tagList(
      tags$h4("Price:", dollar(selectedHouse$Price)), tags$br(),
      sprintf("Address: %s, %s", selectedHouse$Address, selectedHouse$Suburb), tags$br(),
      sprintf("Distance: %s KM to CBD", selectedHouse$Distance), tags$br(),
      sprintf("Rooms: %d", selectedHouse$Rooms), tags$br(),
      sprintf("Bathroom %d", selectedHouse$Bathroom), tags$br(),
      sprintf("Parking: %d", selectedHouse$Car), tags$br(),
      sprintf("Landsize: %d ㎡", selectedHouse$Landsize), tags$br(),
      sprintf("BuildingArea: %d ㎡", selectedHouse$BuildingArea), tags$br(),
      sprintf("Year Built: %d", selectedHouse$YearBuilt), tags$br()
     
    ))
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