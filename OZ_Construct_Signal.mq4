//+------------------------------------------------------------------+
//|                                                     WPR+BAND.mq4 |
//|                                                   Ozires da Cruz |
//|                                                                  |
//+------------------------------------------------------------------+

#define VERSION "1.1"
#property copyright "Check ARROW - Ozires da Cruz"
#property link      ""
#property version VERSION
#property strict
//---- Indicator drawing and buffers
 #property indicator_chart_window
 #property indicator_buffers 2
 //---- Colors and sizes for buffers
 #property indicator_color1 clrDodgerBlue
 #property indicator_color2 clrTomato
 #property indicator_width1 2
 #property indicator_width2 2

#import "user32.dll"
   int GetDC(int hwnd);
   int ReleaseDC(int hwnd,int hdc);
#import "gdi32.dll"
   color GetPixel(int hdc,int x,int y);
   color SetPixel(int hdc, int X, int Y, color crColor);
#import

 //---- Buffer Arrays
 double ExtMapBuffer1[];
 double ExtMapBuffer2[];

extern bool ShowAlert = true;

datetime ArrayTime[], LastTime;
int BUY_SIGNAL = 6;
int SELL_SIGNAL = 7;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
bool Alert_MT4 = false;
bool Alert_Email = false;
bool Alert_Mobile = false;
int MaxBars = 50;
datetime time_candle = 0;

string lastMsg = "";

int init()
  {
//--- indicator buffers mapping
 
   // First buffer
  SetIndexBuffer(0, ExtMapBuffer1);  // Assign buffer array
  SetIndexStyle(0, DRAW_ARROW);      // Style to arrow
  SetIndexArrow(0, 233);             // Arrow code
  
  //Second buffer
  SetIndexBuffer(1, ExtMapBuffer2);  // Assign buffer array          
  SetIndexStyle(1, DRAW_ARROW);      // Style to arrow
  SetIndexArrow(1, 234);             // Arrow code

   //Comment("Version: " + VERSION);
   CreateCommentText();
   
   SetCommentText("Version: LT " + VERSION);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
      if (NewBar(Period())) 
      {
        
         //Sleep(5000);
         
         //printf("*** NEWBAR ***");
         
         
         long ChartNm = ChartID();
         int SubWin = 0;
         string AssetName = Symbol();
         int Per = Period();
         int Shft = 1;
         datetime GimmeTime = iTime(AssetName,Per,Shft);
         double LowPrice    = iLow(AssetName,Per,Shft);
         double HighPrice   = iHigh(AssetName,Per,Shft);
         double ClosePrice  = iClose(AssetName,Per,Shft);
         double OpenPrice  = iClose(AssetName,Per,Shft);
         int hwnd           = WindowHandle(Symbol(),Period());
         int hdc            = GetDC(hwnd);
                  
         int x,y;
                    
          //--
         ChartTimePriceToXY(ChartNm,SubWin,GimmeTime,HighPrice,x,y);              
         //color low_price_bg = GetPixel(hdc,x,y);
         //--

         //if (Close[Shft] > Open[Shft]) {
            if (ConstructlSignal(SELL_SIGNAL))
            {
               DrawThumbsUpDown();
            } else {
               //DrawThumbsUpDown();
            }
         //}
         
         //--
         ChartTimePriceToXY(ChartNm,SubWin,GimmeTime,LowPrice,x,y);              
         //color high_price_bg = GetPixel(hdc,x,y);
         //--
         
         //if (Close[Shft] < Open[Shft]) {                     
            if (ConstructlSignal(BUY_SIGNAL))
            {
               DrawThumbsUpUp();
            } else {
               //DrawThumbsUpUp();
            }
         //}
   
          ReleaseDC(hwnd,hdc);
      
   }
//--- return value of prev_calculated for next call
   return(0);
}
//+------------------------------------------------------------------+
bool LtSignalUp(int hdc, int inix, int iniy) 
{
   //for (int i = 1; i < 200; i++)
   {
      //SetPixel(hdc, inix+3, iniy-i, clrAqua);
   }     

   for (int i = 1; i < 200; i++)
   {
      color bg = GetPixel(hdc, inix, iniy-i);
            
      if (bg == clrYellow)
      {
         PrintFormat("color DW %d y: %d i: %d", bg,iniy, i);
         return true;
      }
   }
   
   return false;
}
//+------------------------------------------------------------------+
bool LtSignalDown(int hdc, int inix, int iniy) 
{
   //for (int i = 1; i < 200; i++)
   {
      //SetPixel(hdc, inix+3, iniy+i, clrAqua);
   }     

   for (int i = 1; i < 200; i++)
   {
      color bg = GetPixel(hdc, inix+3, iniy+i);
      
      if (bg == clrYellow)
      {
         PrintFormat("color DW %d y: %d i: %d", bg,iniy, i);
         return true;
      }
   }
   
   return false;
}
//+------------------------------------------------------------------+
void DrawThumbsUpDown()
{ 
   //DrawThumbsUp(SYMBOL_ARROWDOWN, "Down " + IntegerToString(Bars), High[1] + 10 * Point, Red, 4);      
   ShowMsg("PUT");
   //ExtMapBuffer2[2] = EMPTY_VALUE;
   ExtMapBuffer2[1] = High[1];
}
//+------------------------------------------------------------------+
void DrawThumbsUpUp()
{
   //DrawThumbsUp(SYMBOL_ARROWUP, "Up " + IntegerToString(Bars), Low[1] - 10 * Point, Green, 4);
   ShowMsg("CALL");
   //ExtMapBuffer1[2] = EMPTY_VALUE;
   ExtMapBuffer1[1] = Low[1];
}
//+------------------------------------------------------------------+
void ShowMsg(string type) 
{
   string sDnTime = TimeToStr(Time[0]);
   string sDnTimeLocal = TimeToStr(TimeLocal(), TIME_SECONDS);
   string sTimeGMTOffset = IntegerToString(TimeGMTOffset()/3600);
   string msg = "###-" + Symbol() + "-" + type + "-" + sDnTime;
   string msgJson = "{\"symbol\":\"" + Symbol() 
      + "\",\"type\":\"" + type 
      + "\",\"time\":\"" + sDnTime
      + "\",\"time_local\":\"" + sDnTimeLocal
      + "\",\"time_offset\":\"" + sTimeGMTOffset + "\"}";

      if (lastMsg != msg)
      {
         lastMsg = msg;
         Alert(msg);   
      }
}
//+------------------------------------------------------------------+
void DrawThumbsUp(int SymbolThumbsUp, string ThumbsUpName,double LinePrice,color LineColor, int Width)
{
   ObjectCreate(ThumbsUpName, OBJ_ARROW_THUMB_UP, 0, Time[1], LinePrice); //draw an up arrow
   ObjectSet(ThumbsUpName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(ThumbsUpName, OBJPROP_BGCOLOR, LineColor);
   ObjectSet(ThumbsUpName, OBJPROP_ARROWCODE, 108);//SymbolThumbsUp);
   ObjectSet(ThumbsUpName, OBJPROP_COLOR,LineColor);
   ObjectSet(ThumbsUpName, OBJPROP_WIDTH,Width);   
}

//+------------------------------------------------------------------+
bool NewBar(int period)
{
   bool firstRun = false, newBar = false;
   
   ArraySetAsSeries(ArrayTime,true);
   CopyTime(Symbol(),period,0,2,ArrayTime);
   
   if(LastTime == 0) firstRun = true;
   if(ArrayTime[0] > LastTime)
   {
      if(firstRun == false) newBar = true;
      LastTime = ArrayTime[0];
   }
   
   return newBar;   
}

//+------------------------------------------------------------------+
bool WPRSignal(int BUY_SELL) 
{
   string wpr="ALMOST GRAIL2";
   double dValue0=0;
   
   dValue0 = iCustom(NULL, 5, wpr, BUY_SELL,1);
   
   return !((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}

//+------------------------------------------------------------------+

void CreateCommentText() 
{
   string CommentObjectName = "CommentObject";
   
   // Create text object with given name 
   ObjectCreate(CommentObjectName, OBJ_LABEL, 0, 0, 0, 0);
   
   // Set pixel co-ordinates from top left corner (use OBJPROP_CORNER to set a different corner)   
   ObjectSet(CommentObjectName, OBJPROP_XDISTANCE, 0);
   ObjectSet(CommentObjectName, OBJPROP_YDISTANCE, 10);
}
//+------------------------------------------------------------------+
void SetCommentText(string text)
{
   string CommentObjectName = "CommentObject";
   
    // Set text, font, and colour for object   
   ObjectSetText(CommentObjectName, text, 10, "Arial", Red);
}
//+-------------------------------------------------------------------+
int LengthLowerWick(int i)
{
   // Lower wick length.
   if (((NormalizeDouble(MathMin(Open[i], Close[i]) - Low[i], _Digits) >= NormalizeDouble(0 * Point, _Digits))))
   {
      return MathRound((MathMin(Open[i], Close[i]) - Low[i]) / Point);
   }
   
   return -1;
}

int LengthUpperWick(int i) 
{
   // Upper wick length display.
   if (((NormalizeDouble(High[i] - MathMax(Open[i], Close[i]), _Digits) >= NormalizeDouble(0 * Point, _Digits))))
   {
      return MathRound((High[i] - MathMax(Open[i], Close[i])) / Point);      
   }
   
   return -1;
}

int LengthCandle(int i)
{
   return MathAbs(Open[i] - Close[i])/Point;
}

bool CandleWickOK(int i, int BUY_SELL)
{
   if (BUY_SELL == BUY_SIGNAL)   
   {
      return LengthCandle(i) >= 15 && (LengthLowerWick(i) >= 0 && LengthLowerWick(i) <= 10);
   }
   else {
      return LengthCandle(i) >= 15 && (LengthUpperWick(i) >= 0 && LengthUpperWick(i) <= 10);
   }

} 
//-------------------------------------------------
bool FractalSignal(int BUY_SELL) 
{
   string bk_fractal ="BK Fractals";
   double dValue0=0;
   
   dValue0 = iCustom(NULL,Period(), bk_fractal, BUY_SELL, 2);

   return !((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}
//-------------------------------------------------
bool _4X4Signal(int BUY_SELL) 
{
   string bk_4X4 ="BK MA 4X4";
   double dValue0=0;
   
   dValue0 = iCustom(NULL,Period(), bk_4X4, BUY_SELL, 1);

   return !((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}
//-------------------------------------------------
bool DownTrend() 
{
   string bk_ma50 ="BK MA 50";
   string bk_ma34 ="BK MA 34";
   double dValue50=0;
   double dValue34=0;
   
   dValue50 = iCustom(NULL,Period(), bk_ma50, 0, 0);
   dValue34 = iCustom(NULL,Period(), bk_ma34, 0, 0);

   return dValue50 > dValue34 && Open[1] < dValue50;
}
//-------------------------------------------------
bool UpTrend() 
{
   string bk_ma50 ="BK MA 50";
   double dValue50=0;
   
   dValue50 = iCustom(NULL,Period(), bk_ma50, 0, 0);

   return !DownTrend() && Open[1] > dValue50;
}
//-------------------------------------------------
bool LastNo4X4Signal(int BUY_SELL) 
{
   string bk_4X4 ="BK MA 4X4";
   double dValue0=0;
   double dValue1=0;
   double dValue2=0;
   
   dValue0 = iCustom(NULL,Period(), bk_4X4, BUY_SELL, 2);
   dValue1 = iCustom(NULL,Period(), bk_4X4, BUY_SELL, 3);
   dValue2 = iCustom(NULL,Period(), bk_4X4, BUY_SELL, 4);

   return ((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}
//+------------------------------------------------------------------+
int FanLength(int i) 
{
   string fan="BK FAN";
   double dValue0=0;
   double dValue11=0;
   
   dValue0 = iCustom(NULL,Period(),fan, 0, i);
   dValue11 = iCustom(NULL,Period(),fan, 11, i);

   return MathAbs(dValue0 - dValue11)/Point;  
}
//+------------------------------------------------------------------+
bool OKFan(int i)
{
   return FanLength(i) > 70;
}
//+------------------------------------------------------------------+
bool ConstructlSignal(int BUY_SELL) 
{
   string construct_signal = "Signal_Construct_v1.3";
   
   //** Parâmetros 
   string txt_crft = "~~~~~~ CRIE SEU ARQUIVO INDICADOR ~~~~~~";
   int gerar_ind = 1;
   string name_file = "ozxyz";
   string my_name = "apelido ozxyz";
   int clr_up = 16711680;
   int clr_dn = 255;
   int id_type = 0;
   int number_login = 11111111;
   datetime endTime = 1546214400;
   string txt_crft1 = "";
   string txt0 = "~~~~~~ Indicador 1 de terceiros ~~~~~~";
   int on_off_main1 = 0;
   string name_ind1 = "LP-LT-tr-arr-K";
   int bufferUP1 = 0;
   int bufferDN1 = 1;
   //** Fim Parâmetros 
   double dValue0=0;
   
 dValue0 = iCustom(
      NULL,
      Period(), 
      construct_signal, 
      txt_crft,
      gerar_ind,
      name_file,
      my_name,
      clr_up,
      clr_dn,
      id_type,
      number_login,
      endTime,
      txt_crft1,
      txt0,
      on_off_main1,
      name_ind1,
      bufferUP1,
      bufferDN1,
      BUY_SELL, 
      1);
   if (!((dValue0 == 0) || (dValue0 == EMPTY_VALUE)))
      PrintFormat("*** Value %d", dValue0);
      
   return !((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}

/*
   //** Parâmetros 
   string txt_crft = "~~~~~~ CRIE SEU ARQUIVO INDICADOR ~~~~~~";
   int gerar_ind = 1;
   string name_file = "... nome do arquivo indicador ...";
   string my_name = "... nome completo ou apelido ...";
   int clr_up = 16711680;
   int clr_dn = 255;
   int id_type = 0;
   int number_login = 11111111;
   datetime endTime = 1546214400;
   string txt_crft1 = "";
   string txt0 = "~~~~~~ Indicador 1 de terceiros ~~~~~~";
   int on_off_main1 = 0;
   string name_ind1 = "LP-LT-tr-arr-K";
   int bufferUP1 = 0;
   int bufferDN1 = 1;
   string txt01 = "";
   string txt02 = "~~~~~~ Indicador 2 de terceiros ~~~~~~";
   int on_off_main2 = 1;
   string name_ind2 = ".....";
   int bufferUP2 = 0;
   int bufferDN2 = 1;
   string txt012 = "";
   string txt03 = "~~~~~~ Indicador 3 de terceiros ~~~~~~";
   int on_off_main3 = 1;
   string name_ind3 = ".....";
   int bufferUP3 = 0;
   int bufferDN3 = 1;
   string txt013 = "";
   string txt_adx_1 = "~~~~~~ ADX ~~~~~~";
   int on_off_adx = 1;
   int period_adx = 1;
   double level_adx = 60.0;
   double price_adx = 0;
   string txt_adx_2 = "";
   string txt_cci_1 = "~~~~~~ CCI_1 ~~~~~~";
   int on_off_cci1 = 1;
   int type_cci1 = 1;
   int revers_cci1 = 1;
   int period_cci1 = 14;
   double level_cci1 = 100.0;
   double price_cci1 = 0;
   string txt_cci_2 = "~~~~~~ CCI_2 ~~~~~~";
   int on_off_cci2 = 1;
   int type_cci2 = 1;
   int revers_cci2 = 1;
   int period_cci2 = 14;
   double level_cci2 = 100.0;
   double price_cci2 = 0;
   string txt_cci_3 = "";
   string txt_rsi_1 = "~~~~~~ RSI_1 ~~~~~~";
   int on_off_rsi1 = 1;
   int type_rsi1 = 1;
   int revers_rsi1 = 1;
   int period_rsi1 = 14;
   double level_rsi1 = 20.0;
   double price_rsi1 = 0;
   string txt_rsi_2 = "~~~~~~ RSI_2 ~~~~~~";
   int on_off_rsi2 = 1;
   int type_rsi2 = 1;
   int revers_rsi2 = 1;
   int period_rsi2 = 14;
   double level_rsi2 = 20.0;
   double price_rsi2 = 0;
   string txt_rsi_3 = "";
   string txt_dem_1 = "~~~~~~ DeMarker_1 ~~~~~~";
   int on_off_DeM1 = 0;
   int type_DeM1 = 1;
   int revers_DeM1 = 1;
   int period_DeM1 = 7;
   double level_DeM1 = 0.2;
   string txt_dem_2 = "~~~~~~ DeMarker_2 ~~~~~~";
   int on_off_DeM2 = 1;
   int type_DeM2 = 1;
   int revers_DeM2 = 1;
   int period_DeM2 = 14;
   double level_DeM2 = 0.2;
   string txt_dem_3 = "~~~~~~ DeMarker_3 ~~~~~~";
   int on_off_DeM3 = 1;
   int type_DeM3 = 1;
   int revers_DeM3 = 1;
   int period_DeM3 = 14;
   double level_DeM3 = 0.2;
   string txt_dem_4 = "";
   string txt_Stoch_1 = "~~~~~~ Estocástico ~~~~~~";
   int on_off_Stoch = 1;
   int type_Stoch = 1;
   int revers_Stoch = 1;
   int periodK_Stoch = 5;
   int periodD_Stoch = 3;
   int sloving_Stoch = 3;
   int price_Stoch = 0;
   int methMA_Stoch = 0;
   double level_Stoch = 20.0;
   int type_line = 0;
   string txt_Stoch_2 = "";
   string txt13 = "~~~~~~ WPR_1 ~~~~~~";
   int on_off_WPR1 = 1;
   int type_WPR1 = 1;
   int revers_wpr1 = 1;
   int periodo_WPR1 = 14;
   double level_WPR1 = 20.0;
   string txt14 = "~~~~~~ WPR_2 ~~~~~~";
   int on_off_WPR2 = 1;
   int type_WPR2 = 1;
   int revers_wpr2 = 1;
   int periodo_WPR2 = 14;
   double level_WPR2 = 20.0;
   string txt15 = "~~~~~~ WPR_3 ~~~~~~";
   int on_off_WPR3 = 1;
   int type_WPR3 = 1;
   int revers_wpr3 = 1;
   int periodo_WPR3 = 14;
   double level_WPR3 = 20.0;
   string txt16 = "";
   string txt_mfi_1 = "~~~~~~ MFI_1 ~~~~~~";
   int on_off_MFI1 = 1;
   int type_MFI1 = 1;
   int revers_mfi1 = 1;
   int period_MFI1 = 14;
   double level_MFI1 = 20.0;
   string txt_mfi_2 = "~~~~~~ MFI_2 ~~~~~~";
   int on_off_MFI2 = 1;
   int type_MFI2 = 1;
   int revers_mfi2 = 1;
   int period_MFI2 = 14;
   double level_MFI2 = 20.0;
   string txt_mfi_3 = "";
   string txt_bb_1 = "~~~~~~ BBands_1 ~~~~~~";
   int on_off_BB1 = 1;
   int type_BB1 = 1;
   int revers_BB1 = 1;
   int periodo_BB1 = 20;
   double desvt_BB1 = 2.0;
   int shift_BB1 = 0;
   int preco_BB1 = 0;
   string txt_bb_2 = "~~~~~~ BBands_2 ~~~~~~";
   int on_off_BB2 = 1;
   int type_BB2 = 1;
   int revers_BB2 = 1;
   int periodo_BB2 = 20;
   double desvt_BB2 = 2.0;
   int shift_BB2 = 0;
   int preco_BB2 = 0;
   string txt_bb_3 = "";
   string txt_bb_f1 = "~~~~~~ Filtro de largura de BBands ~~~~~~";
   int on_off_BBf = 1;
   int revers_chBB = 1;
   int periodo_BBf = 20;
   double deviat_BBf = 2.0;
   int shift_BBf = 0;
   double price_BBf = 0;
   int skip_bar = 3;
   int sens = 5;
   string txt_bb_f2 = "";
   string txt20 = "~~~~~~ Envelopes ~~~~~~";
   int on_off_Env = 1;
   int type_Env = 1;
   int revers_Env = 1;
   int period_Env = 14;
   double desvt_Env = 0.1;
   int shift_Env = 0;
   int methMA_Env = 0;
   int price_Env = 0;
   string txt22 = "";
   double rollback = 0.0;
   int filtr_bar = 2;
   int wait_bar = 0;
   int to_arrow = 0;
   string txt25 =  "";
   string txt26 = "___ Filtros de tempo ___";
   int time_type = 1;
   string hour_filtr = "";
   string minut_filtr = "";
   string txt27 = "";
   string txt28 = "___ Estatisticas (para BO) ___";
   int statistika = 1;
   int cntMinut = 20;
   int cnt_bars = 1000;
   int expir = 1;
   string txt29 = "";
   int ots = 10;
   int AlertSound = 0;
   string txt30 = "";
   int AlertMail = 1;
   int AlertNotif = 1;
   int mail_type = 0;

   //** Fim Parâmetros 

*/