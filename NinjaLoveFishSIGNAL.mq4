//+------------------------------------------------------------------+
//|                                          NinjaLoveFishSIGNAL.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//#define __DEBUG__

#define Version "1.17"
#define EAName "NinjaLoveFishSIGNAL"

#property strict
#property version Version
#property copyright "Copyright @2018, Qin Zhao"
#property link "https://www.mql5.com/en/users/zq535228"
#property icon "3232.ico"
#include <stderror.mqh>
#include <stdlib.mqh>
#include "comm.mqh"

#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 1       // Number of buffers
#property indicator_color1 Blue     // Color of the 1st line

extern bool              FilterPairs          = true;



double Buf_0[];             // Declaring arrays (for indicator buffers)
int n=1;                    //一行的行数。
//--------------------------------------------------------------------
int OnInit() // Special function init()
  {
   BG();
   SetIndexBuffer(0,Buf_0);         // Assigning an array to a buffer
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);// Line style
   return 0;                          // Exit the special funct. init()
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int i,Counted_bars;                // Number of counted bars
   Counted_bars=IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;           // Index of the first uncounted
   while(i>=0)                      // Loop for uncounted bars
     {
      Buf_0[i]=iMA(Symbol(),PERIOD_H4,700,0,MODE_SMMA,PRICE_CLOSE,i);
      i--;                          // Calculating index of the next bar
     }

   Symb("AUDCAD");
   Symb("AUDNZD");
   Symb("EURCAD");
   Symb("EURCHF");
   Symb("EURGBP");
//Symb("EURSGD");
   Symb("EURUSD");
   Symb("GBPAUD");
   Symb("GBPCAD");
   Symb("GBPCHF");
   Symb("NZDCAD");
   Symb("NZDUSD");
   Symb("USDSGD");
   Symb("==");

//Symb("_DXY");
   Symb("AUDCHF");
   Symb("AUDJPY");
   Symb("AUDUSD");
   Symb("CADCHF");
   Symb("CADJPY");
//Symb("CHFJPY");
   Symb("EURAUD");
   Symb("EURJPY");
   Symb("EURNZD");
   Symb("GBPJPY");
//Symb("GBPNZD");
//Symb("GBPSGD");
   Symb("GBPUSD");
   Symb("NZDCHF");
   Symb("NZDJPY");
//Symb("NZDSGD");
   Symb("USDCAD");
//Symb("USDCHF");
   Symb("USDJPY");
   Symb("XAUUSD");

   ObjectSetInteger(0,Symbol(),OBJPROP_BGCOLOR,clrGreenYellow);//设置当前的货币兑btn的颜色.

   n=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getPeriodName()
  {
   int p=Period();

   if(p==240)
     {
      return "H4";
     }
   if(p==10080)
     {
      return "W";
     }
   return IntegerToString(p);
  }
//+------------------------------------------------------------------+

string EA=EAName+" v"+Version+" "+Symbol()+" "+getPeriodName();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   double h=0;
//--- If you click on the object with the name buttonID
   if(id==CHARTEVENT_OBJECT_CLICK && ObjectGetInteger(0,sparam,OBJPROP_STATE))
     {
      bool selected1=ObjectGetInteger(0,sparam,OBJPROP_STATE);
      if(Symbol()==sparam && Period()==PERIOD_D1)
        {
         ChartSetSymbolPeriod(0,sparam,PERIOD_H4);
        }
      else
        {
         ChartSetSymbolPeriod(0,sparam,PERIOD_D1);
        }

      ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
      ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrGreenYellow);

     }
//键盘向右，就是打开
   if(id==CHARTEVENT_KEYDOWN)
     {
      if((int)lparam==39)
        {
         ChartOpen(Symbol(),PERIOD_H4);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void btn(string name,int x,int y)
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,name);
//ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrTomato);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
//ObjectSetString(0,name,OBJPROP_TOOLTIP,name);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,80);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,20);

   string sym1 = StringSubstr(Symbol(),0,3);
   string sym2 = StringSubstr(Symbol(),3,6);
   if((StringFind(name,sym1)!=-1 || StringFind(name,sym2)!=-1))
     {
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrPaleTurquoise);//设置当前的货币兑btn的颜色.
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void label(string name,string value,double rsi,int x,int y)
  {

   int windows=0;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,windows,0,0);
   color cc=clrWhite;

   if(rsi>70) cc = clrRed;
   if(rsi<30) cc = clrBlue;

   ObjectSetText(name,value,10,"Calibri",cc);
   if(StringFind(name,"NinjaLoveFish")!=-1)
     {
      ObjectSetText(name,value,12,"Calibri",cc);
     }
   ObjectSet(name,OBJPROP_CORNER,ANCHOR_LEFT_UPPER);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSet(name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,name);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Symb(string sy)
  {
   int pnum = GetPositionExistNum(sy);
   if(FilterPairs)
     {
      if(pnum>=1)
        {
         return;
        }
     }

   label(EA,EA,50,60,5);
   double b=MarketInfo(sy,MODE_BID);
   int m=25;//竖行的距离.
   int btop=10;

   if(sy=="==")
     {
      label(sy+"==","",50,0,btop+m*n);
      n++;
      return;
     }

   double rsi15=iRSI(sy,PERIOD_M15,8,PRICE_CLOSE,0);
   label(sy+"M15","M15",rsi15,30,btop+m*n);
   double rsi30=iRSI(sy,PERIOD_M30,8,PRICE_CLOSE,0);
   label(sy+"M30","M30",rsi30,80,btop+m*n);
   double rsi4h=iRSI(sy,PERIOD_H4,8,PRICE_CLOSE,0);
   label(sy+"H4","H4",rsi4h,130,btop+m*n);
   double rsid1=iRSI(sy,PERIOD_D1,8,PRICE_CLOSE,0);
   label(sy+"D1","D1",rsid1,180,btop+m*n);

   double cc=50;
   double ma=iMA(sy,PERIOD_H4,700,0,MODE_SMMA,PRICE_CLOSE,0);
   double Ma_Bid_Diff=MathAbs(ma-b)/MarketInfo(sy,MODE_POINT);

   if(Ma_Bid_Diff > 1500 && b > ma) cc = 100;
   if(Ma_Bid_Diff > 1500 && b < ma) cc = 0;

   label(sy+"MA","MA",cc,230,btop+m*n);

   double sp=(int)MarketInfo(sy,MODE_SPREAD);
   //统计当前的货币兑点差
   label(sy+"SP",DoubleToStr(sp,0),50,280,btop+m*n);
   //统计持仓货币的数量
   label(sy+"pnum",DoubleToStr(pnum,0),50,320,btop+m*n);

   btn(sy,350,btop+m*n);

   n++;

  }
//+------------------------------------------------------------------+

void BG()
  {
   string name="name";
   string value="g";

   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSetText(name,value,900,"Webdings",clrBlack);
   ObjectSet(name,OBJPROP_CORNER,ANCHOR_LEFT_UPPER);
   ObjectSet(name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
//ObjectSetString(0,name,OBJPROP_TOOLTIP,"NinjaLoveFishSIGNAL");
   ObjectSet(name,OBJPROP_SELECTABLE,0);
   ObjectSet(name,OBJPROP_XDISTANCE,-780);
   ObjectSet(name,OBJPROP_YDISTANCE,0);
//---
  }
//+------------------------------------------------------------------+
