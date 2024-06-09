#ifndef LEDINITS_H
#define LEDINITS_H
#include <FastLED.h>  

#define FASTLED_INTERNAL         // LED LIBS Suppress build banner
// LEDSTRIP MACROS
#define NUM_LEDSTRIP    	144
// MATRIX MACROS 
#define MAT_W  				32          /* Size (columns) of entire matrix */
#define MAT_H  				8          /* and rows */
#define PANELS_W    		1       /* Number of panels wide */
#define PANELS_H    		1       /* Number of panels tall */
#define NUM_LEDSMATRIX		MAT_H * PANELS_H * MAT_W * PANELS_W
# ifdef MINI_BLE
#  define LEDSTRIP_PIN 	    D9
#  define LEDMATRIX_PIN  	D10
# else
#  define LEDSTRIP_PIN    	13
#  define LEDMATRIX_PIN   	12
# endif

// FASTLED VARIABLES -----------------------------------------------------------
enum Program { OFF, FIRE, COMET, COLOR, BALL, ERROR = - 1}; // Enum for program checks
extern uint8_t g_Brightness;
extern int g_PowerLimit;
// LEDSTRIP VARIABLES_____________________________________________________
extern CRGB g_StripLEDs[NUM_LEDSTRIP];
extern CRGB g_selectedStripColor;
extern Program g_currentStripProgram;
// LEDMATRIX VARIABLES_____________________________________________________
extern CRGB g_MatrixLEDs[NUM_LEDSMATRIX];
extern CRGB g_selectedMatrixColor;
extern Program g_currentMatrixProgram;


void  FireAnimation(bool is_matrix);
void  CometBallAnimation(CRGB color, int tail_length, int delay_duration, int interval, int direction, bool is_matrix);
void  BouncingBallAnimation(bool is_matrix);
void  ft_drawComet();

#endif