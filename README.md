Description
===========
Class project to prove classical computers aren't any less powerful
than D-Wave One. Solve the combinatorial optimization problem with
better success probabilities and lower running times.

Files
--------
* download.pl - Script to download the test files from 
[Arxiv](http://arxiv.org/src/1305.5837v1/anc/). The zipped file
wasn't extracting properly for me, so had to do this.

* sa.pl - Version 1 of the classical Simulated Annealing algorithm.
Gets good success probabilities. Running time = 4s (per run).

* sa2.pl - Version 2. Implementation optimized to reduce running
time to 0.8s.

* sa3.c - Version 3. Translation of version 2 in C.
Running time = 50ms.

* sa4.c - Version 4 (LATEST). Slightly more optimized than (3),
and should be compiled with `gcc -O3`. Running time = 35ms.

* admin.pl - Wrapper script for invoking the executable for
different test instances.

Results
--------
I've collected results for 3 different Runs-per-Test-Instance values
: R = {1, 10, 100}.
* R.csv - Success probability numbers for individual instances.
* R.png - Histogram plots.

So far, the results are superior to D-Wave One's.
It remains to be seen how the implementation performs for R = 1000.

Algorithm
==========
Classical Simulated Annealing with MAX = 1000000 (one million)
iterations. The minimum energy found over the course of the
iterations is returned as its output.

Iterations
-----------
Smaller values of MAX (like 100000, 10000, 1000) didn't give
comparably good results, and higher values didn't improve the
success probabilities to an extend that they were worth the
higher running costs. Hence this sweet spot :)

Temperature Schedule
-------------------------
* Initial Temperature T0 = 1
* Final Temperature   Tf = 0
* Temperature Change  dT = (Tf - T0) / MAX = - 0.000001
* Cooling down formula: T = T + dT
  - Turned out it is better to cool down **only** when a higher
energy state has been accepted.
  - This happens in 10% of the iterations, so roughly 100K times.
  - In other cases, (rejecting flip or accepting lower energy state)
leave the temperature unchanged.


Optimizations
--------------
The key observations in improving the running time of the
algorithm were the following.

* Every iteration calculates the energy change dH brought about
by a single spin flip. That's MAX = 1 million calculations.
* The spin flip is "in the air" unless it is accepted, and that
happens only 10% of the time. So, 90% of all spin flips are 
rejections and are not worth actually *doing*.
* Turns out that selecting particles (to flip spin) *sequentially*
is as good as choosing them at random.

The equivalent changes were as follows.

1. dH calculation was reduced to a single lookup, indexed by particle
number. 
2. Flips are saved only when they are accepted. Also, this is when
the energy contributions of individual particles are updated, to 
help facilitate the above lookup. 
3. Sequential selection eliminated the cost of one `rand()` call
per iteration.

(1), (2) reduced the run time from 4s to 0.8s in Perl, and to .05s
in C. Adding (3) reduced the run time to .035s (35ms) in C.

Future Optimizations
------------------------
There are currently two big cost contributors, each consuming about
half of the total run time.

1. The expression `(rand() / RAND_MAX) < exp(- dH / T)`.
2. Spin save and the energy contributions update mechanism.

Possible solutions.
* There are apparently faster Pseudo-Random Number Generators than
`rand()`, based on Intel's SSE instruction set.
* Smarter energy update logic.
