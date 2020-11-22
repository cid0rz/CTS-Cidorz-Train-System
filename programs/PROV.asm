##PROVIDER STATION
hlt
clr
:load_data
fig r3 [virtual-signal=signal-station-number] ;load station number
fig r4 [virtual-signal=signal-L] ;load n of locos
fig r5 [virtual-signal=signal-W] ;load n of wagons
:listen
btr [virtual-signal=signal-yellow]    ;Providers will listen to yellow
fir r1 [virtual-signal=signal-yellow] 
bne r1 r3 :listen ;If recieved signal is not your ID continue listening
:answer  ;perform a series of checks and only asnwers with green if we are ready to fulfill the request
mov r8 red1  ;recieve demanded qty of resource
sub r4 red1  ;recieve number of locos (and substract from the allowed in this station)
sub r5 red1  ;recieve number of wagons (and substract from the allowed in this station)
fig r2 r8    ;look if we have what the network requests
blt r2 r8 :load_data  ;look if we have enough and if not we go back to start
bne r4 0 :load_data  ;check if n of locos is adequate
bne r5 0 :load_data  ;check if n of wagons is adequate
sst r1 [virtual-signal=signal-green]  ;if we arrived here we can fulfill so we set signal to green
mov out1 r1  ;we reply (the absence of reply is a negative reply)
mov out1 0
slp 4        ;wait for the train number calculation performed in the depot
fir r7 [virtual-signal=signal-grey]  ;recieve the requester where we have to send the trains to
fir r6 [virtual-signal=signal-Z]     ;recieve number of trains that will perform the service
sst r7 [virtual-signal=signal-R]     ;set the revieced signal to R (preparing it for the smart-train-stop)
mov out1 1[virtual-signal=signal-white] ; as in the requester this signal will trigger a RUN in another fCPU that will handle the order
mov out1 r6 ;send to the handler the n of trains
mov out1 r7 ;send to the handler the destination
mov out1 r8 ;send to the handler the total quantity to be distributed on the Z trains
mov out1 0
jmp 1
