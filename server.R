# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  raw <- read.csv('./data/raw/Melbourne_housing_FULL.csv',stringsAsFactors = F)
  
  # We only look at Method: S - property sold; SP - property sold prior
  clean <- subset(raw, (Method=="S" | Method=="SP") & (Price != "") )
  
  # use the remaining 80% of data to training and testing the models
  dataset <- clean
  
# read dataset
  output$distPlot <- renderPlot({
    
    x    <- dataset$Rooms
    
    inputNumber <- seq(min(x), max(x), length.out = input$numberOfRooms + 1)
    
    hist(x, breaks = inputNumber, col = "#75AADB", border = "white",
      
         xlab = "Number of rooms",
         main = "Histogram of room")
    
  })
  
}