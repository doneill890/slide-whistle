#ifndef TIM16_H
#define TIM16_H

#include <stdint.h>
#include <stm32l432xx.h>

#define RCC_BASE_ADR (0x40021000UL)
#define TIM16_BASE_ADR (0x40014400UL)

// general setup
#define RCC_APB2EN ((uint32_t *) (RCC_BASE_ADR + 0x60))
#define TIM16_CR1 ((uint32_t *) (TIM16_BASE_ADR + 0x00))
#define TIM16_EGR ((uint32_t *) (TIM16_BASE_ADR + 0x16))
#define TIM16_CCER ((uint32_t *) (TIM16_BASE_ADR + 0x20))
#define TIM16_CNT ((uint32_t *) (TIM16_BASE_ADR + 0x24))
#define TIM16_PSC ((uint32_t *) (TIM16_BASE_ADR + 0x28))
#define TIM16_ARR ((uint32_t *) (TIM16_BASE_ADR + 0x2C))
#define TIM16_BDTR ((uint32_t *) (TIM16_BASE_ADR + 0x44))

// pwm setup
#define TIM16_CCR1 ((uint32_t *) (TIM16_BASE_ADR + 0x34))
#define TIM16_CCMR1 ((uint32_t *) (TIM16_BASE_ADR + 0x18))

// gpio setup
// need to set PA6 as AF14 to get TIM16_CH1

#define RCC_AHB2ENR ((uint32_t *) (RCC_BASE_ADR + 0x4C))

//#define GPIOA_BASE (0x48000000UL) // Base register
#define GPIOA_MODER ((uint32_t *) (GPIOA_BASE + 0x00))
#define GPIOA_AFRL ((uint32_t *) (GPIOA_BASE + 0x20)) // GPIO alternate function low register

void configureGPIO();
void configureTIM16();
void setFrequency(int f, int steps, int on);
int checkStatus();
void setDirection(int val);

#endif

