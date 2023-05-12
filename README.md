# Candle_Volume_Graph
Make a interactive candle and volumne graph in R

---
---

## Part 1 - Main.R


This project uses a linear database.
And a financial graph is made, where one can enter the information of an Excel file and obtain a candlestick graph reflecting the prices. 
Where if you hover over the graph, you will be able to see the price.

<p align="center">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Candle.png" width="550" height="400">
</p>

Also a volume graph. Where if you hover over the graph, you will be able to see the volume.

<p align="center">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Volume.png" width="550" height="400">
</p>

So that in the end I attach both graphs in one.


<p align="center">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Joined.png" width="550" height="400">
</p>

---
---
## Part 2 - Main2.R

The code from Main2.R does not take the data from an Excel file, it extracts it directly from Yahoo Finance.
We use the ticker "F" from 2019/01/01 to 2022/01/01.
This code cleans the data and groups it dayly, weekly, and monthly.
It also creates indicators such as:
- Simple Moving Averages
- Exponential Moving Averages
- Bolinger Bands
- Momentum
- Price Rate of Change
- Moving Average Convergence Divergence
- Relative Strenght Index

It first creates simple graph, where if you hover over the graph, you will be able to see the data of that particular period, including:
- Date
- Open price
- High Price
- Low price
- Close Price
And also at the bottom of the graph we can adjust the time lime.

<p float="left">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Main2-fig1.png" width="450" height="300">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Main2-fig1-2.png" width="450" height="300">
</p>

Then it creates the volumne graph just like in Main.R

<p align="center">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Main2-fig2.png" width="550" height="400">
</p>

Finally it proceeds to create a graph for each one of the indicators and joins them all in a single graph.

<p align="center">
    <img src="https://github.com/Rafa-77/Candle_Volume_Graph/blob/main/Images/Main2-fig1-3.png" width="800" height="400">
</p>
2. 
