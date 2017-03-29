# RacketD

Run Racket as a daemon, for significantly better startup times

```sh
> echo '
#lang racket

(displayln "I\'m running serverside but my output gets sent to the client")
(define val "I\'m the return value")
val
' > test.rkt
> time racket test.rkt             # uncompiled
I'm running serverside but my output gets sent to the client
"I'm the return value"
0.26user 0.04system 0:00.31elapsed 99%CPU (0avgtext+0avgdata 66736maxresident)k
0inputs+0outputs (0major+12439minor)pagefaults 0swaps
> raco make test.rkt
> time racket compiled/test_rkt.zo # compiled
I'm running serverside but my output gets sent to the client
"I'm the return value"
0.22user 0.02system 0:00.25elapsed 98%CPU (0avgtext+0avgdata 64984maxresident)k
0inputs+0outputs (0major+9635minor)pagefaults 0swaps
> time racketd-client test.rkt     # racketd
I'm running serverside but my output gets sent to the client
"I'm the return value"
0.00user 0.00system 0:00.14elapsed 2%CPU (0avgtext+0avgdata 6640maxresident)k
0inputs+0outputs (0major+114minor)pagefaults 0swaps
```

This makes it totally possible to use Racket as a shell script replacement, or
to replace `bc`/`dc` with a simple script like so

```sh
echo "($@)" | racketd-client
```

Then you can give it a funky name (I chose `q.rkt`) and sum from the shell with
`cat some-numbers.txt | xargs q.rkt +`
