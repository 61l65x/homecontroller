#ifndef IR_REMOTECONTROLLER_H
#define IR_REMOTECONTROLLER_H

#ifdef HAS_BLE
#define IR_RECEIVE_PIN 7
#else 
#define IR_RECEIVE_PIN 15
#endif
#include <IRremote.h> 
#include "LedInits.h"


// MY CONTROLLERS COMMAND CODES :D
enum : uint64_t  {
    BrightnessUp = 0xF609FF00,
    BrightnessDown = 0xE21DFF00,
    Off = 0xE01FFF00,
    On = 0xF20DFF00,
    Red = 0xE619FF00,
    Green = 0xE41BFF00,
    Blue = 0xEE11FF00,
    White = 0xEA15FF00,
    Orange = 0xE817FF00,
    LGreen = 0xED12FF00,
    LBlue = 0xE916FF00,
    Flash = 0xB24DFF00,
    LOrange = 0xBF40FF00,
    LLBlue = 0xB34CFF00,
    Purple = 0xFB04FF00,
    LLOrange = 0xFF00FF00,
    BlueBlue = 0xF50AFF00,
    LightPurple = 0xE11EFF00,
    Fade = 0xF10EFF00,
    Yellow = 0xE51AFF00,
    Turkoosi = 0xE31CFF00,
    Pink = 0xEB14FF00,
    Smooth = 0xF00FFF00,
    Undefined = 0xFFFFFFFF // For unrecognized codes
};

// HANDLE THE COMMAND RECEIVED WITH IR
void handleAndProcessIR(void)
{
    if (IrReceiver.decode())
    {
        IRRawDataType command = IrReceiver.decodedIRData.decodedRawData;
        Serial.println(command , HEX);
        switch (command) 
        {
            case BrightnessUp: //____________________________________________ PROGRAMS / FUNCTIONALITIES
                break;
            case BrightnessDown:
                break;
            case Off:
                g_currentStripProgram = OFF;
                break;
            case On:
                g_currentStripProgram = COLOR;
                break;
            case Flash:
                break;
            case Fade:
                break;
            case Smooth:
                break;
            case Red: //______________________________________________________ COLORS 
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Red;
                break;
            case Green:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Green;
                break;
            case Blue:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Blue;
                break;
            case White:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::White;
                break;
            case Orange:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Orange;
                break;
            case LGreen:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::LightGreen; 
                break;
            case LBlue:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::CadetBlue;
                break;
            case LOrange:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::LightGoldenrodYellow; 
                break;
            case LLBlue:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::SkyBlue; 
                break;
            case Purple:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Purple;
                break;
            case LLOrange:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::LightYellow;
                break;
            case BlueBlue:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Cyan;
                break;
            case LightPurple:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::LightPink;
                break;
            case Yellow:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Yellow;
                break;
            case Turkoosi:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::DarkCyan;
                break;
            case Pink:
                g_currentStripProgram = COLOR;
                g_selectedStripColor = CRGB::Pink; // Pink
                break;
            case Undefined:
                break;
            default:
                break;
        }
        IrReceiver.resume();
    }
}

#endif