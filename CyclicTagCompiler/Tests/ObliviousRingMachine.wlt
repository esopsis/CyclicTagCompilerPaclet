(* Tests for compiling oblivious ring machines to n-ary cyclic tag systems and to cyclic tag systems. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "ObliviousRingMachine-Load"
]

(* The reference systems are resource functions. The paclet's resolver also finds those
   that are not yet in the Wolfram Function Repository. *)
ctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["CyclicTagSystemEvolveList"];
nctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["NaryCyclicTag"];
ormEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["ObliviousRingMachine"];

(* If a reference system could not be loaded, for example without a network connection, the other tests fail. *)
VerificationTest[
	MatchQ[{ctEvolve, nctEvolve, ormEvolve}, {__ResourceFunction}],
	True,
	TestID -> "ObliviousRingMachine-ReferenceSystems"
]

ormViaNaryCyclicTag[rule_, init_, states_, t_] :=
	DecodeNaryCyclicTagToObliviousRingMachine[
		nctEvolve[
			ObliviousRingMachineToNaryCyclicTagRule[rule, Length[init], states],
			init,
			ObliviousRingMachineToNaryCyclicTagSteps[t, rule, Length[init], states]],
		rule,
		states]

ormViaCyclicTag[rule_, init_, states_, t_, opts___] :=
	DecodeCyclicTagToObliviousRingMachine[
		ctEvolve[
			ObliviousRingMachineToCyclicTagRule[rule, Length[init], states, opts],
			ObliviousRingMachineToCyclicTagInit[init, rule, states, opts],
			ObliviousRingMachineToCyclicTagSteps[t, rule, Length[init], states, opts]],
		rule,
		Length[init],
		states,
		opts]

(* Both compilations agree with the ring machine itself. *)
ormBothRoutes[rule_, init_, states_, t_] :=
	With[{expected = ormEvolve[rule, init, t]},
		{ormViaNaryCyclicTag[rule, init, states, t] === expected, ormViaCyclicTag[rule, init, states, t] === expected}]

(* A random step: explicit rules, a function step or a pattern rule, with an offset from 0 to 2. *)
randomORMStep[states_, tapeLength_] :=
	Module[{size = RandomInteger[{1, Min[3, tapeLength]}], offset = RandomInteger[{0, 2}], table},
		Switch[RandomChoice[{"rules", "rules", "function", "pattern"}],
			"rules",
				{Table[window -> RandomInteger[states - 1, size],
					{window, RandomSample[Tuples[Range[0, states - 1], size], RandomInteger[{1, states^size}]]}], offset},
			"function",
				table = AssociationThread[Tuples[Range[0, states - 1], size], RandomInteger[states - 1, {states^size, size}]];
				{{table[#] &, {}, size}, offset},
			"pattern",
				With[{vars = Take[{a, b, c}, size]},
					{{(Pattern[#, _] & /@ vars) :> Evaluate[RandomSample[vars]]}, offset}]]]

ormCases =
	BlockRandom[
		Table[
			With[{states = RandomInteger[{2, 3}], tapeLength = RandomInteger[{3, 6}]},
				{Table[randomORMStep[states, tapeLength], RandomInteger[{1, 3}]],
					RandomInteger[states - 1, tapeLength], states, RandomInteger[{0, 10}]}],
			60],
		RandomSeeding -> 42];


(* Rule forms *)

VerificationTest[
	ormBothRoutes[{x_, y_} :> {y, x}, {0, 1, 1, 0}, 2, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-SingleRule"
]

VerificationTest[
	ormBothRoutes[{0, 1} -> {1, 0}, {0, 1, 1, 0}, 2, 6],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-SingleExplicitRule"
]

VerificationTest[
	ormBothRoutes[{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, {0, 1, 1, 0, 1}, 2, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-ListOfRulesIsOneStep"
]

VerificationTest[
	ormBothRoutes[{{{0, 1} -> {1, 0}}, {{1, 1} -> {0, 0}}}, {0, 1, 1, 0, 1}, 2, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-TwoSteps"
]

VerificationTest[
	ormBothRoutes[{{x_, y_} :> {y, x}, 2}, {0, 1, 1, 0, 1}, 2, 5],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-Offset"
]

VerificationTest[
	ormBothRoutes[{Sort, {}, 2}, {1, 0, 1, 0}, 2, 6],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-FunctionStep"
]

VerificationTest[
	ormBothRoutes[{{Reverse, {}, 3}, 2}, {0, 1, 2, 0, 1}, 3, 5],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-FunctionStepOffset"
]

VerificationTest[
	ormBothRoutes[{{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, {0, 1, 1, 0, 0}, 2, 6],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-StepsOfDifferentSizes"
]

VerificationTest[
	ormBothRoutes[{{{{x_, y_} :> {y, x}}, 2}, {Reverse, {}, 3}}, {0, 1, 2, 3, 4, 5}, 6, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-RulesAndFunction"
]

VerificationTest[
	ormBothRoutes[{{{x_, y_, z_} :> {y, z, x}}, 0}, {0, 1, 1, 0}, 2, 3],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-OffsetZero"
]

VerificationTest[
	ormBothRoutes[{{{x_, y_} :> {y, x}}, 7}, {0, 1, 1}, 2, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-OffsetBeyondTape"
]

VerificationTest[
	ormBothRoutes[{{}}, {0, 1, 1}, 2, 3],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-RotateOnly"
]

VerificationTest[
	ormBothRoutes[{{{0} -> {2}, {2} -> {1}}, 1}, {0, 1, 0}, 2, 6],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-SymbolsBeyondTapeStates"
]

VerificationTest[
	ormBothRoutes[{{{2, 2} -> {0, 0}}, 1}, {0, 1, 0}, 3, 4],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-NoRuleMatches"
]

VerificationTest[
	ormBothRoutes[{x_} :> {Mod[x + 1, 3]}, {0, 1, 2, 2}, 3, 6],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-ComputedRightHandSide"
]

VerificationTest[
	ormBothRoutes[{{{0, 1} -> {1, 0}}, 1}, {0, 1, 1, 0}, 2, 0],
	{True, True},
	TestID -> "ObliviousRingMachine-Form-ZeroSteps"
]


(* Random ring machines *)

VerificationTest[
	Select[ormCases, ormViaNaryCyclicTag @@ # =!= ormEvolve[#[[1]], #[[2]], #[[4]]] &],
	{},
	TestID -> "ObliviousRingMachine-Random-NaryCyclicTag"
]

VerificationTest[
	Select[Take[ormCases, 25], ormViaCyclicTag @@ # =!= ormEvolve[#[[1]], #[[2]], #[[4]]] &],
	{},
	TestID -> "ObliviousRingMachine-Random-CyclicTag"
]

VerificationTest[
	Select[Take[ormCases, 10],
		ormViaCyclicTag[Sequence @@ #, "TargetSystem" -> "Rule110"] =!= ormEvolve[#[[1]], #[[2]], #[[4]]] &],
	{},
	TestID -> "ObliviousRingMachine-Random-Rule110"
]


(* Relations between the stages *)

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}}, 2}, 5],
	NaryCyclicTagToCyclicTagRule[ObliviousRingMachineToNaryCyclicTagRule[{{{0, 1} -> {1, 0}}, 2}, 5]],
	TestID -> "ObliviousRingMachine-Relation-RuleChain"
]

(* Three ring machine steps use the two steps of the rule in turn: first, second, first. *)
VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[3, {{{x_, y_} :> {y, x}}, {{x_} :> {x}}}, 4],
	2 Length[ObliviousRingMachineToNaryCyclicTagRule[{{{x_, y_} :> {y, x}}}, 4]] +
		Length[ObliviousRingMachineToNaryCyclicTagRule[{{{x_} :> {x}}}, 4]],
	TestID -> "ObliviousRingMachine-Relation-StepsCycleThroughRule"
]

(* Negative offsets are not implemented; compiling one gives a message. *)
VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{x_, y_} :> {y, x}}, -1}, 4]; "compiled",
	"compiled",
	{ObliviousRingMachineToNaryCyclicTagRule::nni, Catenate::invrp},
	TestID -> "ObliviousRingMachine-NegativeOffset"
]
