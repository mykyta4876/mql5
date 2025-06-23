//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CContageRegressiva
  {
   datetime          m_time_to_next_candle;
   datetime          m_diff;
public:
   void              OnBar();
   void              OnFirstTick();
   datetime          TimeToEnd()const;
   datetime          TimeCurrent()const;
   string            TimeToEndAsString()const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CContageRegressiva::OnFirstTick(void)
  {
   OnBar();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CContageRegressiva::OnBar(void)
  {
   m_time_to_next_candle = iTime(Symbol(),Period(),0) + PeriodSeconds();
   m_diff = ::TimeLocal() - ::TimeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CContageRegressiva::TimeToEnd()const
  {
   return m_time_to_next_candle - TimeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CContageRegressiva::TimeCurrent(void)const
  {
   datetime temp = TimeLocal() - m_diff;
   return temp;
  }
string CContageRegressiva::TimeToEndAsString(void)const
{
   return TimeToStringRegressive(TimeToEnd());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeToStringRegressive(const datetime time_to_string)
  {
   if(time_to_string < 0)
      return "";
   MqlDateTime time;
   TimeToStruct(time_to_string,time);
   if(time.day != 1)
      return TimeToString(StructToTime(time),TIME_DATE|TIME_MINUTES|TIME_SECONDS);

   if(time.hour != 0)
      return TimeToString(StructToTime(time),TIME_MINUTES|TIME_SECONDS);

   if(time.min != 0)
     {
      if(time.min == 1 && time.sec == 0)
         return "60";
      return (string)time.min + ":" + (time.sec >= 10 ? (string) time.sec : "0" + (string) time.sec);
     }
   return (string)time.sec;
  }