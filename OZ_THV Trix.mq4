//+------------------------------------------------------------------+
//|                                                     WPR+BAND.mq4 |
//|                                                   Ozires da Cruz |
//|                                                                  |
//+------------------------------------------------------------------+

#define VERSION "1.0"

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
int BUY_SIGNAL = 4;
int SELL_SIGNAL = 5;
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
   
   SetCommentText("OZ_THV - Version: " + VERSION);
   
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
         if (THVSignal(BUY_SIGNAL) && StochTrendSignal(2))
         {
            DrawThumbsUpUp(1);
         }

         if (THVSignal(SELL_SIGNAL) && StochTrendSignal(3))
         {
            DrawThumbsUpDown(1);
         }
     
   }
//--- return value of prev_calculated for next call
   return(0);
}
//+------------------------------------------------------------------+
void DrawThumbsUpDown(int i)
{ 
   //DrawThumbsUp(SYMBOL_ARROWDOWN, "Down " + IntegerToString(Bars), High[1] + 10 * Point, Red, 4);      
   ShowMsg("PUT");
   ExtMapBuffer2[i] = High[i];
}
//+------------------------------------------------------------------+
void DrawThumbsUpUp(int i)
{
   //DrawThumbsUp(SYMBOL_ARROWUP, "Up " + IntegerToString(Bars), Low[1] - 10 * Point, Green, 4);
   ShowMsg("CALL");
   ExtMapBuffer1[i] = Low[i];
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
bool THVSignal(int BUY_SELL) 
{
   string ind = "THV Trix v6.01";
   double dValue0=0;

   dValue0 = iCustom(NULL, 5, ind, BUY_SELL,2);
   
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
//s-StochTrend!!!!!!!
//+------------------------------------------------------------------+
bool StochTrendSignal(int BUY_SELL) 
{
   string ind = "s-StochTrend!!!!!!!";
   double dValue0=0;

   dValue0 = iCustom(NULL, 5, ind, BUY_SELL,2);
   
   return !((dValue0 == 0) || (dValue0 == EMPTY_VALUE));
}
