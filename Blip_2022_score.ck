// Blip (2022) - a generative drone piece based on a genetic algorithm written in 
// the ChucK programming language. Various mappings to sound exist across
// the 3 .ck files called in this "score". For example, as arrays evolve towards
// a solution, pitch collections evolve from random MIDI note input to 
// various quartal/quintal chords. 

fun void call1()
{

while (true)
{

     Machine.add(me.dir()+"/blip_genetic_OSCENV.ck");
     
     Math.random2(10,20)::second => now;

}

//1::day => now;
}

fun void call2()
{
    
    while (true)
    {
        
        Machine.add(me.dir()+"/blip_genetic_pwm.ck");
        
        Math.random2(20,45)::second => now;
        
    }
    
//    1::day => now;
}

fun void call3()
{
    
    while (true)
    {
        
        Machine.add(me.dir()+"/blip_genetic_sinechords.ck");
        
        Math.random2(20,45)::second => now;
        
    }
    
    //    1::day => now;
}


spork ~ call1();
spork ~ call2();
15::second => now;
spork ~ call3();
1::day => now;