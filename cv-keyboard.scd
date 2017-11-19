//grid cv keyboard
//TRY SETTINGS FOR LOWER LATENCY!
(
//client side variables
~grid = MonoM.new("/monome", 0);
~arc = Arc.new("/monome", 0);
~gridLeds = Array.fill(128, 0);
~arcSelectionLeft = [0, 0]; //left is holding status (one is held 0 is not) right is selection index
~arcSelectionRight = [0, 1];
~arcLedsSaved = [[12, 0], [15, 0]]; //this is misleading because it's grid leds not arc leds
~scale = [
	1.00000,
	1.05946,
	1.12246,
	1.18921,
	1.25992,
	1.33483,
	1.41421,
	1.49831,
	1.58740,
	1.68179,
	1.78180,
	1.88775,
	//2.00000,
];
~updateGridLeds = {
	var x, y, tempGridLedsLeft, tempGridLedsRight, gridWidth;
	gridWidth = 16;
	tempGridLedsLeft = Array.fill(64, 0);
	tempGridLedsRight = Array.fill(64, 0);
	for(0, 7, { arg y;
		for(0, 15, { arg x;
			var index16 = x + (y * gridWidth);
			var index8 = x + (y * 8);
			if(x < 8, {
				tempGridLedsLeft[index8] = ~gridLeds[index16];
			}, {
				tempGridLedsRight[index8 - 8] = ~gridLeds[index16];
			});
		});
	});
	~grid.levmap(0, 0, tempGridLedsLeft);
	~grid.levmap(8, 0, tempGridLedsRight);
};
~updateArcLeds = {arg encoderNumber, ledValue, ledLevel = 15;
	var encoderTemporaryArray = Array.fill(64, { arg index;
		if(index <= ledValue, { ledLevel }, { 0 });
	});
	~arc.ringmap(encoderNumber, encoderTemporaryArray);
};
~intGridLeds = {
	var natRow = [0, 3, 0, 3, 0, 0, 3, 0, 3 ,0, 3, 0];
	var accRow = [9, 0, 9, 0, 9, 9, 0, 9, 0, 9, 0, 9];
	for(0, 7, {arg y;
		for(0, 12, {arg x;
			if(y.even, {
				~gridLeds[x + (y * 16)] = natRow[x];
			}, {
				~gridLeds[x + (y * 16)] = accRow[x];
			})
		});
	});
	~gridLeds[12 + (0 * 16)] = 15;
	~gridLeds[13 + (0 * 16)] = 15;
	~gridLeds[14 + (0 * 16)] = 7;
	~gridLeds[15 + (0 * 16)] = 7;
	~updateGridLeds.value;
};
OSCFunc.newMatching( //grid
	{ arg message, time, addr, recvPort;
		var octave = [-0.1, 0, 0.1, 0.2];
		/*var semi = [(0.1 / 12) * 0, (0.1 / 12) * 1, (0.1 / 12) * 2, (0.1 / 12) * 3,
		(0.1 / 12) * 4, (0.1 / 12) * 5, (0.1 / 12) * 6, (0.1 / 12) * 7,
		(0.1 / 12) * 8, (0.1 / 12) * 9, (0.1 / 12) * 10, (0.1 / 12) * 11];*/
		var semi = {arg degree;
			(~scale[degree] * 0.1) - 0.1;
		};
		var naturals = {arg messageOne, messageTwo, messageThree, octnum;
			var curnote = {
				~currentNote = [messageOne, messageTwo];
				//postln("current note is" + ~currentNote);
			};
			var gateOn = {
				~synth.set(\gate, 1);
			};
			var gateOff = {
				~synth.set(\gate, 0);
			};
			var playLed = {
				~gridLeds[messageOne + (messageTwo * 16)] = 15;
				~updateGridLeds.value;
			};
			var offLed = {
				~gridLeds[messageOne + (messageTwo * 16)] = 9;
				~updateGridLeds.value;
			};
			var offMessage = {
				if([messageOne, messageTwo] == ~currentNote, {
					gateOff.value;
					offLed.value;
				}, {
					offLed.value;
				});
			};
			var gridKey = {arg input;
				curnote.value;
				~synth.set(\add, octave[octnum] + semi.value(input));
				postln(octave[octnum] + semi.value(input));
				gateOn.value;
				playLed.value;
			};
			switch(messageThree, 1, {
				switch(messageOne, 0, {
					gridKey.value(0);
				}, 2, {
					gridKey.value(2);
				}, 4, {
					gridKey.value(4);
				}, 5, {
					gridKey.value(5);
				}, 7, {
					gridKey.value(7);
				}, 9, {
					gridKey.value(9);
				}, 11, {
					gridKey.value(11);
				});
			}, 0, {
				switch(messageOne, 0, {
					offMessage.value;
				}, 2, {
					offMessage.value;
				}, 4, {
					offMessage.value;
				}, 5, {
					offMessage.value;
				}, 7, {
					offMessage.value;
				}, 9, {
					offMessage.value;
				}, 11, {
					offMessage.value;
				});
			});
		};
		var accidentals = {arg messageOne, messageTwo, messageThree, octnum;
			var curnote = {
				~currentNote = [messageOne, messageTwo];
				postln("current note is" + ~currentNote);
			};
			var gateOn = {
				~synth.set(\gate, 1);
			};
			var gateOff = {
				~synth.set(\gate, 0);
			};
			var playLed = {
				~gridLeds[messageOne + (messageTwo * 16)] = 15;
				~updateGridLeds.value;
			};
			var offLed = {
				~gridLeds[messageOne + (messageTwo * 16)] = 3;
				~updateGridLeds.value;
			};
			var offMessage = {
				if([messageOne, messageTwo] == ~currentNote, {
					gateOff.value;
					offLed.value;
				}, {
					offLed.value;
				});
			};
			var gridKey = {arg input;
				curnote.value;
				~synth.set(\add, octave[octnum] + semi.value(input));
				postln(octave[octnum] + semi.value(input));
				gateOn.value;
				playLed.value;
			};
			switch(messageThree, 1, {
				switch(messageOne, 1, {
					gridKey.value(1);
				}, 3, {
					gridKey.value(3);
				}, 6, {
					gridKey.value(6);
				}, 8, {
					gridKey.value(8);
				}, 10, {
					gridKey.value(10);
				});
			}, 0, {
				switch(messageOne, 1, {
					offMessage.value;
				}, 3, {
					offMessage.value;
				}, 6, {
					offMessage.value;
				}, 8, {
					offMessage.value;
				}, 10, {
					offMessage.value;
				});
			});
		};
		if(message[1] < 12, { //play columns
			switch(message[2], 7, {
				naturals.value(message[1], message[2], message[3], 0);
			}, 6, {
				accidentals.value(message[1], message[2], message[3], 0);
			}, 5, {
				naturals.value(message[1], message[2], message[3], 1);
			}, 4, {
				accidentals.value(message[1], message[2], message[3], 1);
			}, 3, {
				naturals.value(message[1], message[2], message[3], 2);
			}, 2, {
				accidentals.value(message[1], message[2], message[3], 2);
			}, 1, {
				naturals.value(message[1], message[2], message[3], 3);
			}, 0, {
				accidentals.value(message[1], message[2], message[3], 3);
			});
		}, { //arc selection columns
			var selrow = [12, 13, 14, 15];
			var arcSelLeds = {arg row, col, side; //side = 0 for left encoders, side = 1 for right encoders
				var clear = {
					for(0, 7, {arg y;
						for(selrow[0], selrow[3], {arg x;
							~gridLeds[x + (y * 16)] = 0;
						});
					});
				};
				var leds = {
					~gridLeds[~arcLedsSaved[0][0] + (~arcLedsSaved[0][1] * 16)] = 15;
					~gridLeds[(~arcLedsSaved[0][0] + 1) + (~arcLedsSaved[0][1] * 16)] = 15;
					~gridLeds[~arcLedsSaved[1][0] + (~arcLedsSaved[1][1] * 16)] = 7;
					~gridLeds[(~arcLedsSaved[1][0] - 1) + (~arcLedsSaved[1][1] * 16)] = 7;
					~updateGridLeds.value;
				};
				switch(side, 0, {
					~arcLedsSaved[0] = [selrow[row], col];
					clear.value();
					leds.value();
				}, 1, {
					~arcLedsSaved[1] = [selrow[row], col];
					clear.value();
					leds.value();
				});
			};
			var leftenc = {arg row, col;
				var pairBound = {arg offset; // check to make sure there is a parameter to go to
					var index = offset + (message[2] * 2);
					if(index < ~pairs.size, {
						~arcSelectionLeft[1] = index;
						postln("arc selection left =" + ~arcSelectionLeft[1]);
						~updateArcLeds.value(0, ~pairs[~arcSelectionLeft[1]][0].arcLedValue);
						~updateArcLeds.value(1, ~pairs[~arcSelectionLeft[1]][1].arcLedValue);
						postln("arc selection left is held");
						arcSelLeds.value(row, col, 0);
					});
				};
				switch(message[3], 1, {
					if(~arcSelectionLeft[0] == 0, {
						~arcSelectionLeft[0] = 1;
						switch(row, 0, {
							pairBound.value(0);
						}, 2, {
							pairBound.value(1);
						});
					});
				}, 0, {
					if(~arcSelectionLeft[0] == 1, {
						~arcSelectionLeft[0] = 0;
						postln("arc selection left is not held");
					});
				});
			};
			var rightenc = {arg row, col;
				/*
				//this doesn't work because it doesn't update the leds right!!!
				var indChk = {arg check; //check if arc selection index is the same and adjust if it is
				if(~arcSelectionRight[1] == ~arcSelectionLeft[1], {
				~arcSelectionLeft[1] = ~arcSelectionLeft[1] + 1;
				});
				};*/
				var pairBound = {arg offset; // check to make sure there is a parameter to go to
					var index = offset + (message[2] * 2);
					if(index < ~pairs.size, {
						~arcSelectionRight[1] = index;
						postln("arc selection right =" + ~arcSelectionRight[1]);
						~updateArcLeds.value(2, ~pairs[~arcSelectionRight[1]][0].arcLedValue);
						~updateArcLeds.value(3, ~pairs[~arcSelectionRight[1]][1].arcLedValue);
						postln("arc selection right is held");
						arcSelLeds.value(row, col, 1);
					});
				};
				switch(message[3], 1, {
					if(~arcSelectionRight[0] == 0, {
						~arcSelectionRight[0] = 1;
						switch(row, 1, {
							pairBound.value(0);
						}, 3, {
							pairBound.value(1);
						});
					});
				}, 0, {
					if(~arcSelectionRight[0] == 1, {
						~arcSelectionRight[0] = 0;
						postln("arc selection right is not held");
					});
				});
			};
			switch(message[1], selrow[0],{
				leftenc.value(0, message[2]);
			}, selrow[1], {
				rightenc.value(1, message[2]);
			}, selrow[2], {
				leftenc.value(2, message[2]);
			}, selrow[3], {
				rightenc.value(3, message[2]);
			});
		});
}, "/monome/grid/key");
OSCFunc.newMatching( //arc
	{ arg message, time, addr, recvPort;
		var arcFunctions = {arg name, messageOne, messageTwo, ledLevel = 15;
			name.change(messageTwo);
			name.sendChange;
			~updateArcLeds.value(messageOne, name.arcLedValue, ledLevel);
		};
		switch(message[1], 0, {
			arcFunctions.value(~pairs[~arcSelectionLeft[1]][0], 0, message[2]);
		}, 1, {
			arcFunctions.value(~pairs[~arcSelectionLeft[1]][1], 1, message[2]);
		}, 2, {
			arcFunctions.value(~pairs[~arcSelectionRight[1]][0], 2, message[2]);
		}, 3, {
			arcFunctions.value(~pairs[~arcSelectionRight[1]][1], 3, message[2]);
		});
}, "/monome/enc/delta");
s.waitForBoot({
	~grid.usePort(16139);
	~arc.usePort(16159);
	~intGridLeds.value;
	s.makeBundle(nil, {
		SynthDef("CVout", {arg freq, env, mul = 0.1, add = 0, gate = 0, amp = 0.2,
			attack = 0.001, decay = 0.001, sustain = 1, release = 0.001, pitchOffset = 0;
			var envshape = Env.adsr(attack, decay, sustain, release, amp);
			var envgen = EnvGen.ar(envshape, gate);
			var pitch = SinOsc.ar(0.2, 0, mul, add + pitchOffset);
			Out.ar(0, pitch);
			Out.ar(1, envgen);
			Out.ar(2, pitch);
		}).add;
		s.sync;
		~synth = Synth("CVout", [\mul, 0]);
		s.sync;
		SynthDef("Delay/Reverb", {arg in, out, delayTime = 1, decayTime = 1, delayLevel = 1;
			var input = SoundIn.ar(in, 1);
			var delay = CombC.ar(input, 4, Lag.kr(delayTime, 0.1), decayTime, delayLevel);
			Out.ar(out, input + delay);
		}).add;
		s.sync;
		~delay = Synth("Delay/Reverb", [\in, 0, \out, 7]);
		~pairs = [ //changes accessable by the arc
			[ArcParameter.new("Attack", 0.001, 10, 25, 2, 0.001, ~synth, \attack, 0),
				ArcParameter.new("Decay", 0.001, 10, 25, 2, 0.001, ~synth, \decay, 0)],
			[ArcParameter.new("Sustain", 0.001, 1, 50, 2, 1, ~synth, \sustain, 0),
				ArcParameter.new("Release", 0.001, 10, 25, 2, 0.001, ~synth, \release, 0)],
			[ArcParameter.new("Delay Time", 0.001, 4, 25, 2, 1, ~delay, \delayTime, 0),
				ArcParameter.new("Decay Time", 0.001, 10, 25, 2, 1, ~delay, \decayTime, 0)],
			[ArcParameter.new("Delay Level", 0, 1, 25, 2, 1, ~delay, \delayLevel, 0),
				ArcParameter.new("Pitch Offset", -0.1, 0.1, 1000, 2, 0, ~synth, \pitchOffset, 0)]
		];
		s.sync;
		~updateArcLeds.value(0, ~pairs[0][0].arcLedValue);
		~updateArcLeds.value(1, ~pairs[0][1].arcLedValue);
		~updateArcLeds.value(2, ~pairs[1][0].arcLedValue);
		~updateArcLeds.value(3, ~pairs[1][1].arcLedValue);
	});
});
)
