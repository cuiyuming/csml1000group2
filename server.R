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
    rooms <- input$rooms
    
    #show(rooms)
    
    if(rooms < 10){
      filteredData <- allhouses[allhouses$Rooms == rooms,]
    }else{
      filteredData <- allhouses[allhouses$Rooms >= rooms,]
    }
    colorData <- filteredData[["Price"]]
    pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
    
    #show(pal)
    
    geoData <- filteredData %>% 
      select(
        Suburb = Suburb,
        Address = Address,
        Price = Price,
        Rooms = Rooms,
        longitude = Longtitude,
        latitude = Lattitude
      )
    #show(geoData)
    maxPrice <- max(geoData[["Price"]]) 
    radius <- geoData[["Price"]] / maxPrice * 500
    
    show(radius)
    leafletProxy("map", data = geoData) %>%
      clearShapes() %>%
      addCircles(radius=radius, 
                 stroke=FALSE, fillOpacity=0.6, fillColor=pal(colorData)) %>%
      
      addLegend("bottomleft", pal=pal, values=colorData, title=rooms,
                layerId="colorLegend")
     
  })
  
}