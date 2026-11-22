(* Tests for compiling n-ary cyclic tag systems to cyclic tag systems.

   With "Optimization" -> "DeletedSymbolsHighest" (the default and, for now, the only setting) the symbol
   columns that are empty in every rule part are dropped from the one-hot encoding: those symbols are never
   appended for, so nothing in the cyclic tag system reads them. The compilation is therefore faithful only up
   to a relabeling of the symbols: every surviving symbol is renamed to its position among the survivors, and
   every dropped symbol decodes to the single label replacedStates, which no surviving symbol uses. Round
   trips are checked with isomorphicQ, which tests exactly that contract; rules with no dropped symbols are
   additionally checked for equality.

   Rule parts must all be the same length: dropping a column needs a rectangular rule, so a rule whose parts
   list different numbers of appendants no longer compiles.

   The construction is described in "A Simpler Polynomial-Time Compilation to Cyclic Tag for Bounded
   Computation", https://community.wolfram.com/t/a-simpler-polynomial-time-compilation-to-cyclic-tag-for-bounded-computation *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "NaryCyclicTag-Load"
]

(* Cyclic tag systems are run with the paclet's own CyclicTagSystem. The other reference systems are resource
   functions; the paclet's resolver also finds those that are not yet in the Wolfram Function Repository. *)
ctEvolve = CyclicTagSystem;
nctEvolve = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction["NaryCyclicTag"];

(* The symbols that every rule part leaves empty, and so the ones the compilation drops. *)
droppedSymbols = EricJamesParfitt`CyclicTagCompiler`Private`deleteds;

(* If a reference system could not be loaded, for example without a network connection, the other tests fail. *)
VerificationTest[
	MatchQ[{nctEvolve}, {__ResourceFunction}],
	True,
	TestID -> "NaryCyclicTag-ReferenceSystems"
]

(* Compile an n-ary cyclic tag system, run the cyclic tag system and decode its evolution. *)
nctViaCyclicTag[rule_, init_, t_, opts___] :=
	DecodeCyclicTagToNaryCyclicTag[
		ctEvolve[
			NaryCyclicTagToCyclicTagRule[rule, opts],
			NaryCyclicTagToCyclicTagInit[init, rule, opts],
			NaryCyclicTagToCyclicTagSteps[t, rule, opts]],
		rule,
		opts]

(* got is isomorphic to want for rule if the two evolutions have the same shape and the symbol-for-symbol
   pairing between them is a well-defined map that is injective on the symbols the rule does not drop. *)
isomorphicQ[rule_][got_, want_] :=
	Length[got] === Length[want] &&
	AllTrue[Transpose[{got, want}], SameQ @@ Length /@ # &] &&
	With[
		{
			pairs = DeleteDuplicates[Catenate[MapThread[Transpose[{#2, #1}] &, {got, want}]]],
			dropped = droppedSymbols[rule]
		},
		DuplicateFreeQ[First /@ pairs] &&
		DuplicateFreeQ[Last /@ Select[pairs, !MemberQ[dropped, First[#]] &]]]

roundTripQ[rule_, init_, t_, opts___] :=
	isomorphicQ[rule][nctViaCyclicTag[rule, init, t, opts], nctEvolve[rule, init, t]]

randomNCTRule[states_] :=
	Table[Table[RandomInteger[states - 1, RandomInteger[{0, 3}]], states], RandomInteger[{1, 4}]]

nctCases =
	BlockRandom[
		Table[
			With[{states = RandomInteger[{2, 4}]},
				{randomNCTRule[states], RandomInteger[states - 1, RandomInteger[{1, 5}]], RandomInteger[{0, 8}]}],
			100],
		RandomSeeding -> 1];

(* The random cases cover both kinds of rule. *)
VerificationTest[
	{
		AnyTrue[nctCases, droppedSymbols[First[#]] === {} &],
		AnyTrue[nctCases, droppedSymbols[First[#]] =!= {} &]
	},
	{True, True},
	TestID -> "NaryCyclicTag-Cases-CoverBothKinds"
]


(* Encoding *)

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}],
	{{0, 1}, {1, 0, 1, 0}, {}, {0, 1, 0, 1}},
	TestID -> "NaryCyclicTag-Rule-OneHot"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{{0, 0, 1}, {1, 0, 0, 0, 1, 0}, {}, {0, 1, 0, 0, 1, 0}, {0, 0, 1}, {1, 0, 0}},
	TestID -> "NaryCyclicTag-Rule-ThreeSymbols"
]

(* Symbol 1 is empty in both parts, so its column is dropped and the blocks are 2 cells wide, not 3. *)
VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{{0, 0}, {1, 0}, {1, 0, 0, 0}, {}},
	TestID -> "NaryCyclicTag-Rule-DroppedSymbol"
]

(* Every rule part has to give an appendant for every symbol. Working out which columns to drop needs a
   rectangular rule, so a rule with parts of different lengths does not compile to a cyclic tag rule. *)
VerificationTest[
	Quiet[MatchQ[NaryCyclicTagToCyclicTagRule[{{{1}}, {{0}, {1, 1}}}], {{___Integer} ...}]],
	False,
	TestID -> "NaryCyclicTag-Rule-RaggedPartsDoNotCompile"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{1, 0, 1}, {{{1}, {0, 0}}, {{}, {1, 1}}}],
	{0, 1, 1, 0, 0, 1},
	TestID -> "NaryCyclicTag-Init-TwoSymbols"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{2, 0}, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{0, 0, 1, 1, 0, 0},
	TestID -> "NaryCyclicTag-Init-ThreeSymbols"
]

(* The dropped symbol 1 encodes as an all-zero block, and 2 takes over its place in the encoding. *)
VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1, 2}, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{1, 0, 0, 0, 0, 1},
	TestID -> "NaryCyclicTag-Init-DroppedSymbol"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[5, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	15,
	TestID -> "NaryCyclicTag-Steps"
]

(* Dropping symbol 1 makes each step cost 2 cyclic tag steps instead of 3. *)
VerificationTest[
	NaryCyclicTagToCyclicTagSteps[5, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	10,
	TestID -> "NaryCyclicTag-Steps-DroppedSymbol"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[
		{NaryCyclicTagToCyclicTagInit[{2, 0, 1}, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}]},
		{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{{2, 0, 1}},
	TestID -> "NaryCyclicTag-Decode-InvertsInit"
]

(* With a dropped symbol the decoding inverts the encoding up to the relabeling: 0 and 2 survive as 0 and 2,
   and the dropped symbol 1 comes back as 2 as well. *)
VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[
		{NaryCyclicTagToCyclicTagInit[{0, 1, 2}, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}]},
		{{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{{0, 2, 1}},
	TestID -> "NaryCyclicTag-Decode-InvertsInit-DroppedSymbol"
]


(* Round trips *)

VerificationTest[
	nctViaCyclicTag[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 8],
	nctEvolve[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0}, 8],
	TestID -> "NaryCyclicTag-RoundTrip-Basic"
]

VerificationTest[
	nctViaCyclicTag[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}, {2, 0, 1}, 10],
	nctEvolve[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}, {2, 0, 1}, 10],
	TestID -> "NaryCyclicTag-RoundTrip-ThreeSymbols"
]

VerificationTest[
	nctViaCyclicTag[{{{1}, {0, 0}}, {{}, {1, 1}}}, {1, 0, 1}, 0],
	{{1, 0, 1}},
	TestID -> "NaryCyclicTag-RoundTrip-ZeroSteps"
]

(* Symbol 0 is dropped here, so the tape that empties is a relabeling of the n-ary one: the surviving symbol 1
   becomes 0 and the dropped symbol 0 becomes 1. *)
VerificationTest[
	nctViaCyclicTag[{{{}, {0}}}, {0, 1}, 6],
	{{1, 0}, {0}, {1}, {}, {}, {}, {}},
	TestID -> "NaryCyclicTag-RoundTrip-TapeEmpties"
]

VerificationTest[
	roundTripQ[{{{}, {0}}}, {0, 1}, 6],
	True,
	TestID -> "NaryCyclicTag-RoundTrip-TapeEmpties-Isomorphic"
]

(* Symbol 1 is dropped, so the decoded evolution is a relabeling of the n-ary one, not a copy of it. *)
VerificationTest[
	nctViaCyclicTag[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}, {0, 1, 2}, 6],
	{{0, 2, 1}, {2, 1, 2}, {1, 2}, {2, 0}, {0}, {2}, {}},
	TestID -> "NaryCyclicTag-RoundTrip-DroppedSymbol-Relabeled"
]

VerificationTest[
	roundTripQ[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}, {0, 1, 2}, 6],
	True,
	TestID -> "NaryCyclicTag-RoundTrip-DroppedSymbol"
]

(* Every column is dropped, so both symbols collapse onto the one label that no surviving symbol uses. *)
VerificationTest[
	nctViaCyclicTag[{{{}, {}}}, {0, 1}, 3],
	{{0, 0}, {0}, {}, {}},
	TestID -> "NaryCyclicTag-RoundTrip-AllColumnsDropped"
]

VerificationTest[
	roundTripQ[{{{}, {}}}, {0, 1}, 3],
	True,
	TestID -> "NaryCyclicTag-RoundTrip-AllColumnsDropped-Isomorphic"
]

VerificationTest[
	nctViaCyclicTag[{}, {}, 3],
	{{}, {}, {}, {}},
	TestID -> "NaryCyclicTag-RoundTrip-EmptyRule"
]

VerificationTest[
	Select[nctCases, !roundTripQ @@ # &],
	{},
	TestID -> "NaryCyclicTag-RoundTrip-Random"
]

(* The cases with nothing to drop must come back exactly, not merely up to a relabeling. *)
VerificationTest[
	Select[
		Select[nctCases, droppedSymbols[First[#]] === {} &],
		nctViaCyclicTag @@ # =!= nctEvolve @@ # &],
	{},
	TestID -> "NaryCyclicTag-RoundTrip-Random-NothingDropped-Exact"
]


(* "TargetSystem" -> "Rule110" *)

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0}}}, "TargetSystem" -> "Rule110"],
	{{0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "NaryCyclicTag-Rule110-Rule"
]

VerificationTest[
	{
		NaryCyclicTagToCyclicTagInit[{1}, {{{1}, {0}}}, "TargetSystem" -> "Rule110"],
		NaryCyclicTagToCyclicTagSteps[5, {{{1}, {0}}}, "TargetSystem" -> "Rule110"]
	},
	{{0, 1, 0, 0, 0, 0}, 30},
	TestID -> "NaryCyclicTag-Rule110-InitSteps"
]

(* "Rule110" has to be capitalized; anything else is not a recognized target system and does not silently
   fall back to the default. *)
VerificationTest[
	IntegerQ[NaryCyclicTagToCyclicTagSteps[5, {{{1}, {0}}}, "TargetSystem" -> "rule110"]],
	False,
	TestID -> "NaryCyclicTag-Rule110-LowerCaseNotAccepted"
]

VerificationTest[
	Select[Take[nctCases, 25], !roundTripQ[Sequence @@ #, "TargetSystem" -> "Rule110"] &],
	{},
	TestID -> "NaryCyclicTag-Rule110-Random"
]

VerificationTest[
	AllTrue[
		Take[nctCases, 25],
		Divisible[Length[NaryCyclicTagToCyclicTagRule[First[#], "TargetSystem" -> "Rule110"]], 6] &],
	True,
	TestID -> "NaryCyclicTag-Rule110-MultipleOf6"
]

(* Padding the blocks out to a multiple of 6 changes how wide they are, not which symbol each one stands for,
   so "Rule110" decodes to the same relabeling as the default. *)
VerificationTest[
	Select[
		Take[nctCases, 25],
		nctViaCyclicTag[Sequence @@ #, "TargetSystem" -> "Rule110"] =!= nctViaCyclicTag @@ # &],
	{},
	TestID -> "NaryCyclicTag-Rule110-SameRelabeling"
]


(* "Optimization" *)

VerificationTest[
	OptionValue[NaryCyclicTagToCyclicTagRule, "Optimization"],
	"DeletedSymbolsHighest",
	TestID -> "NaryCyclicTag-Optimization-Default"
]

(* Rule, Init and Decode are gated on the optimization they implement, so an unimplemented setting leaves
   them unevaluated instead of quietly compiling something else. Steps keeps working. *)
VerificationTest[
	MatchQ[
		{
			NaryCyclicTagToCyclicTagRule[{{{1}, {0}}}, "Optimization" -> "None"],
			NaryCyclicTagToCyclicTagInit[{1}, {{{1}, {0}}}, "Optimization" -> "None"],
			DecodeCyclicTagToNaryCyclicTag[{{0, 1}}, {{{1}, {0}}}, "Optimization" -> "None"]
		},
		{_NaryCyclicTagToCyclicTagRule, _NaryCyclicTagToCyclicTagInit, _DecodeCyclicTagToNaryCyclicTag}],
	True,
	TestID -> "NaryCyclicTag-Optimization-UnimplementedSettingDoesNotEvaluate"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[5, {{{1}, {0}}}, "Optimization" -> "None"],
	10,
	TestID -> "NaryCyclicTag-Optimization-StepsIgnoresSetting"
]

(* Every function in the chain accepts the option, so one list of options can be passed to all of them. *)
VerificationTest[
	AllTrue[
		{
			NaryCyclicTagToCyclicTagRule, NaryCyclicTagToCyclicTagInit, NaryCyclicTagToCyclicTagSteps,
			DecodeCyclicTagToNaryCyclicTag, ObliviousRingMachineToCyclicTagRule,
			ObliviousRingMachineToCyclicTagInit, ObliviousRingMachineToCyclicTagSteps,
			DecodeCyclicTagToObliviousRingMachine, CellularAutomatonToCyclicTagRule,
			CellularAutomatonToCyclicTagInit, CellularAutomatonToCyclicTagSteps,
			DecodeCyclicTagToCellularAutomaton, AutomataNetworkToCyclicTagRule,
			AutomataNetworkToCyclicTagInit, AutomataNetworkToCyclicTagSteps,
			DecodeCyclicTagToAutomataNetwork
		},
		KeyExistsQ[Association[Options[#]], "Optimization"] &],
	True,
	TestID -> "NaryCyclicTag-Optimization-DeclaredThroughoutChain"
]
