// https://gist.githubusercontent.com/Vini2/bd22b36ddc69c5327097921f5118b709/raw/c264e17adf64d7bdab5fbd961939154dbe95e2fc/SimpleDemoGA.java

// ChucK implementation of genetic algo - with mapping to OscEnv ChuGen class (which I created to conveniently work with multiple oscillator types 
// and conveniently affect ADSR as a method rather than outside UGen) 

/* what is mapped to sound:

1) the fitness metric result (ranging 0-5) is used to multiply a base frequency val.
for the OscEnv.freq() - this is actually (1-6 to avoid multiplying by 0 and getting a thud sound from 0Hz)

2) trem rate on master gain becomes slower with increase in # of generations needed to reach solution 

3) crossover point , involves swapping pitch shifter arguments, see around line 217 
// put in a function that on input of 30 begins to process via spectacle then stops processing after 20-25'' 



*/

// for synth 
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
    
    
    
Math.random2f(0.8,1.33) => float stretch;    

OscEnv synth1 => HPF hi => Chorus chor => JCRev rev => LPF lo => Echo ech => Envelope fade => Gain master;
synth1 => PitShift shift1 => ech;
synth1 => PitShift shift2 => ech;

master => Pan2 panL => dac;
master => Pan2 panR => dac;

panL.pan(-0.66);
panR.pan(0.66);

0.35 => shift1.mix => shift2.mix;

    Event trigOsc; 
    
    0.3::second => ech.delay;
    
    1::second => ech.max;
    0.35 => ech.mix;
    
    1::second => fade.duration;
    0.05 => synth1.gain;
    0.05 => rev.mix;
    250 => hi.freq;
    synth1.oscil("SinOsc");
    220 => synth1.freq;
    0.1 => chor.mix;
    2000 => lo.freq;


SinOsc lfoTrem => blackhole; 

fun void trem()
{
     while (true)
     {
         Math.fabs(lfoTrem.last()) * 0.85 => master.gain;
         1::samp => now;
     }
 }

class simpleDemoGA
{
    
   
    
    Population population; // no need for constructor from line 11 
    Individual fittest;
    Individual secondFittest;    0 => int generationCount;
    
    fun void main() // will work like a general setup / init
    {
        Math.random2(300,2000) => int baseHz;
        
        fade.keyOn();

        Math.random() => int rn;
        
        
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
//  trigOsc.signal();
         lfoTrem.freq(Math.fabs(3.0 - (generationCount * 0.02))); //  
         synth1.times(Math.random2f(0.01,0.1),0.01,0.01,0.01);

         (1 + population.fittest) * baseHz =>  synth1.freq;
         synth1.trig(1);
         synth1.gain(Math.random2f(0.002,0.1));
         stretch * Math.random2(100,200)::ms => now;
         synth1.trig(0);
  //<<< "hi" >>>;
}

<<< "\nSolution found in generation:   ", generationCount >>>;
//synth1.gain(0.5);
fade.keyOff();
fade.duration() => now;
<<< "\nFittnes:     ", population.getFittest().fitness >>>;
<<< "\nGenes:   ">>>;
for ( 0 => int i; i < 5; i++)
{
    <<< population.getFittest().genes[i] >>>; 
}

<<< "  '  ' " >>>; // 
}

// Selection -
fun void selection()
{
    population.getFittest() @=> fittest; // this func  getFittest() should return something...it does, it returns an Individual class instance 
    
    population.getSecondFittest() @=> secondFittest; //

}


// Crossover
fun void crossover()
{
    Math.random() => int rn; 
    
    // select a random crossover point
    Math.random2(0, population.individuals[0].geneLength) => int crossOverPoint; // no .nextInt 
   // <<< "CROSSOVER POINT IS ", crossOverPoint >>>;
    // swap values among parents
    for (0 => int i; i < crossOverPoint; i++)
    {
        fittest.genes[i] => int temp;
      //  <<< "1st and 2nd fittest" , fittest.genes[i], secondFittest.genes[i] >>>;
 
        secondFittest.genes[i] => fittest.genes[i];
        temp => secondFittest.genes[i];
        
        shift1.shift(fittest.genes[i]+2.0);
        shift2.shift(secondFittest.genes[i]+1.5);
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
}


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
    Individual individuals[10]; 
    0 => int fittest;

// Initialize population
fun void initializePopulation(int size)
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

simpleDemoGA o;

//Shred mainIn;


o.main();


1::day => now;




