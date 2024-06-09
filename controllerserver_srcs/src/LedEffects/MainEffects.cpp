#include "LedInits.h"
#include "EffectHeaders/ledgfx.h"
#include "EffectHeaders/comet.h"
#include "EffectHeaders/marquee.h"
#include "EffectHeaders/twinkle.h"
#include "EffectHeaders/fire.h"
#include "EffectHeaders/bounce.h"

// Different Fire ANimation Classes!
//ClassicFireEffect fire(NUM_LEDS, 30, 100, 3, 2, false, true);   // Outwards from Middle
//ClassicFireEffect fire(NUM_LEDS, 30, 100, 3, 2, true, true);    // Inwards toward Middle
//ClassicFireEffect fire(NUM_LEDS, 20, 100, 3, 4, true, false);     // Outwards from Zero
//ClassicFireEffect fire(NUM_LEDS, 20, 100, 3, 4, false, false);     // Inwards from End
//ClassicFireEffect fire(NUM_LEDS, 50, 300, 30, 12, true, false);     // More Intense, Extra Sparking
// Global scope
ClassicFireEffect ledStripFireEffect(NUM_LEDSTRIP, 20, 100, 3, NUM_LEDSTRIP, true, false);
ClassicFireEffect ledMatrixFireEffect(NUM_LEDSMATRIX, 20, 100, 3, NUM_LEDSMATRIX, true, false);
BouncingBallEffect globalLedStripBouncingBallEffect(NUM_LEDSTRIP, 3, 10, false);
BouncingBallEffect globalLedMatrixBouncingBallEffect(NUM_LEDSMATRIX, 3, 10, false);

  void  FireAnimation(bool is_matrix)
  {
    if (is_matrix)
      ledMatrixFireEffect.DrawFire(g_MatrixLEDs, NUM_LEDSMATRIX);
    else
      ledStripFireEffect.DrawFire(g_StripLEDs, NUM_LEDSTRIP);
    delay(33);
  }

void BouncingBallAnimation(bool is_matrix) 
{
  if (is_matrix) {
    globalLedMatrixBouncingBallEffect.Draw(); // For matrix
  } else {
    globalLedStripBouncingBallEffect.Draw(); // For LED strip
  }
  delay(33);
}

  void ft_drawComet()
  { 
    DrawComet();
    delay(33);
  }


