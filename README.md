# Car-Crash-Alert
MIPS program to simulate a car crash alert using polling

CS 264: Computer Organization and Assembly Programming<br>
Lab 3 (Part 2)

Assignment Details
------------------
- Write a program that allows you to simulate a car crash alert program. The keyboard will be used as inputs. The display will print the scenario based on input using the polling method.
- Ignore all inputs other than A, B, C, and S.
- If the car is already in a mode that the user inputs, nothing changes.

Functions
---------
- A: (accelerate; assume the car is accelerating and no longer braking)
  - Print "car acel"
- B: (brake; default; assume the car is braking and no longer accelerating)
  - Print "car brak"
- C: (crash)
  - Print "car crash"
  - If speed is equal to or below 15, print "Airbag no deploy"
  - If speed is above 15 and below 45, print "Airbags deployed"
  - If speed is equal to or above 45 and braking, print "Airbags deploy Ambulance no alert"
  - If speed is equal to or above 45 and accelerating, print "Airbags deploy Ambulance alerted!"
- S: (speed; default = 0)
  - User inputs numbers until next S is typed
  - This will be the speed of the vehicle
