#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# eCOnect: PyGate reset
#
# Notes:
# - PyGate resets is about sx1308 and SX1257. These chips use a *positive* reset
#
# F.Thiebolt    Nov.20  initial release
#


# #############################################################################
#
# Import zone
#
import sys
import time
# GPIO @ RPi
try:
    import RPi.GPIO as GPIO
except:
    pass
# GPIO @ Nvidia Jetson Nano
try:
    import Jetson.GPIO as GPIO
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
    GPIO.setup(reset_pin, GPIO.OUT, initial=GPIO.LOW)

    #print(f"{_measureTime}  Topic: {topic:>32}  Payload: {payload}" )
    print(f"Now about to start PyGate chips reset with pin {reset_pin} ...")
    time.sleep(0.5)

    try:
        # invert
        GPIO.output(reset_pin, not(GPIO.input(reset_pin)))
        time.sleep(0.5)

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

