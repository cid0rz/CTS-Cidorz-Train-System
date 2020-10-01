##PROV STATION ORDER HANDLER
:start
clr
hlt            ;configuration is similar to requester handler, it starts reading data
mov r6 green1  ;recieve Z number of trains
mov r7 green1  ;recieve destination R
mov r8 green1  ;recieve total qty of resources of the order
div r8 r6      ;store the quantity per train on r8
:wait_for_train
btr [virtual-signal=signal-T]  ;wait for train to be present to check if it is loaded
:wait_for_loading
slp 10
fir r1 r8                    ;read from station train contents
blt r1 r8 :wait_for_loading  ;if not enough continue loading
mov out1 r7                  ;output req destination signal to station, allowing the train to leave (and indication which req to go to)
slp 10                       ;give the train time to leave
mov out1 0                   ;reset
sub r6 1                     ;account for the train that left
bgt r6 0 :wait_for_train     ;if there are more trains to come, wait
mov out1 1[virtual-signal=signal-fcpu-run]  ;if not tell the main provider fCPU to run again
mov out1 0  ;clear
jmp :start  ;restart
