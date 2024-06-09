#ifndef HELP_UTILS_H
#define HELP_UTILS_H
#include "LedInits.h"

/**
 * @brief Handle the color data from the http request
 * @param colorData The color data from the http request in hexa
 * @param brightness The brightness data from the http request in int
*/
CRGB handleColorBrightnessData(const char* colorData, const char *brightness) 
{
  if (colorData != NULL)
  {
    uint32_t color = strtoul(colorData, NULL, 16);
    uint8_t alpha = (color >> 24) & 0xFF;
    uint8_t red = (color >> 16) & 0xFF;
    uint8_t green = (color >> 8) & 0xFF;
    uint8_t blue = color & 0xFF;
    CRGB correctedColor = CRGB(red, green, blue);
    fill_solid(g_StripLEDs, NUM_LEDSTRIP, correctedColor);
    if (brightness != NULL) {
      int temp = atoi(brightness);
      if (temp >= 0 && temp <= 255 && g_Brightness != temp){
        g_Brightness = temp;
        FastLED.setBrightness(g_Brightness);

        }
    }
    return correctedColor;
    }
  return CRGB::Black;
}
/**
 * @brief Handle the checking the current program and running it
 * using global variables.
*/
void handlePrograms(void)
{
    FastLED.clear();  // Clear the LEDs before applying new effects

    switch (g_currentStripProgram)
    {
        case FIRE:
            FireAnimation(false);
            break;
        case COMET:
            CometBallAnimation(g_selectedStripColor, 5, random(5, 40), 10000, 1, false);
            break;
        case COLOR:
            fill_solid(g_StripLEDs, NUM_LEDSTRIP, g_selectedStripColor);
            break;
        case BALL:
            BouncingBallAnimation(false);
            break;
        default:
            break;
    }
    switch (g_currentMatrixProgram)
    {
        case FIRE:
            FireAnimation(true);
            break;
        case COMET:
            //ft_drawComet();
            CometBallAnimation(g_selectedMatrixColor, 5, random(5, 40), 10000, 1, true);
            break;
        case COLOR:
            fill_solid(g_MatrixLEDs, NUM_LEDSMATRIX, g_selectedMatrixColor);
            break;
        case BALL:
            BouncingBallAnimation(true);
            break;
        default:
            break;
    }
    FastLED.show(g_Brightness);
}


#endif