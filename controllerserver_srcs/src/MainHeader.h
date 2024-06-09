#ifndef MAINHEADER_H
#define MAINHEADER_H

#include <Arduino.h>
#include <FastLED.h>
#include "ProgHandlers.h"
#include "LedInits.h"

// DEBUGGING if DEBUG == 1 then Serial.prints will be enabled
# define DEBUG 0
#if DEBUG == 1
# define debugln(x) Serial.println(x)
# define debug(x) Serial.print(x)
#else
# define debugln(x)
# define debug(x)
#endif
#ifdef HAS_BLE // The small ble controllers doesnt have enough memory to run both
#include "BleControls.h"
#else
#include "WifiControls.h"
#endif
#include "LedInits.h"
//#include "IRremotecontroller.h"
#endif
