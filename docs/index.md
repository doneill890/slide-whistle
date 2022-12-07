---
layout: page
title: Project Overview
permalink: /
exclude: true
---

# Project Abstract

In this project, the team aims to create an automated slide whistle that can play a piece of music on its own. The input to the system is an array of notes and durations and the title of the song. A microcontroller (MCU) takes this information and calculates the signals to send to a stepper motor and fan. The fan is directed to blow into the mouthpiece of the slide whistle and the motor controls a rack and pinion attached to the slide whistle pull rod, thus playing music. The MCU also sends the name of the song and the current note over a serial peripheral interface (SPI) to a field programmable gate array (FPGA) which displays that information on an LCD. All of these signals are synchronized so that the slide whistle armature moves and the fan blows to play the correct note for the correct duration and the note is displayed on the LCD all at the same time. 

# Project Motivation

A slide whistle can be a fun and pleasing instrument to play tunes with, but the tedious process of holding the slide whistle, blowing into it, and moving the rod to the correct position to play the desired notes can quickly become laborious and tiresome. The *Autonomous* Slide Whistle removes these inconveniences, providing the user with musical enjoyment at the press of a button.

# System Block Diagram

<div style="text-align: left">
  <img src="./assets/schematics/block_diagram.png" alt="logo" width="600" />
</div>

The overall system block diagram is shown above. The microcontroller takes song information (a series of notes) and plays the notes on the slide whistle by controlling a fan system and stepper motor that moves the rod. Meanwhile, it also communicates with the FPGA over a serial peripheral interface, sending the name of the song and the current note being played for the FPGA to display on the LCD.
