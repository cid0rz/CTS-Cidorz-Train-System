# CTS-Cidorz-Train-System
Programs running inside the fCPUs of a train scheduling system for the game Factorio as well as blueprints showcasing the functionality.
DISCLAIMER: It is not a plug and play system, you need to make a basic setup for it to work.
DISCLAIMER2: In these programs and the mock-up some values have been selected/altered to make it easy to show how the system works. The main "cheat" is the stack size used for wood that is 5, this allows us to fill a train with theoretically 5x40x4 = 800 wood. In case you want to transport real full trains of wood you need to change that value. You need to also add any goods you want to transport that are not in the dictionary. The dictionary is the 2 constant combinators that are near the server.

- [Introduction](#introduction)
- [Initial setup and general indications](#initial-setup-and-general-indications)
- [Detail Explanation on the big mock-up](#detail-explanation-on-the-big-mock-up)



## Introduction
The goal is to schedule trains to transport materials from supplying stations (Providers from now on) to demanding stations (Requesters from now on). The system works in the following way:
* There is a Depot station with the trains available to service a number of requester and providers, the depot has a server that continuously polls requesters to look for new needs. 
* When a Requester is asked it can send the items that it is missing together with other info such as number of locomotives and wagons the station is prepared for.
* Then the Depot polls all the providers looking for the first that can satisfy the full order. If it finds a suitable provider it confirms the order to both parts (after calculating the number of trains to dispatch) and proceeds to dispatch the trains. As soon as they are out, the Depot continues to poll for new requests.

## Initial setup and general indications
For the system to work you need to have installed [fCPU](https://mods.factorio.com/mod/fcpu) to be able to execute the asm programs of this repo and [smarter trains](https://mods.factorio.com/mod/SmartTrains) to be able to dynamically alter the train schedules and thus direct them properly.
All the stations (Depot, requester and provider) are on the same "line" so smarter trains will give each a unique ID that we will use. This is why you need to create the line before starting the fCPU's. The station number must be assigned before starting to run the program so the station must be added to the line before starting it. For convention the depot will be the first station of your line.

All the stations are connected with red wire, red wire is common to all main fCPU's as both input and output. All the main fCPUs have also green wire input with data private to that station (like ID, material, wagons accepted, etc.)

## Detail Explanation on the big mock-up
The big mock-up is a small train circuit to be able to test and examine the system. It consists on one depot with 2 binaries, 2 requesters and 2 providers. 
First of all let's see the configuration of the train line in smarter trains:

![line config](/images/stconfig.jpg)

As you can see all the stations are in the same line and depot is number one. Then the trains need to be added to the line and set to automatic. They will wait in the depot for the order.

There are some areas of interest in the mock-up that can be seen in the following image:

![mock-up areas](/images/mockup_areas.jpg)

In the picture you can see:

* in red the main server/brain of the system.
* in green two constant combinators that switch between R1/R2 and P1/P2 stations.
* in blue the feeder to release material to refill the providers:

![feeder detail](/images/feeder_detail.jpg)

Just put a negative quantity on the constant combinator and turn it on. It will release that amount from the chests to the current selected provider. To start as the default order is 2k wood I recommend to have -2.4k in that combinator for the first time.

To commission a station the procedure is similar to all of them but with some differences:

1. first you need to move the pointer on the auxiliary fCPU to the idle position, this position is in all three cases after the hlt in line four. So the auxiliary fCPU must have the pointer on the fifth line and must be ON but halted.
2. then you need to start the main fCPU of the station and verify it loads the data (the station ID, the L signal, the W signal and in case of requesters maybe the missing materials).
3. when you start the main server the station will reply in turn. If you need to add a new station it is not necessary to stop the system as long as you set it up properly before connecting to the common wire.

Here you can see an example of a requester station cabled and with the input signals on the green wire:

![requester](/images/requester.jpg)

For each requester the type of goods to request must be set in the program (line 9 of the REQ.asm file) and also the limit and wait time between checking for demand can be tweaked in lines 10 and 11 respectively. 

```x86asm
:check_req
fig r2 [item=wood]    ;retrieve demand   <-- change for the material you have the requester set up for
bge r2 1000 :listen   ;if needed try to book an order <-- 1000 is selected for the mock-up it is a small quantity
slp 3600              ;don't check inventory all the time <--
```
