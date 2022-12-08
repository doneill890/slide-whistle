
#include "tim1.h"

void configureTIM16(){
  // function for enabling all the necessary registers to have TIM16 work in
  // pulse mode and send an arbitrary number of pulses. 

  *RCC_APB2EN |= (1 << 17);     // enable PCLK2

  *TIM16_CCMR1 |= (1 << 6);     // set OC1M[2:0] = 110 to enter PWM mode 1
  *TIM16_CCMR1 |= (1 << 5);

  *TIM16_CCMR1 |= (1 << 3);     // enable OC1PE for read/write operations on the preload register
  *TIM16_CR1 |= (1 << 7);       // ARPE auto-relaod preload enable
  *TIM16_CCER |= (1 << 0);      // capture/compare 1 output enable
  *TIM16_CCER |= (1 << 2);      // OC1N is output now, idk what this does

  *TIM16_BDTR |= (1 << 15);     // main output enable
  *TIM16_CCER |= (1 << 0);      // capture/compare 1 output enable
  *TIM16_CCER |= (1 << 2);      // capture/compare 1 complementary output enable
  
  TIM16->DIER |= _VAL2FLD(TIM_DIER_UIE, 1); // update interrupt enable
  TIM16->SR &= ~_VAL2FLD(TIM_SR_UIF, 1); // clear update interrupt flag
}

void configureGPIO(){
  // function for configuring GPIO block A to send pulses from TIM16.

  *RCC_AHB2ENR |= (1 << 0);         // enable GPIO A clock

  *GPIOA_MODER &= ~(1 << 2*6);      // set pin A6 to alternate function mode
  *GPIOA_MODER |= (1 << (2*6+1));
  
  int pin = 5;
  GPIOA->MODER |= (0b1 << 2*pin);  // set pin A5 as output
  GPIOA->MODER &= ~(0b1 << (2*pin+1));

  GPIOA->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL6, 0b1110); // set alternate function for PWM
}

void setDirection(int val) {
    // function to set the pin indicating motor direction correctly
    // 1 is moving the slide closer to the mouthpiece for higher notes
    // 0 is moving the slide away from the mouthpiece for lower notes

    int pin = 5;
    if (val) {
      GPIOA->ODR |= (1 << pin);
    }
    else{
      GPIOA->ODR &= ~(1 << pin);
    }
}

void setFrequency(int f, int steps, int on){
  // function to set the frequency of the pulses sent to the motor and then send 
  // [steps] number of pulses.

  TIM16->SR &= ~_VAL2FLD(TIM_SR_UIF, 1);   // clear update interrupt
  *TIM16_PSC = 1; // in-comping clock is 4 GHz, clock frequency after prescalar is 2 GHz

  *TIM16_ARR = (int) 2*1000000/f;
  if (on){
    *TIM16_CCR1 = (int) 2*1000000/(2*f);
  } 
  else{
    *TIM16_CCR1 = 0;
  }

  TIM16->RCR &= _VAL2FLD(TIM_RCR_REP, 0); // clear RCR rep value
  TIM16->RCR |= _VAL2FLD(TIM_RCR_REP, steps-1);  // set RCR to number of counts
  TIM16->EGR |= _VAL2FLD(TIM_EGR_UG, 1);   // update generate
  TIM16->CR1 |= _VAL2FLD(TIM_CR1_OPM, 1);  // enable one pulse mode

  TIM16->SR &= ~_VAL2FLD(TIM_SR_UIF, 1);   // clear update interrupt
  TIM16->CR1 |= _VAL2FLD(TIM_CR1_CEN, 1);  // enable counter
}


int checkStatus(){
  // function to check if the ulses have completed sending (an update interrupt event raises.

  return _FLD2VAL(TIM_SR_UIF, TIM16->SR);  // check for update interrupt
  
}
