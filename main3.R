# By @Rafa-77

# El presente trabajo esta compuesto por una aplicacion interactiva en Shiny
# Para ello se explicaran las partes que se llevaron a cabo:


# Cargar R packages
library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(quantmod)
library(lubridate)
library(dplyr)
library(readxl)
library(quantmod)


# La primera parte es la pagina principal
# En esta se establecen los inputs que el usuario pondra para la obtencion 
# de informacion que se utilizara posteiormente.
# Los inputs consisten en fechas y un "ticker" que es el codigo de un
# isntrumento financiero.

main_page <- tabPanel(
  title = "Analysis",
  titlePanel("Analysis"),
  sidebarLayout(
    sidebarPanel(
      title = "Inputs",
      dateInput("Idate", "Initial Date:", value = "2019-01-01", format = "yyyy/mm/dd"),
      dateInput("Fdate", "Final Date:", value = "2022-01-01", format = "yyyy/mm/dd"),
      selectInput("time_factor", "Time Period", choices = c("Daily", "Weekly", "Monthly"), selected = "Daily"),
      textInput("ticker", "Ticker", value = "F"),
      textOutput("txtout"),
      br(),
      p("Press Button to Get the Data and Main Graph"),
      actionButton("GO","Run", icon = icon("play")),
      br(),
      br(),
      br(),
      p("Press Button to Accept the Data and View the Indicators"),
      actionButton("apply","Start Indicators", icon = icon("play")),
      br(),
      br(),
      br(),
      checkboxGroupInput("ingraphIndicators", "In-Graph Indicators", 
                         choices = c("Simple Moving Average",
                                     "Exponential Moving Average",
                                     "Bolinger Bands")),
      br()
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "Plot",
          plotlyOutput("plot_1")
        ),
        tabPanel(
          title = "Data",
          tableOutput("data")
        )
      )
    )
  )
)




# La segunda parte consiste en las funciones que se usaran mas adelante.
#####################
# Funciones

# Esta funcion crea un dataframe con la informacion obtenida de Yahoo Finance
# Adhiere datos correnpondientes a divisiones de semanas y meses
create_data <- function(raw, ticker){
  data <- as.data.frame(raw)
  df <- cbind(Date = rownames(data), data)
  rownames(df) <- 1:nrow(df)
  df$Date <- as.Date(df$Date)
  df$Day <- as.Date(cut(df$Date, "day"))
  df$Week <- as.Date(cut(df$Date, "week"))
  df$Month <- as.Date(cut(df$Date, "month"))
  remove <- paste(ticker, ".", sep ="")
  colnames(df) <- gsub(remove,"",as.character(colnames(df)))
  df
}

# Con los datos de semanas y meses anteiormente creados, ahora se procede a 
# agrupar el conteido del dataframe segun periodicidad.
create_period_data <- function(df, factor){
  if(factor == "Daily"){
    df_Day <- df %>%
      group_by(Day) %>%
      summarize(Day = max(Day), across(Open:Adjusted, mean))
    
    colnames(df_Day)[which(names(df_Day) == "Day")] <- "Date"
    df_using <- as.data.frame(df_Day)
    df_using
    
  } else if(factor == "Weekly"){
    df_Week <- df %>%
      group_by(Week) %>%
      summarize(Week = max(Week), across(Open:Adjusted, mean))
    
    colnames(df_Week)[which(names(df_Week) == "Week")] <- "Date"
    df_using <- as.data.frame(df_Week)
    df_using
    
  } else if(factor == "Monthly"){
    df_Month <- df %>%
      group_by(Month) %>% 
      summarize(Month = max(Month), across(Open:Adjusted, mean))
    
    colnames(df_Month)[which(names(df_Month) == "Month")] <- "Date"
    df_using <- as.data.frame(df_Month)
    df_using
    
  }
} 


# Esta funcion es para generar un grafico de velas
draw_plot_original <- function(data){
  fig1 <- data %>% 
    plot_ly(x = data$Date, 
            type="candlestick",
            open = data$Open, 
            close = data$Close,
            high = data$High, 
            low = data$Low, 
            showlegend = FALSE) 
  fig1
}

# esta funcion sirve para generar un dataframe que ocntenda las series de 
# datos con la informacion de inidcadores financieros. 
indicators_data <- function(original){
  # Simple Moving Average
  SMAn <- 5
  SMAover <- "Close"
  original$SMA <- TTR::SMA(original[SMAover], n = SMAn)
  
  
  # EXponential Moving Average
  EMAn = 5
  EMAover = "Close"
  original$EMA <- TTR::EMA(original[EMAover], n = EMAn)
  
  # Bandas de Bolinger 
  BBn = 20
  BBsd = 2
  BB <- TTR::BBands(original[,c("High","Low","Close")], n = BBn, sd = BBsd)
  BB <- as.data.frame(BB)
  BBnames <- c("BBdn", "BBmavg", "BBup", "BBpctB")
  colnames(BB) <- BBnames
  original <- subset(cbind(original, BB))
  
  original
}



# esta funcion ayuda con los inputs del CheckBox 
# regresa un valor segun la combinacion escogida
comb_ingraph <- function(ingraphinput){
  if (is.null(ingraphinput)){return(10)}
  
  SMA <- "Simple Moving Average"   %in% ingraphinput
  EMA <- "Exponential Moving Average"     %in% ingraphinput
  BBs <- "Bolinger Bands"  %in% ingraphinput
  
  if (SMA & EMA & BBs){
    s <- 7 
  } else if (SMA & BBs){
    s <- 6
  }else if (EMA & BBs){
    s <- 5
  }else if (SMA & EMA){
    s <- 4
  } else if (SMA){
    s <-1
  } else if (EMA){
    s <-2
  } else if (BBs) {
    s <- 3
  }  
  
  return(as.numeric(s)) 
}


# Estas son funciones para añadir los indicadores al grafico principal
draw_plot_SMA <- function(plot, data){
  fig1 <- plot %>% 
    add_lines(x = data$Date, 
              y = data$SMA, 
              name = "Simple Moving Average",
              line = list(color = 'deeppink', width = 1),
              inherit = F)
  fig1
}

draw_plot_EMA <- function(plot, data){
  fig1 <- plot %>% 
    add_lines(x = data$Date, 
              y = data$EMA, 
              name = "Exponential Moving Average",
              line = list(color = 'green', width = 1),
              inherit = F)
  fig1
}

draw_plot_BBS <- function(plot, data){
  fig1 <- plot %>% 
    add_lines(x = data$Date, 
              y = data$BBup, 
              name = "Upper B Band",
              line = list(color = 'Blue', width = 1.3),
              inherit = F) %>% 
    add_lines(x = data$Date, 
              y = data$BBdn, 
              name = "Lower B Band",
              line = list(color = 'Blue', width = 1.3),
              inherit = F) %>% 
    add_lines(x = data$Date, 
              y = data$BBmavg, 
              name = "Moving Average",
              line = list(color = 'deeppink', width = 1),
              inherit = F) 
  fig1
}



# esta funcion, toma el resultado de la funcion de combinaciones 
# y utiliza las graficas necesarias, segun el input escogido
draw_plot_ingraph <- function(combination, data, plot){
  if (combination == 10){
    return(plot)
  } else if (combination == 7){
    return(draw_plot_SMA(draw_plot_EMA(draw_plot_BBS(plot, data), data), data))
  } else if (combination == 6){
    return(draw_plot_SMA(draw_plot_BBS(plot, data), data))
  }else if (combination == 5){
    return(draw_plot_EMA(draw_plot_BBS(plot, data), data))
  }else if (combination == 4){
    return(draw_plot_SMA(draw_plot_EMA(plot, data), data))
  } else if (combination == 1){
    return(draw_plot_SMA(plot, data))
  } else if (combination == 2){
    return(draw_plot_EMA(plot, data))
  } else if (combination == 3) {
    return(draw_plot_BBS(plot, data))
  } 
  
}



# El diseño general de la UI 
#############################
# UI
ui <- navbarPage(
  title = "Trabajo Final: Financial Data Analyzer",
  p("Alumno: Rafael Alejandro Martínez Vásquez"),
  main_page)



#############################
# Server

# En este apartado se utilizan las funciones previamente descritas 
# para desarrollar los outputs
server <- function(input, output){
  raw <- eventReactive(
    input$GO,
    {req(input$ticker)
      getSymbols(input$ticker, from = input$Idate, to = input$Fdate, 
                 src = "yahoo", auto.assign = FALSE)  
    })
  
  # Aqui se genra la informacion segun los inputs principales
  data <- eventReactive(
    input$GO,
    {req(input$ticker)
      create_data(raw(), input$ticker)
    })
  
  # Aqui se toma la informacion general y se obtiene segun la periodicidad escogida
  period_data <- eventReactive(
    input$GO,
    {req(input$time_factor)
      create_period_data(data(), input$time_factor)
    })
  
  output$data <- renderTable(period_data())
  
  # aqui se obtienen la informacion de los indicadores segun la informaicon anterior
  main_data <-  eventReactive(
    input$GO,
    {indicators_data(period_data())
    })
  
  
  # Plot principal
  plot_1 <- eventReactive(
    input$GO,{
      draw_plot_original(period_data())
    })
  # Display principal
  observeEvent(
    input$GO,{
      output$plot_1 <- renderPlotly(draw_plot_original(period_data()))
    }
  )
  
  # Aqui se obtienen las conbinaciones del Chechbox
  combination_ingraph <- renderText(
    {comb_ingraph(input$ingraphIndicators)
    })
  
  # Aqui se aplican los indicadores al grafico general.
  observeEvent(
    input$apply,{
      output$plot_1 <- renderPlotly(
        draw_plot_ingraph(combination_ingraph(), main_data(), plot_1())%>% 
          layout(title = "Candlestick Chart",
                 yaxis = list(title = "Price"),
                 xaxis = list(rangeslider = list(visible = F))) 
      )
    }
  )
  
}


#############################
# App
# La ultima seccion es para general la app
shinyApp(ui = ui, server = server)
