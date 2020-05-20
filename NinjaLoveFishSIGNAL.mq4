//+------------------------------------------------------------------+
//|                                          NinjaLoveFishSIGNAL.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//#define __DEBUG__

#define Version "1.18"
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

extern int               FilterPairsNum=1;
extern int               mnb = 123;
extern int               mns = 321;
extern ENUM_TIMEFRAMES   TMVIEW= PERIOD_W1;
extern ENUM_TIMEFRAMES   TMEXE = PERIOD_H4;


int n=1;                    //一行的行数。
double ps = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStartLot()
  {
   double earn=((MathAbs(0.00230)/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKVALUE));
   double re=AccountBalance()/500/earn-0.002;

   if(StringFind(Symbol(),"GBP")!=-1 || StringFind(Symbol(),"XAU")!=-1)
     {
      re = 0.03;
     }
   if(StringFind(Symbol(),"JPY")!=-1)
     {
      re = 0.01;
     }

   return(re);
  }


//--------------------------------------------------------------------
int OnInit() // Special function init()
  {
   BG();

   ps=MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)/100000;

   ObjectCreate(0,"LOT",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"LOT",OBJPROP_XDISTANCE,500+180);
   ObjectSetInteger(0,"LOT",OBJPROP_YDISTANCE,20);
   ObjectSetString(0,"LOT",OBJPROP_TEXT,"Lots:"+DoubleToStr(GetStartLot(),2));
   ObjectSetInteger(0,"LOT",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"LOT",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"LOT",OBJPROP_XSIZE,70);

   ObjectCreate(0,"BUY",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"BUY",OBJPROP_XDISTANCE,500);
   ObjectSetInteger(0,"BUY",OBJPROP_YDISTANCE,20);
   ObjectSetString(0,"BUY",OBJPROP_TEXT,"BUY");
   ObjectSetInteger(0,"BUY",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"BUY",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"BUY",OBJPROP_XSIZE,70);
//ObjectSetString(0,"BUY",OBJPROP_FONT,"Calibri");


   if(MarketInfo(Symbol(),MODE_SWAPLONG)>0)
     {
      ObjectSetInteger(0,"BUY",OBJPROP_BGCOLOR,clrChartreuse);
      ObjectSetString(0,"BUY",OBJPROP_TEXT,"BUY +"+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),1));
     }
   else
     {
      ObjectSetInteger(0,"BUY",OBJPROP_BGCOLOR,clrLightSalmon);
      ObjectSetString(0,"BUY",OBJPROP_TEXT,"BUY "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),1));
     }

   ObjectCreate(0,"SELL",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"SELL",OBJPROP_XDISTANCE,500+90);
   ObjectSetInteger(0,"SELL",OBJPROP_YDISTANCE,20);
   ObjectSetString(0,"SELL",OBJPROP_TEXT,"SELL");
   ObjectSetInteger(0,"SELL",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"SELL",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"SELL",OBJPROP_XSIZE,70);

   if(MarketInfo(Symbol(),MODE_SWAPSHORT)>0)
     {
      ObjectSetInteger(0,"SELL",OBJPROP_BGCOLOR,clrChartreuse);
      ObjectSetString(0,"SELL",OBJPROP_TEXT,"SELL +"+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),1));
     }
   else
     {
      ObjectSetInteger(0,"SELL",OBJPROP_BGCOLOR,clrLightSalmon);
      ObjectSetString(0,"SELL",OBJPROP_TEXT,"SELL "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),1));
     }

   ObjectCreate(0,"CLR",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CLR",OBJPROP_XDISTANCE,500+270);
   ObjectSetInteger(0,"CLR",OBJPROP_YDISTANCE,20);
   ObjectSetString(0,"CLR",OBJPROP_TEXT,"CLR");
   ObjectSetInteger(0,"CLR",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"CLR",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"CLR",OBJPROP_XSIZE,70);

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {

   label(EA,EA,50,60,5);

   Symb("txt机会货币兑如下：");
   Symb("AUDCAD");
   Symb("AUDNZD");
   Symb("AUDCHF");
   Symb("EURAUD");
   Symb("EURCAD");
   Symb("EURCHF");
   Symb("EURGBP");
   Symb("EURUSD");
   Symb("NZDCAD");
   Symb("USDSGD");
   Symb("USDCAD");
   Symb("==");
   Symb("USDJPY");
   Symb("GBPCAD");
   Symb("GBPAUD");
   Symb("XAUUSD");
   Symb("==");

   aorders();//现有仓位列表

   ObjectSetInteger(0,Symbol(),OBJPROP_BGCOLOR,clrGreenYellow);//设置当前的货币兑btn的颜色.
   ObjectSetInteger(0,Symbol()+".",OBJPROP_BGCOLOR,clrGreenYellow);//设置当前持仓货币兑btn的颜色.

   label("Comm0","买点：寻找内部结构的对称点，估算挂单，考虑止损跨度。",50,30,10+25*(n+1));
   label("Comm1","开仓：GPB和JPY开仓RSI指标M5周期12，其他货币兑为8。",50,30,10+25*(n+2));
   label("Comm2","止损：仓位（0.01/2300），一般情况下可以接受2000-2500的跨度！",50,30,10+25*(n+3));
   label("Comm3","切记：一切皆有可能的价格，被套三层再开新网格，本金重要！",50,30,10+25*(n+4));

   label("Comm4",Symbol()+"价值系数："+DoubleToStr(ps,5),50,30,10+25*(n+5));

   n=1;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//ObjectsDeleteAll();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void aorders()
  {
   Symb("txt现有仓位如下：");

   string a;

   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
         if(StringFind(a,OrderSymbol())==-1)
           {
            a+=OrderSymbol()+",";
           }
        }
     }

   string result[];
   int k=StringSplit(a,',',result);

   for(int i=0; i<k; i++)
     {
      if(result[i]!="")
        {
         Symb2(result[i]);
        }
     }

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EA=EAName+" v"+Version+" "+Symbol()+" "+getPeriodName();
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
      string sy=StringSubstr(sparam,0,6);

      if(Symbol()==sy && Period()==TMVIEW)
        {
         ChartSetSymbolPeriod(0,sy,TMEXE);
        }
      else
        {
         ChartSetSymbolPeriod(0,sy,TMVIEW);
        }

      if("CLR"==sy)
        {
         ObjectsDeleteAll();
         OnInit();
         start();
        }
      else
        {
         ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
         ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrGreenYellow);

        }
      Print(sparam);

     }
//键盘向右，就是打开
   if(id==CHARTEVENT_KEYDOWN)
     {
      if((int)lparam==39)
        {
         ChartOpen(Symbol(),TMEXE);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void btn(string name,int x,int y)
  {
   ObjectDelete(0,name);
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

   if(rsi>60)
      cc = clrRed;
   if(rsi<40)
      cc = clrBlue;

   ObjectSetText(name,value,10,"Calibri",cc);
   if(StringFind(name,"Nin")!=-1)
     {
      ObjectSetText(name,value,12,"Calibri",cc);
     }
   if(StringFind(name,"Comm")!=-1)
     {
      ObjectSetText(name,value,8,"Calibri",cc);
     }
   if(StringFind(name,"txt")!=-1)
     {
      ObjectSetText(name,value,8,"Calibri",cc);
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
   int pnum;

   if(mnb>0 && mns>0)
     {
      pnum=GetPositionExistNum(sy,mnb)+GetPositionExistNum(sy,mns);
     }
   else
     {
      pnum=GetPositionExistNum(sy);
     }

   if(pnum>=FilterPairsNum)
     {
      return;
     }

   double b=MarketInfo(sy,MODE_BID);
   int m=25;//竖行的距离.
   int btop=10;

   if(sy=="==")
     {
      label(sy+"==","",50,0,btop+m*n);
      n++;
      return;
     }

   if(StringFind(sy,"txt")!=-1)
     {
      StringReplace(sy,"txt","");
      label("txt"+IntegerToString(n),sy,50,30,btop+m*n);
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

   if(Ma_Bid_Diff > 1500 && b > ma)
      cc = 100;
   if(Ma_Bid_Diff > 1500 && b < ma)
      cc = 0;

   label(sy+"MA","MA",cc,230,btop+m*n);

   double sp=(int)MarketInfo(sy,MODE_SPREAD);
//统计当前的货币兑点差
//label(sy+"SP",DoubleToStr(sp,0),50,280,btop+m*n);
//统计持仓货币的数量
   label(sy+"pnum",DoubleToStr(pnum,0),50,280,btop+m*n);

   btn(sy,320,btop+m*n);

   n++;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Symb2(string sy)
  {
   int pnum=GetPositionExistNum(sy);
   double b=MarketInfo(sy,MODE_BID);
   int m=25;//竖行的距离.
   int btop=10;

   double rsi15=iRSI(sy,PERIOD_M15,8,PRICE_CLOSE,0);
   label(sy+"cM15","M15",rsi15,30,btop+m*n);
   double rsi30=iRSI(sy,PERIOD_M30,8,PRICE_CLOSE,0);
   label(sy+"cM30","M30",rsi30,80,btop+m*n);
   double rsi4h=iRSI(sy,PERIOD_H4,8,PRICE_CLOSE,0);
   label(sy+"cH4","H4",rsi4h,130,btop+m*n);
   double rsid1=iRSI(sy,PERIOD_D1,8,PRICE_CLOSE,0);
   label(sy+"cD1","D1",rsid1,180,btop+m*n);

   double cc=50;
   double ma=iMA(sy,PERIOD_H4,700,0,MODE_SMMA,PRICE_CLOSE,0);
   double Ma_Bid_Diff=MathAbs(ma-b)/MarketInfo(sy,MODE_POINT);

   if(Ma_Bid_Diff > 1500 && b > ma)
      cc = 100;
   if(Ma_Bid_Diff > 1500 && b < ma)
      cc = 0;

   label(sy+"cMA","MA",cc,230,btop+m*n);

   double sp=(int)MarketInfo(sy,MODE_SPREAD);

   label(sy+"cpnum",DoubleToStr(pnum,0),50,280,btop+m*n);

   btn(sy+".",320,btop+m*n);

   n++;

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
