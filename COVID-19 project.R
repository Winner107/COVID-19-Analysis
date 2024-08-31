library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)

# Download the data
covid_data_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
covid_data <- read.csv(covid_data_url)

# Preprocess the data
covid_data_long <- covid_data %>%
  pivot_longer(cols = starts_with("X"), names_to = "Date", values_to = "Cases") %>%
  mutate(Date = as.Date(sub("X", "", Date), format = "%m.%d.%y")) %>%
  group_by(Date) %>%
  summarise(Cases = sum(Cases))

# Print the first few rows of the dataset to check
head(covid_data_long)

ui <- fluidPage(
  titlePanel("COVID-19 Data Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("dateRange", "Select Date Range:",
                     start = min(covid_data_long$Date),
                     end = max(covid_data_long$Date)),
      actionButton("update", "Update Plot")
    ),
    mainPanel(
      plotOutput("covidPlot")
    )
  )
)

server <- function(input, output, session) {
  # Reactive expression to filter data based on date range
  filtered_data <- reactive({
    req(input$update)
    isolate({
      covid_data_long %>%
        filter(Date >= input$dateRange[1] & Date <= input$dateRange[2])
    })
  })
  
  # Generate plot based on filtered data
  output$covidPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = Date, y = Cases)) +
      geom_line(color = "steelblue") +
      labs(title = "COVID-19 Cases Over Time", x = "Date", y = "Number of Cases") +
      theme_minimal()
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
