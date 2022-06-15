
// mapping of genetic algo to pulse oscs with modulation on width 

/* 

1) fitness gene results act as triggers for on off of pulse wave ADSR, as the set evolves towards 1-1-1-1-1
   more rhythmic regularity is achieved 
   
 //  2) as generation count increases - bitcrusher wet mix increases, fitness metric maps to how much bitcrushing is applied to the signal with bitcrusher...
   
   
 */ 

PulseOsc p => ADSR pulseADSR => LPF lo => Envelope e =>Echo ech1  => Gain master => dac;
p => Envelope reve => NRev rev => HPF hi => Gain revGain =>  ech1 => master;
ech1 => LPF lo2 => master;
ech1 => Bitcrusher bc => LPF lobit => Spectacle spect => dac;
spect.table("delay","ascending");
0.66 => spect.mix; // 
0.6 => spect.feedback;
spect.gain(0.65);
spect.range(100,4100);
<<< spect.bands(), "frequency bands with random delay by default" >>>;

ech1 => LPF sub => master;

300 => sub.freq;

lobit => HPF hibit => master;

TriOsc slowTrem => blackhole;
0.007 => slowTrem.freq;

fun void trem()
{
    while (true)
    {
        Math.fabs(slowTrem.last()) * 0.4 => master.gain;
        1::samp => now;
    }
}


0.1 => bc.gain;
8 => bc.bits;
12 => bc.downsampleFactor;
3500 => lobit.freq;

300 => lo2.freq;
1500 => hibit.freq;
0.2 => hibit.gain;


pulseADSR.set(0.5::second, 0.5::second,0.25,0.5::second);


0.35 => ech1.mix;
1::second => ech1.max;
0.45::second => ech1.delay;
3::second => reve.duration;
reve.keyOn();

0.2 => revGain.gain;

0.6 => rev.mix;
2::second => e.duration;
e.keyOn();

500 => hi.freq;
400 => lo.freq;
0.05 => p.gain;
Math.random2(25,125) => p.freq;

SinOsc lfo1 => blackhole;

fun void pwm()
{
    Math.random2f(0.04,0.25) => lfo1.freq;
    
    while (true)
    {
        Math.fabs(lfo1.last()) * 0.9 => p.width;
        1::samp => now;
    }
}




class simpleDemoGA
{
    Population population; // no need for constructor from line 11 
    Individual fittest;
    Individual secondFittest;
    0 => int generationCount;
    
    fun void main() // will work like a general setup / init
    {
        Math.random() => int rn;
        
        
        population.initializePopulation(10); 
        population.calculateFitness();
        
        <<< "Generation:    ", generationCount, "Fittest:    ", population.fittest >>>;
        
        //While population gets an individual with maximum fitness
        
        while (population.fittest < 5)
        {
            ++generationCount;
            
            // do selection 
            selection();
        
        // do crossover
        crossover();
    
    // do mutation under a random probability
    if (Math.random() % 7 < 5) // no .nextInt so just use new random numb generator 
    {   mutation();
}

// add fittest offspring to population

addFittestOffspring();

// calculate new fitness value

population.calculateFitness();

<<< " Generation:   ", generationCount, "Fittest:     ", population.fittest >>>; 

if (population.fittest == 0)
    bc.bits(2);
else if (population.fittest == 1)
    bc.bits(4);
else if (population.fittest == 2)
    bc.bits(8);
else if (population.fittest == 3)
    bc.bits(10);
else if (population.fittest == 4)
    bc.bits(24);

0.001 + (0.01 * generationCount) => bc.gain; 

if (generationCount > 100)
    0.001 + (0.004 * generationCount) => bc.gain; 

    
}

e.keyOff();
<<< "\nSolution found in generation:   ", generationCount >>>;
<<< "\nFittnes:     ", population.getFittest().fitness >>>; 
<<< "\nGenes:   ">>>;


for ( 0 => int i; i < 5; i++)
{
    <<< population.getFittest().genes[i] >>>; 
}

<<< "  '  ' " >>>; //
}

// Selection
fun void selection()
{
    population.getFittest() @=> fittest;     
    population.getSecondFittest() @=> secondFittest; //

}


// Crossover
fun void crossover()
{
    Math.random() => int rn; 
    
    // select a random crossover point
    Math.random2(0, population.individuals[0].geneLength) => int crossOverPoint; // no .nextInt 
    
    // swap values among parents
    for (0 => int i; i < crossOverPoint; i++)
    {
        fittest.genes[i] => int temp;
        secondFittest.genes[i] => fittest.genes[i];
        temp => secondFittest.genes[i];
    }
    
}

// Mutation // 

fun void mutation()
{
    Math.random() => int rn;
    
    // select a random mutation point
    
    Math.random2(0,population.individuals[0].geneLength-1) => int mutationPoint;
    
    // Flip the values at the mutation point
    if (fittest.genes[mutationPoint] == 0) 
    {
        1 => fittest.genes[mutationPoint];
    }
    else {
        0 => fittest.genes[mutationPoint];
    }
    
    Math.random2(0,population.individuals[0].geneLength-1) => mutationPoint;
    
    if (secondFittest.genes[mutationPoint] == 0)
    {
        1 => secondFittest.genes[mutationPoint];
    }
    else
    {   0 => secondFittest.genes[mutationPoint];}
}

fun Individual getFittestOffspring()
{
    if (fittest.fitness > secondFittest.fitness)
    {
        return fittest;
    }
    return secondFittest;
}


// replace least fittest individual from most fittest offspring

fun void addFittestOffspring()
{
    fittest.calcFitness();
    secondFittest.calcFitness();
    
    // get index of least fit individual 
    
    population.getLeastFittestIndex() => int leastFittestIndex; 
    
    // Replace least fittest individual from most fittest offspring
    getFittestOffspring() @=> population.individuals[leastFittestIndex];
    
    getFittestOffspring() @=> Individual returnGenes;
    for (0 => int i; i < 5; i++)
    {
        <<< "FITTEST GENE:", returnGenes.genes[i] >>>;
        
        if (returnGenes.genes[i] == 1)
            pulseADSR.keyOn(1);
        else
            pulseADSR.keyOff(1);
        
        Math.random2(50,150)  * generationCount::ms => now;
    }
}

// spork ~ main();
}





// these two classes run fine 
// Individual class 
class Individual
{
    0 => int fitness;
    int genes[5];
    5 => int geneLength;
    
    fun void Individual()
    {
        Math.random() => int rn;
        
        for ( 0 => int i; i < genes.cap(); i++) // .cap() instead of .length
        {
            Math.random() % 2 => genes[i]; // there's no .nextInt method for the rn in ChucK
        }
        
        0 => fitness;
    }
    
    fun void calcFitness()
    {
        0 => fitness;
        for ( 0 => int i; i < 5; i++)
        {
            if (genes[i] == 1)
            {
                ++fitness;
            }
        }
    }
}


// Population class

class Population 
{
    10 => int popSize;
    Individual individuals[10]; // 
    0 => int fittest;

// Initialize population
fun void initializePopulation(int size) //- line 180 in the Java example
{
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        individuals[i].Individual(); // 
    }
}

// Get the fittest individual
fun Individual getFittest()
{
    -2147483648 => int maxFit; //line 188 , there's no MIN_VALUE in ChucK
    0 => int maxFitIndex;
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        if ( maxFit <= individuals[i].fitness)
        {
            individuals[i].fitness => maxFit;
            i => maxFitIndex;
        }
    }
    
    individuals[maxFitIndex].fitness => fittest;
    
    return individuals[maxFitIndex];
}

fun Individual getSecondFittest()
{
    0 => int maxFit1;
    0 => int maxFit2;
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        if (individuals[i].fitness > individuals[maxFit1].fitness)
        {
            maxFit1 => maxFit2;
            i => maxFit1;
        }
        else if ( individuals[i].fitness > individuals[maxFit2].fitness)
        {
            i => maxFit2;
        }
    }
    return individuals[maxFit2];
}

// Get index of least fittest individual

fun int getLeastFittestIndex()
{
    2147483648 => int minFitVal; // no Interger.MAX_VALUE in ChucK
    0 => int minFitIndex;
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        if ( minFitVal >= individuals[i].fitness)
        {
            individuals[i].fitness => minFitVal; 
            i => minFitIndex;
        }
    }
    return minFitIndex;
}

// calculate fitness of each individual
fun void calculateFitness()
{
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        individuals[i].calcFitness();
    }
    getFittest();
}

}

spork ~ trem();
spork ~ pwm();

simpleDemoGA o;

o.main();



