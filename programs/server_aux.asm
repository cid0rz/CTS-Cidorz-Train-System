##MAIN DEPOT TRAIN CONTROL (ORDER HANDLER) ;probably to understand the program you ned to see the circuit
:start
clr
hlt
mov r7 green1    ;read prov number
mov r2 green1    ;read Z (number of trains)
mov r4 green1    ;read n of locos (L)
mov r5 green1    ;read n of wagons (W)
sst r7 [virtual-signal=signal-P]  ;set signal type of provider to P
mov out1 r7  ;output required signals to the wire
mov out2 r4
mov out3 r5
:look_for_trains    ;there are filters on the depot that only allow to poll 1 station at a time depending on signal-info singnal
mov r8 10[virtual-signal=signal-info] ;we initiate the "depot polling signal" signal-info to 10
:loop_lft
mov out4 r8
slp 20
:check_departure
fir r1 [virtual-signal=signal-destination] ;check if we got any departure (there is a memory cell to register departures)
bgt r1 0 :check_z                          ;if we got a departure we check if there are still trains to dispatch
add r8 10                                  ;otherwise increase polling signal in 10
bge r8 100 :look_for_trains                ;if we got to the end of the available depot slots start from the first one
jmp :loop_lft
:check_z    ;check if there are still trains to dispatch
sub r2 1    ;substract the one that just left
mov out5 1[virtual-signal=signal-black] ;clean the memory cell
mov out5 0
beq r2 0 :end  ;if there are no more trains to dispatch, finish
jmp :loop_lft  ;otherwise loop
:end
mov out1 1[virtual-signal=signal-fcpu-run] ;send signbal to the main depot fCPU to start searching for providers again
mov out1 0
jmp :start
