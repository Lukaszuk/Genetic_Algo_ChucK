
// ChucK implementation of genetic algorithm - adapted from the following Java code  - 
// https://gist.githubusercontent.com/Vini2/bd22b36ddc69c5327097921f5118b709/raw/c264e17adf64d7bdab5fbd961939154dbe95e2fc/SimpleDemoGA.java

// there are no sound mappings in this particular .ck file, but see the Blip_score.ck files for an implementation that maps elements to create piece 



class simpleDemoGA
{
    Population population; 
    Individual fittest;   
    Individual secondFittest;
    0 => int generationCount;
    
    fun void main() // 
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

}

<<< "\nSolution found in generation:   ", generationCount >>>;
<<< "\nFittnes:     ", population.getFittest().fitness >>>; // 
<<< "\nGenes:   ">>>;
       for ( 0 => int i; i < 5; i++)
      {
          <<< population.getFittest().genes[i] >>>; 
      }

<<< "  '  ' " >>>; // don't think it'll print double quotes without error
   }

// Selection - 
     fun void selection()
     {
        population.getFittest() @=> fittest; // 
    
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
fun void initializePopulation(int size) 
{
    for ( 0 => int i; i < individuals.cap(); i++)
    {
        individuals[i].Individual(); 
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



simpleDemoGA o;

o.main();



