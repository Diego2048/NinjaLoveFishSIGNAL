//+------------------------------------------------------------------+
//|                                          NinjaLoveFishSIGNAL.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//#define __DEBUG__

#define Version "1.14"
#define EAName "NinjaLoveFishSIGNAL"

#property strict
#property version Version
#property copyright "Copyright @2018, Qin Zhao"
#property link "https://www.mql5.com/en/users/zq535228"
#property icon "3232.ico"
#property indicator_chart_window

#include <stderror.mqh>
#include <stdlib.mqh>
#include "comm.mqh"
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   BG();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll();
  }

//调用此函数就可以快速的设置货币兑.
int n=1;
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

   Symb("AUDCAD");
   Symb("AUDNZD");
   Symb("EURCAD");
   Symb("EURCHF");
   Symb("EURGBP");
   Symb("EURSGD");
   Symb("EURUSD");
   Symb("GBPAUD");
   Symb("GBPCAD");
   Symb("GBPCHF");
   Symb("NZDCAD");
   Symb("NZDUSD");
   Symb("USDSGD");
   Symb("==");

   Symb("_DXY");
   Symb("AUDCHF");
   Symb("AUDJPY");
   Symb("AUDUSD");
   //Symb("CADCHF");
   //Symb("CADJPY");
   //Symb("CHFJPY");
   Symb("EURAUD");
   Symb("EURJPY");
   Symb("EURNZD");
   Symb("GBPJPY");
   Symb("GBPNZD");
   //Symb("GBPSGD");
   Symb("GBPUSD");
   Symb("NZDCHF");
   Symb("NZDJPY");
   Symb("NZDSGD");
   Symb("USDCAD");
   //Symb("USDCHF");
   Symb("USDJPY");

   ObjectSetInteger(0,Symbol(),OBJPROP_BGCOLOR,clrGreenYellow);//设置当前的货币兑btn的颜色.

   n=1;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   double h=0;
//--- If you click on the object with the name buttonID
   if(id==CHARTEVENT_OBJECT_CLICK && ObjectGetInteger(0,sparam,OBJPROP_STATE))
     {
      bool selected1=ObjectGetInteger(0,sparam,OBJPROP_STATE);
      Print(Period());
      //dump(PERIOD_CURRENT);
      if(Symbol()==sparam && Period()==PERIOD_H4)
        {
         ChartSetSymbolPeriod(0,sparam,PERIOD_W1);
        }
      else
        {
         ChartSetSymbolPeriod(0,sparam,PERIOD_H4);
        }

      ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
      ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrGreenYellow);
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

   if(Ma_Bid_Diff > 2000 && b > ma) cc = 100;
   if(Ma_Bid_Diff > 2000 && b < ma) cc = 0;

   label(sy+"MA","MA",cc,230,btop+m*n);

   btn(sy,280,btop+m*n);

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
   ObjectSet(name,OBJPROP_XDISTANCE,-810);
   ObjectSet(name,OBJPROP_YDISTANCE,0);
//---
  }
//+------------------------------------------------------------------+
