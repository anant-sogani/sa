#!/usr/bin/env perl

use strict;
use warnings;

# Total number of Particles.
my $N = 108;

#
# O: Couplings.
# Z: Spins.
# P: Particle Energies.
# E: Graph's Minimum Energy.
#
my (@O, @Z, @P, $E);

# Command-Line Customizable: Total Trials.
my $K = $ARGV[1] || 10;

# Success Count.
my $s = 0;

sub read_instance {
    my $instance = shift;

    open my $fh, "<", $instance or die $!;
    while (<$fh>) {
        $E = $1 if m/with energy (-?\d+)/;
        next unless m/^(\d+) (\d+) (-?1)/;
        my ($i, $j, $cij) = ($1, $2, $3);
        push @{ $O[$i] }, [ $j, $cij ];
        push @{ $O[$j] }, [ $i, $cij ];
    }
    close $fh;
}

sub init_Z { $Z[$_] = (rand(2) < 1 ? -1 : 1) for (1 .. $N); }

sub init_P {
    for my $i (1 .. $N) {
        my $h = 0;
        for my $c (@{ $O[$i] }) {
            my ($j, $cij) = @{$c};
            $h += $Z[$j] * $cij;
        }
        $P[$i] = -$Z[$i] * $h;
    }
}

sub H {
    my $h = 0;
    $h += $P[$_] for (1 .. $N);
    return $h / 2;
}

sub save_flip {
    my $i = shift;

    for my $c (@{ $O[$i] }) {
        my ($j, $cij) = @{$c};
        $P[$j] += 2 * $Z[$i] * $Z[$j] * $cij;
    }

    $P[$i] = -$P[$i];
    $Z[$i] = -$Z[$i];
}

sub anneal {

    # Initialize Spins.
    init_Z();

    # Initial Particle Energies.
    init_P();

    # Initial Energy.
    my ($H, $Hmin) = (H(), H());

    # Command-Line Customizable: Annealing Iterations.
    my $MAX = $ARGV[2] || 1000000;

    # Temperature Schedule.
    my ($T0, $Tf) = (1, 0);
    my $dT = ($Tf - $T0) / $MAX;
    my $T  = $T0;

    # Anneal.
    for (1 .. $MAX) {

        # Select a random Particle for flipping Spin.
        my $i = int(rand($N)) + 1;

        # Calculate Energy change.
        my $dH = -2 * $P[$i];

        # Accept Lower-Energy state.
        if ($dH < 0) {

            # New Energy.
            $H += $dH;
            $Hmin = $H if $H < $Hmin;

            save_flip($i);
        }
        else {

            # Accept Higher-Energy state probabilistically.
            if (rand() < exp(-$dH / $T)) {

                # New Energy.
                $H += $dH;

                # Reduce Temperature.
                $T += $dT;

                save_flip($i);
            }
            else {

                # Reject Flip.
            }
        }

    }

    return $Hmin;
}

sub sa { anneal(); }

#
# MAIN.
# <it> <file-name> [<K = No. of Runs>] [<MAX = Annealing Iter>]
#
read_instance($ARGV[0]);

for (1 .. $K) {
    my $h = sa();
    $s++ if $h == $E;
}

print $s / $K . "\n";
