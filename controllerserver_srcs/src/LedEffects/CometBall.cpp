/* 
 *  ========== Shooting Star Animation ==========
 *  red, green, blue - Choose a color with RGB values (0 to 255).
 *  tail_length - A larger value results in shorter tail.
 *  delay_duration - A larger value results in slower movement speed.
 *  interval - Time interval between new shooting stars (in milliseconds).
*/
#include  "LedInits.h"

// FIREBALL
unsigned long previousMillis = 0;           // Stores last time LEDs were updated
int count = 0;                              // Stores count for incrementing up to the NUM_LEDs   

// FIREBALL ANIMATION
void CometBallAnimation(CRGB color, int tail_length, int delay_duration, int interval, int direction, bool is_matrix) {
  unsigned long currentMillis = millis();
    int meteorPos = 0;
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      count = 0;
    }
  if (is_matrix == false)
  {
    if (direction == -1) {
      if (count < NUM_LEDSTRIP) {
        meteorPos = NUM_LEDSTRIP - (count % (NUM_LEDSTRIP + 1));
        map(meteorPos, NUM_LEDSTRIP, 0, 255, 0);  // Map position to red value in reverse
        g_StripLEDs[meteorPos].setRGB(color.r, color.g, color.b);
        count++;
      }
    } else {
      if (count < NUM_LEDSTRIP) {
        meteorPos = count % (NUM_LEDSTRIP + 1);
        map(meteorPos, 0, NUM_LEDSTRIP, 0, 255);  // Map position to red value
        g_StripLEDs[meteorPos].setRGB(color.r, color.g, color.b);
        count++;
      }
    }
    fadeToBlackBy(g_StripLEDs, NUM_LEDSTRIP, tail_length);
  }else{
    
      if (direction == -1) {
        if (count < NUM_LEDSMATRIX) {
          meteorPos = NUM_LEDSMATRIX - (count % (NUM_LEDSMATRIX + 1));
          map(meteorPos, NUM_LEDSMATRIX, 0, 255, 0);
          g_MatrixLEDs[meteorPos] = color;
          count++;
        }
      } else {
        if (count < NUM_LEDSMATRIX) {
          meteorPos = count % (NUM_LEDSMATRIX + 1);
          map(meteorPos, 0, NUM_LEDSMATRIX, 0, 255);
          g_MatrixLEDs[meteorPos] = color;
          count++;
        }
      }
      fadeToBlackBy(g_MatrixLEDs, NUM_LEDSMATRIX, tail_length);
    }
  delay(delay_duration);
}

