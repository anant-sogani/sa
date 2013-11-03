#!/usr/bin/env perl

use strict;
use warnings;

# Total number of Particles.
my $N = 108;

#
# C: Couplings.
# Z: Spins.
# O: Couplings given a Particle.
# E: Graph's Minimum Energy.
#
my (@C, @Z, @O, $E);

# Total Trials.
my $K = 10;

# Success Count.
my $s = 0;

sub read_instance {
    my $instance = shift;

    open my $fh, "<", $instance or die $!;
    while (<$fh>) {
        $E = $1 if m/with energy (-?\d+)/;
        next unless m/^(\d+) (\d+) (-?1)/;

        my ($i, $j, $cij) = ($1, $2, $3);
        my $c = [ $i, $j, $cij ];
        push @C, $c;
        push @{ $O[$i] }, $c;
        push @{ $O[$j] }, $c;
    }
    close $fh;
}

sub init_Z { $Z[$_] = (rand(2) < 1 ? -1 : 1) for (1 .. $N); }

sub flip_Zi {
    my $i = int(rand($N)) + 1;
    $Z[$i] = -$Z[$i];
    return $i;
}

sub unflip_Zi {
    my $i = shift;
    $Z[$i] = -$Z[$i];
}

sub H {
    my $sum = 0;
    for my $c (@C) {
        my ($i, $j, $cij) = @{$c};
        $sum += $Z[$i] * $Z[$j] * $cij;
    }
    return -$sum;
}

sub dH {
    my $i   = shift;
    my $sum = 0;
    for my $c (@{ $O[$i] }) {
        my ($i, $j, $cij) = @{$c};
        $sum += $Z[$i] * $Z[$j] * $cij;
    }
    return -2 * $sum;
}

sub anneal {

    # Initialize Spins.
    init_Z();

    # Initial Energy.
    my ($H, $Hmin) = (H(), H());

    # Annealing Iterations.
    my $MAX = 1000000;

    # Temperature Schedule.
    my ($T0, $Tf) = (1, 0);
    my $dT = ($Tf - $T0) / $MAX;
    my $T  = $T0;

    # Anneal.
    for (1 .. $MAX) {

        # Flip a randomly-chosen Particle's Spin.
        my $i = flip_Zi();

        # Calculate Energy change dH = Hnew - H;
        my $dH = dH($i);

        # Accept Lower-Energy state.
        if ($dH < 0) {
            $H += $dH;
            $Hmin = $H if $H < $Hmin;
        }
        else {

            # Accept Higher-Energy state probabilistically.
            if (rand() < exp(-$dH / $T)) {
                $H += $dH;
                $T += $dT;
            }
            else {

                # Reject Flip.
                unflip_Zi($i);
            }
        }

    }

    return $Hmin;
}

sub sa { anneal(); }

#
# MAIN.
#
read_instance($ARGV[0]);

for (1 .. $K) {
    my $h = sa();
    $s++ if $h == $E;
    print "$h vs $E (#$_)\n";
}

print "p(s) = $s / $K = " . ($s / $K) . "\n";

