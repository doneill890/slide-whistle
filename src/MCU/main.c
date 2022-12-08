/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : defining the functions needed to play music on a slide whistle and display the
          song information on an LCD by sending it via SPI to the FPGA.

*/

#include <stdio.h>
#include "tim1.h"
#include <stm32l432xx.h>
#include "STM32L432KC.h"
#include "STM32L432KC_TIM.h"
#include <string.h>

#define IN2CM 2.54
#define MAXLEN 50 // I need a max length of the song to put into the struct, so I arbitraily chose 50
#define STEP2CM ((3*IN2CM*1.8*3.141592653)/360) // conversion factors.
#define CM2STEP (1/STEP2CM)
#define FREQ 200 // frequency for sending pulses to the motor. higher means less time between steps.
#define Q 500 // note length definitions in ms. (Quarter)
#define E Q/2 // (Eighth)
#define H Q*2 // (Half)

struct song {
  // Struct to define everything needed to play a song.
  // this way we can define several different songs and insert it as the declared song to play
  // in the main function
  const char title[16];
  const int length; // in number of notes
  const char notes[MAXLEN][4]
  const int durations[MAXLEN];
};

const struct song harry_potter = {
    "Harry Potter",
    14,
    {"B4", "E5", "G5", "F#5", "E5", "B5", "A5", "F#5", "E5", "G5", "F#5", "Eb5", "F5", "B4"},
    {Q, Q+E, E, Q, H, Q, H+Q, H+Q, Q+E, E, Q, H, Q, Q+H}
 };

 const struct song sad_times = {
    "Wa wa wa waaaa",
    4,
    {"A5", "G#5", "G5", "F#5"}, 
    {H, H+E, H+Q, H+H}
 };

const struct song ABCs = {
    "Alphabet song",
    14,
    {"D5", "D5", "A5", "A5", "B5", "B5", "A5", "G5", "G5", "F#5", "F#5", "E5", "E5", "D5"},
    {Q, Q, Q, Q, Q, Q, H, Q, Q, Q, Q, Q, Q, H}
};

double getLoc(const char note[4]) {
    // given a note, returns a location in cm. 0 is the slide as close to the mouthpiece as possible
    
    if      (!strcmp("Bb6", note))   {return 0;}
    else if (!strcmp("B5", note))  {return 1.6;}
    else if (!strcmp("Bb5", note))  {return 4.2;}
    else if (!strcmp("A5", note))   {return 4.9;}
    else if (!strcmp("G#5", note))  {return 5.5;}
    else if (!strcmp("G5", note))   {return 6.3;}
    else if (!strcmp("F#5", note))  {return 6.9;}
    else if (!strcmp("F5", note))   {return 7.6;}
    else if (!strcmp("E5", note))   {return 8.3;}
    else if (!strcmp("Eb5", note))  {return 9.4;}
    else if (!strcmp("D5", note))   {return 10.2;}
    else if (!strcmp("Db5", note))  {return 11.1;}
    else if (!strcmp("C5", note))   {return 12;}
    else if (!strcmp("B4", note))   {return 13.2;}
    else if (!strcmp("Bb4", note))  {return 14.1;}
    else if (!strcmp("A4", note))   {return 15.2;}
    else {return 0;}
}

void fillString(const char string[], char newStr[], int len) {
  // function to fills a string with spaces until it is len long.
  // relies on the fact that the string has been initialized with some length >= len
  // and the actual contents of the string are <= len so the rest can be filled with spaces.

  int currLen = strlen(string);

  for (int i=0; i<len; i++) {
    if (i > currLen - 1) {newStr[i] = ' ';}
    else {newStr[i] = string[i];}
  } 
}

void wait(void){
  // function to wait for the TIM16 to be done sending pulses to the motor.

  int status = checkStatus();
  while (status == 0){status = checkStatus();}
}


void sendTitle(const char title[]) {
  // Function to send the title to the FPGA via SPI, where it will put on the display

  char screenTitle[16];
  fillString(title, screenTitle, 16); // The FPGA expects 16 characters, so fill the rest 
  // of the title with spaces instead of null characters.

  digitalWrite(PA10, 1); // indicate that a title is being sent
  digitalWrite(PA11, 1); // raise spiLoad

  for (int i=0; i <16; i++){
    spiSendReceive(screenTitle[i]);
  }

  digitalWrite(PA11, 0); // drop spiLoad
}

void sendNote(const char note[]) {
  // Function to send the note to the FPGA via SPI, where it will put on the display

  char screenNote[3];
  fillString(note, screenNote, 3);  // The FPGA expects 16 characters, so fill the rest 
  // of the title with spaces instead of null characters.

  digitalWrite(PA10, 0); // indicate that a note is being sent
  digitalWrite(PA11, 1); // raise spiLoad

  for (int i=0; i <3; i++){
    spiSendReceive(screenNote[i]);
  }

  digitalWrite(PA11, 0); // drop spiLoad
}

float goToPos(float currPosition, float nextPosition) { 
  // function to go to the next position (given in cm) using the motor
  // and update the current one.

  float dist = currPosition - nextPosition; // in cm
  int steps = dist*CM2STEP;
  float realNextPos = currPosition - steps*STEP2CM; // calculate the next position since we won't hit next position exactly.
  if (steps < 0) {steps = -steps;}
  
  if (dist < 0){ setDirection(0); } 
  else { setDirection(1); }
  
  if (steps == 0) {} // do nothing if we're already in the right place
  else {
    setFrequency(FREQ, steps, 1); // sends steps to motor
    wait(); // waits for step sending timer to be done counting up steps
  }
  return realNextPos;
}


void setup(void) {
  // setup function to ensure all the clocks and configuration registers are turned on.

  // Enable GPIOA, B, C, TIM16 clock
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);
  RCC->APB1ENR1 |= (RCC_APB1ENR1_TIM6EN);

  
  initSPI(1, 0, 0);
  configureGPIO();
  
  // initialize TIM6 for delay, TIM16 for sending pulses to the stepper controller
  initTIM(TIM6);
  configureTIM16();

  pinMode(PA11, GPIO_OUTPUT);  // LOAD
  pinMode(PA10, GPIO_OUTPUT);   // titleNote
  pinMode(PA2, GPIO_INPUT);    // starter pin
  pinMode(PA12, GPIO_OUTPUT);  // fan cntrl pin

  delay_millis(TIM6, 200)// wait for LCD to startup before sending data.

}


/*********************************************************************
*
*       main() 
*
*  Function description
*   initialize data to play, send the title to the screen,
*   then play the song by putting the correct notes on the screen
*   and moving the motor to the right place
*/
int main(void) {
  struct song songToPlay = harry_potter; // LOAD IN SONG DATA HERE

  float currPosition = 0; // in steps away from zero in cm
  float nextPosition;

  setup();
  sendTitle(songToPlay.title);

  while(1) {

    while(digitalRead(PA2)){} // wait until button press to start song
    
    digitalWrite(PA12, 1); // turn fan on
    delay_millis(TIM6, 3000); // wait 3 seconds for the fan to start up

    for (int i = 0; i < songToPlay.length; ++i){
      
      sendNote(songToPlay.notes[i]); // send the next note
      nextPosition = getLoc(songToPlay.notes[i]); // get the next location
      currPosition = goToPos(currPosition, nextPosition); // go to that location
      delay_millis(TIM6, songToPlay.durations[i]); // wait for duration of note

    }
    sendNote("end"); // at the end of the song, turn off the dfan and reset the motor.
    digitalWrite(PA12, 0);
    currPosition = goToPos(currPosition, 0);
  }
}


/*************************** End of file ****************************/
