//+------------------------------------------------------------------+
//|                                                     WPR+BAND.mq4 |
//|                                                   Ozires da Cruz |
//|                                                                  |
//+------------------------------------------------------------------+

#define VERSION "1.3"

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

 //---- Buffer Arrays
 double ExtMapBuffer1[];
 double ExtMapBuffer2[];

extern bool ShowAlert = false;
extern bool CopyToClipboard = true;
extern bool HillFilter = true;
extern bool WCCIFilter = true;
extern double BandDeviation = 2.4;

datetime ArrayTime[], LastTime;
int BUY_SIGNAL = 0;
int SELL_SIGNAL = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int WPR_1 = 4;
int WPR_2 = 7;
int WPR_3 = 10;
int WPR_4 = 14;
int WPR_5 = 21;
double Ur_max = 2.0;
double Ur_min = 98.0;
int idk = 5;
bool Alert_MT4 = false;
bool Alert_Email = false;
bool Alert_Mobile = false;

string hill = "Hill no repaint+Arrows1";
string wcci = "Weighted WCCI indikatorforeks.ru";
string fxr_sr_zones = "fxr_sr_zones";

int OnInit()
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
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   if (NewBar(Period())) 
   {
    
      if (HasSignal(BUY_SIGNAL))      
      {
         DrawThumbsUpUp();
      }
                    
      if (HasSignal(SELL_SIGNAL)) 
      {
         DrawThumbsUpDown();
      }

   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void DrawThumbsUpDown()
{ 
   //DrawThumbsUp(SYMBOL_ARROWDOWN, "Down " + IntegerToString(Bars), High[1] + 10 * Point, Red, 4);      
   ShowMsg("PUT");
   ExtMapBuffer2[1] = High[1];
}
//+------------------------------------------------------------------+
void DrawThumbsUpUp()
{
   //DrawThumbsUp(SYMBOL_ARROWUP, "Up " + IntegerToString(Bars), Low[1] - 10 * Point, Green, 4);
   ShowMsg("CALL");
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

   if (ShowAlert)
   {
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

//+------------------------------------------------------------------+
bool HasSignal(int BUY_SELL) 
{
   string my_holy_grail = "My Holy Grail";
   string tt_alert_1 = "TT Alert 1";

   double mhg_value0=0;
   double ta1_value0=0;
   bool mhg_signal = false;
   bool ta1_signal = false;
   
   mhg_value0 = iCustom(NULL,5,my_holy_grail, BUY_SELL,1);
   ta1_value0 = iCustom(NULL,5,tt_alert_1, BUY_SELL,1);
   
   mhg_signal = !((mhg_value0 == 0) || (mhg_value0 == EMPTY_VALUE)); // yellow
   ta1_signal = !((ta1_value0 == 0) || (ta1_value0 == EMPTY_VALUE)); // black 
   
   return mhg_signal && ta1_signal;
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

/*
void ShowLabel(string text, int x, int y) 
{
   ObjectCreate("ObjName" + x + y, OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjName"  + x + y,text,7, "Verdana", Yellow);
   //ObjectSet("ObjName" + x + y, OBJPROP_CORNER, 0);
   ObjectSet("ObjName" + x + y, OBJPROP_XDISTANCE, x);
   ObjectSet("ObjName" + x + y, OBJPROP_YDISTANCE, y);
}
*/