//+------------------------------------------------------------------+
//|                                             CPatternDetector.mqh |
//|                                    Copyright 2017, Erwin Beckers |
//|                                      https://www.erwinbeckers.nl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Erwin Beckers"
#property link      "https://www.erwinbeckers.nl"
#property strict

input string __pinbar__                = "------ Candle stick patterns ------"; 
input bool   DrawPinBars               = true;
input bool   DrawInsideBars            = true;
input bool   DrawDoubleBarReversal     = true;
input bool   DrawTrippleBarReversal    = true;
input bool   DrawReversalBars          = true;
input bool   DrawFakey                 = true;
input bool   DrawDoji                  = true;
input int    PipsMargin                = 5;

input string __sizefilter__            = "------ Bar size filter ------"; 
input bool   BarSizeFilterEnabled      = true;

input string __hilofilter__            = "------ Swing hi/lo filter ------"; 
input bool   SwingHiLoFilterEnabled    = true;
input int    SwingHighLowBars          = 5;

input string __srfilter__              = "------ Support/Resistance filter ------"; 
input bool   UseSRFilter               = false;
input int    PipsFromSRMargin          = 10;

bool     refresh=false;
datetime _prevTime;

#include <Patterns\CCandleSizeFilter.mqh>;
#include <Patterns\CSwingHiLoFilter.mqh>;
#include <Patterns\CSRFilter.mqh>;

#include <Patterns\CDojiPattern.mqh>;
#include <Patterns\CDoubleReversalPattern.mqh>;
#include <Patterns\CInsideBarPattern.mqh>;
#include <Patterns\CPinbarPattern.mqh>;
#include <Patterns\CTrippleReversalPattern.mqh>;
#include <Patterns\CReversalPattern.mqh>;
#include <Patterns\IPatternDetector.mqh>;

//+------------------------------------------------------------------+
class CPatternDetector
{
private:
   int                     _period;
   IPatternDetector*       _patterns[];
   int                     _patternCount;
   
   IPatternDetector*       _filters[];
   int                     _filterCount;
   
public:   
   //+------------------------------------------------------------------+
   CPatternDetector(int period)
   {
      _period       = 0;
      _patternCount = 0;
      _filterCount  = 0;
      
      ArrayResize(_patterns, 20);
      if (DrawReversalBars) _patterns[_patternCount++] = new CReversalPattern(_period);
      if (DrawTrippleBarReversal) _patterns[_patternCount++] = new CTrippleReversalPattern(_period, PipsMargin);
      if (DrawDoubleBarReversal) _patterns[_patternCount++] = new CDoubleReversalPattern(_period, PipsMargin);
      if (DrawPinBars) _patterns[_patternCount++] = new CPinbarPattern(_period);
      if (DrawInsideBars) _patterns[_patternCount++] = new CInsideBarPattern(_period);
      if (DrawDoji) _patterns[_patternCount++] = new CDojiPattern(_period);
      
      ArrayResize(_filters, 20);
      if (BarSizeFilterEnabled) _filters[_filterCount++] = new CCandleSizeFilter(_period);
      if (SwingHiLoFilterEnabled) _filters[_filterCount++] = new CSwingHiLoFilter(_period, SwingHighLowBars);
      if (UseSRFilter) _filters[_filterCount++] = new CSRFilter(_period, PipsFromSRMargin);
   }
   
   //+------------------------------------------------------------------+
   ~CPatternDetector()
   {
      for (int i=0; i < _patternCount; ++i)
      {
         delete _patterns[i];
      }
      ArrayFree (_patterns);
      
      for (int i=0; i < _filterCount; ++i)
      {
         delete _filters[i];
      }
      ArrayFree (_filters);
   }
   
   //+------------------------------------------------------------------+
   bool PassesFilter(int bar)
   {
      for (int i=0; i < _filterCount; ++i)
      {
         if (! _filters[i].IsValid(bar)) return false;
      }
      return true;
   }
   
   //+------------------------------------------------------------------+
   bool IsValidPattern(int bar, string& patternName, color& clr)
   {
      for (int i=0; i < _patternCount; ++i)
      {
         if ( _patterns[i].IsValid(bar) ) 
         {
            patternName = _patterns[i].PatternName();
            clr         = _patterns[i].PatternColor();
            return true;
         }
      }
      return false;
   }
};

