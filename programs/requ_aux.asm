##REQ STATION ORDER HANDLER
:start
clr
hlt              ;this configuration allows you to start reading data straight after the RUN signal
mov r6 green1    ;pointer will start here, this records Z the number of trains to wait
mov out1 1[virtual-signal=signal-D]     ;requester stations just need to pint the train back to depot with D=1 signal
:wait_for_train
btr [virtual-signal=signal-destination] ;when a train leaves smart-train-stop will emit 1 tick signal of this type
sub r6 1         ;account for teh train just left
bgt r6 0 :wait_for_train ;check if there are more trains to come
mov out1 1[virtual-signal=signal-fcpu-run] ;if no more trains send main requester fCPU RUN signal
mov out1 0
jmp :start
