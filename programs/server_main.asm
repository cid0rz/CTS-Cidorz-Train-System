##DEPOT MAIN SERVER
hlt
clr
mov r1 1[virtual-signal=signal-grey] ;grey is main polling signal
:polling  ;ask all the requesters if they need anything
mov out1 r1
mov out1 0
slp 2
fir r3 [virtual-signal=signal-station-number] ;check for reply form requester
bgt r3 0 :search_prov  ;if there is reply search for a provider to fulfill the order
inc r1                 ;if not increase the polling count
bge r1 100 3           ;if we polled all the requesters, start from the begining
jmp :polling           ;else: poll next requester
:search_prov  ;search for a suitable provider
fir r4 [virtual-signal=signal-L]  ;read locomotives allowed by requester
fir r5 [virtual-signal=signal-W]  ;read wagons allowed by requester
mov r2 red1                       ;read actual goods requested
mov r8 1[virtual-signal=signal-yellow] ;set the starting polling signal for providers (yellow)
:loop_prov   ;send to the provider polling signal + basic data for checks
mov out1 r8  ;send polling signal
mov out1 0
mov out1 r2  ;send goods
mov out1 r4  ;send requested locos
mov out1 r5  ;send requested wagons
mov out1 0
fig r6 r2    ;retrieve stack size for demanded item and start the calculations while provider checks
mul r6 40    ;40 slots per wagon
mul r6 r5    ;r5 wagons per train (so r6 stores how much will be sent per train)
slp 3        ;provider is SLOW! damn! xD
fir r7 [virtual-signal=signal-green]  ;check for green or ask next provider
bne r7 0 :book          ;if we got a green we got a confirmation so we book
beq r8 100 :not_found   ;if we got to provider 100 (you can adjust those limits) there is no suitabel provider
inc r8                  ;increas polling provider signal
jmp :loop_prov          ;continue looping
:book  ;book on provider and requester and finally trains
div r2 r6               ;calulate number of trains
inc r2                  ;round up so we dont get train filling problems
sst r2 [virtual-signal=signal-Z] ;we set n of trains to be sent to Z signal
:reply_requester        ;confirm order to the requester        
mov out1 r1             ;send requester number (to activate req but will be recorded by the PROV as well)
mov out1 r2             ;send Z (will be recorded by PROV as well)
mov out1 0
mov out1 r7             ;send provider number to requester (for bookeeping and debugging) 
mov out1 0
bas r2 [virtual-signal=signal-red] :polling ;if we didnt find a suitable provider we continue polling following requesters
:book_trains                                ;else we book trains
mov out1 1[virtual-signal=signal-white]     ;this signal will trigger a RUN in another fCPU that will handle the order
mov out1 r7                                 ;send prov number to handler (to send trains to)
mov out1 r2                                 ;send n of trains to handler
mov out1 r4                                 ;send n of locos to handler
mov out1 r5                                 ;send n of wagons to handler
mov out1 0
jmp 1
:not_found
mov r2 1[virtual-signal=signal-red]    ;we set the red flag as we didnt find a suitable provider
jmp :reply_requester                   ;we jump here to reply to requester with red and continue polling
