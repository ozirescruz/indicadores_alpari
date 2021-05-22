//+------------------------------------------------------------------+
//|                                                     WPR+BAND.mq4 |
//|                                                   Ozires da Cruz |
//|                                                                  |
//+------------------------------------------------------------------+

#define VERSION "BK REVERSE 1.2 - Check FAN AND TREND"

#property copyright "Ozires da Cruz"
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
#import

 //---- Buffer Arrays
 double ExtMapBuffer1[];
 double ExtMapBuffer2[];

extern bool ShowAlert = true;

datetime ArrayTime[], LastTime;
int BUY_SIGNAL = 0;
int SELL_SIGNAL = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
bool Alert_MT4 = false;
bool Alert_Email = false;
bool Alert_Mobile = false;
int MaxBars = 500;

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
   
   SetCommentText("Version: " + VERSION);
   
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
         long ChartNm = ChartID();
         int SubWin = 0;
         string AssetName = Symbol();
         int Per = Period();
         int Shft = 1;
         datetime GimmeTime = iTime(AssetName,Per,Shft);
         double LowPrice    = iLow(AssetName,Per,Shft);
         double HighPrice   = iHigh(AssetName,Per,Shft);
         double ClosePrice  = iClose(AssetName,Per,Shft);
         int hwnd           = WindowHandle(Symbol(),Period());
         int hdc            = GetDC(hwnd);
         
         int x,y;
         
         //--
         ChartTimePriceToXY(ChartNm,SubWin,GimmeTime,ClosePrice,x,y);              
         color close_price_bg = GetPixel(hdc,x,y);
         //---               
   
         //--
         ChartTimePriceToXY(ChartNm,SubWin,GimmeTime,LowPrice,x,y);              
         color low_price_bg = GetPixel(hdc,x,y);
         //--
              
         //if (low_price_bg == clrRoyalBlue && close_price_bg == clrBlack && Close[Shft] < Open[Shft]) 
         {
            //if (CandleWickOK(Shft, BUY_SIGNAL))
            if (FractalSignal(SELL_SIGNAL) && _4X4Signal(0) && OKFan(Shft) && LastNo4X4Signal(0))
            {
               DrawThumbsUpUp();
            }
            
            if (FractalSignal(SELL_SIGNAL) && _4X4Signal(0) && UpTrend() && LastNo4X4Signal(0))
            {
               DrawThumbsUpUp();
            }

         }
         
         //--
         ChartTimePriceToXY(ChartNm,SubWin,GimmeTime,HighPrice,x,y);              
         color high_price_bg = GetPixel(hdc,x,y);
         //--
                              
         //if (high_price_bg == clrCrimson && close_price_bg == clrBlack && Close[Shft] > Open[Shft]) 
         {
            //if (CandleWickOK(Shft, SELL_SIGNAL))
            if (FractalSignal(BUY_SIGNAL) && _4X4Signal(1) && OKFan(Shft)  && LastNo4X4Signal(1))
            {
               DrawThumbsUpDown();
            }
            
            if (FractalSignal(BUY_SIGNAL) && _4X4Signal(1) && DownTrend()  && LastNo4X4Signal(1))
            {
               DrawThumbsUpDown();
            }

         }
   
          ReleaseDC(hwnd,hdc);
      
   }
//--- return value of prev_calculated for next call
   return(0);
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

