//+------------------------------------------------------------------+
//|                                                       Painel.mqh |
//|                                        Copyright 2022, GT Método |
//|                                         https://www.gtmetodo.com |
//+------------------------------------------------------------------+
#include "defines.mqh"
#include "customLabel.mqh"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Trade\Trade.mqh>
#include <Controls\Picture.mqh>
#include "BarTime.mqh"
#include "dealInfo.mqh"
#include "positionInfo.mqh"

#define LOGO_PATH "painel\\images\\logo_80.bmp"

string languagepainel;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInterface : public CAppDialog
  {
   bool              m_use_init_file;
public:
   virtual bool      OnInit(const string title, const ENUM_ANCHOR_POINT anchor, const int x, const int y, const int width, const int height, const bool use_init_file);
   virtual bool      OnEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
   virtual void      Destroy(const int reason = 0);
protected:
   virtual bool      CreateComponentes(const int client_area_width, const int client_area_height) { return true; }
   void              Position(const ENUM_ANCHOR_POINT anchor, const int row, const int column, const int total_rows, const int total_columns, const int row_space, const int column_space,  const int padding_left,const int padding_top, const int padding_right, const int padding_bottom,const int clienteAreaWidth,const int clienteAreaHeight, int &x1,int &y1,int &x2,int &y2);
   template <typename T>
   bool              CreateElement(T *label,const string name,const string text,const ENUM_ANCHOR_POINT anchor, const int row,const int column,const int total_rows,const int total_columns, const int row_space, const int column_space, const int padding_left,const int padding_top,const int padding_right,const int padding_bottom,const int width,const int height);
  };
//+------------------------------------------------------------------+
//| Path para não remover meus programas atoa                        |
//+------------------------------------------------------------------+
void CInterface::Destroy(const int reason)
  {
   switch(reason)
     {
      case REASON_REMOVE:
      case REASON_CLOSE:
      case REASON_CHARTCLOSE:
      case REASON_PROGRAM:
         CAppDialog::Destroy(reason); //remove de verdade o indicador
         break;
      default:
         //m_deinit_reason = reason;
         m_chart.Detach();
         CDialog::Destroy(reason); //não remove o indicador
         break;
     }

//---
//m_deinit_reason=reason;
   if(m_use_init_file)
      IniFileSave();

//--- detach chart object from chart
   m_chart.Detach();
//--- call parent destroy
   CDialog::Destroy();
//---
   switch(reason)
     {
      case REASON_PROGRAM:
      case REASON_REMOVE:
      case REASON_CLOSE:
      case REASON_CHARTCLOSE:
         //ChartIndicatorDelete(m_chart_id,m_subwin,shortname);
         // remove all indicadors
        {

        }
      break;
     }
//--- send message
   EventChartCustom(CONTROLS_SELF_MESSAGE,ON_APP_CLOSE,m_subwin,0.0,ProgramName());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CInterface)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInterface::OnInit(const string title, const ENUM_ANCHOR_POINT anchor, const int x, const int y, const int width, const int height, const bool use_init_file)
  {
   m_use_init_file = use_init_file;

//+------------------------------------------------------------------+
//|VERIFICA A LÍNGUA DO TERMINAL                                     |
//+------------------------------------------------------------------+
// Obtém a linguagem do terminal
   string terminal_language = TerminalInfoString(TERMINAL_LANGUAGE);

// Define a variável global languagepainel conforme a linguagem do terminal
   if(StringFind(terminal_language, "English") >= 0)
     {
      languagepainel = "eng";
     }
   else
      if(StringFind(terminal_language, "Portuguese") >= 0)
        {
         languagepainel = "pt";
        }
      else
        {
         languagepainel = "unknown";
        }


   CRect r;

   const int chart_width =(int) ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   const int chart_height =(int) ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   const int chart_width_half = (int) chart_width / 2;
   const int chart_height_half = (int) chart_height / 2;

   switch(anchor)
     {
      case  ANCHOR_LEFT_UPPER:
         r.left = x;
         r.top = y;
         break;
      case  ANCHOR_LEFT:
         r.left = x;
         r.top = chart_height_half - height / 2 + y;
         break;
      case  ANCHOR_LEFT_LOWER:
         r.left = x;
         r.top = chart_height - height - y;
         break;
      case  ANCHOR_UPPER:
         r.left = chart_width_half + x;
         r.top = y;
         break;
      case  ANCHOR_CENTER:
         r.left = chart_width_half + x - width / 2 ;
         r.top = chart_height_half + y - height / 2;
         break;
      case  ANCHOR_LOWER:
         r.left = chart_width_half + x;
         r.top = chart_height - y - height;
         break;
      case  ANCHOR_RIGHT_UPPER:
         r.left = chart_width - x - width;
         r.top = y;
         break;
      case  ANCHOR_RIGHT:
         r.left = chart_width - x - width;
         r.top = chart_height_half + y;
         break;
      case  ANCHOR_RIGHT_LOWER:
         r.left = chart_width - x - width;
         r.top = chart_height - y - height;
         break;
     }
   r.Size(width,height);


   if(!Create(0,title,0,r.left,r.top,r.right,r.bottom))
     {
      Print("Erro to create interface painel, code:",GetLastError());
      DebugBreak();
      return false;
     };
   if(!CreateComponentes(width-8,height-28))
      return false;

   if(use_init_file)
      IniFileLoad();
   return Run();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterface::Position(const ENUM_ANCHOR_POINT anchor, const int row, const int column, const int total_rows, const int total_columns, const int row_space, const int column_space,  const int padding_left,const int padding_top, const int padding_right, const int padding_bottom,const int clienteAreaWidth,const int clienteAreaHeight, int &x1,int &y1,int &x2,int &y2)
  {
   const int width = (int)(clienteAreaWidth / total_columns),
             height = (int)(clienteAreaHeight / total_rows);
   x1 = width * column;
   y1 = height * row;

   x2 = x1 + (width * column_space);
   y2 = y1 + (height * row_space);

//x2 = x1 + width;
//y2 = y1 + height;

   x1 = x1 + padding_left;
   x2 = x2 - padding_right;
   y1 = y1 + padding_top;
   y2 = y2 - padding_bottom;

   int temp_x, temp_width;
   switch(anchor)
     {
      case  ANCHOR_RIGHT_UPPER:
         temp_x = x1;
         x1 = x2;
         x2 = temp_x;
         break;
      case  ANCHOR_UPPER:
         temp_width = x2 - x1;
         x1 = x1 + (temp_width / 2);
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template <typename T>
bool CInterface::CreateElement(T *object,const string name,const string text,const ENUM_ANCHOR_POINT anchor, const int row,const int column,const int total_rows,const int total_columns, const int row_space, const int column_space, const int padding_left,const int padding_top,const int padding_right,const int padding_bottom,const int width,const int height)
  {
   static int call=0;
   int x1,y1,x2,y2;
   Position(anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,width,height,x1,y1,x2,y2);

   if(0 <=  ObjectFind(0,name)) 
     {
      ResetLastError();
      if(!ObjectDelete(0,name)) //não dar pra attachar, precisa criar o path pra class CButton na funçao create para isso
         printf("cannot delete the %s \"%s\" error:%d",typename(object),name,GetLastError());
     }

   ResetLastError();
   if(!object.Create(0,name,0,x1,y1,x2,y2))
     {
      printf("cannot create the %s \"%s\" error:%d",typename(object),name,GetLastError());
      DebugBreak();
      return false;
     };
   object.Text(text);
   if(!Add(object))
     {
      DebugBreak();
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInterfacePainel : public CInterface
  {
protected:
   CLabel            m_labels[52];
   CButton           m_buttons[5];
   CPicture          m_picturies[1];
public:
   virtual bool      CreateComponentes(const int client_area_width, const int client_area_height);
   CLabel            *TitleLabel() { return &m_labels[37]; }
   CLabel            *SymbolLabel() { return &m_labels[0]; }
   CLabel            *SymbolValue() { return &m_labels[1]; }
   CLabel            *TimeCurrentLabel() { return &m_labels[2]; }
   CLabel            *TimeCurrentValue() { return &m_labels[3]; }
   CLabel            *BarExpirationLabel() { return &m_labels[4]; }
   CLabel            *BarExpirationValue() { return &m_labels[5]; }
   CLabel            *MagicNumberLabel() { return &m_labels[6]; }
   CLabel            *MagicNumberValue() { return &m_labels[7]; }
   CLabel            *LoginLabel() { return &m_labels[8]; }
   CLabel            *LoginValue() { return &m_labels[9]; }
   CLabel            *AccountNameLabel() { return &m_labels[10]; }
   CLabel            *AccountNameValue() { return &m_labels[11]; }
   CLabel            *BrokerLabel() { return &m_labels[12]; }
   CLabel            *BrokerValue() { return &m_labels[13]; }
   CLabel            *LicenseLabel() { return &m_labels[14]; }
   CLabel            *LicenseValue() { return &m_labels[15]; }
   CLabel            *ProfitDayLabel() { return &m_labels[16]; }
   CLabel            *ProfitDayValue() { return &m_labels[17]; }
   CLabel            *ProfitWeekLabel() { return &m_labels[18]; }
   CLabel            *ProfitWeekValue() { return &m_labels[19]; }
   CLabel            *ProfitMonthLabel() { return &m_labels[20]; }
   CLabel            *ProfitMonthValue() { return &m_labels[21]; }
   CLabel            *ProfitTotalLabel() { return &m_labels[22]; }
   CLabel            *ProfitTotalValue() { return &m_labels[23]; }
   CLabel            *ProfitDayAmountValue() { return &m_labels[24]; }
   CLabel            *ProfitWeekAmountValue() { return &m_labels[25]; }
   CLabel            *ProfitMonthAmountValue() { return &m_labels[26]; }
   CLabel            *ProfitTotalAmountValue() { return &m_labels[27]; }
   CLabel            *DirectionLabel() { return &m_labels[28]; }
   CLabel            *VolumeLabel() { return &m_labels[29]; }
   CLabel            *ResultLabel() { return &m_labels[30]; }
   CLabel            *BuyLabel() { return &m_labels[31]; }
   CLabel            *SellLabel() { return &m_labels[32]; }
   CLabel            *VolumeBuyValue() { return &m_labels[33]; }
   CLabel            *VolumeSellValue() { return &m_labels[34]; }
   CLabel            *ResultBuyValue() { return &m_labels[35]; }
   CLabel            *ResultSellValue() { return &m_labels[36]; }
   CLabel            *AccountTypeLabel() { return &m_labels[37]; }
   CLabel            *AccountTypeValue() { return &m_labels[38]; }

   CButton           *ZeroButtom() { return &m_buttons[0]; }
   CButton           *PauseButtom() { return &m_buttons[1]; }
   CButton           *Line1() { return &m_buttons[2]; }
   CButton           *Line2() { return &m_buttons[3]; }
   CButton           *Line3() { return &m_buttons[4]; }

   CPicture          *LogoPicture() { return &m_picturies[0]; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInterfacePainel::CreateComponentes(const int client_area_width,const int client_area_height)
  {
// initial configs
   int total_rows = 30,
       total_columns = 3,
       padding_left = 7,
       padding_top = 2,
       padding_right = 10,
       padding_bottom = 2,
       element_counter = 0,
       row_space = 1,
       column_space = 1,
       row,
       column;
   ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER;
   string prefix_name = "painel_element_",
          name,
          text;
   bool res = true;

// start creating



// não sei porque os botões tem que serem criados primeiro para poder enviar o evento de click
   total_columns = 5;
   row_space = 3;
   row = total_rows - 3;
   column = 2;



   if(languagepainel == "pt")
     {
      text = "Zerar";
     }
   else // Inglês por padrão
     {
      text = "Close";
     }
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ZeroButtom(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);



// logo e titulo
   padding_left = 25;
   total_columns = 4;
   row =0;
   row_space = 1;

/*
   column = 0;
   text = "LOGO";
   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(LogoPicture(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   if(!LogoPicture().BmpName("::"+LOGO_PATH))
      DebugBreak();
*/
   column = 0;
   text = "DTT Trend Catcher";
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(TitleLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   TitleLabel().FontSize(28);

// linha 1
   total_columns =1;
   padding_left = 7;
   row =7;
   column = 0;
   text = "";
   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(Line1(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   Line1().Height(2);


// labels
   total_columns =3;
   row_space = 1;
   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Ativo";
     }
   else // Inglês por padrão
     {
      text = "Symbol";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(SymbolLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;

   if(languagepainel == "pt")
     {
      text = "Hora Servidor";
     }
   else // Inglês por padrão
     {
      text = "Broker hour";
     }

   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(TimeCurrentLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   TimeCurrentLabel().Anchor(anchor);

   column = 2;

   if(languagepainel == "pt")
     {
      text = "Próximo Candle";
     }
   else // Inglês por padrão
     {
      text = "Next candle";
     }

   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(BarExpirationLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   BarExpirationLabel().Anchor(anchor);

   row++;
   column = 0;
   text = Symbol();
   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(SymbolValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = TimeToString(TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(TimeCurrentValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   TimeCurrentValue().Anchor(anchor);

   column = 2;
   text = "";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(BarExpirationValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   BarExpirationValue().Anchor(anchor);

   row++;



   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Número da conta";
     }
   else // Inglês por padrão
     {
      text = "Account number";
     }


   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(LoginLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 2;
   text = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(LoginValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   LoginValue().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Nome da conta";
     }
   else // Inglês por padrão
     {
      text = "Account name";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(AccountNameLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 2;
   text = AccountInfoString(ACCOUNT_NAME);
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(AccountNameValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   AccountNameValue().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Tipo de conta";
     }
   else // Inglês por padrão
     {
      text = "Account type";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(BrokerLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 2;
   text = "Waiting...";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(BrokerValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   BrokerValue().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Licença expira";
     }
   else // Inglês por padrão
     {
      text = "License expire";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(LicenseLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 2;

   text = "Waiting...";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(LicenseValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   LicenseValue().Anchor(anchor);




   


// linha 2
   total_columns =1;
   row++;
   row++;
   column = 0;
   text = "";
   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(Line2(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   Line2().Height(2);

//labels
   total_columns =3;
   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Dia";
     }
   else // Inglês por padrão
     {
      text = "Day";
     }


   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitDayLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = "12/12";
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitDayAmountValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitDayAmountValue().Anchor(anchor);

   column = 2;
   text = "R$ 272.00";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitDayValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitDayValue().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Semana";
     }
   else // Inglês por padrão
     {
      text = "Week";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitWeekLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = "12/12";
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitWeekAmountValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitWeekAmountValue().Anchor(anchor);

   column = 2;
   text = "R$ 272.00";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitWeekValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitWeekValue().Anchor(anchor);

   row++;
   column = 0;


   if(languagepainel == "pt")
     {
      text = "Mês";
     }
   else // Inglês por padrão
     {
      text = "Month";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitMonthLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = "12/12";
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitMonthAmountValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitMonthAmountValue().Anchor(anchor);

   column = 2;
   text = "R$ 272.00";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ProfitMonthValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ProfitMonthValue().Anchor(anchor);



// linha 3
   total_columns =1;
   row++;
   row++;
   column = 0;
   text = "";
   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(Line3(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   Line3().Height(2);


   total_columns =3;
   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Tipo da posição";
     }
   else // Inglês por padrão
     {
      text = "Position type";
     }


   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(DirectionLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   
   if(languagepainel == "pt")
     {
      text = "Lotes";
     }
   else // Inglês por padrão
     {
      text = "Lots";
     }

   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(VolumeLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   VolumeLabel().Anchor(anchor);

   column = 2;

   if(languagepainel == "pt")
     {
      text = "Resultado";
     }
   else // Inglês por padrão
     {
      text = "Result";
     }


   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ResultLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ResultLabel().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Compra";
     }
   else // Inglês por padrão
     {
      text = "Buy";
     }

   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(BuyLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = "0.00";
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(VolumeBuyValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   VolumeBuyValue().Anchor(anchor);

   column = 2;
   text = "R$ 0.00";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ResultBuyValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ResultBuyValue().Anchor(anchor);

   row++;
   column = 0;

   if(languagepainel == "pt")
     {
      text = "Venda";
     }
   else // Inglês por padrão
     {
      text = "Sell";
     }


   anchor = ANCHOR_LEFT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(SellLabel(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);

   column = 1;
   text = "0.00";
   anchor = ANCHOR_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(VolumeSellValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   VolumeSellValue().Anchor(anchor);

   column = 2;
   text = "R$ 0.00";
   anchor = ANCHOR_RIGHT_UPPER;
   name = prefix_name + IntegerToString(++element_counter);
   res&=CreateElement(ResultSellValue(),name,text,anchor,row,column,total_rows,total_columns,row_space,column_space,padding_left,padding_top,padding_right,padding_bottom,client_area_width,client_area_height);
   ResultSellValue().Anchor(anchor);

   return res;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInterfacePainelApp : public CInterfacePainel
  {
   CTrade            m_trade;
   CContageRegressiva m_bar_conometer;
   CPositionsInfo    m_positions;
   CDealsInfo m_deals_day,
              m_deals_week,
              m_deals_month,
              m_deals_total;
   int               m_last_rates;
   ulong             m_magic_number;
public:
   bool              OnInit(const ulong magic_number, const string title, const ENUM_ANCHOR_POINT anchor, const int x, const int y, const int width, const int height, const bool use_init_file);
   void              OnTick();
   void              OnTimer();
   void              OnTrade();
   void              OnDeinit(const int reason);
protected:
   void              OnBar();
   bool              OnEvent(const int id,const long& lparam,const double& dparam,const string& sparam);
   void              Zerar();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CInterfacePainelApp)
ON_EVENT(ON_CLICK,ZeroButtom(),Zerar)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_END(CInterfacePainel)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInterfacePainelApp::OnInit(const ulong magic_number,const string title,const ENUM_ANCHOR_POINT anchor,const int x,const int y,const int width,const int height,const bool use_init_file)
  {
   if(!CInterfacePainel::OnInit(title,anchor,x,y,width,height,use_init_file))
      return false;
// set magic number to trader
   m_trade.SetExpertMagicNumber(magic_number);
   m_magic_number = magic_number;
   MagicNumberValue().Text(IntegerToString(magic_number));
   EventSetTimer(1);
// force init bar_conometer
   m_bar_conometer.OnFirstTick();
//init deal objects
   m_deals_day.OnInit(PERIOD_D1,magic_number);
   m_deals_week.OnInit(PERIOD_W1,magic_number);
   m_deals_month.OnInit(PERIOD_MN1,magic_number);
   m_deals_total.OnInit(0,magic_number);
// force Tick
   OnTick();
// force Trade
   OnTrade();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::OnTick(void)
  {
   const int rates = Bars(Symbol(),Period());
   if(m_last_rates != rates)
     {
      m_last_rates = rates;
      OnBar();
     }
   string account_currency = AccountInfoString(ACCOUNT_CURRENCY);
   string prefix = account_currency + " ";
   m_positions.OnTick();
   ResultBuyValue().Text(prefix + DoubleToString(m_positions.BuyProfit(),2));
   ResultSellValue().Text(prefix + DoubleToString(m_positions.SellProfit(),2));
   VolumeBuyValue().Text(DoubleToString(m_positions.BuyVolume(),2));
   VolumeSellValue().Text(DoubleToString(m_positions.SellVolume(),2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::OnTimer(void)
  {
// set bar expiration
   BarExpirationValue().Text(m_bar_conometer.TimeToEndAsString());
   TimeCurrentValue().Text(TimeToString(TimeCurrent(),TIME_MINUTES|TIME_SECONDS));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::OnTrade(void)
  {
   m_deals_day.OnTrade();
   m_deals_week.OnTrade();
   m_deals_month.OnTrade();
   m_deals_total.OnTrade();

   string account_currency = AccountInfoString(ACCOUNT_CURRENCY);
   string prefix = account_currency + " ";
   ProfitDayValue().Text(prefix + DoubleToString(m_deals_day.Profit(),2));
   ProfitWeekValue().Text(prefix + DoubleToString(m_deals_week.Profit(),2));
   ProfitMonthValue().Text(prefix + DoubleToString(m_deals_month.Profit(),2));
   ProfitTotalValue().Text(prefix + DoubleToString(m_deals_total.Profit(),2));

   int winners,
       lossers;
   string text;

   winners = m_deals_day.Winners();
   lossers = m_deals_day.Lossers();
   text = winners == 0 && lossers == 0 ? "0/0" :  IntegerToString(winners) + "/" + IntegerToString(lossers);
   ProfitDayAmountValue().Text(text);

   winners = m_deals_week.Winners();
   lossers = m_deals_week.Lossers();
   text = winners == 0 && lossers == 0 ? "0/0" :  IntegerToString(winners) + "/" + IntegerToString(lossers);
   ProfitWeekAmountValue().Text(text);

   winners = m_deals_month.Winners();
   lossers = m_deals_month.Lossers();
   text = winners == 0 && lossers == 0 ? "0/0" :  IntegerToString(winners) + "/" + IntegerToString(lossers);
   ProfitMonthAmountValue().Text(text);

   winners = m_deals_total.Winners();
   lossers = m_deals_total.Lossers();
   text = winners == 0 && lossers == 0 ? "0/0" :  IntegerToString(winners) + "/" + IntegerToString(lossers);
   ProfitTotalAmountValue().Text(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::OnDeinit(const int reason)
  {
   EventKillTimer();
   CInterfacePainel::Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::OnBar(void)
  {
   m_bar_conometer.OnBar();
   m_deals_day.OnBar();
   m_deals_week.OnBar();
   m_deals_month.OnBar();
   m_deals_total.OnBar();
   OnTrade();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInterfacePainelApp::Zerar(void)
  {
   Print(__FUNCTION__);
   ulong ticket;
// close orders
   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      ticket = OrderGetTicket(i);
      if(OrderGetInteger(ORDER_MAGIC) != m_magic_number)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != Symbol())
         continue;
      m_trade.OrderDelete(ticket);
     }
// close positions
   for(int i=PositionsTotal()-1; i >= 0; i--)
     {
      ticket = PositionGetTicket(i);
      if(PositionGetInteger(POSITION_MAGIC) != m_magic_number)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      m_trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
