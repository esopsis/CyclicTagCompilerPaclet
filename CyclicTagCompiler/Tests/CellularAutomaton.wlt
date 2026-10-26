(* Tests for compiling cellular automata to oblivious ring machines and to cyclic tag systems. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "CellularAutomaton-Load"
]

(* The reference systems are resource functions. The paclet's resolver also finds those
   that are not yet in the Wolfram Function Repository. *)
ctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["CyclicTagSystemEvolveList"];
ormEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["ObliviousRingMachine"];

(* If a reference system could not be loaded, for example without a network connection, the other tests fail. *)
VerificationTest[
	MatchQ[{ctEvolve, ormEvolve}, {__ResourceFunction}],
	True,
	TestID -> "CellularAutomaton-ReferenceSystems"
]

(* Without "InfiniteSteps" the compiled system reproduces the cells whose light cones stay inside the tape:
   2 r fewer cells each step, shifted by Ceiling[r] cells, for as long as some cells are left. *)
reliableRegion[{n_, k_, r_}, init_, t_] :=
	With[{tapeLength = Length[init]},
		MapIndexed[
			Take[#1[[Ceiling[r] (First[#2] - 1) + 1 ;;]], tapeLength - 2 r (First[#2] - 1)] &,
			Take[CellularAutomaton[{n, k, r}, init, t], UpTo[Quotient[tapeLength - 1, 2 r] + 1]]]]

caViaObliviousRingMachine[{n_, k_, r_}, init_, t_, opts___] :=
	DecodeObliviousRingMachineToCellularAutomaton[
		ormEvolve[
			CellularAutomatonToObliviousRingMachineRule[{n, k, r}, Length[init], k, opts],
			CellularAutomatonToObliviousRingMachineInit[init, r, opts],
			CellularAutomatonToObliviousRingMachineSteps[t, Length[init], r, opts]],
		r,
		opts]

caViaCyclicTag[{n_, k_, r_}, init_, t_, opts___] :=
	DecodeCyclicTagToCellularAutomaton[
		ctEvolve[
			CellularAutomatonToCyclicTagRule[{n, k, r}, Length[init], k, opts],
			CellularAutomatonToCyclicTagInit[init, k, r, opts],
			CellularAutomatonToCyclicTagSteps[t, Length[init], k, r, opts]],
		Length[init],
		k,
		r,
		opts]

(* Rules with 2 and 3 colors and ranges 1/2, 1, 3/2 and 2, with a few initial conditions each. *)
caCases =
	BlockRandom[
		Catenate@Table[
			Table[{spec, RandomInteger[spec[[2]] - 1, RandomInteger[{3, 6}]], RandomInteger[{0, 3}]}, 4],
			{spec, {{30, 2, 1}, {110, 2, 1}, {RandomInteger[3^27 - 1], 3, 1}, {6, 2, 1/2},
				{RandomInteger[2^16 - 1], 2, 3/2}, {RandomInteger[2^32 - 1], 2, 2}}}],
		RandomSeeding -> 8];


(* Oblivious ring machine stage *)

VerificationTest[
	CellularAutomatonToObliviousRingMachineRule[30],
	{{{1, 1, 1} -> {0, 1, 1}, {1, 1, 0} -> {0, 1, 0}, {1, 0, 1} -> {0, 0, 1}, {1, 0, 0} -> {1, 0, 0},
		{0, 1, 1} -> {1, 1, 1}, {0, 1, 0} -> {1, 1, 0}, {0, 0, 1} -> {1, 0, 1}, {0, 0, 0} -> {0, 0, 0}}},
	TestID -> "CellularAutomaton-ORM-Rule"
]

VerificationTest[
	Length[CellularAutomatonToObliviousRingMachineRule[30, 4, "InfiniteSteps" -> True]],
	6,
	TestID -> "CellularAutomaton-ORM-RuleInfiniteSteps"
]

VerificationTest[
	{
		CellularAutomatonToObliviousRingMachineInit[{1, 0, 1}],
		CellularAutomatonToObliviousRingMachineInit[{1, 0, 1}, 1, "InfiniteSteps" -> True],
		CellularAutomatonToObliviousRingMachineInit[{1, 0, 1}, 1/2, "InfiniteSteps" -> True]
	},
	{{1, 0, 1}, {0, 0, 1, 0, 1}, {0, 1, 0, 1}},
	TestID -> "CellularAutomaton-ORM-Init"
]

VerificationTest[
	{
		CellularAutomatonToObliviousRingMachineSteps[3, 5],
		CellularAutomatonToObliviousRingMachineSteps[3, 5, 1, "InfiniteSteps" -> True],
		CellularAutomatonToObliviousRingMachineSteps[3, 5, 3/2, "InfiniteSteps" -> True]
	},
	{15, 21, 24},
	TestID -> "CellularAutomaton-ORM-Steps"
]

VerificationTest[
	caViaObliviousRingMachine[{30, 2, 1}, {0, 0, 0, 1, 0, 0, 1}, 3],
	reliableRegion[{30, 2, 1}, {0, 0, 0, 1, 0, 0, 1}, 3],
	TestID -> "CellularAutomaton-ORM-RoundTrip"
]

VerificationTest[
	caViaObliviousRingMachine[{30, 2, 1}, {0, 0, 0, 1, 0, 0, 1}, 5, "InfiniteSteps" -> True],
	CellularAutomaton[30, {0, 0, 0, 1, 0, 0, 1}, 5],
	TestID -> "CellularAutomaton-ORM-RoundTripInfiniteSteps"
]

VerificationTest[
	caViaObliviousRingMachine[{6, 2, 1/2}, {0, 1, 0, 0, 1, 1}, 4, "InfiniteSteps" -> True],
	CellularAutomaton[{6, 2, 1/2}, {0, 1, 0, 0, 1, 1}, 4],
	TestID -> "CellularAutomaton-ORM-RoundTripHalfRange"
]


(* Cyclic tag *)

VerificationTest[
	Select[caCases, caViaCyclicTag @@ # =!= reliableRegion @@ # &],
	{},
	TestID -> "CellularAutomaton-CyclicTag-Default"
]

VerificationTest[
	Select[caCases, caViaCyclicTag[Sequence @@ #, "InfiniteSteps" -> True] =!= CellularAutomaton @@ # &],
	{},
	TestID -> "CellularAutomaton-CyclicTag-InfiniteSteps"
]

VerificationTest[
	Select[caCases[[;; ;; 4]], caViaCyclicTag[Sequence @@ #, "TargetSystem" -> "Rule110"] =!= reliableRegion @@ # &],
	{},
	TestID -> "CellularAutomaton-CyclicTag-Rule110"
]

VerificationTest[
	SameQ[
		CellularAutomatonToCyclicTagRule[30, 6],
		CellularAutomatonToCyclicTagRule[{30}, 6],
		CellularAutomatonToCyclicTagRule[{30, 2}, 6],
		CellularAutomatonToCyclicTagRule[{30, 2, 1}, 6],
		CellularAutomatonToCyclicTagRule[Thread[Tuples[{1, 0}, 3] -> IntegerDigits[30, 2, 8]], 6]],
	True,
	TestID -> "CellularAutomaton-CyclicTag-RuleForms"
]

VerificationTest[
	Divisible[Length[CellularAutomatonToCyclicTagRule[30, 4, "TargetSystem" -> "Rule110"]], 6],
	True,
	TestID -> "CellularAutomaton-CyclicTag-Rule110MultipleOf6"
]


(* Compiled cellular automata *)

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 8][{0, 0, 0, 1, 0, 0, 1, 0}, 4],
	reliableRegion[{30, 2, 1}, {0, 0, 0, 1, 0, 0, 1, 0}, 4],
	TestID -> "CellularAutomaton-Compiled-Default"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 8, "InfiniteSteps" -> True][{0, 0, 0, 1, 0, 0, 1, 0}, 3],
	CellularAutomaton[30, {0, 0, 0, 1, 0, 0, 1, 0}, 3],
	TestID -> "CellularAutomaton-Compiled-InfiniteSteps"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 6, "Mod6CyclicTag" -> True][{0, 0, 0, 1, 0, 0}, 2],
	reliableRegion[{30, 2, 1}, {0, 0, 0, 1, 0, 0}, 2],
	TestID -> "CellularAutomaton-Compiled-Mod6CyclicTag"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[{2007, 3, 1}, 5][{0, 1, 2, 0, 1}, 2],
	reliableRegion[{2007, 3, 1}, {0, 1, 2, 0, 1}, 2],
	TestID -> "CellularAutomaton-Compiled-ThreeColors"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[Thread[Tuples[{1, 0}, 3] -> IntegerDigits[110, 2, 8]], 6, "InfiniteSteps" -> True][
		{0, 1, 0, 0, 1, 1}, 3],
	CellularAutomaton[110, {0, 1, 0, 0, 1, 1}, 3],
	TestID -> "CellularAutomaton-Compiled-ExplicitRules"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[{6, 2, 1/2}, 5, "InfiniteSteps" -> True][{0, 1, 0, 0, 1}, 4],
	CellularAutomaton[{6, 2, 1/2}, {0, 1, 0, 0, 1}, 4],
	TestID -> "CellularAutomaton-Compiled-HalfRange"
]

VerificationTest[
	Length /@ CompiledCellularAutomatonToCyclicTag[30, 7][{0, 0, 0, 1, 0, 0, 0}, 5],
	{7, 5, 3, 1},
	TestID -> "CellularAutomaton-Compiled-ShrinkingRegion"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 6, "InfiniteSteps" -> True][{0, 0, 1, 0, 0, 1}, 3],
	caViaCyclicTag[{30, 2, 1}, {0, 0, 1, 0, 0, 1}, 3, "InfiniteSteps" -> True],
	TestID -> "CellularAutomaton-Compiled-SameAsStages"
]

(* Init uses enough colors for the colors in init, even when k is smaller. *)
VerificationTest[
	{
		CellularAutomatonToCyclicTagInit[{0, 2, 1, 0}] === CellularAutomatonToCyclicTagInit[{0, 2, 1, 0}, 3],
		DecodeCyclicTagToCellularAutomaton[
			EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["CyclicTagSystemEvolveList"][
				CellularAutomatonToCyclicTagRule[{2007, 3, 1}, 7, "InfiniteSteps" -> True],
				CellularAutomatonToCyclicTagInit[{0, 2, 1, 0, 1, 2, 0}, 2, 1, "InfiniteSteps" -> True],
				CellularAutomatonToCyclicTagSteps[4, 7, 3, 1, "InfiniteSteps" -> True]],
			7, 3, 1, "InfiniteSteps" -> True] === CellularAutomaton[{2007, 3, 1}, {0, 2, 1, 0, 1, 2, 0}, 4]
	},
	{True, True},
	TestID -> "CellularAutomaton-Init-ColorsFromInit"
]
