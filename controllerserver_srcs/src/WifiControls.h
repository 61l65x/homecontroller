#ifndef WIFICONTROLS_H
#define WIFICONTROLS_H                                 
#include <DNSServer.h>
#include <ESPAsyncWebServer.h>
#ifdef NODEMCU_ESP8266
#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#else
#include <ESPmDNS.h>
#include <WiFiClient.h>
#endif
#include "ProgHandlers.h"
#include "LedInits.h"
const char* mdnsName = "desktopcontroller";
AsyncWebServer server(80);
// WIFIAP CREDENTIALS CREATES ITS OWN WIFI NETWORK
const char* ap_ssid = "AP_SSID";   // Wifi_ap doesnt work if the password is under 8 char....
const char* ap_password = "AP_PASSWORD";
const char* srv_ssid = "WIFI_SSID";   // Wifi_ap doesnt work if the password is under 8 char....
const char* srv_password = "WIFI_PASSWORD";
IPAddress IPaddr (192, 168, 168, 168);
IPAddress IPmask(255, 255, 255, 0);
// SERVER CREDENTIALS CONNECTS TO A WIFI NETWORK
void handleHttpCommand(AsyncWebServerRequest *request);

/**
 * @brief Start the wifi access point or the server
 * Needs to be connected with wifi to work.
 * @param ap_ssid The ssid of the wifi network what will be created
 * @param ap_password The password of the wifi network what will be created
 * @param create_wifiAP If true, it will create a wifi network, if false, it will connect to a wifi network.
 * */
void init_wifihttp(int create_wifiAP)
{
    if (create_wifiAP)
    {  
        WiFi.softAP(ap_ssid, ap_password);
        WiFi.softAPConfig(IPaddr, IPaddr, IPmask);
        debugln("Access Point Started");
        debugln("IP Address: ");
        debugln(WiFi.softAPIP());
    }
    else
    {
        debugln("Connecting to ");
        while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
        Serial.println("WiFi connected");
        Serial.print("IP address: ");
        Serial.println(WiFi.localIP());
    }

    if (!MDNS.begin(mdnsName))
        debugln("Error setting up MDNS responder!");
    else 
        debugln("mDNS responder started");
    delay(1000);
    server.onNotFound([](AsyncWebServerRequest *request){
        handleHttpCommand(request);
    });
    server.begin();
    debugln("HTTP server started");
}


/**
 * @brief Handle the http commands from the http request
 * @param request The http request
*/
void handleHttpCommand(AsyncWebServerRequest *request) 
{
    String route = request->url();
    String color_code = request->arg("color");
    String brightness_code = request->arg("brightness");

    Serial.println(route);
    Serial.println(color_code);
    Serial.println(brightness_code);

    if (route.equalsIgnoreCase("/DISCONNECT")) {
        request->client()->stop();
    } else if (route.equalsIgnoreCase("/FIRE")) {
        g_currentStripProgram = FIRE;
        g_selectedStripColor = handleColorBrightnessData(color_code.c_str(), NULL);
    } else if (route.equalsIgnoreCase("/OFF")) {
        g_currentStripProgram = OFF;
        g_selectedStripColor = handleColorBrightnessData(color_code.c_str(), NULL);
    } else if (route.equalsIgnoreCase("/COMET")) {
        g_currentStripProgram = COMET;
        g_selectedStripColor = handleColorBrightnessData(color_code.c_str(), NULL);
    } else if (route.equalsIgnoreCase("/PLAIN")) {// PLAIN will be the default so the brightness will be handled here
        g_currentStripProgram = COLOR;
        g_selectedStripColor = handleColorBrightnessData(color_code.c_str(), brightness_code.c_str()); 
    } else if (route.equalsIgnoreCase("/MATRIXFIRE")) {
        g_currentMatrixProgram = FIRE;
        g_selectedMatrixColor = handleColorBrightnessData(color_code.c_str(), NULL);
    }else if (route.equalsIgnoreCase("/MATRIXPLAIN")) {
        g_currentMatrixProgram = COLOR;
        g_selectedMatrixColor = handleColorBrightnessData(color_code.c_str(), brightness_code.c_str());
    }
    else if (route.equalsIgnoreCase("/MATRIXOFF")){
        g_currentMatrixProgram = OFF;
        g_selectedMatrixColor = handleColorBrightnessData(color_code.c_str(), NULL);
    } else {
        request->send(404, "text/plain", "Not Found");
    }
}

#endif