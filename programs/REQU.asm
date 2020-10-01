##REQUESTER STATION
hlt
:load_data
clr
fig r3 [virtual-signal=signal-station-number] ;load station number
fig r4 [virtual-signal=signal-L] ;load n of locos
fig r5 [virtual-signal=signal-W] ;load n of wagons
:check_req
fig r2 [item=wood]    ;retrieve demand
bge r2 1000 :listen   ;if needed try to book an order
slp 3600              ;don't check inventory all the time
jmp :check_req
:listen               ;loop to check for polling signal
btr [virtual-signal=signal-grey]
fir r1 [virtual-signal=signal-grey]
bne r1 r3 :listen     ;if recieved signal is not your ID: loop
:answer               ;if recieved is your ID answer
mov out1 r3           ;send sequentially needed data
nop
mov out1 r4
mov out1 r5
mov out1 r2
mov out1 0 
:listen2             ;wait for final reply after confirmation with provider
btr [virtual-signal=signal-grey]
fir r1 [virtual-signal=signal-grey]
bne r1 r3 :listen2   ;if recieved signal is not your ID: loop
mov r6 red1          ;read number of trains (Z) or red color as no provider available
mov r7 red1          ;record provider number to be able to debug
:check_confirmation
bad r6 [virtual-signal=signal-Z] :load_data ;If we got a red, reboot the system.
mov out1 1[virtual-signal=signal-white] ;this will activate other fCPU that will handle the order
mov out1 r6
mov out1 0
jmp 1
