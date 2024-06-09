#include "MainHeader.h"

// FAST LED INITS FOR EXTERNED_____________________________________
CRGB g_StripLEDs[NUM_LEDSTRIP] = {0};         //  LEDSTRIP ARRAY
CRGB g_selectedStripColor = CRGB::White;               //   CURRENTLY SELECTED COLOR STRIP
CRGB g_selectedMatrixColor = CRGB::White;              //   CURRENTLY SELECTED COLOR MATRIX
CRGB g_MatrixLEDs[NUM_LEDSMATRIX] = {0};       //  LEDMATRIX ARRAY
uint8_t g_Brightness = 255;            //    0-255 LED brightness scale
int g_PowerLimit = 3000;          //     900mW Power Limit || Can be set of for brighter colors
Program g_currentStripProgram = OFF;
Program g_currentMatrixProgram = OFF;



void setup() 
{
 // Serial.begin(115200);
  //while (!Serial) { }
  //IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);
  pinMode(LEDSTRIP_PIN, OUTPUT);
  pinMode(LEDMATRIX_PIN, OUTPUT);
  FastLED.addLeds<WS2812B, LEDMATRIX_PIN, GRB>(g_MatrixLEDs, NUM_LEDSMATRIX); // COLOR codes are sent in GRB order to leds
  FastLED.addLeds<WS2812B, LEDSTRIP_PIN, GRB>(g_StripLEDs, NUM_LEDSTRIP);
  FastLED.setBrightness(g_Brightness);
  FastLED.setMaxPowerInMilliWatts(g_PowerLimit);
  #ifdef HAS_BLE
  debugln("BLE INIT");
  ble_init();
  #elif !MINI_BLE
  init_wifihttp(false);
  pinMode(LED_BUILTIN, OUTPUT);
  set_max_power_indicator_LED(LED_BUILTIN);
  #endif
}

// LOOP THE PROGRAMS
void loop()
{
  #ifdef HAS_BLE
  ble_mainloop();
  #endif
  //handleAndProcessIR();
  handlePrograms();
}
