Description
===========
Class project to prove classical computers aren't any less powerful than D-Wave One. Solve the combinatorial optimization problem with better success probabilities and lower running times.

Files
--------
* download.pl - Script to download the test files from [Arxiv](http://arxiv.org/src/1305.5837v1/anc/). The zipped file wasn't extracting properly for me, so had to do this.

* sa.pl - Version 1 of the classical simulated annealing algorithm. Gets good success probabilities. Running time = 4s per run.

* sa2.pl - Version 2. Implementation optimized to reduce running time to 0.8s per run.

* sa3.c - Version 3. Translation of version 2 in C. Running time = 50ms per run.

* sa4.c - Version 4. Slightly more optimized than (3), to be compiled with `gcc -O3`. Running time now 35ms per run.

* admin.pl - Wrapper script for invoking the executable for different test instances.
