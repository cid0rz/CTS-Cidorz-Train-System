# CTS-Cidorz-Train-System
Programs running inside the fCPU's of a train scheduling system for the game Factorio as well as blueprints showcasing the functionality.
DISCLAIMER: It is not a plug and play system, you need to make a basic setup for it to work. 



## Introduction
The goal is to schedule trains to transport materials from supplying stations (Providers from now on) to demanding stations (Requesters from now on). The system works in the following way:
* There is a Depot station with the trains available to service a number of requester and providers, the depot has a server that continuously polls requesters to look for new needs. 
* When a Requester is asked it can send the items that it is missing together with other info such as number of locomotives and wagons the station is prepared for.
* Then the Depot polls all the providers looking for the first that can satisfy the full order. If it finds a suitable provider it confirms the order to both parts (after calculating the number of trains to dispatch) and proceeds to dispatch the trains. As soon as they are out, the Depot continues to poll for new requests.

## Initial setup and general indications
For the system to work you need to have installed [fcpu](https://mods.factorio.com/mod/fcpu) to be able to execute the asm programs of this repo and [smarter trains](https://mods.factorio.com/mod/SmartTrains) to be able to dynamically alter the train schedules and thus direct them properly.
All the stations (Depot, requester and provider) are on the same "line" so smarter trains will give each a unique ID that we will use. This is why you need to create the line before starting the fCPU's. The station number must be assigned before starting to run the program so the station must be added to the line before starting it. For convention the depot will be the first station of your line. 

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

Just put a negative quantity on the constant combinator and turn it on. It will release that amount from the chests to the current selected provider. To start as the default order is 2k wood I recomend to have -2.4k in that combinator for the first time. 
