class CDealsInfo
  {
   int               m_loss_operations;
   int               m_win_operations;
   double            m_total_profit;
   ENUM_TIMEFRAMES   m_timeframe;
   datetime          m_from;
   ulong             m_magic;
   datetime          m_last_time_day;
public:
   void              OnInit(const datetime from, ulong magic) { m_from = from; m_magic = magic; }
   void              OnInit(const ENUM_TIMEFRAMES timeframe, ulong magic) { m_timeframe = timeframe; OnInit(iTime(Symbol(),m_timeframe,0),magic); }
   void              OnBar();
   void              OnDay();
   double            Profit()const {return m_total_profit; }
   int               Winners()const { return m_win_operations; }
   int               Lossers()const { return m_loss_operations; }
   void              OnTrade();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDealsInfo::OnTrade(void)
{
   m_loss_operations = 0;
   m_win_operations = 0;
   m_total_profit = 0;

   ulong ticket;
   double profit;

   HistorySelect(m_from, TimeCurrent());
   const int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != m_magic)
         continue;

      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;


         // Verifica o motivo do fechamento da posição
         long reason = HistoryDealGetInteger(ticket, DEAL_REASON);
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

         if (reason == DEAL_REASON_SL || reason == DEAL_REASON_TP)
         {
            m_total_profit += profit;

            if(profit >= 0)
            {
               m_win_operations++;
            }
            else
            {
               m_loss_operations++;
            }
         }
      }
   }



void CDealsInfo::OnBar(void)
{
   const datetime time_day = iTime(Symbol(),PERIOD_D1,0);
   if(m_last_time_day != time_day)
   {
      m_last_time_day = time_day;
      OnDay();
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDealsInfo::OnDay(void)
  {
   if(m_from != 0)
     {
      m_from = iTime(Symbol(),m_timeframe,0);
      OnTrade();
     }
  }