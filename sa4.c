#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Total Particles. */
#define N 108

/* Maximum Couplings per Particle. */
#define CMAX 8

/* 8-Bit Integers suffice. */
typedef char i8;

/* Representation of a single coupling. */
typedef struct {
    i8 j;
    i8 cij;
} c_t;

/* Coupling Matrix. */
static c_t O[N + 1][CMAX];

/* Spins. */
static i8 Z[N + 1];

/* Particle Energies. */
static i8 P[N + 1];

/* Graph's Minimum Energy. */
static int E;

/* Command-Line Customizable: Total Trials. */
static int K = 10;

/* Success Count. */
static int s = 0;

/* Command-Line Customizable: Annealing Iterations. */
int MAX = 1000000;

static
void
insert (i8 i,
        i8 j,
        i8 cij)
{
    i8     m;

    for (m = 0; m < CMAX; m++) {
        if (!O[i][m].j) {
            O[i][m].j   = j;
            O[i][m].cij = cij;
            return;
        }
    }

    printf("ERROR: Exceeded maximum neighbors\n");
    exit(EXIT_SUCCESS);
}

static
void
read_instance (const char     *instance)
{
    char    str[200];
    int     i;
    int     j;
    int     cij;
    int     retcode;
 
    FILE    *fp = fopen(instance, "r");
    if (!fp) {
        printf("ERROR: Could not open file %s\n", instance);
        exit(EXIT_SUCCESS);
    }

    /* Minimum Energy. */
    retcode = fscanf(fp, "%s %s %s %s %s %d\n",
                     str, str, str, str, str, &E);
    if (!retcode) {
        printf("ERROR: Could not read from file %s\n", instance);
        exit(EXIT_SUCCESS);
    }

    /* Couplings. */
    while (!feof(fp)) {
        retcode = fscanf(fp, "%d %d %d\n", &i, &j, &cij);
        if (!retcode) {
            printf("ERROR: Could not read from file %s\n", instance);
            exit(EXIT_SUCCESS);
        }

        insert((i8)i, (i8)j, (i8)cij);
        insert((i8)j, (i8)i, (i8)cij);
    }

    fclose(fp);
}

static
void
init_Z (void)
{
    i8  i;
    for (i = 1; i <= N; i++) {
        Z[i] = ((rand() % 2) ? 1 : -1);
    }
}

static
void
init_P (void)
{
    i8  i;
    i8  m;
    i8  h;
    i8  j;
    i8  cij;

    for (i = 1; i <= N; i++) {
        h = 0;
        for (m = 0; m < CMAX; m++) {
            if (!O[i][m].j) { break; }

            j   = O[i][m].j;
            cij = O[i][m].cij;
            h  += Z[j] * cij;    
        }

        P[i] = -Z[i] * h;
    }
}

static
int
calc_H (void)
{
    i8      i;
    int     h = 0;

    for (i = 1; i <= N; i++) {
        h += (int) P[i];
    }

    return h / 2;
}

static
void
save_flip (i8   i)
{
    i8  m;
    i8  j;
    i8  cij;

    for (m = 0; m < CMAX; m++) {
        if (!O[i][m].j) { break; }

        j   = O[i][m].j;
        cij = O[i][m].cij;

        P[j] += 2 * Z[i] * Z[j] * cij;
    }

    P[i] = -P[i];
    Z[i] = -Z[i];
}

static
int
anneal (void)
{
    /* Initialize Spins. */
    init_Z();

    /* Initial Particle Energies. */
    init_P();

    /* Initial Energy. */
    int     H    = calc_H();
    int     Hmin = calc_H();

    /* Temperature Schedule. */
    float   T0 = 1;
    float   Tf = 0;
    float   dT = (Tf - T0) / MAX;
    float   T  = T0;
    
    int     dH; 
    int     iter;
    i8      i = 0;

    /* Anneal. */
    for (iter = 0; iter < MAX; iter++) {

        /* Sequentially select a Particle for flipping Spin. */
        i = ((i < N) ? i + 1 : 1);
        
        /* Calculate Energy change. */
        dH = -2 * P[i];

        /* Accept Lower-Energy state. */
        if (dH < 0) {

            /* New Energy. */
            H += dH;
            Hmin = ((H < Hmin) ? H : Hmin);

            save_flip(i);
        }
        else {

            /* Accept Higher-Energy state probabilistically. */
            if ((rand() / (float)RAND_MAX) < exp(-dH / T)) {

                /* New Energy. */
                H += dH;

                /* Reduce Temperature. */
                T += dT;

                save_flip(i);
            }
            else {
                /* Reject Flip. */
            }
        }
    }

    return Hmin;
}

static
int
sa (void)
{
    return anneal();
}

/*
 * MAIN:
 * <it> <file-name> [<K = No. of Runs>] [<MAX = Annealing Iter>]
 */
int main (int n, char * args[])
{
    int     k;
    int     h;

    read_instance(args[1]);

    /* Customizable Parameters. */
    if (args[2]) { K = atoi(args[2]);   }
    if (args[3]) { MAX = atoi(args[3]); }

    for (k = 0; k < K; k++) {
        h = sa();
        if (h == E) {
            s++;
        }
    }

    printf("%1.2f\n", (float) s / K);
    return 0;
}

