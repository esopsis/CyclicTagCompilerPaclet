(* Tests for compiling automata networks to oblivious ring machines and to cyclic tag systems. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "AutomataNetwork-Load"
]

(* The reference systems are resource functions. The paclet's resolver also finds those
   that are not yet in the Wolfram Function Repository. *)
ctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["CyclicTagSystemEvolveList"];
ormEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["ObliviousRingMachine"];
anEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["AutomataNetworkRun"];

(* If a reference system could not be loaded, for example without a network connection, the other tests fail. *)
VerificationTest[
	MatchQ[{ctEvolve, ormEvolve, anEvolve}, {__ResourceFunction}],
	True,
	TestID -> "AutomataNetwork-ReferenceSystems"
]

anViaObliviousRingMachine[network_, init_, t_, states_ : 2] :=
	DecodeObliviousRingMachineToAutomataNetwork[
		ormEvolve[
			AutomataNetworkToObliviousRingMachineRule[network, states],
			AutomataNetworkToObliviousRingMachineInit[init, network],
			AutomataNetworkToObliviousRingMachineSteps[t, network, states]],
		network,
		states]

anViaCyclicTag[network_, init_, t_, states_ : 2, opts___] :=
	DecodeCyclicTagToAutomataNetwork[
		ctEvolve[
			AutomataNetworkToCyclicTagRule[network, states, opts],
			AutomataNetworkToCyclicTagInit[init, network, states, opts],
			AutomataNetworkToCyclicTagSteps[t, network, states, opts]],
		network,
		states,
		opts]

xorRule = Thread[Tuples[{0, 1}, 2] -> {0, 1, 1, 0}];
notRule = {{0} -> 1, {1} -> 0};

(* Automaton 1 is read three times, once twice by automaton 3, which reads nothing else. *)
xorNetwork = {{xorRule, {2, 3}, 1}, {notRule, {1}, 2}, {Thread[Tuples[{0, 1}, 2] -> {1, 0, 0, 1}], {1, 1}, 3}};

(* Three states; automaton 3 reads only automaton 2, and automaton 1 reads automaton 2 twice. *)
threeStateNetwork = {
	{Thread[Tuples[{2, 1, 0}, 3] -> {2, 1, 2, 2, 1, 2, 2, 1, 0, 1, 1, 1, 2, 2, 0, 1, 1, 2, 1, 1, 1, 0, 0, 0, 0, 0, 1}], {2, 2, 3}, 1},
	{Thread[Tuples[{2, 1, 0}, 2] -> {0, 0, 1, 0, 0, 1, 2, 0, 1}], {1, 3}, 2},
	{{{2} -> 0, {1} -> 1, {0} -> 2}, {2}, 3}};

(* Elementary rule 30 on a ring of 5 cells. *)
rule30Ring = Table[{Thread[Tuples[{1, 0}, 3] -> IntegerDigits[30, 2, 8]], {Mod[i - 2, 5] + 1, i, Mod[i, 5] + 1}, i}, {i, 5}];

(* Automaton 2 is not read by any automaton. *)
unreadNetwork = {{notRule, {1}, 1}, {xorRule, {1, 1}, 2}};

(* Labels need not be integers in order. *)
labeledNetwork = {{xorRule, {"b", "c"}, "a"}, {notRule, {"a"}, "c"}, {xorRule, {"c", "a"}, "b"}};

(* Rules given by patterns. *)
patternNetwork = {{{{x_, y_} :> Mod[x + y, 2]}, {2, 3}, 1}, {{{x_} :> 1 - x}, {1}, 2}, {{{x_, y_} :> Boole[x == y]}, {1, 1}, 3}};
patternNetwork3 = {{{{x_, y_} :> Mod[x + y, 3]}, {2, 3}, 1}, {{{x_} :> Mod[x + 1, 3]}, {1}, 2}, {{{x_, y_} :> Max[x, y]}, {1, 2}, 3}};

randomNetwork[n_, k_, states_] :=
	Table[{Thread[Tuples[Range[0, states - 1], k] -> RandomInteger[states - 1, states^k]], RandomInteger[{1, n}, k], i}, {i, n}]

anCases =
	BlockRandom[
		Flatten[
			Table[{randomNetwork[n, k, s], RandomInteger[s - 1, n], RandomInteger[{0, 3}], s}, {n, 1, 4}, {k, 1, 2}, {s, 2, 3}],
			2],
		RandomSeeding -> 2026];


(* Oblivious ring machine stage *)

VerificationTest[
	AutomataNetworkToObliviousRingMachineInit[{1, 0, 1}, xorNetwork],
	{1, 1, 1, 0, 1, 1},
	TestID -> "AutomataNetwork-ORM-Init"
]

VerificationTest[
	AutomataNetworkToObliviousRingMachineSteps[3, xorNetwork],
	3 Length[AutomataNetworkToObliviousRingMachineRule[xorNetwork]],
	TestID -> "AutomataNetwork-ORM-Steps"
]

VerificationTest[
	anViaObliviousRingMachine[xorNetwork, {1, 0, 1}, 4],
	anEvolve[xorNetwork, {1, 0, 1}, 4],
	TestID -> "AutomataNetwork-ORM-XorNetwork"
]

VerificationTest[
	anViaObliviousRingMachine[threeStateNetwork, {1, 2, 0}, 3, 3],
	anEvolve[threeStateNetwork, {1, 2, 0}, 3],
	TestID -> "AutomataNetwork-ORM-ThreeStates"
]

VerificationTest[
	anViaObliviousRingMachine[rule30Ring, {0, 0, 1, 0, 0}, 4],
	CellularAutomaton[30, {0, 0, 1, 0, 0}, 4],
	TestID -> "AutomataNetwork-ORM-CellularAutomaton"
]

VerificationTest[
	{
		anViaObliviousRingMachine[unreadNetwork, {1, 0}, 3] === anEvolve[unreadNetwork, {1, 0}, 3],
		anViaObliviousRingMachine[labeledNetwork, {1, 0, 1}, 3] === anEvolve[labeledNetwork, {1, 0, 1}, 3]
	},
	{True, True},
	TestID -> "AutomataNetwork-ORM-UnreadAndLabeled"
]

VerificationTest[
	Select[anCases, anViaObliviousRingMachine @@ # =!= anEvolve @@ Most[#] &],
	{},
	TestID -> "AutomataNetwork-ORM-Random"
]


(* Cyclic tag *)

VerificationTest[
	anViaCyclicTag[xorNetwork, {1, 0, 1}, 3],
	anEvolve[xorNetwork, {1, 0, 1}, 3],
	TestID -> "AutomataNetwork-CyclicTag-XorNetwork"
]

VerificationTest[
	anViaCyclicTag[threeStateNetwork, {1, 2, 0}, 2, 3],
	anEvolve[threeStateNetwork, {1, 2, 0}, 2],
	TestID -> "AutomataNetwork-CyclicTag-ThreeStates"
]

VerificationTest[
	anViaCyclicTag[rule30Ring, {0, 0, 1, 0, 0}, 1],
	CellularAutomaton[30, {0, 0, 1, 0, 0}, 1],
	TestID -> "AutomataNetwork-CyclicTag-CellularAutomaton"
]

VerificationTest[
	anViaCyclicTag[xorNetwork, {1, 0, 1}, 3, 3],
	anEvolve[xorNetwork, {1, 0, 1}, 3],
	TestID -> "AutomataNetwork-CyclicTag-ExtraStates"
]

VerificationTest[
	anViaCyclicTag[xorNetwork, {0, 1, 1}, 2, 2, "TargetSystem" -> "Rule110"],
	anEvolve[xorNetwork, {0, 1, 1}, 2],
	TestID -> "AutomataNetwork-CyclicTag-Rule110"
]

VerificationTest[
	Select[Take[anCases, 12], anViaCyclicTag @@ # =!= anEvolve @@ Most[#] &],
	{},
	TestID -> "AutomataNetwork-CyclicTag-Random"
]


(* Pattern rules *)

VerificationTest[
	{
		anViaObliviousRingMachine[patternNetwork, {1, 0, 1}, 3] === anEvolve[patternNetwork, {1, 0, 1}, 3],
		anViaCyclicTag[patternNetwork, {1, 0, 1}, 2] === anEvolve[patternNetwork, {1, 0, 1}, 2]
	},
	{True, True},
	TestID -> "AutomataNetwork-Patterns-TwoStates"
]

VerificationTest[
	anViaCyclicTag[patternNetwork3, {1, 2, 0}, 2, 3],
	anEvolve[patternNetwork3, {1, 2, 0}, 2],
	TestID -> "AutomataNetwork-Patterns-ThreeStates"
]


(* Compiled networks *)

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[xorNetwork][{1, 0, 1}, 3],
	anEvolve[xorNetwork, {1, 0, 1}, 3],
	TestID -> "AutomataNetwork-Compiled-Default"
]

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[threeStateNetwork, 3][{1, 2, 0}, 2],
	anEvolve[threeStateNetwork, {1, 2, 0}, 2],
	TestID -> "AutomataNetwork-Compiled-ThreeStates"
]

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[xorNetwork, "Mod6CyclicTag" -> True][{0, 1, 1}, 2],
	anEvolve[xorNetwork, {0, 1, 1}, 2],
	TestID -> "AutomataNetwork-Compiled-Mod6CyclicTag"
]

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[xorNetwork][{0, 1, 1}, 2],
	anViaCyclicTag[xorNetwork, {0, 1, 1}, 2],
	TestID -> "AutomataNetwork-Compiled-SameAsStages"
]
