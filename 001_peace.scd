// alloc a buffer for the FFT
b = Buffer.alloc(s,2048,1);

// read a sound
c = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname+/+ "sounds/ringopeace.wav", channels:[0]);


SynthDef.new(\iam, {
	arg i=0, j=2, freq=440, speed=1, va=1;
	var sig;
    sig = PlayBuf.ar(2,c,speed);
	sig = FreeVerb.ar(sig, i, i, i);
	sig = FreeVerb.ar(sig, i/1.1, i/1.1, i/1.1);
	sig = FreeVerb.ar(sig, i/1.2, i/1.2, i/1.2);
	sig = FreeVerb.ar(sig, i/1.3, i/1.3, i/1.3);
	sig = Resonz.ar(sig, freq, 2); //(2, 0.5)
	sig = sig * va;
	Out.ar(0, sig!2);
}).add;


SynthDef.new(\gran, {
	arg i=0, j=2, freq=440, speed=1, va=0.2;
	var sig;
	sig = GrainBuf.ar(1,Dust.ar(i),j,c,1,speed,2,0,-1,512,1,0);
	sig = sig * va;
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;



(

~iter1 = 30;
~iter2 = 20;
~gran_syn = Synth(\gran, [
		\i, 0,
		\j, 0.2,
	]);

{

	~iter1.do({
		arg val;
		val.postln;
		Synth(\iam, [
			\i, linlin(val,0, ~iter, 0, 1),
			\j, linlin(val,0, ~iter, 2, 0.5),
			\freq, linlin(val,0, ~iter, 440, 100),
			\speed, linlin(val, 0, ~iter, 1, 0.25),
			\va, linlin(val, 0, ~iter, 1, 10)
		]);
		c.duration.wait;

	})
}.fork;

{
	~iter2.do({
		arg val;
		if(val<19, {
			~gran_syn.set(\i, linlin(val,0, ~iter, 0, 50));
			~gran_syn.set(\j, linlin(val,0, ~iter, 0.2, 1));
			~gran_syn.set(\speed, linlin(val,0, ~iter, 1, 0.5));
			~gran_syn.set(\va, linlin(val,0, ~iter, 0.2, 0.1));
		}, {~gran_syn.set(\va, linlin(val,0, ~iter, 0.1, 0.08))});
		c.duration.wait;
	});
	10.wait;
	s.freeAll;
}.fork;
)

