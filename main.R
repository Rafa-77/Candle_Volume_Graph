rm(list = ls())

# Lugar de trabajo
setwd("D:/alex_/Documents/UNAM/8vo Semestre/proba/Proyecto") 

############################################################

# Librerias
library(ggplot2)
library(plotly)
library(quantmod)
library(readxl)

# Base de datos
excel <- read.csv("TTEK.csv")

# Convertirla a DF
df <- data.frame(excel)

# Columna de colores: para la gráfica de volumen
for (i in 1:length(df[,1])) {
  if (df$Close[i] >= df$Open[i]) {
    df$direction[i] = 'Increasing'
  } else {
    df$direction[i] = 'Decreasing'
  }
}

# Bandas de Bolinger para la gráfica de velas
bbands <- BBands(df[,c("High","Low","Close")])
# Unir base de datos con los datos de Bolinger
df_bb <- subset(cbind(df, data.frame(bbands[,1:3])))

# Reducir el tamaño del DataFrame 
# NOTA: dado que son datos diarios, al abarcar mayor tiempo, la gráfica pierde estetica
# por ello un tiempo que mantenga lapsos diarios como principal fuente hace que la
# gráfica sea una buena representacion.
df_tail <- tail(df_bb, 30)


############################################################
# Gráficas

attach(df_tail)

# Grafica de Velas, con 4 lineas auxiliares: 2 de Bolinger, 1 de Medias Moviles y
# 1 que rastrea el precio de entrada.

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

fig1



# Grafica de Volumen

fig2 <- df_tail %>% 
  plot_ly(x = Date, 
          y = Volume, 
          type = 'bar', 
          name = "Volume",
          color = direction, 
          colors = c('deepskyblue','darksalmon'),
          showlegend = FALSE)  %>% 
  layout(yaxis = list(title = "Volume"))

fig2


# Grafica conjunta
fig3 <- subplot(fig1, fig2, 
                heights = c(0.7,0.2), 
                nrows = 2,
                shareX = TRUE, 
                titleY = TRUE)

fig3

detach(df_tail)
