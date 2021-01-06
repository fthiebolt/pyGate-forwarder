#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# eCOnect: PyGate reset
#
# Notes:
# - PyGate resets is about sx1308 and SX1257. These chips use a *positive* reset
#
# F.Thiebolt    Dec.20  inverted GPIO4 due to the transistor that drives
#                       the PyGate's SX1xxx_RST lines on Jetson Nano (no transistor for RPi)
# F.Thiebolt    Nov.20  initial release
#


# #############################################################################
#
# Import zone
#
import sys
import time

rst_initial_value = None
# GPIO @ Nvidia Jetson Nano
# [dec.20] note that RPi.GPIO also exists on Jetson !
try:
    if rst_initial_value is None:
        import Jetson.GPIO as GPIO
        #import RPi.GPIO as GPIO
        print("Jetson Nano detected ...")
        # initial value for RST line
        rst_initial_value=GPIO.LOW     # buffer or direct connexion
        #rst_initial_value=GPIO.HIGH     # transistor
except:
    pass
# GPIO @ RPi
try:
    if rst_initial_value is None:
        import RPi.GPIO as GPIO
        print("RPi detected ...")
        rst_initial_value=GPIO.LOW
except:
    pass


# #############################################################################
#
# Global variables
#

# Reset pin
reset_pin = 4    # BCM pin 4, SYSFS pin 216, BOARD pin 7



# #############################################################################
#
# MAIN
#
def main():

    # Global variables

    # Pin Setup:
    GPIO.setmode(GPIO.BCM)  # BCM pin-numbering scheme from Raspberry Pi

    # set pin as an output pin with optional initial state of LOW
    GPIO.setup(reset_pin, GPIO.OUT, initial=rst_initial_value)

    #print(f"{_measureTime}  Topic: {topic:>32}  Payload: {payload}" )
    print(f"Now about to reset PyGate's SX1308 & SX1257 with GPIO {reset_pin} and initial value as {rst_initial_value} ...")
    time.sleep(0.5)
    #time.sleep(5)

    try:
        # invert
        GPIO.output(reset_pin, not(GPIO.input(reset_pin)))
        time.sleep(2)

        # back to original state
        GPIO.output(reset_pin, not(GPIO.input(reset_pin)))
        time.sleep(0.5)

        print(f"PyGate has been reset!")
    except Exception as ex:
        prinf(f"Raised exception: {ex}")
        pass

    finally:
        GPIO.cleanup()


#
# Execution or import
if __name__ == "__main__":

    #
    print("\n###\n[eCONect] PyGate reset app.\n###")

    main()

