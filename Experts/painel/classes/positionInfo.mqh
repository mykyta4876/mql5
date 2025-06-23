//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPositionsInfo
  {
   double            m_buy_volume, m_sell_volume, m_total_volume,
                     m_buy_profit, m_sell_profit, m_total_profit,
                     m_buy_price_avg, m_sell_price_avg, m_total_price_avg;
   //m_buy_points, m_sell_points, m_total_points;
public:
   void              OnTick();
   double            BuyVolume()const { return m_buy_volume; }
   double            SellVolume()const { return m_sell_volume; }
   double            TotalVolume()const { return m_total_volume; }
   double            BuyProfit()const { return m_buy_profit; }
   double            SellProfit()const { return m_sell_profit; }
   double            TotalProfit()const { return m_total_profit; }
   double            BuyPoints()const { return (BuyPriceAvg() == 0 ? 0 : BuyPriceAvg()- iClose(Symbol(),Period(),0))/Point(); }
   double            SellPoints()const { return (SellPriceAvg() == 0 ? 0 : SellPriceAvg() - iClose(Symbol(),Period(),0))/Point(); }
   //double            TotalPoints()const { return TotalProfit() / SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE); }
   double            BuyPriceAvg()const { return m_buy_price_avg; }
   double            SellPriceAvg()const { return m_sell_price_avg; }
   double            TotalPriceAvg()const { return m_total_price_avg; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionsInfo::OnTick(void)
  {
   double profit = 0,
          volume = 0,
          points = 0,
          open = 0;

   m_buy_volume =0;
   m_sell_volume =0;
   m_total_volume =0;
   m_buy_profit =0;
   m_sell_profit =0;
   m_total_profit =0;
   m_buy_price_avg =0;
   m_sell_price_avg =0;
   m_total_price_avg=0;
//m_buy_points=0;
//m_sell_points=0;
//m_total_points=0;

   const int total = PositionsTotal();
   for(int i=0; i<total; i++)
     {
      PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;

      volume = PositionGetDouble(POSITION_VOLUME);
      profit = PositionGetDouble(POSITION_PROFIT);
      open = PositionGetDouble(POSITION_PRICE_OPEN);
      // finaceiro para pontos
      //points = profit / SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);

      m_total_volume += volume;
      m_total_profit += profit;
      //m_total_points += points;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         m_buy_volume += volume;
         m_buy_profit += profit;
         m_buy_price_avg += open * volume;
         //m_buy_points += points;
        }
      else
        {
         m_sell_volume += volume;
         m_sell_profit += profit;
         m_sell_price_avg += open * volume;
         //m_sell_points += points;
        }
     }
// evite dividir por zero
   if(m_buy_volume != 0)
      m_buy_price_avg /= m_buy_volume;
   else
      m_buy_price_avg = 0;

// evite dividir por zero
   if(m_sell_volume != 0)
      m_sell_price_avg /= m_sell_volume;
   else
      m_sell_price_avg = 0;

// evite dividir por zero
   if((m_buy_volume-m_sell_volume) != 0)
      m_total_price_avg = ((m_buy_price_avg * m_buy_volume) - (m_sell_price_avg * m_sell_volume)) / (m_buy_volume-m_sell_volume);
   else
      m_total_price_avg = 0;
  }
//+------------------------------------------------------------------+
