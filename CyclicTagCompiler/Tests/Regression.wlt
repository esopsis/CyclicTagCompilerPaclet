(* Regression tests: the expected values of decoded evolutions were computed by the original CyclicTagCompiler
   packages that this paclet was made from, using CyclicTagCompilerDev/regression/captureGolden.wls.
   The expected compiled rules, initial conditions and step counts were recomputed three times since: first for
   the smaller encoding of the digit delays in the oblivious ring machine to n-ary cyclic tag compilation, then
   for "Optimization" -> "DeletedSymbolsHighest", which drops the symbol columns that every n-ary rule part
   leaves empty, and then for the symbol-reuse encoding, which selects an oblivious ring machine appendant with
   the tape symbols themselves instead of a separate marker symbol. The decoded evolutions of oblivious ring
   machines, cellular automata and automata networks are unchanged by all three: they only narrow the cyclic tag
   encoding those compilations pass through. Large values are compared by the SHA-256 hash of their InputForm.

   The construction is described in "A Simpler Polynomial-Time Compilation to Cyclic Tag for Bounded
   Computation", https://community.wolfram.com/t/a-simpler-polynomial-time-compilation-to-cyclic-tag-for-bounded-computation *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "Regression-Load"
]

regressionHash[expr_] := Hash[ToString[expr, InputForm], "SHA256", "HexString"]


VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}, {{0, 1}, {}}}],
	{{0, 1}, {1, 0, 1, 0}, {}, {0, 1, 0, 1}, {1, 0, 0, 1}, {}},
	TestID -> "Regression-NCT-Rule-1"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{{0, 0, 1}, {1, 0, 0, 0, 1, 0}, {}, {0, 1, 0, 0, 1, 0}, {0, 0, 1}, {1, 0, 0}},
	TestID -> "Regression-NCT-Rule-2"
]

(* Symbol 1 is empty in every rule part, so its column is dropped and the blocks are 2 cells wide, not 3. *)
VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{{0, 0}, {1, 0}, {1, 0, 0, 0}, {}},
	TestID -> "Regression-NCT-Rule-3"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"],
	{{0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {}, {0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-NCT-Rule-4"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}, "TargetSystem" -> "Rule110"],
	{{0, 0, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {}},
	TestID -> "Regression-NCT-Rule-5"
]

(* Every column is dropped, so the rule becomes the single empty appendant. *)
VerificationTest[
	{NaryCyclicTagToCyclicTagRule[{{{}, {}}}], NaryCyclicTagToCyclicTagRule[{}]},
	{{{}}, {{}}},
	TestID -> "Regression-NCT-Rule-6"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1, 1}, {{{1}, {0, 0}}, {{}, {1, 1}}, {{0, 1}, {}}}],
	{1, 0, 0, 1, 0, 1},
	TestID -> "Regression-NCT-Init-1"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{2, 0, 1}, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{0, 0, 1, 1, 0, 0, 0, 1, 0},
	TestID -> "Regression-NCT-Init-2"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1}, {{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"],
	{1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
	TestID -> "Regression-NCT-Init-3"
]

(* The dropped symbol 1 encodes as an all-zero block, and 2 takes over its place in the encoding. *)
VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1, 2}, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{1, 0, 0, 0, 0, 1},
	TestID -> "Regression-NCT-Init-4"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[7, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	21,
	TestID -> "Regression-NCT-Steps-1"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[7, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}, "TargetSystem" -> "Rule110"],
	42,
	TestID -> "Regression-NCT-Steps-2"
]

(* Dropping symbol 1 makes each step cost 2 cyclic tag steps instead of 3. *)
VerificationTest[
	NaryCyclicTagToCyclicTagSteps[7, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	14,
	TestID -> "Regression-NCT-Steps-3"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[CyclicTagSystem[NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}], NaryCyclicTagToCyclicTagInit[{2, 0, 1}, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}], NaryCyclicTagToCyclicTagSteps[6, {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}]], {{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{{2, 0, 1}, {0, 1}, {1, 1, 1}, {1, 1, 0, 1}, {1, 0, 1, 2}, {0, 1, 2, 0, 1}, {1, 2, 0, 1, 1, 1}},
	TestID -> "Regression-NCT-Decode-1"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[CyclicTagSystem[NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagInit[{0, 1}, {{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagSteps[5, {{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"]], {{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"],
	{{0, 1}, {1, 1}, {1, 1, 1}, {1, 1, 0, 0}, {1, 0, 0, 1, 1}, {0, 0, 1, 1, 0, 0}},
	TestID -> "Regression-NCT-Decode-2"
]

(* With symbol 1 dropped the decoded evolution is the n-ary one relabeled: the survivors 0 and 2 keep their
   numbers and the dropped symbol 1 comes back as 2 as well. *)
VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[CyclicTagSystem[NaryCyclicTagToCyclicTagRule[{{{1}, {}, {0}}, {{0, 1}, {}, {}}}], NaryCyclicTagToCyclicTagInit[{0, 1, 2}, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}], NaryCyclicTagToCyclicTagSteps[6, {{{1}, {}, {0}}, {{0, 1}, {}, {}}}]], {{{1}, {}, {0}}, {{0, 1}, {}, {}}}],
	{{0, 2, 1}, {2, 1, 2}, {1, 2}, {2, 0}, {0}, {2}, {}},
	TestID -> "Regression-NCT-Decode-3"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{x_, y_} :> {y, x}, 4],
	{{{}, {2}, {}}, {{0, 2}, {1, 2}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{2, 0, 0}, {2, 1, 0}, {}}, {{0, 1}, {1, 1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}},
	TestID -> "Regression-ORM-NCTRule-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{{}, {2}, {}}, {{0, 2}, {1, 2}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{2, 0, 0}, {2, 1, 0}, {}}, {{1, 0}, {0, 0}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}},
	TestID -> "Regression-ORM-NCTRule-2"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{Sort, {}, 2}, 4],
	{{{}, {2}, {}}, {{0, 2}, {1, 2}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{2, 0, 0}, {2, 0, 1}, {}}, {{0, 1}, {1, 1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}, {{0}, {1}, {}}},
	TestID -> "Regression-ORM-NCTRule-3"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	{{{}, {3}, {3, 3}, {}}, {{0, 3, 3}, {1, 3, 3}, {2, 3, 3}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{3, 3, 0, 0}, {3, 3, 1, 0}, {3, 3, 2, 0}, {}}, {{3, 0, 1}, {3, 1, 1}, {3, 2, 1}, {}}, {{0, 2}, {1, 2}, {2, 2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}, {{0}, {1}, {2}, {}}},
	TestID -> "Regression-ORM-NCTRule-4"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{}, 3],
	{},
	TestID -> "Regression-ORM-NCTRule-5"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[10, {{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	130,
	TestID -> "Regression-ORM-NCTSteps-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[4, {}, 3],
	4,
	TestID -> "Regression-ORM-NCTSteps-2"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{}, {0, 0}, {1, 0, 0, 0}, {0, 1, 0, 0}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {0, 0, 1, 0, 1, 0}, {0, 0, 0, 1, 1, 0}, {0, 1, 1, 0}, {1, 0, 1, 0}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {1, 0}, {0, 1}, {1, 0}, {0, 1}},
	TestID -> "Regression-ORM-Rule-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	{{}, {0, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-ORM-Rule-2"
]

VerificationTest[
	regressionHash[ObliviousRingMachineToCyclicTagRule[{{Reverse, {}, 3}, 2}, 5, 3]],
	"4e27f1fb150a8e8676929c04f4aa2967a783b2a1ab9af5339ad247a269e7f56f",
	TestID -> "Regression-ORM-Rule-3"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagInit[{0, 1, 1, 0}, {x_, y_} :> {y, x}],
	{1, 0, 0, 1, 0, 1, 1, 0},
	TestID -> "Regression-ORM-Init-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagInit[{0, 2, 1, 1, 0}, {{Reverse, {}, 3}, 2}, 3],
	{1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0},
	TestID -> "Regression-ORM-Init-2"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagSteps[6, {{Reverse, {}, 3}, 2}, 5, 3],
	468,
	TestID -> "Regression-ORM-Steps-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagSteps[6, {x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	360,
	TestID -> "Regression-ORM-Steps-2"
]

VerificationTest[
	DecodeCyclicTagToObliviousRingMachine[CyclicTagSystem[ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5], ObliviousRingMachineToCyclicTagInit[{0, 1, 1, 0, 1}, {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}], ObliviousRingMachineToCyclicTagSteps[4, {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5]], {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{0, 1, 1, 0, 1}, {1, 0, 1, 1, 0}, {1, 1, 0, 1, 0}, {0, 1, 0, 0, 0}, {0, 0, 0, 1, 0}},
	TestID -> "Regression-ORM-Decode-1"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineRule[30],
	{{{1, 1, 1} -> {0, 1, 1}, {1, 1, 0} -> {0, 1, 0}, {1, 0, 1} -> {0, 0, 1}, {1, 0, 0} -> {1, 0, 0}, {0, 1, 1} -> {1, 1, 1}, {0, 1, 0} -> {1, 1, 0}, {0, 0, 1} -> {1, 0, 1}, {0, 0, 0} -> {0, 0, 0}}},
	TestID -> "Regression-CA-ORMRule-1"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineRule[{6, 2, 1/2}],
	{{{1, 1} -> {0, 1}, {1, 0} -> {1, 0}, {0, 1} -> {1, 1}, {0, 0} -> {0, 0}}},
	TestID -> "Regression-CA-ORMRule-2"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineInit[{0, 1, 1, 0, 1}, 1, "InfiniteSteps" -> True],
	{0, 0, 0, 1, 1, 0, 1},
	TestID -> "Regression-CA-ORMInit-1"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineInit[{0, 1, 1, 0, 1}, 3/2],
	{0, 1, 1, 0, 1},
	TestID -> "Regression-CA-ORMInit-2"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineSteps[4, 6, 3/2, "InfiniteSteps" -> True],
	36,
	TestID -> "Regression-CA-ORMSteps-1"
]

VerificationTest[
	CellularAutomatonToObliviousRingMachineSteps[4, 6],
	24,
	TestID -> "Regression-CA-ORMSteps-2"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[30, 5]],
	"18ccda5687ec66f12d314ea1baa70f824832dfe6a862ab4146bf7eec1f44c88f",
	TestID -> "Regression-CA-Rule-1"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[110, 4, 2, "InfiniteSteps" -> True]],
	"f4f8bbaa367d1dc21cd0d2a5a8a8bcdeb25b39dfba0af6212ac1fdf58955be95",
	TestID -> "Regression-CA-Rule-2"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[{2007, 3, 1}, 4]],
	"9998ca26628f4d9b3907f6a96fc55b2e72acb478ec7e3ec09faf0a4458e132ae",
	TestID -> "Regression-CA-Rule-3"
]

VerificationTest[
	CellularAutomatonToCyclicTagRule[{6, 2, 1/2}, 4, 2, "TargetSystem" -> "Rule110"],
	{{}, {0, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-CA-Rule-4"
]

VerificationTest[
	CellularAutomatonToCyclicTagInit[{0, 1, 1, 0, 1}],
	{1, 0, 0, 1, 0, 1, 1, 0, 0, 1},
	TestID -> "Regression-CA-Init-1"
]

VerificationTest[
	CellularAutomatonToCyclicTagInit[{0, 2, 1, 0}, 3, 1, "InfiniteSteps" -> True],
	{1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0},
	TestID -> "Regression-CA-Init-2"
]

VerificationTest[
	CellularAutomatonToCyclicTagSteps[3, 5],
	450,
	TestID -> "Regression-CA-Steps-1"
]

VerificationTest[
	CellularAutomatonToCyclicTagSteps[3, 5, 2, 1/2, "InfiniteSteps" -> True],
	504,
	TestID -> "Regression-CA-Steps-2"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 6][{0, 0, 1, 0, 0, 1}, 2],
	{{0, 0, 1, 0, 0, 1}, {1, 1, 1, 1}, {0, 0}},
	TestID -> "Regression-CA-Compiled-1"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[30, 6, "InfiniteSteps" -> True][{0, 0, 1, 0, 0, 1}, 3],
	{{0, 0, 1, 0, 0, 1}, {1, 1, 1, 1, 1, 1}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}},
	TestID -> "Regression-CA-Compiled-2"
]

VerificationTest[
	CompiledCellularAutomatonToCyclicTag[{6, 2, 1/2}, 5, "Mod6CyclicTag" -> True][{0, 1, 0, 0, 1}, 3],
	{{0, 1, 0, 0, 1}, {1, 1, 0, 1}, {0, 1, 1}, {1, 0}},
	TestID -> "Regression-CA-Compiled-3"
]

VerificationTest[
	AutomataNetworkToObliviousRingMachineInit[{1, 0, 1}, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	{1, 1, 1, 0, 1, 1},
	TestID -> "Regression-AN-ORMInit-1"
]

VerificationTest[
	AutomataNetworkToObliviousRingMachineSteps[3, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}, 2],
	66,
	TestID -> "Regression-AN-ORMSteps-1"
]

VerificationTest[
	regressionHash[AutomataNetworkToCyclicTagRule[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}]],
	"a9f7e88db8efbd6911d1ffd7aafe60bea3cea7f239a6a51cbb7bc5305dfbd6fa",
	TestID -> "Regression-AN-Rule-1"
]

VerificationTest[
	regressionHash[AutomataNetworkToCyclicTagRule[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}, 2, "TargetSystem" -> "Rule110"]],
	"9bcd73554427019deaab2fdf88816563d66feb4ba165a3ab0a0b423c28410aea",
	TestID -> "Regression-AN-Rule-2"
]

VerificationTest[
	AutomataNetworkToCyclicTagInit[{1, 0, 1}, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	{0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1},
	TestID -> "Regression-AN-Init-1"
]

VerificationTest[
	AutomataNetworkToCyclicTagSteps[2, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	1200,
	TestID -> "Regression-AN-Steps-1"
]

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}][{1, 0, 1}, 3],
	{{1, 0, 1}, {1, 0, 1}, {1, 0, 1}, {1, 0, 1}},
	TestID -> "Regression-AN-Compiled-1"
]

VerificationTest[
	CompiledAutomataNetworkToCyclicTag[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}, "Mod6CyclicTag" -> True][{0, 1, 1}, 2],
	{{0, 1, 1}, {0, 1, 1}, {0, 1, 1}},
	TestID -> "Regression-AN-Compiled-2"
]
