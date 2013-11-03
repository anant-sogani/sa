#!/usr/bin/env perl

use strict;
use warnings;

#
# Command-Line Customizable:
# Number of Trials per Benchmarking Instance.
#
my $R = $ARGV[1] || 10;

#
# Command-Line Customizable:
# Location of Executable.
#
my $exe = $ARGV[0] || q(./sa2.pl);

# Location of Instance Files.
my $dir = q(instances);

# Input and Output Data.
open my $ih, "<", "success.txt" or die $!;
open my $oh, ">", "results/$R.csv" or die $!;

print $oh "Instance, D-Wave p(s), Classical SA p(s)\n";

my $N = 1;

while (<$ih>) {
    next unless m/(Benchmark.*txt) (\d[.]\d+)/;

    # Obtain Instance File and D-Wave's Success Probability.
    my ($file, $succ) = ($1, $2);
    my $path = $dir . "/" . $file;

    print "$R Trials on Instance #$N ...\n";

    # Obtain Success Probability of Executable on R runs.
    my $exe_succ = `$exe "$path" $R`;
    chomp($exe_succ);

    print $oh "$file, $succ, $exe_succ\n";
    $N++;
}

close $ih;
close $oh;
