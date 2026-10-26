(* Tests for compiling n-ary cyclic tag systems to cyclic tag systems. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "NaryCyclicTag-Load"
]

(* The reference systems are resource functions. The paclet's resolver also finds those
   that are not yet in the Wolfram Function Repository. *)
ctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["CyclicTagSystemEvolveList"];
nctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["NaryCyclicTag"];

(* If a reference system could not be loaded, for example without a network connection, the other tests fail. *)
VerificationTest[
	MatchQ[{ctEvolve, nctEvolve}, {__ResourceFunction}],
	True,
	TestID -> "NaryCyclicTag-ReferenceSystems"
]

(* Compile an n-ary cyclic tag system, run the cyclic tag system and decode its evolution. *)
nctViaCyclicTag[rule_, init_, states_, t_, opts___] :=
	DecodeCyclicTagToNaryCyclicTag[
		ctEvolve[
			NaryCyclicTagToCyclicTagRule[rule, states, opts],
			NaryCyclicTagToCyclicTagInit[init, states, opts],
			NaryCyclicTagToCyclicTagSteps[t, states, opts]],
		states,
		opts]

randomNCTRule[states_] :=
	Table[Table[RandomInteger[states - 1, RandomInteger[{0, 3}]], states], RandomInteger[{1, 4}]]

nctCases =
	BlockRandom[
		Table[
			With[{states = RandomInteger[{2, 4}]},
				{randomNCTRule[states], RandomInteger[states - 1, RandomInteger[{1, 5}]], states, RandomInteger[{0, 8}]}],
			100],
		RandomSeeding -> 1];


(* Encoding *)

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}],
	{{0, 1}, {1, 0, 1, 0}, {}, {0, 1, 0, 1}},
	TestID -> "NaryCyclicTag-Rule-OneHot"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, 3],
	{{0, 1, 0}, {1, 0, 0, 1, 0, 0}, {}, {}, {0, 1, 0, 0, 1, 0}, {}},
	TestID -> "NaryCyclicTag-Rule-MoreStates"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{1, 0, 1}],
	{0, 1, 1, 0, 0, 1},
	TestID -> "NaryCyclicTag-Init-Default"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{2, 0}, 3],
	{0, 0, 1, 1, 0, 0},
	TestID -> "NaryCyclicTag-Init-ThreeStates"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[5, 3],
	15,
	TestID -> "NaryCyclicTag-Steps"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[{NaryCyclicTagToCyclicTagInit[{2, 0, 1}, 3]}, 3],
	{{2, 0, 1}},
	TestID -> "NaryCyclicTag-Decode-InvertsInit"
]


(* Round trips *)

VerificationTest[
	nctViaCyclicTag[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 2, 8],
	nctEvolve[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 8],
	TestID -> "NaryCyclicTag-RoundTrip-Basic"
]

VerificationTest[
	nctViaCyclicTag[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}, {2, 0, 1}, 3, 10],
	nctEvolve[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}, {2, 0, 1}, 10],
	TestID -> "NaryCyclicTag-RoundTrip-ThreeStates"
]

VerificationTest[
	nctViaCyclicTag[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 4, 6],
	nctEvolve[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 6],
	TestID -> "NaryCyclicTag-RoundTrip-ExtraStates"
]

VerificationTest[
	nctViaCyclicTag[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0, 1}, 2, 0],
	{{1, 0, 1}},
	TestID -> "NaryCyclicTag-RoundTrip-ZeroSteps"
]

VerificationTest[
	nctViaCyclicTag[{{{}, {0}}}, {0, 1}, 2, 6],
	nctEvolve[{{{}, {0}}}, {0, 1}, 6],
	TestID -> "NaryCyclicTag-RoundTrip-TapeEmpties"
]

VerificationTest[
	Select[nctCases, nctViaCyclicTag @@ # =!= nctEvolve[#[[1]], #[[2]], #[[4]]] &],
	{},
	TestID -> "NaryCyclicTag-RoundTrip-Random"
]


(* "TargetSystem" -> "Rule110" *)

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0}}}, "TargetSystem" -> "Rule110"],
	{{0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "NaryCyclicTag-Rule110-Rule"
]

VerificationTest[
	{NaryCyclicTagToCyclicTagInit[{1}, 2, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagSteps[5, 2, "TargetSystem" -> "Rule110"]},
	{{0, 1, 0, 0, 0, 0}, 30},
	TestID -> "NaryCyclicTag-Rule110-InitSteps"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0}}, {{0, 0}, {}}}, "TargetSystem" -> "rule110"],
	NaryCyclicTagToCyclicTagRule[{{{1}, {0}}, {{0, 0}, {}}}, "TargetSystem" -> "Rule110"],
	TestID -> "NaryCyclicTag-Rule110-LowerCase"
]

VerificationTest[
	Select[Take[nctCases, 25],
		nctViaCyclicTag[Sequence @@ #, "TargetSystem" -> "Rule110"] =!= nctEvolve[#[[1]], #[[2]], #[[4]]] &],
	{},
	TestID -> "NaryCyclicTag-Rule110-Random"
]

VerificationTest[
	AllTrue[
		Take[nctCases, 25],
		Divisible[Length[NaryCyclicTagToCyclicTagRule[#[[1]], #[[3]], "TargetSystem" -> "Rule110"]], 6] &],
	True,
	TestID -> "NaryCyclicTag-Rule110-MultipleOf6"
]
