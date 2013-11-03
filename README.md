Description
===========
Class project to prove classical computers aren't any less powerful than D-Wave One. Solve the combinatorial optimization problem with better success probabilities and lower running times.

Files
--------
* download.pl - Script to download the test files from [Arxiv](http://arxiv.org/src/1305.5837v1/anc/). The zipped file wasn't extracting properly for me, so had to do this.

* sa.pl - Version 1 of the classical Simulated Annealing algorithm. Gets good success probabilities. Running time = 4s (per run).

* sa2.pl - Version 2. Implementation optimized to reduce running time to 0.8s.

* sa3.c - Version 3. Translation of version 2 in C. Running time = 50ms.

* sa4.c - Version 4 (LATEST). Slightly more optimized than (3), and should be compiled with `gcc -O3`. Running time = 35ms.

* admin.pl - Wrapper script for invoking the executable for different test instances.

Results
--------
I've collected results for 3 different Runs-per-Test-Instance values - **R** = {1, 10, 100}.
* R.csv - Success Probability numbers for individual instances.
* R.png - Histogram plots.

So far, the results are superior to D-Wave One's. It remains to be seen how my implementation performs for **R** = 1000.
