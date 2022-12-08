---
layout: page
title: Documentation
permalink: /doc/
---

# Schematics
<!-- Include images of the schematics for your system. They should follow best practices for schematic drawings with all parts and pins clearly labeled. You may draw your schematics either with a software tool or neatly by hand. -->

## Overall Block Diagram

<div style="text-align: left">
  <img src="../assets/schematics/block_diagram.png" alt="logo" width="600" />
</div>

## Overall system schematic

<div style="text-align: left">
  <img src="../assets/schematics/system_schem.png" alt="logo"/>
  <p style="font-style: italic"> Overall Schematic of entire system, including MCU, FPGA, fan, motor, and LCD. Note that both MCU and FPGA are powered via a USB connection, and the 12V values come from benchtop power supplies. </p>
</div>

# Source Code Overview

The source code for the project is located in the Github repository [here](https://github.com/doneill890/slide-whistle/tree/main/src). 

The MCU files there can be uploaded to the STM32L432KC microcontroller on the Nucleo development board. They are used to generate the correct signals for the fan power control, motor controller IC, and SPI transactions to the FPGA. The FPGA files were uploaded to the ICE40UP5K FPGA on the UPduino v3.1 development board. These describe hardware that takes in SPI messages from the MCU and interfaces with the LCD to print the desired text. 
# Bill of Materials
<!-- The bill of materials should include all the parts used in your project along with the prices and links.  -->

| Item | Part Number | Quantity | Unit Price | Vendor | Link |
| ---- | ----------- | -------- | ---------- | ------ | ---- |
| Lukmaa Slide Whistle | B091JVNBP9 | 1 | $9.99 | Amazon | [link](https://www.amazon.com/Lukmaa-Whistle-Instrument-Parent-Child-Stuffers/dp/B091JVNBP9/ref=sr_1_11?crid=2WIX541U4JRYK&keywords=slide+whistle&qid=1666912591&qu=eyJxc2MiOiI0LjgxIiwicXNhIjoiNC4xNyIsInFzcCI6IjQuMDIifQ%3D%3D&sprefix=slide+whistle%2Caps%2C164&sr=8-11) |
| Focus LCDs Character Display | C162D-BW-LW65 | 1 | $13.70 | Digikey | [link](https://www.digikey.com/en/products/detail/focus-lcds/C162D-BW-LW65/13683627) |
| GDSTIME 5015 Fan | C162D-BW-LW65 | 1 | $17.99 | Amazon | [link](https://www.amazon.com/gp/product/B089Y3QPYF/ref=ox_sc_act_title_2?smid=A235LT0EDLFSAR&psc=1) |
| Pololou Stepper Controller Breakout | A4988 | 1 |  | Declan O'Niell | |
| Nucleo STM32L432KC Microcontroller | NUCLEO-L432KC | 1 |  | E155 kit | [link](https://www.st.com/en/evaluation-tools/nucleo-l432kc.html) |
| UPDuino v3.1 ICE40 UP5K FPGA |  | 1 |  | E155 kit | [link](https://upduino.readthedocs.io/en/latest/introduction/introduction.html) |
| PLA for 3D printing | | 500g |  | HMC Makerspace | |
| NPN Transistor | 2N 3904 | 1 |  | Engineering stockroom | |
| 10K Potentiometer | | 1 |  | Engineering stockroom | |
| SPDT Push-Button Switch | | 1 |  | E155 kit | | 
| 47 μF Polarized Capacitor | | 1 |  | Engineering stockroom | |
| 1KOhm Resistor | | 1 |  | Engineering stockroom | |

**Total cost: $41.68**
