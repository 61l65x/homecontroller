#ifndef BLE_CONTROLS_H
#define BLE_CONTROLS_H
#include "ProgHandlers.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>


#define LED_SERVICEUUID		  "fce02801-f817-46a4-ad85-7448f54ee154"
#define LEDSTRIP_CHARUUID	  "7de6d78a-6acb-4f06-b0c4-196c463e7696"
#define LEDMATRIX_CHARUUID	  "a0433a8f-46a3-4921-99bd-6f311d39b22e"

static BLEServer *pServer = NULL;
static BLECharacteristic *pMatrixCharacteristic = NULL;
static BLECharacteristic *pStripCharacteristic  =  NULL;
static bool      isConnected = false;
static bool      wasConnected = false;
//static uint8_t   valueToMatrix = 0;
//static uint8_t   valueToStrip = 0;

class ServerCallback : public BLEServerCallbacks
{
  void onConnect(BLEServer *pServer)
  {
    isConnected = true;
  }
  void onDisconnect(BLEServer *pServer)
  {
    isConnected = false;
  }
};

class BLEDataProcessor : public BLECharacteristicCallbacks {
protected:
  void processBLEData(std::string data, Program &currentProgram, CRGB &selectedColor) {
    int colorPos = data.find("color=");
    int brightnessPos = data.find("&brightness=");
    std::string colorCode, brightnessCode;

    if (colorPos != std::string::npos)
      colorCode = data.substr(colorPos + 6, brightnessPos - (colorPos + 6));
    if (brightnessPos != std::string::npos)
      brightnessCode = data.substr(brightnessPos + 12);
    if (data.find("PLAIN") != std::string::npos)
      currentProgram = COLOR;
    else if (data.find("OFF") != std::string::npos)
      currentProgram = OFF;
    else if (data.find("FIRE") != std::string::npos)
      currentProgram = FIRE;
    else if (data.find("COMET") != std::string::npos)
      currentProgram = COMET;
    else if (data.find("BALL") != std::string::npos)
      currentProgram = BALL;
    if (!colorCode.empty())
      selectedColor = handleColorBrightnessData(colorCode.c_str(), brightnessCode.c_str());

    debugln(colorCode);
    debugln(brightnessPos);
    debugln("BLE DATA PROCESSED");
    delay(22);
  }
};

class LedMatrixCharUART : public BLEDataProcessor {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();

    if (rxValue.length() > 0) {
      processBLEData(rxValue, g_currentMatrixProgram, g_selectedMatrixColor);
    }
  }
};

class LedStripCharUART : public BLEDataProcessor {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();

    if (rxValue.length() > 0) {
      processBLEData(rxValue, g_currentStripProgram, g_selectedStripColor);
    }
  }
};

/**
 * @brief Init all needed callbacks & services for BLE
*/
void ble_init(void)
{
  // Init Server & Callbacks & Service to advertise
  BLEDevice::init("ESP32-BLE-LEDDEVICE");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallback());
  BLEService *pServiceUART = pServer->createService(LED_SERVICEUUID);
  // Matrix Characteristic
  pMatrixCharacteristic = pServiceUART->createCharacteristic(LEDMATRIX_CHARUUID, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_READ);
  pMatrixCharacteristic->setCallbacks(new LedMatrixCharUART());
  pMatrixCharacteristic->setValue("LedMatrix-Characteristics");
  //  Strip Characteristic
  pStripCharacteristic = pServiceUART->createCharacteristic(LEDSTRIP_CHARUUID, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_READ);
  pStripCharacteristic->setCallbacks(new LedStripCharUART());
  pStripCharacteristic->setValue("LedStrip-Characteristics");

  //  Start server & advertise
  pServiceUART->start();
  pServer->getAdvertising()->start();
}

/**
 * @brief Main loop for BLE to handle connections & disconnections
*/
void ble_mainloop(void)
{
   /* For frequent advertising dont need now !
    static unsigned long lastAdvertiseTime = 0;
    const unsigned long advertiseInterval = 500;

    if (millis() - lastAdvertiseTime >= advertiseInterval)
    {
        Serial.println("UART Over BLE restarting advertising");
        pServer->startAdvertising();
        lastAdvertiseTime = millis();
    }*/

    if (wasConnected && !isConnected)
    {
        debugln("UART Over BLE disconnection");
        debugln("UART Over BLE restarting advertising");
        pServer->startAdvertising();
        delay(10);
    }

    if (isConnected && !wasConnected)
       debugln("UART Over BLE connection");

    wasConnected = isConnected;
}


#endif