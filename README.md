# CTS-Cidorz-Train-System
Programs running inside the fCPUs of a train scheduling system for the game Factorio as well as blueprints showcasing the functionality.

DISCLAIMER: It is not a plug and play system, you need to make a basic setup for it to work. The system should be well suited for medium load average size factories. It is not super optimized by default, nor to load the trains fully, nor to any extent. Its main goal is ease of use and easy to hack while being usable and fun. If you make some different design choices (changing the programs here and there) you can modify the system to your needs.

DISCLAIMER2: In these programs and the mock-up some values have been selected/altered to make it easy to show how the system works. The main "cheat" is the stack size used for wood that is 5, this allows us to fill a train with theoretically 5x40x4 = 800 wood. In case you want to transport real full trains of wood you need to change that value. You need to also add any goods you want to transport that are not in the dictionary. The dictionary is the 2 constant combinators that are near the server. Recently a new instruction has been provided in fCPU to retrieve the stack size of an item. It is offered as a substitute for the manually built dictionary in line (near line 26 in main server program) and can be found as `uiss r6 r2`.

- [Introduction](#introduction)
- [Initial setup and general indications](#initial-setup-and-general-indications)
- [Explanation of the system and small mock-up](#explanation-of-the-system-and-small-mock-up)
- [Detail Explanation on the big mock-up](#detail-explanation-on-the-big-mock-up)


## Introduction
The goal is to schedule trains to transport materials from supplying stations (Providers from now on) to demanding stations (Requesters from now on). The system works in the following way:
* There is 1 Depot station with the trains available to service a number of requester and providers, the depot has a server that continuously polls requesters to look for new needs. I have tested with networks of around 100 stations with no problems. I think if the network is bigger than that you split in multiple depots that serve stations that are nearby.
* When a Requester is asked it can send the items that it is missing together with other info such as number of locomotives and wagons the station is prepared for.
* Then the Depot polls all the providers looking for the first that can satisfy the full order. If it finds a suitable provider it confirms the order to both parts (after calculating the number of trains to dispatch) and proceeds to dispatch the trains. As soon as they are out, the Depot continues to poll for new requests.

## Initial setup and general indications
For the system to work you need to have installed [fCPU](https://mods.factorio.com/mod/fcpu) to be able to execute the asm programs of this repo and [smarter trains](https://mods.factorio.com/mod/SmartTrains) to be able to dynamically alter the train schedules and thus direct them properly.
All the stations (Depot, requester and provider) are on the same "line" so smarter trains will give each a unique ID that we will use. This is why you need to create the line before starting the fCPU's. The station number must be assigned before starting to run the program so the station must be added to the line before starting it. For convention the depot will be the first station of your line.

All the stations are connected with red wire, red wire is common to all main fCPU's as both input and output. All the main fCPUs have also green wire input with data private to that station (like ID, material, wagons accepted, etc.). It has green output to communicate with the auxiliary fCPU as well.

To commission a station the procedure is similar in all of them but with some differences:

1. Add the station to the train line of the depot you want to add the station to.
2. first you need to move the pointer on the auxiliary fCPU to the idle position, this position is in all three cases after the hlt in line 4. So the auxiliary fCPU must have the pointer on line 5 and must be ON but halted.
3. then you need to start the main fCPU of the station and verify it loads the data (the station ID, the L signal, the W signal and in case of requesters maybe the missing materials).
4. Wire the red cable from the substation to your red main network. It is not necessary to stop the system as long as you set it up properly before connecting to the common wire.

Here you can see an example of a requester station cabled and with the input signals on the green wire:

![requester](/images/requester.jpg)

For each requester the type of goods to request must be set in the program (line 9 of the REQ.asm file) and also the limit and wait time between checking for demand can be tweaked in lines 10 and 11 respectively. 

```asm
:check_req
fig r2 [item=wood]    ;retrieve demand   <-- change for the material you have the requester set up for
bge r2 1000 :listen   ;if needed try to book an order <-- 1000 is selected for the mock-up it is a small quantity
slp 3600              ;don't check inventory all the time <--
```


## Explanation of the system and small mock-up
The small mock-up lets you examine the system with reduced footprint and less running from one place to another. It consist on one station of each type with the auxiliary systems to test their functionalities.
![small mockup](/images/small_mockup.jpg)
In the picture we can see the layout of it with different color markings:
* In blue squares we can see the main fCPU's of each station.
* There are 2 orange dots near constant combinators that assign an ID to each station (this is in order not to setup a line in smarter trains for it to work)
* The green squares are either [pushbuttons](https://mods.factorio.com/mod/pushbutton) or constant combinators to help reset the stations (they simulate a train stopped in the stop). The trains stopped must be set to automatic for the stations to be able to clear properly.

If the three stations are set as described in the previous section with the auxiliary fCPUs ready to run but halted and the main fCPU's runnig you can start the main server. In the small mock-up with the preset values you should obtain a booking like this:

| Server Main | Requester | Provider |
|---|---|---|
| ![server](/images/main_depot_loaded.jpg) | ![requester](/images/req_loaded.jpg) | ![provider](/images/prov_loaded.jpg)|

I left the fCPUs without clearing until the train left so it is easy to see if something goes wrong. The main signals and their meaning is as follows:

* grey signal is Requester ID
* green signal is Provider ID
* Z is the number of trains to dispatch
* L is the number of locomotives per train (in case different trains are used for different purposes on the same depot, this has not been tested)
* W is the number of wagons per train
The goods being exchanged (in this case wood) appear in many places since it is used for some calculations.

Both of the aux fcpu's on providers and requesters are pretty straight forward, they basically copy Z and the quantity to load on each train for the provider and count trains. For the depot tough is a bit more complicated since correct train composition must be selected. I usually lay 10 depot stations and a big stacker or group of stackers before them. Then orders are loaded, trains are dispatched and new trains come to fill the depot very fast. As I said I have not tested with different train compositions but you'd need to filter the trains in order to have every composition always available to dispatch.
Lets have a look in the case of the example order how the aux depot is loaded:

   ![depot_aux](/images/depot_aux_loaded.jpg)

Z,L and W have the meaning already explained. P is the provider the trains need to be sent to. i (signal info) is a signal I use to iterate over all the stations present in the depot. This way I am sure I dispatch 1 train at a time.

## Detail Explanation on the big mock-up
The big mock-up is a small train circuit to be able to test and examine the system. It consists on one depot with 2 binaries, 2 requesters and 2 providers. 
First of all let's see the configuration of the train line in smarter trains:

![line config](/images/stconfig.jpg)

As you can see all the stations are in the same line and depot is number one. Then the trains need to be added to the line and set to automatic. They will wait in the depot for the order. The conditions on the line must be set to signal# as seen in the screenshot so the trains read their destination before leaving the stops. 

There are some areas of interest in the mock-up that can be seen in the following image:

![mock-up areas](/images/mockup_areas.jpg)

In the picture you can see:

* in red the main server/brain of the system.
* in green two constant combinators that switch between R1/R2 and P1/P2 stations.
* in blue the feeder to release material to refill the providers:

![feeder detail](/images/feeder_detail.jpg)

Just put a negative quantity on the constant combinator and turn it on. It will release that amount from the chests to the current selected provider. To start as the default order is 2k wood I recommend to have -2.4k in that combinator for the first time.

