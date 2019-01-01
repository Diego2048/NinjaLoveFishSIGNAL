//+------------------------------------------------------------------+
//|                                                 comm_signals.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignal_RSI()
  {
   int Signal=0;
   if(iRSI(Symbol(),PERIOD_M5,RSIPeriod,PRICE_CLOSE,0)>RSIsell)
     {
      Signal=-1;
     }
   if(iRSI(Symbol(),PERIOD_M5,RSIPeriod,PRICE_CLOSE,0)<RSIbuy)
     {
      Signal=1;
     }

   return Signal;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSignal_BB_UPPER(int shift)
  {
   double top=iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   return top;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSignal_BB_LOWER(int shift)
  {
   double bom=iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_LOWER,shift);
   return bom;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSignal_BB_Width(int shift)
  {
   double top = iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   double bom = iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_LOWER,shift);

   double re=MathAbs(top-bom)/vPoint;

   return re;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSignal_BB(int shift)
  {
   double l1 = iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_MAIN,shift+5);
   double l  = iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_MAIN,shift);
   double l0 = iBands(Symbol(),PERIOD_M5,17,2,0,PRICE_CLOSE,MODE_MAIN,shift-5);

   if(l0<l && l<l1 && Ask<l1 && Ask<l0)
     {
      return 1;//buy
     }
   if(l0>l && l>l1 && Bid>l1 && Bid>l0)
     {
      return -1;
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSignal_ATR(int InpAtrPeriod)
  {
   return(iCustom(Symbol(),PERIOD_M5, "ATR", InpAtrPeriod, 0, 0));
  }
//===================================================================================================================================================
//===================================================================================================================================================
int GetSignaliMA(int iMA_Period,double iMA_OpenDistance)
  {
   int Signal=0;

   double iMA_Signal=iMA(Symbol(),PERIOD_M5,iMA_Period,0,MODE_LWMA,PRICE_CLOSE,0);

   double Ma_Bid_Diff=MathAbs(iMA_Signal-Bid)/vPoint;

   if(Ma_Bid_Diff > iMA_OpenDistance && Bid > iMA_Signal) Signal = -1;
   if(Ma_Bid_Diff > iMA_OpenDistance && Bid < iMA_Signal) Signal = 1;

   return(Signal);
  }
//+------------------------------------------------------------------+
