
// ChucK implementation of genetic algo - using "degraded" (via the PitShift UGen) sine wave oscillator bank


// various mappings here via things like the generation count , but main idea is that as fitness increases and arrays 
// work towards [1,1,1,1,1] solution, quartal/quintal chords are formed


 

class OscEnv extends Chugraph 
{
    SinOsc sine; TriOsc tri; SawOsc saw; PulseOsc pulse; 
    
    sine => ADSR env => Gain gainy => outlet;
    
    fun void freq (float hz)
    {
        hz => sine.freq => tri.freq => saw.freq => pulse.freq;
    }
    
    fun void mul (float lvl)
    {
        gainy.gain;    }
        
        fun void width (float wid)
        {
            wid => tri.width => saw.width => pulse.width;
        }
        
        fun void sync (int syn)
        {
            syn => sine.sync => tri.sync => saw.sync => pulse.sync;
        }
        fun void phase (float ph)
        {
            ph => sine.phase => tri.phase => saw.phase => pulse.phase;
        }
        
        
        fun void oscil(string type)
        {
            if (type == "sine")
            {sine => env;
            tri !=> env;
            saw !=> env;
            pulse !=> env;}
            
            else if (type == "tri")
            {tri => env;
            sine !=> env;
            saw !=> env;
            pulse !=> env;}
            
            else if (type == "saw")
            {saw => env;
            tri !=> env;
            sine !=> env;
            pulse !=> env;}
            
            else if (type == "pulse")
            {pulse => env;
            tri !=> env;
            saw !=> env;
            sine !=> env;}
        }
        
        fun void times (float a, float d, float s, float r)
        {
            env.set(a::second, d::second, s, r::second);
        }
        
        fun void trig (int trigger)
        {
            if (trigger == 1)
                env.keyOn(1);
            else if (trigger == 0)
                env.keyOff(1);
        }
        
    }

OscEnv oscy[5];

Gain master => dac;
NRev rev;
PitShift pitch1;
Echo ech1 => Gain fb => ech1 => Envelope fade => Pan2 pan => master;

fade.duration(3::second);

fade.keyOn();

0.33 => fb.gain;
0.3::second => ech1.delay;
1.0::second => ech1.max;


0.51 => pitch1.shift;
0.8=> pitch1.mix;
//  0.1 => chor1.mix;

for (0 => int t; t < 5; t++)
{
    oscy[t] =>  pitch1 => fade;
    oscy[t] => rev => fade;
    pitch1 => ech1;
    
    oscy[t].oscil("sine");
    0.0025 => oscy[t].gain;
}
0.09 => rev.mix;

Math.random2(36,96) => int basePch;
float randFreq;
Math.random2(20,100) => int baseRate;



class simpleDemoGA
{
    Population population; // no need for constructor from line 11 
    Individual fittest;
    Individual secondFittest;
    0 => int generationCount;
    
    fun void main() // will work like a general setup / init
    {
        Math.random() => int rn;
        
        // line 20 constructor not needed;
        
        population.initializePopulation(10); // 
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

}

<<< "\nSolution found in generation:   ", generationCount >>>;
<<< "\nFittnes:     ", population.getFittest().fitness >>>; // STOP LINE 55 9:47PM  ??? 
<<< "\nGenes:   ">>>;
for ( 0 => int i; i < 5; i++)
{
    <<< population.getFittest().genes[i] >>>; 
}

<<< "  '  ' " >>>; 
}

// Selection -  
fun void selection()
{
    population.getFittest() @=> fittest; 
    
    population.getSecondFittest() @=> secondFittest; //

}


// Crossover
fun void crossover()
{
    Math.random() => int rn; //
    
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
        
        int randOct;
        Math.random2(0,2) => int randOctTest;
        
        for (0 => int i; i < 5; i++)
        {
            <<< "FITTEST GENE:", returnGenes.genes[i] >>>;
                oscy[i].times(Math.random2f(0.01,0.3),0.2,0.05,0.5);
            
            if (returnGenes.genes[i] == 1)
            { 
                if ( randOctTest == 1)
                    12 => randOct;
                else if (randOctTest == 0)
                    24 => randOct;
                else
                    0 => randOct;
                
                randOct + (basePch + 7) => basePch;
            Std.mtof(basePch *  (Math.random2f(0.91,1.1)))=> oscy[i].freq;
            pan.pan(Math.random2f(0.25,0.45));
            Math.random2f(0.3,0.4) => oscy[i].mul;}
            
            else if (returnGenes.genes[i] == 0)
            {    Std.mtof(Math.random2(36,96)) => randFreq;
            randFreq => oscy[i].freq;
            pan.pan(Math.random2f(-0.25,0.45));
            Math.random2f(0.1,0.4) => oscy[i].mul;}
            
            1 => oscy[i].trig;

            (1+ generationCount) * baseRate::ms => now;
            0 => oscy[i].trig;
            (1 + generationCount) * baseRate::ms => now;
            
            }
            
            //0.5::second => now;

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
    Individual individuals[10]; // array of 10 instances of Individual class 
    0 => int fittest;

// Initialize population
fun void initializePopulation(int size) //
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

//spork ~ playSines();


simpleDemoGA o;

o.main();

1::day => now;

