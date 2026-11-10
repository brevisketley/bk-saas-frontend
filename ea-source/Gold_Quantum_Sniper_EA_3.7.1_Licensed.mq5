//+------------------------------------------------------------------+
//| Gold Quantum Sniper EA.mq5                                       |
//| BK Corp Club                                                     |
//+------------------------------------------------------------------+
#property strict
#property version   "6.71"
#property description "Gold Quantum Sniper EA v6.71 (MT5)"
#property description ""
#property description "BK Corp Club Proprietary Trading System"
#property description ""
#property description "High-probability execution model"
#property description "Multi-layer trade system"
#property description "Adaptive risk management"
#property description ""
#property description "Core Features:"
#property description "Precision entry logic"
#property description "Multi-trade handling"
#property description "Adaptive trailing system"
#property description "Market condition awareness"
#property description ""
#property description "Execution:"
#property description "Real-time market evaluation"
#property description "Automated trade deployment"
#property description "Position scaling protection"
#property description ""
#property description "Optimized for MT5"
#property description "Gold Trading System"
#property description "BK Corp Club"

//================ LOCKED SETTINGS =================//
#define EA_NAME               "Gold Quantum Sniper EA"
#define EA_PRODUCT_ID         "ff58ca0c-1b6e-406d-95bc-e8ae24bb27bd" // immutable BK licensing product UUID; one binary per EA product

#define LOT_SIZE              0.01

#define MAX_TRADES_CHART      10

// SL is now a user-selectable input, independent per style (see
// "Risk Options" group below) - SL_USD define removed.
// TP intentionally removed - trade runs until the trailing stop is hit.

// Each trading style below has its own fixed magic number so trades from
// both can run concurrently and be told apart in the terminal / history.
#define MAGIC_STANDARD         20240403
#define MAGIC_AGGRESSIVE       20240404

// Core signal logic (BK Corp Club standard, Section 2) - locked, identical
// across the whole EA family. Not adjustable inputs. Shared by both styles.
#define RSI_PERIOD             14
#define EMA_PERIOD             20
#define RSI_BULL_LEVEL         55.0
#define RSI_BEAR_LEVEL         45.0
#define SIGNAL_TIMEFRAME       PERIOD_M15

// Opt-in H1 trend-confirmation layer (see "Trend Confirmation" input group
// below). Timeframe itself is locked; only whether each style requires it
// is an input.
#define TREND_TIMEFRAME        PERIOD_H1
//=================================================//

//================= TRADING STYLE =================//
enum ENUM_YESNO
{
   OPT_NO  = 0, // No
   OPT_YES = 1  // Yes
};

input group "Trading Style"
input ENUM_YESNO InpStandard   = OPT_YES; // Standard (Magic 20240403)
input ENUM_YESNO InpAggressive = OPT_NO;  // Aggressive (Magic 20240404)
//=================================================//

//================= RISK OPTIONS =================//
enum ENUM_SL_OPTION
{
   SL_5  = 5,  // -$5 SL
   SL_10 = 10, // -$10 SL
   SL_25 = 25  // -$25 SL
};

input group "BK Corp Club Licence"
input string InpLicenseKey = ""; // Enter the licence key supplied by BK Corp Club

input group "Risk Options"
input ENUM_SL_OPTION InpSLOptionStandard   = SL_5; // Standard SL (Magic 20240403)
input ENUM_SL_OPTION InpSLOptionAggressive = SL_5; // Aggressive SL (Magic 20240404)
//=================================================//

//============== TREND CONFIRMATION ==============//
input group "Trend Confirmation"
input ENUM_YESNO InpTrendStandard   = OPT_NO; // Standard H1 Trend (Magic 20240403)
input ENUM_YESNO InpTrendAggressive = OPT_NO; // Aggressive H1 Trend (Magic 20240404)
//=================================================//

//======== MOMENTUM EXHAUSTION REVERSAL GUARD ========//
// Requires that style's H1 Trend Confirmation input above to ALSO be Yes -
// this guard only ever engages for a trend-confirmed stack (see comment
// on the "MOMENTUM EXHAUSTION REVERSAL GUARD" locked-settings block
// below, near EXHAUSTION_COOLDOWN_SECONDS, for the full pattern definition).
input group "Momentum Exhaustion Reversal Guard"
input ENUM_YESNO InpExhaustionStandard   = OPT_NO; // Standard Exhaustion Guard - Wick Path (Magic 20240403)
input ENUM_YESNO InpExhaustionAggressive = OPT_NO; // Aggressive Exhaustion Guard - Wick Path (Magic 20240404)
input ENUM_YESNO InpExhaustionPath2Standard   = OPT_NO; // Standard - No-Wick Continuation Path (Magic 20240403)
input ENUM_YESNO InpExhaustionPath2Aggressive = OPT_NO; // Aggressive - No-Wick Continuation Path (Magic 20240404)
//=================================================//

//============== PDH/PDL REVERSAL ZONE ==============//
input group "PDH/PDL Reversal Zone"
input ENUM_YESNO InpPDZoneStandard   = OPT_NO; // Standard - 15-Min Cooldown on PDH/PDL Touch (Magic 20240403)
input ENUM_YESNO InpPDZoneAggressive = OPT_NO; // Aggressive - 15-Min Cooldown on PDH/PDL Touch (Magic 20240404)
//=================================================//

//========== OPT-IN SAFEGUARDS (BK CORP CLUB BUILD STANDARD) ==========//
// All default OFF. Flipping any of these to true/nonzero is the ONLY
// way default behavior changes - core strategy/trade logic above is
// untouched by this block either way. Shared across both styles.
#define USE_EMERGENCY_STOP          false
#define EMERGENCY_STOP_POINTS       0

#define USE_DAILY_LOSS_LIMIT        false
#define MAX_DAILY_LOSS_AMOUNT       0.0

#define USE_VOLATILITY_FILTER       false
#define MAX_ATR_POINTS              0

#define USE_POST_LOSS_COOLDOWN      false
#define POST_LOSS_COOLDOWN_CANDLES  0

// News filter: blocks NEW trade opens (fresh entries and stack adds alike)
// in a window around HIGH-impact USD calendar events. Does NOT close or
// otherwise touch positions already open - trailing/management logic is
// untouched either way. OFF by default like the rest of this block.
// Requires the broker/server to supply MQL5 Economic Calendar data - if
// the feed is empty/unavailable this fails OPEN (does not block trades),
// consistent with this EA's existing fail-open pattern (see
// HasSufficientMargin). Verify with a standalone diagnostic script first.
#define USE_NEWS_FILTER              false
#define NEWS_FILTER_MINUTES_BEFORE   15
#define NEWS_FILTER_MINUTES_AFTER    15
#define NEWS_CACHE_REFRESH_SECONDS   300   // re-query the calendar at most every 5 min
//=====================================================================//

//========== ENTRY RULES (ALWAYS ACTIVE - NOT OPT-IN) ==========//
// Always-on core entry conditions, not toggleable extras.
#define CONFIRM_TIMEFRAME       PERIOD_M5   // secondary trend-confirmation timeframe
#define SL_HIT_DELAY_SECONDS    30          // 30-second pause on new opens for a style after THAT style's SL is hit
//================================================================//

//====== MOMENTUM EXHAUSTION REVERSAL GUARD (opt-in, per style) ======//
// Detects a cross-timeframe exhaustion-reversal pattern and, when it
// fires, closes ALL open positions for that style (both directions) and
// pauses all new opens for that style for a fixed cooldown. Default OFF.
// Only ever consulted for a style when BOTH this toggle AND that style's
// own H1 Trend Confirmation toggle are Yes (see InpTrendStandard/
// Aggressive above) - this guard is specifically for pumps/dumps against
// an active trend-confirmed stack, per BK Corp Club spec.
//
// Candle A (exhaustion candle, M15 - reuses SIGNAL_TIMEFRAME): the most
// recently CLOSED M15 candle. Qualifies if its wick (in the direction
// that would extend the open position's favor - upper wick while long,
// lower wick while short) is strictly greater than its own real body.
// Body/wick color is irrelevant for Candle A itself.
//
// Candle B (confirmation, M5 - reuses CONFIRM_TIMEFRAME): checked live,
// tick by tick, on the CURRENTLY FORMING M5 candle. Confirms the instant
// BOTH conditions hold at once: (1) price has traded through Candle A's
// low (long side) / high (short side) - a lower low / higher high versus
// Candle A - AND (2) the current M5 candle is itself forming opposite-
// colour to the trend (currently trading below its own open for the long
// case, above its own open for the short case). Neither condition alone
// fires it - both must be true on the same tick.
//
// The watch stays armed for the ENTIRE M15 bar following Candle A (i.e.
// across all three M5 candles inside it, whichever one satisfies both
// conditions first). If that whole M15 bar closes without confirmation,
// Candle A is discarded - no carry-forward into a later M15 bar. A new
// Candle A must qualify fresh each time SIGNAL_TIMEFRAME rolls a bar.
//
// PATH 2 - No-Wick Continuation (separate opt-in toggle, only evaluated
// on an M15 bar where Candle A did NOT qualify for the wick path above):
// Candle B (M5): the first M5 candle, within the M15 window following
// Candle A, to CLOSE opposite-colour to the trend (bearish while long,
// bullish while short).
// Candle C (M5): the very next M5 candle after B. Confirms live/intrabar
// the instant it is (1) itself forming opposite-colour to the trend AND
// (2) its evolving body has passed all the way through B's entire body -
// i.e. current price beyond B's open (lower than B's open for the long
// case, higher than B's open for the short case). If C closes without
// confirming, Path 2 goes back to watching for a fresh Candle B (still
// within the same M15 window). Like Path 1, the whole B-then-C sequence
// must complete within the M15 bar following Candle A or it's discarded.
#define EXHAUSTION_COOLDOWN_SECONDS  120   // 2 minutes, blocks ALL new opens (either direction) for the style
//=====================================================================//

//====== PDH/PDL REVERSAL ZONE (opt-in, per style) ======//
// Previous day's high and low (PDH/PDL) act as support/resistance.
// Pulled from the prior CLOSED D1 bar - mathematically identical to the
// highest H1 high / lowest H1 low across that whole prior calendar day,
// computed directly instead of looped across 24 H1 bars. Recalculated
// at most once per day, at broker day-rollover, then held fixed for the
// rest of the day.
//
// This is a TIME-based cooldown, NOT a price/dollar buffer. Checked
// live, tick by tick, edge-triggered: the instant price FIRST touches
// or crosses PDH or PDL (Bid >= PDH, or Bid <= PDL) - having NOT been
// touching it the tick before - a single, fixed
// PD_ZONE_COOLDOWN_SECONDS cooldown starts for that style and runs
// its full course. It does NOT keep getting re-armed on every tick
// while price remains beyond the level, so it always expires on
// schedule and trading resumes - even if price is still sitting
// beyond PDH/PDL (e.g. gold broke out and kept trending). It only
// re-arms on a genuinely fresh touch: price pulled back off the
// level, then touched it again. When enabled for a style, ALL new
// opens for that style (fresh entries and stack adds alike) are
// blocked while the cooldown is active. Does NOT close or otherwise
// touch positions already open. Default OFF.
#define PD_ZONE_COOLDOWN_SECONDS  900   // 15 minutes, blocks ALL new opens (either direction) for the style
//=========================================================//

enum ENUM_BIAS { BIAS_NEUTRAL, BIAS_BULLISH, BIAS_BEARISH };

// One trading style's full parameter set + on/off state. Standard and
// Aggressive each get one of these, populated in OnInit(). Every function
// that manages or opens trades takes one of these so the two styles never
// see or interfere with each other's positions (filtered by .magic).
struct SStyle
{
   bool     enabled;
   ulong    magic;
   double   trailStart;
   double   trailStep;
   double   slUsd;            // this style's own SL, from its Risk Options dropdown
   bool     useTrend;         // this style's own H1 Trend Confirmation toggle
   bool     usePDZone;        // this style's own PDH/PDL Reversal Zone toggle (opt-in, see input group above)
   datetime pdZoneCooldownUntil; // 0 = no active cooldown; blocks ALL new opens for this style until this time (touch/cross of PDH or PDL)
   bool     pdZoneWasTouching;    // edge-detection: true if the zone was already being touched last tick, so the cooldown only (re)starts on a FRESH touch, not every tick price sits beyond the level
   int      firstEntrySeconds;
   string   label;
   datetime lastStackLogBar; // throttles the stacking-gate diagnostic below to once per bar
   datetime lastSLHitTime;   // last time THIS style's SL was hit (0 = never) - drives SL_HIT_DELAY_SECONDS

   // Momentum Exhaustion Reversal Guard state (opt-in, see input group above)
   bool     useExhaustionGuard;       // this style's own Path 1 (wick) toggle
   datetime exhaustionCooldownUntil;  // 0 = no active cooldown; blocks ALL new opens for this style until this time
   bool     exhaustionArmedBuy;       // Path 1: true while watching for a Candle-B breach below a qualifying long-side Candle A
   double   exhaustionRefLowBuy;      // Path 1: Candle A's low being watched (long side)
   datetime exhaustionBarTimeBuy;     // open time of the M15 bar last evaluated for the long side (shared by Path 1 and Path 2 dispatch)
   bool     exhaustionArmedSell;      // Path 1: true while watching for a Candle-B breach above a qualifying short-side Candle A
   double   exhaustionRefHighSell;    // Path 1: Candle A's high being watched (short side)
   datetime exhaustionBarTimeSell;    // open time of the M15 bar last evaluated for the short side

   // Path 2 (No-Wick Continuation) state - only used when Candle A does NOT qualify for Path 1
   bool     useExhaustionPath2;          // this style's own Path 2 toggle
   int      exhaustionPath2StateBuy;     // 0=inactive, 1=waiting for Candle B, 2=have B, waiting for Candle C
   double   exhaustionPath2BOpenBuy;     // Candle B's open (long side) - the level Candle C's body must pass
   datetime exhaustionPath2BBarTimeBuy;  // open time of the confirmed Candle B (long side) - Candle C is the very next M5 bar
   datetime exhaustionPath2WindowEndBuy; // end of the M15 window this Path 2 watch must resolve within (long side)
   int      exhaustionPath2StateSell;    // mirror of the above for the short side
   double   exhaustionPath2BOpenSell;
   datetime exhaustionPath2BBarTimeSell;
   datetime exhaustionPath2WindowEndSell;
};

SStyle g_standard;
SStyle g_aggressive;

datetime g_lastMarginWarnBar = 0;
double   g_dailyLoss         = 0.0;
datetime g_dailyLossDay      = 0;
double   g_pdHigh            = 0.0;   // previous day's high (PDH), cached at rollover
double   g_pdLow             = 0.0;   // previous day's low (PDL), cached at rollover
datetime g_pdZoneDay         = 0;     // D1 bar time this PDH/PDL pair was computed for (0 = not cached yet)
datetime g_lastLossCloseTime = 0;
int      g_atrHandle         = INVALID_HANDLE;
int      g_rsiHandle         = INVALID_HANDLE;
int      g_emaHandle         = INVALID_HANDLE;
int      g_rsiHandleM5       = INVALID_HANDLE; // M5 trend-confirmation RSI
int      g_emaHandleM5       = INVALID_HANDLE; // M5 trend-confirmation EMA
int      g_rsiHandleH1       = INVALID_HANDLE; // H1 opt-in Trend Confirmation RSI
int      g_emaHandleH1       = INVALID_HANDLE; // H1 opt-in Trend Confirmation EMA

// News filter state (opt-in, see USE_NEWS_FILTER above)
MqlCalendarValue g_newsEvents[];       // cached HIGH-impact USD events only
datetime         g_newsEventsRefreshed = 0;
datetime         g_lastNewsWarnBar     = 0; // throttles the news-block diagnostic to once per bar

//+------------------------------------------------------------------+
double USDToPrice(double usd)
{
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickValue <= 0 || tickSize <= 0) return 0;

   double valuePerTick = tickValue * LOT_SIZE;
   return (usd / valuePerTick) * tickSize;
}
//+------------------------------------------------------------------+
double GetMinStopDistance()
{
   double stopLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   double freeze    = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*_Point;
   double minDist   = MathMax(stopLevel,freeze);

   // Verification standard #3: 10-point safety floor if broker/tester reports 0
   if(minDist <= 0)
      minDist = 10 * _Point;

   return minDist;
}
//+------------------------------------------------------------------+
// Verification standard #2: normalize lot to broker min/max/step
double NormalizeLot(double lot)
{
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(stepLot <= 0) stepLot = (minLot > 0) ? minLot : 0.01;

   double normalized = MathRound(lot / stepLot) * stepLot;

   if(minLot > 0 && normalized < minLot) normalized = minLot;
   if(maxLot > 0 && normalized > maxLot) normalized = maxLot;

   return NormalizeDouble(normalized, 2);
}
//+------------------------------------------------------------------+
// Verification standard #5: free-margin pre-check, throttled to once per bar
bool HasSufficientMargin(double lot, ENUM_ORDER_TYPE type, double price)
{
   double marginRequired = 0.0;

   if(!OrderCalcMargin(type, _Symbol, lot, price, marginRequired))
      return true; // broker couldn't calc - don't block, fail open (unchanged prior behavior)

   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

   if(marginRequired > freeMargin)
   {
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(barTime != g_lastMarginWarnBar)
      {
         Print(EA_NAME, ": insufficient free margin. Required: ", marginRequired, " Free: ", freeMargin);
         g_lastMarginWarnBar = barTime;
      }
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
// Core signal logic (BK Corp Club standard, Section 2) - locked.
// RSI(14) and EMA(20) on M15, evaluated on the previous CLOSED bar.
// Shared by both trading styles - one bias read per tick, applied to
// whichever style(s) are enabled.
ENUM_BIAS GetBias()
{
   double rsiBuf[1];
   double emaBuf[1];

   if(CopyBuffer(g_rsiHandle, 0, 1, 1, rsiBuf) <= 0) return BIAS_NEUTRAL;
   if(CopyBuffer(g_emaHandle, 0, 1, 1, emaBuf) <= 0) return BIAS_NEUTRAL;

   double prevClose = iClose(_Symbol, SIGNAL_TIMEFRAME, 1);
   double prevRSI    = rsiBuf[0];
   double prevEMA    = emaBuf[0];

   if(prevRSI > RSI_BULL_LEVEL && prevClose > prevEMA) return BIAS_BULLISH;
   if(prevRSI < RSI_BEAR_LEVEL && prevClose < prevEMA) return BIAS_BEARISH;

   return BIAS_NEUTRAL;
}
//+------------------------------------------------------------------+
// M5 trend-confirmation layer: same RSI(14)/EMA(20) test as GetBias(),
// evaluated on the previous closed M5 bar instead of M15. A new trade
// (fresh entry or stack add, either style) only fires when this agrees
// with the M15 bias direction from GetBias() - see the gate in OnTick().
ENUM_BIAS GetBiasM5()
{
   double rsiBuf[1];
   double emaBuf[1];

   if(CopyBuffer(g_rsiHandleM5, 0, 1, 1, rsiBuf) <= 0) return BIAS_NEUTRAL;
   if(CopyBuffer(g_emaHandleM5, 0, 1, 1, emaBuf) <= 0) return BIAS_NEUTRAL;

   double prevClose = iClose(_Symbol, CONFIRM_TIMEFRAME, 1);
   double prevRSI    = rsiBuf[0];
   double prevEMA    = emaBuf[0];

   if(prevRSI > RSI_BULL_LEVEL && prevClose > prevEMA) return BIAS_BULLISH;
   if(prevRSI < RSI_BEAR_LEVEL && prevClose < prevEMA) return BIAS_BEARISH;

   return BIAS_NEUTRAL;
}
//+------------------------------------------------------------------+
// Opt-in H1 Trend Confirmation layer (see "Trend Confirmation" input
// group). Same RSI(14)/EMA(20) test as GetBias()/GetBiasM5(), evaluated
// on the previous closed H1 bar. Per-style: only consulted for a style
// when that style's own trend toggle is Yes - see the gate in OnTick().
// Fails open (BIAS_NEUTRAL) if the handle or buffer isn't ready, matching
// this EA's existing fail-open pattern elsewhere.
ENUM_BIAS GetBiasH1()
{
   if(g_rsiHandleH1==INVALID_HANDLE || g_emaHandleH1==INVALID_HANDLE) return BIAS_NEUTRAL;

   double rsiBuf[1];
   double emaBuf[1];

   if(CopyBuffer(g_rsiHandleH1, 0, 1, 1, rsiBuf) <= 0) return BIAS_NEUTRAL;
   if(CopyBuffer(g_emaHandleH1, 0, 1, 1, emaBuf) <= 0) return BIAS_NEUTRAL;

   double prevClose = iClose(_Symbol, TREND_TIMEFRAME, 1);
   double prevRSI    = rsiBuf[0];
   double prevEMA    = emaBuf[0];

   if(prevRSI > RSI_BULL_LEVEL && prevClose > prevEMA) return BIAS_BULLISH;
   if(prevRSI < RSI_BEAR_LEVEL && prevClose < prevEMA) return BIAS_BEARISH;

   return BIAS_NEUTRAL;
}
//+------------------------------------------------------------------+
// Per-style Trend Confirmation gate: true if this style is allowed to
// open (either direction) given its own useTrend toggle. When the toggle
// is off, always true (no-op, unchanged prior behavior). When on, blocks
// ONLY if H1 bias is the OPPOSITE direction of the M15 signal - H1
// neutral or unavailable still allows the trade (fail open).
bool TrendConfirmed(ENUM_BIAS signalBias, const SStyle &s)
{
   if(!s.useTrend) return true;

   ENUM_BIAS trendBias = GetBiasH1();
   if(trendBias == BIAS_NEUTRAL) return true;

   return (trendBias == signalBias);
}
//+------------------------------------------------------------------+
// Shared calculation - recomputed at most once per day, at broker day
// rollover. Reads the prior CLOSED D1 bar's high/low, which is exactly
// the highest H1 high / lowest H1 low across that whole prior calendar
// day. Held fixed for the rest of the day once cached. If history is
// not yet available (e.g. right after attach), g_pdZoneDay is left at
// its prior value and this simply retries on the next tick.
void RefreshPDZone()
{
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(today == g_pdZoneDay) return; // already cached for today

   double ph = iHigh(_Symbol, PERIOD_D1, 1);
   double pl = iLow(_Symbol, PERIOD_D1, 1);
   if(ph <= 0.0 || pl <= 0.0) return; // history not ready yet - retry next tick

   g_pdHigh    = ph;
   g_pdLow     = pl;
   g_pdZoneDay = today;
}
//+------------------------------------------------------------------+
// Per-style PDH/PDL touch/cross detector - called once per tick for
// every ENABLED style (see the call added alongside
// CheckExhaustionReversalGuard in OnTick), regardless of the style's
// own usePDZone toggle state (the toggle is checked inside).
// Edge-triggered: only starts a fresh PD_ZONE_COOLDOWN_SECONDS
// cooldown the instant price transitions into touching/crossing PDH
// or PDL (touching==true this tick, wasTouching==false last tick).
// While price continues sitting beyond the level on later ticks, the
// cooldown is left alone to run its course and expire on schedule -
// it does NOT keep getting pushed forward. No-op if the toggle is
// off or the zone hasn't been cached yet.
void CheckPDZoneCooldown(SStyle &s)
{
   if(!s.usePDZone) return;
   if(g_pdZoneDay == 0) return; // not cached yet this run

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(bid <= 0.0) return;

   bool touching = (bid >= g_pdHigh || bid <= g_pdLow);

   if(touching && !s.pdZoneWasTouching)
      s.pdZoneCooldownUntil = TimeCurrent() + PD_ZONE_COOLDOWN_SECONDS; // fresh touch only - starts the one-shot 15-min timer

   s.pdZoneWasTouching = touching;
}
//+------------------------------------------------------------------+
int CountPositions(ulong magic)
{
   int c=0;
   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t=PositionGetTicket(i);
      if(PositionSelectByTicket(t))
         if(PositionGetInteger(POSITION_MAGIC)==magic &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
            c++;
   }
   return c;
}
//+------------------------------------------------------------------+
ulong GetLatestTradeByType(ENUM_POSITION_TYPE type, ulong magic)
{
   ulong latest=0;
   datetime time=0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;

      if(PositionGetInteger(POSITION_MAGIC)!=magic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=type) continue;

      datetime openTime=(datetime)PositionGetInteger(POSITION_TIME);

      if(openTime>time)
      {
         time=openTime;
         latest=t;
      }
   }
   return latest;
}
//+------------------------------------------------------------------+
bool HasOpenPositionType(ulong magic, ENUM_POSITION_TYPE type)
{
   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=magic) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==type) return true;
   }
   return false;
}
//+------------------------------------------------------------------+
// Closes EVERY open position for this style's magic number, both
// directions, regardless of current floating P/L. Used only by the
// Momentum Exhaustion Reversal Guard trigger below - deliberately closes
// both sides (not just the side that triggered) so an opposite-direction
// stack can never be left open confused about which way the style is
// currently biased (per spec).
void CloseAllPositionsForStyle(const SStyle &s)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=s.magic) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;

      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      MqlTradeRequest r;
      MqlTradeResult  rs;
      ZeroMemory(r);
      ZeroMemory(rs);

      r.action    = TRADE_ACTION_DEAL;
      r.position  = t;
      r.symbol    = _Symbol;
      r.volume    = PositionGetDouble(POSITION_VOLUME);
      r.type      = (type==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      r.price     = (r.type==ORDER_TYPE_SELL) ? SymbolInfoDouble(_Symbol,SYMBOL_BID) : SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      r.deviation = 20;
      r.magic     = s.magic;

      bool sent = OrderSend(r, rs);
      if(!sent || (rs.retcode!=TRADE_RETCODE_DONE && rs.retcode!=TRADE_RETCODE_PLACED))
         Print(EA_NAME, " [", s.label, "]: Exhaustion Guard close failed for ticket #", t, ": ", rs.retcode);
   }
}
//+------------------------------------------------------------------+
// Fires when either side's exhaustion pattern is confirmed: closes ALL
// open positions for this style (both directions) and starts the
// EXHAUSTION_COOLDOWN_SECONDS window during which OnTick will not open
// any new trade (fresh entry or stack add, either direction) for this
// style. See the gate added in OnTick.
void TriggerExhaustionGuard(SStyle &s, string sideLabel)
{
   CloseAllPositionsForStyle(s);

   s.exhaustionCooldownUntil = TimeCurrent() + EXHAUSTION_COOLDOWN_SECONDS;
   s.exhaustionArmedBuy      = false;
   s.exhaustionArmedSell     = false;

   Print(EA_NAME, " [", s.label, "]: Momentum Exhaustion Reversal Guard fired (", sideLabel,
         ") - all open positions closed, new opens paused ", EXHAUSTION_COOLDOWN_SECONDS, "s.");
}
//+------------------------------------------------------------------+
// Long-side watch: only relevant while this style holds an open BUY. Once
// per new M15 bar, tests whether the candle that JUST closed (shift 1,
// SIGNAL_TIMEFRAME) is an exhaustion candle (upper wick > body):
//   - if YES and Path 1 is enabled: arms the Path 1 watch (unchanged from
//     before) for the entire next M15 bar.
//   - if NO and Path 2 is enabled: arms the Path 2 watch instead (waiting
//     for Candle B) for the entire next M15 bar.
// Either way, anything armed from an older M15 bar is discarded first,
// unconditionally, since its window has by definition just closed without
// confirmation - no indefinite carry-forward.
void CheckExhaustionLongSide(SStyle &s)
{
   if(!HasOpenPositionType(s.magic, POSITION_TYPE_BUY))
   {
      s.exhaustionArmedBuy      = false;
      s.exhaustionPath2StateBuy = 0;
      return;
   }

   datetime candleATime = iTime(_Symbol, SIGNAL_TIMEFRAME, 1);

   if(s.exhaustionBarTimeBuy != candleATime)
   {
      s.exhaustionArmedBuy = false; // previous M15 window has closed - void it

      double o = iOpen(_Symbol, SIGNAL_TIMEFRAME, 1);
      double c = iClose(_Symbol, SIGNAL_TIMEFRAME, 1);
      double h = iHigh(_Symbol, SIGNAL_TIMEFRAME, 1);
      double l = iLow(_Symbol, SIGNAL_TIMEFRAME, 1);

      double body         = MathAbs(c - o);
      double upperWick     = h - MathMax(o, c);
      bool   wickQualifies = (upperWick > body);

      if(s.useExhaustionGuard && wickQualifies)
      {
         s.exhaustionArmedBuy      = true;
         s.exhaustionRefLowBuy     = l;
         s.exhaustionPath2StateBuy = 0; // Path 2 doesn't apply this cycle - Candle A had a wick
      }
      else if(s.useExhaustionPath2 && !wickQualifies)
      {
         s.exhaustionPath2StateBuy     = 1; // waiting for Candle B
         s.exhaustionPath2WindowEndBuy = candleATime + 2*PeriodSeconds(SIGNAL_TIMEFRAME);
         s.exhaustionPath2BBarTimeBuy  = 0;
      }
      else
      {
         s.exhaustionPath2StateBuy = 0;
      }

      s.exhaustionBarTimeBuy = candleATime;
   }

   if(s.exhaustionArmedBuy)
   {
      double m5Open = iOpen(_Symbol, CONFIRM_TIMEFRAME, 0);
      double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      bool lowerLow       = (bid < s.exhaustionRefLowBuy);   // lower low vs. Candle A (M15)
      bool oppositeColour = (bid < m5Open);                  // current M5 candle forming bearish

      if(lowerLow && oppositeColour)
      {
         TriggerExhaustionGuard(s, "long-side pump exhaustion (M15 wick / M5 confirmation)");
         return;
      }
   }

   if(s.exhaustionPath2StateBuy != 0)
      CheckExhaustionPath2Long(s);
}
//+------------------------------------------------------------------+
// Path 2 (No-Wick Continuation), long side. State 1 = waiting for Candle B
// (first M5 candle, within the window, to CLOSE bearish). State 2 = have
// B, watching the very next M5 candle (Candle C) live for it to also be
// forming bearish AND for its evolving body to have passed all the way
// through B's entire body (price beyond B's open). If C's bar comes and
// goes without confirming, drops back to state 1 (fresh Candle B search),
// still bounded by the same M15 window as Candle A.
void CheckExhaustionPath2Long(SStyle &s)
{
   if(TimeCurrent() >= s.exhaustionPath2WindowEndBuy)
   {
      s.exhaustionPath2StateBuy = 0; // window expired - no confirmation in time
      return;
   }

   if(s.exhaustionPath2StateBuy == 1)
   {
      datetime m5BarTime        = iTime(_Symbol, CONFIRM_TIMEFRAME, 1);
      datetime candleACloseTime = s.exhaustionPath2WindowEndBuy - PeriodSeconds(SIGNAL_TIMEFRAME);

      // Only accept a candidate B that closed AFTER Candle A itself closed
      // (otherwise the "last closed M5 bar" on the very first tick of this
      // window would just be one of Candle A's own M5 sub-candles).
      if(m5BarTime < candleACloseTime) return;

      double bOpen  = iOpen(_Symbol, CONFIRM_TIMEFRAME, 1);
      double bClose = iClose(_Symbol, CONFIRM_TIMEFRAME, 1);

      if(bClose < bOpen) // Candle B closed bearish
      {
         s.exhaustionPath2StateBuy    = 2;
         s.exhaustionPath2BOpenBuy    = bOpen;
         s.exhaustionPath2BBarTimeBuy = m5BarTime;
      }
      return;
   }

   // state == 2: watching for Candle C (the M5 bar immediately after B)
   datetime expectedCTime  = s.exhaustionPath2BBarTimeBuy + PeriodSeconds(CONFIRM_TIMEFRAME);
   datetime currentBarTime = iTime(_Symbol, CONFIRM_TIMEFRAME, 0);

   if(currentBarTime > expectedCTime)
   {
      s.exhaustionPath2StateBuy = 1; // C's bar came and went without confirming - watch for a fresh B
      return;
   }
   if(currentBarTime < expectedCTime) return; // C hasn't started forming yet

   double cOpen = iOpen(_Symbol, CONFIRM_TIMEFRAME, 0);
   double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   bool cBearish    = (bid < cOpen);                     // Candle C itself forming bearish
   bool bodyPassesB = (bid < s.exhaustionPath2BOpenBuy);  // C's evolving body has passed all the way through B's body

   if(cBearish && bodyPassesB)
      TriggerExhaustionGuard(s, "long-side no-wick continuation (M5 Candle B/C confirmation)");
}
//+------------------------------------------------------------------+
// Short-side watch - exact mirror of CheckExhaustionLongSide above.
void CheckExhaustionShortSide(SStyle &s)
{
   if(!HasOpenPositionType(s.magic, POSITION_TYPE_SELL))
   {
      s.exhaustionArmedSell      = false;
      s.exhaustionPath2StateSell = 0;
      return;
   }

   datetime candleATime = iTime(_Symbol, SIGNAL_TIMEFRAME, 1);

   if(s.exhaustionBarTimeSell != candleATime)
   {
      s.exhaustionArmedSell = false;

      double o = iOpen(_Symbol, SIGNAL_TIMEFRAME, 1);
      double c = iClose(_Symbol, SIGNAL_TIMEFRAME, 1);
      double h = iHigh(_Symbol, SIGNAL_TIMEFRAME, 1);
      double l = iLow(_Symbol, SIGNAL_TIMEFRAME, 1);

      double body         = MathAbs(c - o);
      double lowerWick     = MathMin(o, c) - l;
      bool   wickQualifies = (lowerWick > body);

      if(s.useExhaustionGuard && wickQualifies)
      {
         s.exhaustionArmedSell      = true;
         s.exhaustionRefHighSell    = h;
         s.exhaustionPath2StateSell = 0;
      }
      else if(s.useExhaustionPath2 && !wickQualifies)
      {
         s.exhaustionPath2StateSell     = 1;
         s.exhaustionPath2WindowEndSell = candleATime + 2*PeriodSeconds(SIGNAL_TIMEFRAME);
         s.exhaustionPath2BBarTimeSell  = 0;
      }
      else
      {
         s.exhaustionPath2StateSell = 0;
      }

      s.exhaustionBarTimeSell = candleATime;
   }

   if(s.exhaustionArmedSell)
   {
      double m5Open = iOpen(_Symbol, CONFIRM_TIMEFRAME, 0);
      double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      bool higherHigh     = (ask > s.exhaustionRefHighSell);  // higher high vs. Candle A (M15)
      bool oppositeColour = (ask > m5Open);                   // current M5 candle forming bullish

      if(higherHigh && oppositeColour)
      {
         TriggerExhaustionGuard(s, "short-side dump exhaustion (M15 wick / M5 confirmation)");
         return;
      }
   }

   if(s.exhaustionPath2StateSell != 0)
      CheckExhaustionPath2Short(s);
}
//+------------------------------------------------------------------+
// Path 2, short side - exact mirror of CheckExhaustionPath2Long above.
void CheckExhaustionPath2Short(SStyle &s)
{
   if(TimeCurrent() >= s.exhaustionPath2WindowEndSell)
   {
      s.exhaustionPath2StateSell = 0;
      return;
   }

   if(s.exhaustionPath2StateSell == 1)
   {
      datetime m5BarTime        = iTime(_Symbol, CONFIRM_TIMEFRAME, 1);
      datetime candleACloseTime = s.exhaustionPath2WindowEndSell - PeriodSeconds(SIGNAL_TIMEFRAME);

      if(m5BarTime < candleACloseTime) return;

      double bOpen  = iOpen(_Symbol, CONFIRM_TIMEFRAME, 1);
      double bClose = iClose(_Symbol, CONFIRM_TIMEFRAME, 1);

      if(bClose > bOpen) // Candle B closed bullish
      {
         s.exhaustionPath2StateSell    = 2;
         s.exhaustionPath2BOpenSell    = bOpen;
         s.exhaustionPath2BBarTimeSell = m5BarTime;
      }
      return;
   }

   datetime expectedCTime  = s.exhaustionPath2BBarTimeSell + PeriodSeconds(CONFIRM_TIMEFRAME);
   datetime currentBarTime = iTime(_Symbol, CONFIRM_TIMEFRAME, 0);

   if(currentBarTime > expectedCTime)
   {
      s.exhaustionPath2StateSell = 1;
      return;
   }
   if(currentBarTime < expectedCTime) return;

   double cOpen = iOpen(_Symbol, CONFIRM_TIMEFRAME, 0);
   double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   bool cBullish    = (ask > cOpen);
   bool bodyPassesB = (ask > s.exhaustionPath2BOpenSell);

   if(cBullish && bodyPassesB)
      TriggerExhaustionGuard(s, "short-side no-wick continuation (M5 Candle B/C confirmation)");
}
//+------------------------------------------------------------------+
// Entry point called once per tick per enabled style (see OnTick). No-op
// unless this style's H1 Trend Confirmation is Yes AND at least one of
// the two guard paths (wick / no-wick continuation) is enabled - both
// paths are scoped to trend-confirmed stacks only, per spec.
void CheckExhaustionReversalGuard(SStyle &s)
{
   if(!s.useTrend) return;
   if(!s.useExhaustionGuard && !s.useExhaustionPath2) return;

   CheckExhaustionLongSide(s);
   CheckExhaustionShortSide(s);
}
//+------------------------------------------------------------------+
// Tighter entry layer (Aggressive style only, firstEntrySeconds=0 for
// Standard so this is always true for it): the first trade of a new stack
// only fires once the current M15 signal candle has been open for at
// least the given number of seconds. Purely a timing/noise filter - it
// does not re-evaluate the RSI/EMA bias (that stays locked to the same
// closed bar all M15 period), it just avoids firing on the exact tick of
// bar rollover. Stacked adds are unaffected either way.
bool FirstEntryCandleConfirmed(int firstEntrySeconds)
{
   if(firstEntrySeconds <= 0) return true;

   datetime barOpen = iTime(_Symbol, SIGNAL_TIMEFRAME, 0);
   return (TimeCurrent() - barOpen) >= firstEntrySeconds;
}
//+------------------------------------------------------------------+
// Stacking gate: a new same-direction trade is only allowed if there are
// zero open trades in that direction FOR THIS STYLE'S MAGIC NUMBER
// (subject to the first-entry timing gate above), OR the most recently
// opened trade of that direction (same magic) has reached this style's
// trailStart (its trailing stop has activated). That trade then becomes
// the trigger for the next one. No time-based bypass on stacked adds.
// Each style's stack is completely independent of the other style's.
bool AllowNewTrade(ENUM_POSITION_TYPE type, SStyle &s)
{
   ulong t=GetLatestTradeByType(type, s.magic);
   if(t==0) return FirstEntryCandleConfirmed(s.firstEntrySeconds);

   if(!PositionSelectByTicket(t)) return false;

   double profit = PositionGetDouble(POSITION_PROFIT);

   bool allowed = (profit >= s.trailStart);

   // Diagnostic: once per bar, log why a stack add was blocked, so this is
   // directly observable in the Experts tab instead of inferred from code.
   if(!allowed)
   {
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(barTime != s.lastStackLogBar)
      {
         Print(EA_NAME, " [", s.label, "]: stack add blocked - latest ",
               (type==POSITION_TYPE_BUY ? "BUY" : "SELL"),
               " ticket #", t, " profit $", DoubleToString(profit,2),
               " has not reached trailStart $", DoubleToString(s.trailStart,2));
         s.lastStackLogBar = barTime;
      }
   }

   return allowed;
}
//+------------------------------------------------------------------+
// News filter (opt-in, USE_NEWS_FILTER above): refreshes a cached list of
// upcoming/recent HIGH-impact USD calendar events at most once every
// NEWS_CACHE_REFRESH_SECONDS, so OnTick never hits CalendarValueHistory()
// directly. If the feed is unavailable (CalendarValueHistory returns < 0
// or 0), the cache is simply left empty and the filter fails OPEN -
// consistent with this EA's existing fail-open pattern elsewhere.
void RefreshNewsCache()
{
   if(TimeCurrent() - g_newsEventsRefreshed < NEWS_CACHE_REFRESH_SECONDS) return;

   // Look back far enough to still catch the "after" side of an event that
   // just occurred, and ahead far enough to cover the cache's own refresh gap.
   datetime from = TimeTradeServer() - (NEWS_FILTER_MINUTES_BEFORE + NEWS_FILTER_MINUTES_AFTER) * 60;
   datetime to   = TimeTradeServer() + 2*86400;

   MqlCalendarValue vals[];
   ResetLastError();
   int total = CalendarValueHistory(vals, from, to, NULL, "USD");

   ArrayFree(g_newsEvents);
   g_newsEventsRefreshed = TimeCurrent();

   if(total <= 0)
      return; // feed unavailable or empty this cycle - fail open, cache stays empty

   ArrayResize(g_newsEvents, total);
   int kept = 0;

   for(int i=0; i<total; i++)
   {
      MqlCalendarEvent ev;
      if(!CalendarEventById(vals[i].event_id, ev)) continue;
      if(ev.importance != CALENDAR_IMPORTANCE_HIGH) continue;

      g_newsEvents[kept] = vals[i];
      kept++;
   }

   ArrayResize(g_newsEvents, kept);
}
//+------------------------------------------------------------------+
// Returns true if TimeTradeServer() currently falls inside the
// before/after window of any cached HIGH-impact USD event.
bool IsHighImpactUSDNewsWindow()
{
   RefreshNewsCache();

   datetime now = TimeTradeServer();

   for(int i=0; i<ArraySize(g_newsEvents); i++)
   {
      datetime evTime   = g_newsEvents[i].time;
      datetime winStart = evTime - NEWS_FILTER_MINUTES_BEFORE*60;
      datetime winEnd   = evTime + NEWS_FILTER_MINUTES_AFTER*60;

      if(now >= winStart && now <= winEnd)
         return true;
   }
   return false;
}
//+------------------------------------------------------------------+
// Opt-in safeguard gate - all OFF by default, so this returns true
// unconditionally unless the trader explicitly enables one above.
// Shared across both styles (these are account/symbol-level safeguards,
// not per-style).
bool SafeguardsAllowTrade()
{
   if(USE_DAILY_LOSS_LIMIT)
   {
      datetime today = iTime(_Symbol, PERIOD_D1, 0);
      if(today == g_dailyLossDay && g_dailyLoss >= MAX_DAILY_LOSS_AMOUNT)
         return false;
   }

   if(USE_POST_LOSS_COOLDOWN)
   {
      if(g_lastLossCloseTime > 0)
      {
         datetime candleTime = iTime(_Symbol, PERIOD_CURRENT, POST_LOSS_COOLDOWN_CANDLES);
         if(g_lastLossCloseTime > candleTime)
            return false;
      }
   }

   if(USE_VOLATILITY_FILTER && g_atrHandle != INVALID_HANDLE)
   {
      double atrBuf[];
      if(CopyBuffer(g_atrHandle, 0, 1, 1, atrBuf) > 0)
      {
         double atrPoints = atrBuf[0] / _Point;
         if(atrPoints > MAX_ATR_POINTS)
            return false;
      }
   }

   if(USE_NEWS_FILTER && IsHighImpactUSDNewsWindow())
   {
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(barTime != g_lastNewsWarnBar)
      {
         Print(EA_NAME, ": new trade opens blocked - inside ", NEWS_FILTER_MINUTES_BEFORE,
               "m/", NEWS_FILTER_MINUTES_AFTER, "m window of a HIGH-impact USD event.");
         g_lastNewsWarnBar = barTime;
      }
      return false;
   }

   return true;
}
//+------------------------------------------------------------------+
bool OpenTrade(ENUM_ORDER_TYPE type, const SStyle &s)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return false;

   double slDist = USDToPrice(s.slUsd);
   double minDist = GetMinStopDistance();

   if(slDist < minDist) slDist = minDist;

   int d = (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   double price, sl;
   double tp = 0; // no take profit - trade runs until the trailing stop closes it

   if(type == ORDER_TYPE_BUY)
   {
      price = tick.ask;
      sl = NormalizeDouble(tick.bid - slDist, d);
   }
   else // ORDER_TYPE_SELL
   {
      price = tick.bid;
      sl = NormalizeDouble(tick.ask + slDist, d);
   }

   double lot = NormalizeLot(LOT_SIZE);

   if(!HasSufficientMargin(lot, type, price))
      return false;

   MqlTradeRequest r;
   MqlTradeResult res;
   ZeroMemory(r);
   ZeroMemory(res);

   r.action   = TRADE_ACTION_DEAL;
   r.symbol   = _Symbol;
   r.volume   = lot;
   r.type     = type;
   r.price    = price;
   r.sl       = sl;
   r.tp       = tp;
   r.magic    = s.magic;
   r.deviation= 20;
   r.comment  = EA_NAME + " " + s.label + (type==ORDER_TYPE_BUY ? " Buy" : " Sell");

   bool sent = OrderSend(r,res);

   if(!sent || (res.retcode!=TRADE_RETCODE_DONE && res.retcode!=TRADE_RETCODE_PLACED))
   {
      Print("OrderSend failed (", s.label, "): ", res.retcode);
      return false;
   }

   return true;
}
//+------------------------------------------------------------------+
void ManageTrailing(const SStyle &s)
{
   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;

      if(PositionGetInteger(POSITION_MAGIC)!=s.magic) continue;

      double profit=PositionGetDouble(POSITION_PROFIT);
      if(profit < s.trailStart) continue;

      double open=PositionGetDouble(POSITION_PRICE_OPEN);
      double sl=PositionGetDouble(POSITION_SL);
      double tp=PositionGetDouble(POSITION_TP);
      double current=PositionGetDouble(POSITION_PRICE_CURRENT);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      int d=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

      // Continuous trail: once activated at s.trailStart profit, the stop
      // sits s.trailStep behind current price and moves forward tick by
      // tick with it. Floored at entry so the stop never sits worse than
      // breakeven once trailing has activated.
      double trailDist = USDToPrice(s.trailStep);

      double newSL;
      bool improved;

      if(type==POSITION_TYPE_BUY)
      {
         newSL = NormalizeDouble(current - trailDist, d);
         if(newSL < open) newSL = open;
         // Verification standard #4: never move stop in the unfavorable direction
         improved = (newSL > sl);
      }
      else // POSITION_TYPE_SELL
      {
         newSL = NormalizeDouble(current + trailDist, d);
         if(newSL > open) newSL = open;
         improved = (sl==0 || newSL < sl);
      }

      if(improved)
      {
         MqlTradeRequest r;
         MqlTradeResult rs;
         ZeroMemory(r);
         ZeroMemory(rs);

         r.action=TRADE_ACTION_SLTP;
         r.position=t;
         r.symbol=_Symbol;
         r.sl=newSL;
         r.tp=tp;

         bool sent = OrderSend(r,rs);
         if(!sent || (rs.retcode!=TRADE_RETCODE_DONE && rs.retcode!=TRADE_RETCODE_PLACED))
            Print("Trailing failed (", s.label, "): ", rs.retcode);
      }
   }
}
//+------------------------------------------------------------------+
// Opt-in safeguard: emergency stop. OFF by default (USE_EMERGENCY_STOP = false),
// so this function is a no-op unless explicitly enabled. Filtered per style
// magic number so it acts independently on each style's own positions.
void CheckEmergencyStop(ulong magic)
{
   if(!USE_EMERGENCY_STOP) return;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=magic) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;

      double open    = PositionGetDouble(POSITION_PRICE_OPEN);
      double current = PositionGetDouble(POSITION_PRICE_CURRENT);
      double distPts = MathAbs(open-current)/_Point;

      bool losing = (PositionGetDouble(POSITION_PROFIT) < 0);

      if(losing && distPts >= EMERGENCY_STOP_POINTS)
      {
         MqlTradeRequest r;
         MqlTradeResult rs;
         ZeroMemory(r);
         ZeroMemory(rs);

         r.action   = TRADE_ACTION_DEAL;
         r.position = t;
         r.symbol   = _Symbol;
         r.volume   = PositionGetDouble(POSITION_VOLUME);
         r.type     = (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
         r.price    = (r.type==ORDER_TYPE_SELL) ? SymbolInfoDouble(_Symbol,SYMBOL_BID) : SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         r.deviation= 20;
         r.magic    = magic;

         bool sent = OrderSend(r, rs);
         if(!sent || (rs.retcode!=TRADE_RETCODE_DONE && rs.retcode!=TRADE_RETCODE_PLACED))
            Print("Emergency stop close failed: ", rs.retcode);
      }
   }
}
//+------------------------------------------------------------------+

//================ BK CORP CLUB ONLINE LICENSING =================//
#define LICENSE_API_BASE       "https://bk-saas-backend.onrender.com"
#define LICENSE_TENANT_DOMAIN  "bkcorp"
#define LICENSE_HEARTBEAT_SEC  300
#define LICENSE_HTTP_TIMEOUT   10000

string g_licenseSessionToken = "";
string g_licenseDeviceId = "";
bool   g_licenseAllowed = false;
datetime g_licenseLastSuccess = 0;
string g_licenseLastReason = "not_checked";

string TrimLicenseText(string value)
{
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
}

string JsonEscape(string value)
{
   StringReplace(value, "\\", "\\\\");
   StringReplace(value, "\"", "\\\"");
   StringReplace(value, "\r", "\\r");
   StringReplace(value, "\n", "\\n");
   StringReplace(value, "\t", "\\t");
   return value;
}

string LicenseJsonString(const string json, const string field)
{
   string marker = "\"" + field + "\":\"";
   int start = StringFind(json, marker);
   if(start < 0) return "";
   start += StringLen(marker);
   int finish = StringFind(json, "\"", start);
   if(finish < 0) return "";
   return StringSubstr(json, start, finish - start);
}

bool LicenseResponseAllowed(const string response)
{
   if(StringFind(response, "\"allowed\":true") >= 0) return true;
   if(StringFind(response, "\"allowed\": true") >= 0) return true;
   return false;
}

bool LicensePost(const string endpoint, const string body, string &response)
{
   string headers = "Content-Type: application/json\r\n"
                    "x-tenant-domain: " + LICENSE_TENANT_DOMAIN + "\r\n";
   char requestData[];
   char responseData[];
   string responseHeaders;
   int copied = StringToCharArray(body, requestData, 0, WHOLE_ARRAY, CP_UTF8);
   if(copied <= 1)
   {
      g_licenseLastReason = "request_encoding_failed";
      return false;
   }
   ArrayResize(requestData, copied - 1);

   ResetLastError();
   int status = WebRequest("POST", LICENSE_API_BASE + endpoint, headers,
                           LICENSE_HTTP_TIMEOUT, requestData, responseData,
                           responseHeaders);
   if(status == -1)
   {
      g_licenseLastReason = "webrequest_error_" + IntegerToString(GetLastError());
      Print(EA_NAME, ": licence server connection failed. In MT5, add ",
            LICENSE_API_BASE, " under Tools > Options > Expert Advisors > Allow WebRequest.");
      return false;
   }

   response = CharArrayToString(responseData, 0, -1, CP_UTF8);
   if(status < 200 || status >= 300)
   {
      g_licenseLastReason = "server_http_" + IntegerToString(status);
      Print(EA_NAME, ": licence server rejected request (HTTP ", status, "): ", response);
      return false;
   }
   return true;
}

bool ActivateOnlineLicense()
{
   string key = TrimLicenseText(InpLicenseKey);
   if(key == "")
   {
      g_licenseLastReason = "license_key_missing";
      Print(EA_NAME, ": enter your BK Corp Club licence key in the EA settings.");
      return false;
   }

   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   string account = IntegerToString(login);
   string broker = AccountInfoString(ACCOUNT_SERVER);
   // Stable terminal/account fingerprint. The server also binds this activation
   // to the broker account and observed public IP address.
   g_licenseDeviceId = IntegerToString(login) + "|" + broker + "|" +
                       TerminalInfoString(TERMINAL_DATA_PATH);

   string body = "{\"key\":\"" + JsonEscape(key) +
                 "\",\"accountNumber\":\"" + JsonEscape(account) +
                 "\",\"broker\":\"" + JsonEscape(broker) +
                 "\",\"deviceId\":\"" + JsonEscape(g_licenseDeviceId) +
                 "\",\"eaProductId\":\"" + EA_PRODUCT_ID + "\"}";
   string response = "";
   if(!LicensePost("/license/activate-v2", body, response))
      return false;

   if(!LicenseResponseAllowed(response))
   {
      g_licenseLastReason = LicenseJsonString(response, "reason");
      if(g_licenseLastReason == "") g_licenseLastReason = "license_not_approved";
      Print(EA_NAME, ": licence activation denied: ", g_licenseLastReason);
      return false;
   }

   g_licenseSessionToken = LicenseJsonString(response, "sessionToken");
   if(g_licenseSessionToken == "")
   {
      g_licenseLastReason = "session_token_missing";
      Print(EA_NAME, ": server response did not include a session token.");
      return false;
   }

   g_licenseAllowed = true;
   g_licenseLastSuccess = TimeLocal();
   g_licenseLastReason = "active";
   Print(EA_NAME, ": BK Corp Club licence ACTIVATED. Trading permission granted by server.");
   return true;
}

bool CheckOnlineLicenseHeartbeat()
{
   if(g_licenseSessionToken == "" || InpLicenseKey == "")
   {
      g_licenseAllowed = false;
      g_licenseLastReason = "session_or_key_missing";
      return false;
   }

   string body = "{\"key\":\"" + JsonEscape(TrimLicenseText(InpLicenseKey)) +
                 "\",\"sessionToken\":\"" + JsonEscape(g_licenseSessionToken) +
                 "\",\"accountNumber\":\"" + JsonEscape(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))) +
                 "\",\"broker\":\"" + JsonEscape(AccountInfoString(ACCOUNT_SERVER)) +
                 "\",\"deviceId\":\"" + JsonEscape(g_licenseDeviceId) +
                 "\",\"eaProductId\":\"" + EA_PRODUCT_ID + "\"}";
   string response = "";
   if(!LicensePost("/license/heartbeat-v2", body, response))
   {
      g_licenseAllowed = false; // fail closed: no new entries without server approval
      return false;
   }

   if(!LicenseResponseAllowed(response))
   {
      g_licenseLastReason = LicenseJsonString(response, "reason");
      if(g_licenseLastReason == "") g_licenseLastReason = "license_not_active";
      g_licenseAllowed = false;
      Print(EA_NAME, ": licence no longer authorised: ", g_licenseLastReason);
      return false;
   }

   g_licenseAllowed = true;
   g_licenseLastSuccess = TimeLocal();
   g_licenseLastReason = "active";
   return true;
}

void OnTimer()
{
   CheckOnlineLicenseHeartbeat();
}
//===============================================================//

int OnInit()
{
   string sym = _Symbol;
   StringToUpper(sym);

   if(StringFind(sym,"XAU")<0 && StringFind(sym,"GOLD")<0)
   {
      Print(EA_NAME, ": symbol '", _Symbol, "' is not a gold pair. EA will not initialize.");
      return INIT_FAILED;
   }

   // Resolve each trading style's fixed parameter set. Values themselves
   // are locked (not inputs) - only whether each style is ON/OFF, and now
   // each style's SL, are.
   g_standard.enabled           = (InpStandard == OPT_YES);
   g_standard.magic              = MAGIC_STANDARD;
   g_standard.trailStart         = 1.0;
   g_standard.trailStep          = 2.0;
   g_standard.slUsd              = (double)InpSLOptionStandard;
   g_standard.useTrend           = (InpTrendStandard == OPT_YES);
   g_standard.usePDZone          = (InpPDZoneStandard == OPT_YES);
   g_standard.pdZoneCooldownUntil = 0;
   g_standard.pdZoneWasTouching = false;
   g_standard.firstEntrySeconds  = 0;
   g_standard.label              = "Standard";
   g_standard.lastSLHitTime      = 0;
   g_standard.useExhaustionGuard   = (InpExhaustionStandard == OPT_YES);
   g_standard.exhaustionCooldownUntil = 0;
   g_standard.exhaustionArmedBuy      = false;
   g_standard.exhaustionRefLowBuy     = 0.0;
   g_standard.exhaustionBarTimeBuy    = 0;
   g_standard.exhaustionArmedSell     = false;
   g_standard.exhaustionRefHighSell   = 0.0;
   g_standard.exhaustionBarTimeSell   = 0;
   g_standard.useExhaustionPath2         = (InpExhaustionPath2Standard == OPT_YES);
   g_standard.exhaustionPath2StateBuy     = 0;
   g_standard.exhaustionPath2BOpenBuy     = 0.0;
   g_standard.exhaustionPath2BBarTimeBuy  = 0;
   g_standard.exhaustionPath2WindowEndBuy = 0;
   g_standard.exhaustionPath2StateSell     = 0;
   g_standard.exhaustionPath2BOpenSell     = 0.0;
   g_standard.exhaustionPath2BBarTimeSell  = 0;
   g_standard.exhaustionPath2WindowEndSell = 0;

   g_aggressive.enabled          = (InpAggressive == OPT_YES);
   g_aggressive.magic            = MAGIC_AGGRESSIVE;
   g_aggressive.trailStart       = 1.0;
   g_aggressive.trailStep        = 1.0;
   g_aggressive.slUsd            = (double)InpSLOptionAggressive;
   g_aggressive.useTrend         = (InpTrendAggressive == OPT_YES);
   g_aggressive.usePDZone        = (InpPDZoneAggressive == OPT_YES);
   g_aggressive.pdZoneCooldownUntil = 0;
   g_aggressive.pdZoneWasTouching = false;
   g_aggressive.firstEntrySeconds= 300; // 5-min first-entry confirmation gate
   g_aggressive.label            = "Aggressive";
   g_aggressive.lastSLHitTime    = 0;
   g_aggressive.useExhaustionGuard   = (InpExhaustionAggressive == OPT_YES);
   g_aggressive.exhaustionCooldownUntil = 0;
   g_aggressive.exhaustionArmedBuy      = false;
   g_aggressive.exhaustionRefLowBuy     = 0.0;
   g_aggressive.exhaustionBarTimeBuy    = 0;
   g_aggressive.exhaustionArmedSell     = false;
   g_aggressive.exhaustionRefHighSell   = 0.0;
   g_aggressive.exhaustionBarTimeSell   = 0;
   g_aggressive.useExhaustionPath2         = (InpExhaustionPath2Aggressive == OPT_YES);
   g_aggressive.exhaustionPath2StateBuy     = 0;
   g_aggressive.exhaustionPath2BOpenBuy     = 0.0;
   g_aggressive.exhaustionPath2BBarTimeBuy  = 0;
   g_aggressive.exhaustionPath2WindowEndBuy = 0;
   g_aggressive.exhaustionPath2StateSell     = 0;
   g_aggressive.exhaustionPath2BOpenSell     = 0.0;
   g_aggressive.exhaustionPath2BBarTimeSell  = 0;
   g_aggressive.exhaustionPath2WindowEndSell = 0;

   if(!g_standard.enabled && !g_aggressive.enabled)
   {
      Print(EA_NAME, ": both Standard and Aggressive are set to No - EA will not initialize. Set at least one to Yes.");
      return INIT_FAILED;
   }

   if(g_standard.enabled)
      Print(EA_NAME, ": Standard style ACTIVE (magic ", MAGIC_STANDARD, ", SL -$", (int)InpSLOptionStandard,
            ", $1 start / $2 step / no entry delay, H1 Trend Confirmation ",
            (g_standard.useTrend ? "ON" : "OFF"), ", Exhaustion Guard Wick-Path ",
            (g_standard.useExhaustionGuard ? (g_standard.useTrend ? "ON" : "ON but INACTIVE - requires H1 Trend Confirmation also ON") : "OFF"),
            ", No-Wick-Continuation-Path ",
            (g_standard.useExhaustionPath2 ? (g_standard.useTrend ? "ON" : "ON but INACTIVE - requires H1 Trend Confirmation also ON") : "OFF"),
            ", PDH/PDL Reversal Zone ",
            (g_standard.usePDZone ? "ON (15-min cooldown on touch)" : "OFF"), ")");
   if(g_aggressive.enabled)
      Print(EA_NAME, ": Aggressive style ACTIVE (magic ", MAGIC_AGGRESSIVE, ", SL -$", (int)InpSLOptionAggressive,
            ", $1 start / $1 step / 5-min first-entry gate, H1 Trend Confirmation ",
            (g_aggressive.useTrend ? "ON" : "OFF"), ", Exhaustion Guard Wick-Path ",
            (g_aggressive.useExhaustionGuard ? (g_aggressive.useTrend ? "ON" : "ON but INACTIVE - requires H1 Trend Confirmation also ON") : "OFF"),
            ", No-Wick-Continuation-Path ",
            (g_aggressive.useExhaustionPath2 ? (g_aggressive.useTrend ? "ON" : "ON but INACTIVE - requires H1 Trend Confirmation also ON") : "OFF"),
            ", PDH/PDL Reversal Zone ",
            (g_aggressive.usePDZone ? "ON (15-min cooldown on touch)" : "OFF"), ")");

   Print(EA_NAME, ": M5+M15 dual-timeframe trend confirmation ACTIVE on all new opens. ",
         "SL-hit cooldown ACTIVE: ", SL_HIT_DELAY_SECONDS, "s pause per style after that style's SL is hit.");

   if(USE_NEWS_FILTER)
      Print(EA_NAME, ": News filter ACTIVE - blocking new opens ", NEWS_FILTER_MINUTES_BEFORE,
            "m before / ", NEWS_FILTER_MINUTES_AFTER, "m after HIGH-impact USD events. ",
            "Fails OPEN if the calendar feed is unavailable.");

   g_rsiHandle = iRSI(_Symbol, SIGNAL_TIMEFRAME, RSI_PERIOD, PRICE_CLOSE);
   g_emaHandle = iMA(_Symbol, SIGNAL_TIMEFRAME, EMA_PERIOD, 0, MODE_EMA, PRICE_CLOSE);

   if(g_rsiHandle==INVALID_HANDLE || g_emaHandle==INVALID_HANDLE)
   {
      Print(EA_NAME, ": failed to create RSI/EMA indicator handles.");
      return INIT_FAILED;
   }

   g_rsiHandleM5 = iRSI(_Symbol, CONFIRM_TIMEFRAME, RSI_PERIOD, PRICE_CLOSE);
   g_emaHandleM5 = iMA(_Symbol, CONFIRM_TIMEFRAME, EMA_PERIOD, 0, MODE_EMA, PRICE_CLOSE);

   if(g_rsiHandleM5==INVALID_HANDLE || g_emaHandleM5==INVALID_HANDLE)
   {
      Print(EA_NAME, ": failed to create M5 confirmation RSI/EMA indicator handles.");
      return INIT_FAILED;
   }

   // H1 Trend Confirmation handles - only created if at least one style has
   // its trend toggle on, since GetBiasH1() fails open (BIAS_NEUTRAL) when
   // a handle is INVALID_HANDLE, this is not required for correctness, but
   // avoids an unused indicator subscription when neither style uses it.
   if(g_standard.useTrend || g_aggressive.useTrend)
   {
      g_rsiHandleH1 = iRSI(_Symbol, TREND_TIMEFRAME, RSI_PERIOD, PRICE_CLOSE);
      g_emaHandleH1 = iMA(_Symbol, TREND_TIMEFRAME, EMA_PERIOD, 0, MODE_EMA, PRICE_CLOSE);

      if(g_rsiHandleH1==INVALID_HANDLE || g_emaHandleH1==INVALID_HANDLE)
         Print(EA_NAME, ": failed to create H1 Trend Confirmation indicator handles - trend filter will fail open (allow trades) until resolved.");
   }

   if(USE_VOLATILITY_FILTER)
      g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);

   // Fail closed: EA cannot initialise trading without backend approval.
   if(!ActivateOnlineLicense())
   {
      Print(EA_NAME, ": licence activation failed (", g_licenseLastReason,
            "). EA will not trade until a valid active key is supplied and approved.");
      return INIT_FAILED;
   }

   EventSetTimer(LICENSE_HEARTBEAT_SEC);
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_atrHandle != INVALID_HANDLE)   IndicatorRelease(g_atrHandle);
   if(g_rsiHandle != INVALID_HANDLE)   IndicatorRelease(g_rsiHandle);
   if(g_emaHandle != INVALID_HANDLE)   IndicatorRelease(g_emaHandle);
   if(g_rsiHandleM5 != INVALID_HANDLE) IndicatorRelease(g_rsiHandleM5);
   if(g_emaHandleM5 != INVALID_HANDLE) IndicatorRelease(g_emaHandleM5);
   if(g_rsiHandleH1 != INVALID_HANDLE) IndicatorRelease(g_rsiHandleH1);
   if(g_emaHandleH1 != INVALID_HANDLE) IndicatorRelease(g_emaHandleH1);
}
//+------------------------------------------------------------------+
// Tracks closed-trade P&L for the opt-in daily loss limit / post-loss
// cooldown safeguards, AND the always-active per-style SL-hit cooldown.
// Both loss-tracking safeguards remain account/symbol-level (shared
// across styles) exactly as before; the SL-hit cooldown is recorded per
// style via magic number.
void OnTradeTransaction(const MqlTradeTransaction &trans,
                         const MqlTradeRequest &request,
                         const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(!HistoryDealSelect(trans.deal)) return;

   long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
   if(magic != MAGIC_STANDARD && magic != MAGIC_AGGRESSIVE) return;

   long entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY) return;

   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT)
                  + HistoryDealGetDouble(trans.deal, DEAL_SWAP)
                  + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);

   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(today != g_dailyLossDay)
   {
      g_dailyLossDay = today;
      g_dailyLoss    = 0.0;
   }

   if(profit < 0)
   {
      g_dailyLoss += MathAbs(profit);
      g_lastLossCloseTime = TimeCurrent();
   }

   // Always-active SL-hit cooldown: only a NEGATIVE-profit close via
   // DEAL_REASON_SL counts as a true stop-out. A positive/breakeven SL
   // close is a trailing-stop exit (ManageTrailing moves the SL field
   // itself), not the original protective stop, so it does not trigger
   // the cooldown. Tracked per style via magic number.
   long dealReason = HistoryDealGetInteger(trans.deal, DEAL_REASON);
   if(dealReason == DEAL_REASON_SL && profit < 0)
   {
      if(magic == MAGIC_STANDARD)
      {
         g_standard.lastSLHitTime = TimeCurrent();
         Print(EA_NAME, " [Standard]: SL hit, $", DoubleToString(profit,2),
               ". New opens paused ", SL_HIT_DELAY_SECONDS, "s for this style.");
      }
      else if(magic == MAGIC_AGGRESSIVE)
      {
         g_aggressive.lastSLHitTime = TimeCurrent();
         Print(EA_NAME, " [Aggressive]: SL hit, $", DoubleToString(profit,2),
               ". New opens paused ", SL_HIT_DELAY_SECONDS, "s for this style.");
      }
   }
}
//+------------------------------------------------------------------+
void OnTick()
{
   RefreshPDZone(); // cheap no-op after the first tick of each new day - keeps PDH/PDL current

   // Manage existing trades for each enabled style independently - each
   // only ever touches its own magic number's positions.
   if(g_standard.enabled)
   {
      CheckEmergencyStop(g_standard.magic);
      ManageTrailing(g_standard);
      CheckExhaustionReversalGuard(g_standard);
      CheckPDZoneCooldown(g_standard);
   }
   if(g_aggressive.enabled)
   {
      CheckEmergencyStop(g_aggressive.magic);
      ManageTrailing(g_aggressive);
      CheckExhaustionReversalGuard(g_aggressive);
      CheckPDZoneCooldown(g_aggressive);
   }

   // Existing positions continue to receive trailing/risk management above.
   // New entries are blocked immediately whenever the backend licence is not active.
   if(!g_licenseAllowed) return;

   if(!SafeguardsAllowTrade()) return;

   ENUM_BIAS bias = GetBias();
   if(bias==BIAS_NEUTRAL) return;

   // Always-active entry rule: M5 must confirm the same direction as the
   // M15 bias before ANY new open (fresh entry or stack add, either style).
   ENUM_BIAS biasM5 = GetBiasM5();
   if(biasM5 != bias) return;

   ENUM_POSITION_TYPE posType = (bias==BIAS_BULLISH) ? POSITION_TYPE_BUY  : POSITION_TYPE_SELL;
   ENUM_ORDER_TYPE    ordType = (bias==BIAS_BULLISH) ? ORDER_TYPE_BUY     : ORDER_TYPE_SELL;

   // Each style independently checks its own trade cap, SL-hit cooldown,
   // and stacking gate, then opens under its own magic number if allowed.
   // Fully independent - one style firing/stacking/cooling-down has no
   // effect on the other.
   if(g_standard.enabled)
   {
      bool slCooldown = (g_standard.lastSLHitTime > 0 &&
                          (TimeCurrent() - g_standard.lastSLHitTime) < SL_HIT_DELAY_SECONDS);
      bool exhaustionCooldown = (g_standard.exhaustionCooldownUntil > 0 &&
                                  TimeCurrent() < g_standard.exhaustionCooldownUntil);
      bool pdZoneCooldown = (g_standard.pdZoneCooldownUntil > 0 &&
                              TimeCurrent() < g_standard.pdZoneCooldownUntil);
      if(!slCooldown && !exhaustionCooldown && !pdZoneCooldown && CountPositions(g_standard.magic) < MAX_TRADES_CHART &&
         TrendConfirmed(bias, g_standard) && AllowNewTrade(posType, g_standard))
         OpenTrade(ordType, g_standard);
   }

   if(g_aggressive.enabled)
   {
      bool slCooldown = (g_aggressive.lastSLHitTime > 0 &&
                          (TimeCurrent() - g_aggressive.lastSLHitTime) < SL_HIT_DELAY_SECONDS);
      bool exhaustionCooldown = (g_aggressive.exhaustionCooldownUntil > 0 &&
                                  TimeCurrent() < g_aggressive.exhaustionCooldownUntil);
      bool pdZoneCooldown = (g_aggressive.pdZoneCooldownUntil > 0 &&
                              TimeCurrent() < g_aggressive.pdZoneCooldownUntil);
      if(!slCooldown && !exhaustionCooldown && !pdZoneCooldown && CountPositions(g_aggressive.magic) < MAX_TRADES_CHART &&
         TrendConfirmed(bias, g_aggressive) && AllowNewTrade(posType, g_aggressive))
         OpenTrade(ordType, g_aggressive);
   }
}
//+------------------------------------------------------------------+