# By @Rafa-77

rm(list = ls())

# Lugar de trabajo
setwd("D:/alex_/Documents/UNAM/8vo Semestre/proba/Proyecto2") 

############################################################

# Librerias
library(ggplot2)
library(plotly)
library(quantmod)
library(lubridate)
library(dplyr)
library(readxl)
library(quantmod)

# Con getSymbols
ticker = "F"
inicio <- "2019-01-01"
fin <- "2022-01-01"
raw <- getSymbols(ticker, from = inicio, to = fin, 
                  src = "yahoo", auto.assign = FALSE)

data <- as.data.frame(raw)

df <- cbind(Date = rownames(data), data)
rownames(df) <- 1:nrow(df)


df$Date <- as.Date(df$Date)

df$Day <- as.Date(cut(df$Date, "day"))
df$Week <- as.Date(cut(df$Date, "week"))
df$Month <- as.Date(cut(df$Date, "month"))


remove <- paste(ticker, ".", sep ="")

colnames(df) <- gsub(remove,"",as.character(colnames(df)))

df_Day <- df %>%
  group_by(Day) %>%
  summarize(Day = max(Day), across(Open:Adjusted, mean))

colnames(df_Day)[which(names(df_Day) == "Day")] <- "Date"


df_Week <- df %>%
  group_by(Week) %>%
  summarize(Week = max(Week), across(Open:Adjusted, mean))

colnames(df_Week)[which(names(df_Week) == "Week")] <- "Date"


df_Month <- df %>%
  group_by(Month) %>% 
  summarize(Month = max(Month), across(Open:Adjusted, mean))

colnames(df_Month)[which(names(df_Month) == "Month")] <- "Date"


################################################################


df_using <- as.data.frame(df_Week)

# Columna de colores: para la gráfica de volumen
for (i in 1:length(df_using[,1])) {
  if (df_using$Close[i] >= df_using$Open[i]) {
    df_using$direction[i] = 'Increasing'
  } else {
    df_using$direction[i] = 'Decreasing'
  }
}


# Simple Moving Average
SMAn = 5
SMAover = "Close"
df_using$SMA <- TTR::SMA(df_using[SMAover], n = SMAn)

# EXponential Moving Average
EMAn = 5
EMAover = "Close"
df_using$EMA <- TTR::EMA(df_using[EMAover], n = EMAn)

# Bandas de Bolinger 
BBn = 20
BBsd = 2
BB <- TTR::BBands(df_using[,c("High","Low","Close")], n = BBn, sd = BBsd)
BB <- as.data.frame(BB)
BBnames <- c("BBdn", "BBmavg", "BBup", "BBpctB")
colnames(BB) <- BBnames
df_using <- subset(cbind(df_using, BB))


# Momentum 
Mn = 5
Mover = "Close"
df_using$Mom <- TTR::momentum(df_using[Mover], n = Mn)

# Price Rate of Change
ROCn = 5
ROCover = "Close"
df_using$ROC <- TTR::ROC(df_using[ROCover], n = ROCn)

# MACD
MACDover = "Close"
MACDnfast = 12
MACDnslow = 26
MACDnsig = 9
MACDmatype = "SMA"
MACD <- TTR::MACD(df_using[MACDover],nFast = MACDnfast, 
                     nSlow = MACDnslow,nSig = MACDnsig, 
                     maType = MACDmatype)

MACD <- as.data.frame(MACD)
MACDnames <- c("MACDmacd", "MACDsignal")
colnames(MACD) <- MACDnames
df_using <- subset(cbind(df_using, MACD))



# RSI
RSIn = 5
RSIover = "Close"
df_using$RSI <- TTR::RSI(df_using[RSIover], n = RSIn)


################################################################
# Graficas

attach(df_using)


# Original
fig1 <- df_using %>% 
  plot_ly(x = Date, 
          type="candlestick",
          open = Open, 
          close = Close,
          high = High, 
          low = Low, 
          showlegend = FALSE) 



# Volumen
fig2 <- df_using %>% 
  plot_ly(x = Date, 
          y = Volume, 
          type = 'bar', 
          name = "Volume",
          color = direction, 
          colors = c('deepskyblue','darksalmon'),
          showlegend = FALSE)  %>% 
  layout(yaxis = list(title = "Volume"))



# Simple Moving Average
# Agregar cuanto en numero y en texto
# Agregar seleccion de color
fig1 <- fig1 %>% 
  add_lines(x = Date, 
          y = SMA, 
          name = "Simple Moving Average",
          line = list(color = 'deeppink', width = 1),
          inherit = F)


# EXponential Moving Average
fig1 <- fig1 %>% 
  add_lines(x = Date, 
            y = EMA, 
            name = "Exponential Moving Average",
            line = list(color = 'green', width = 1),
            inherit = F)

# Bandas de Bolinger 
fig1 <- fig1 %>% 
  add_lines(x = Date, 
            y = BBup, 
            name = "Upper B Band",
            line = list(color = 'Blue', width = 1.3),
            inherit = F) %>% 
  add_lines(x = Date, 
            y = BBdn, 
            name = "Lower B Band",
            line = list(color = 'Blue', width = 1.3),
            inherit = F) %>% 
  add_lines(x = Date, 
            y = BBmavg, 
            name = "Moving Average",
            line = list(color = 'deeppink', width = 1),
            inherit = F) 
  # polygon(c(df_using$Date, rev(df_using$Date)), c(BBup, rev(BBdn)), col = "red")

  

# Momentum 
# fig1 <- fig1 %>% 
#  add_lines(x = Date, 
#            y = Mom, 
#            name = "Momentum",
#            line = list(color = 'orange', width = 1),
#            inherit = F)

fig3 <- df_using %>% 
  plot_ly(x = Date, 
          y = Mom, 
          type = "scatter",
          mode ="lines",
          name = "Momentum",
          color = "orange", 
          colors = "Set2",
          showlegend = FALSE)  %>% 
  layout(yaxis = list(title = "Momentum"))



# Price Rate of Change
#fig1 <- fig1 %>% 
#  add_lines(x = Date, 
#            y = ROC, 
#            name = "Rate of Change",
#            line = list(color = 'deepskyblue', width = 1),
#            inherit = F)

fig4 <- df_using %>% 
  plot_ly(x = Date, 
          y = ROC, 
          type = "scatter",
          mode ="lines",
          name = "ROC",
          # color = "orange", 
          colors = "Set2",
          showlegend = FALSE)  %>% 
  layout(yaxis = list(title = "ROC"))


# MACD
#fig1 <- fig1 %>% 
#  add_lines(x = Date, 
#            y = MACDmacd, 
#            name = "MACD",
#            line = list(color = 'Blue', width = 1.3),
#            inherit = F) %>% 
#  add_lines(x = Date, 
#            y = MACDsignal, 
#            name = "Signal",
#            line = list(color = 'Red', width = 1.3),
#            inherit = F)


fig5 <- df_using %>% 
  plot_ly(x = Date, 
          y = MACDmacd, 
          type = "scatter",
          mode ="lines",
          name = "MACD",
          # color = "orange", 
          colors = "Set2",
          showlegend = T)  %>% 
  add_lines(x = Date, 
            y = MACDsignal, 
            name = "Signal",
            line = list(color = 'Red', width = 1.3),
            inherit = F)  %>% 
  layout(yaxis = list(title = "MACD"))


# RSI
#fig1 <- fig1 %>% 
#  add_lines(x = Date, 
#            y = RSI, 
#            name = "Relative Strength Index",
#            line = list(color = 'Brown', width = 1),
#            inherit = F)

fig6 <- df_using %>% 
  plot_ly(x = Date, 
          y = RSI, 
          type = "scatter",
          mode ="lines",
          name = "RSI",
          # color = "orange", 
          colors = "Set2",
          showlegend = FALSE)  %>% 
  layout(yaxis = list(title = "RSI"))

detach(df_using)


# Layout
fig1 <- fig1 %>% 
  layout(title = "Candlestick Chart",
       yaxis = list(title = "Price"),
       xaxis = list(rangeslider = list(visible = F))) 

#################################
fig1 <- subplot(fig1, fig3, 
                heights = c(0.7,0.2), 
                nrows = 2,
                shareX = TRUE, 
                titleY = TRUE)
#################################

fig1 <- df_tail %>% 
  plot_ly(x = Date, 
          type="candlestick",
          open = Open, 
          close = Close,
          high = High, 
          low = Low, 
          showlegend = FALSE) %>% 
  add_lines(x = Date, 
            y = up, 
            name = "Upper B Band",
            line = list(color = 'Blue', width = 1.3),
            inherit = F) %>% 
  add_lines(x = Date, 
            y = dn, 
            name = "Lower B Band",
            line = list(color = 'Orange', width = 1.3),
            inherit = F) %>% 
  add_lines(x = Date, 
            y = mavg, 
            name = "Moving Average",
            line = list(color = 'deeppink', width = 1),
            inherit = F) %>% 
  add_lines(x = Date, 
            y = Open, 
            name = "Opening Trace",
            line = list(color = 'black', width = 0.4), 
            inherit = F) %>% 
  layout(title = "Candlestick Chart",
         yaxis = list(title = "Price"),
         xaxis = list(rangeslider = list(visible = F))) 
