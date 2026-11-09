(* Regression tests: the expected values of decoded evolutions were computed by the original CyclicTagCompiler
   packages that this paclet was made from, using CyclicTagCompilerDev/regression/captureGolden.wls.
   The expected compiled rules and step counts were recomputed for the smaller encoding of the digit delays in
   the oblivious ring machine to n-ary cyclic tag compilation.
   Large values are compared by the SHA-256 hash of their InputForm. *)

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
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}, {{0, 1}, {}}}, 3],
	{{0, 1, 0}, {1, 0, 0, 1, 0, 0}, {}, {}, {0, 1, 0, 0, 1, 0}, {}, {1, 0, 0, 0, 1, 0}, {}, {}},
	TestID -> "Regression-NCT-Rule-2"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}],
	{{0, 0, 1}, {1, 0, 0, 0, 1, 0}, {}, {0, 1, 0, 0, 1, 0}, {0, 0, 1}, {1, 0, 0}},
	TestID -> "Regression-NCT-Rule-3"
]

VerificationTest[
	NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"],
	{{0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {}, {}, {0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-NCT-Rule-4"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1, 1}, 2],
	{1, 0, 0, 1, 0, 1},
	TestID -> "Regression-NCT-Init-1"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{2, 0, 1}, 3],
	{0, 0, 1, 1, 0, 0, 0, 1, 0},
	TestID -> "Regression-NCT-Init-2"
]

VerificationTest[
	NaryCyclicTagToCyclicTagInit[{0, 1}, 2, "TargetSystem" -> "Rule110"],
	{1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
	TestID -> "Regression-NCT-Init-3"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[7, 3],
	21,
	TestID -> "Regression-NCT-Steps-1"
]

VerificationTest[
	NaryCyclicTagToCyclicTagSteps[7, 3, "TargetSystem" -> "Rule110"],
	42,
	TestID -> "Regression-NCT-Steps-2"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[CyclicTagSystem[NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}], NaryCyclicTagToCyclicTagInit[{2, 0, 1}, 3], NaryCyclicTagToCyclicTagSteps[6, 3]], 3],
	{{2, 0, 1}, {0, 1}, {1, 1, 1}, {1, 1, 0, 1}, {1, 0, 1, 2}, {0, 1, 2, 0, 1}, {1, 2, 0, 1, 1, 1}},
	TestID -> "Regression-NCT-Decode-1"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[CyclicTagSystem[NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagInit[{0, 1}, 2, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagSteps[5, 2, "TargetSystem" -> "Rule110"]], 2, "TargetSystem" -> "Rule110"],
	{{0, 1}, {1, 1}, {1, 1, 1}, {1, 1, 0, 0}, {1, 0, 0, 1, 1}, {0, 0, 1, 1, 0, 0}},
	TestID -> "Regression-NCT-Decode-2"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{x_, y_} :> {y, x}, 4],
	{{{}, {3}, {}, {}}, {{2}, {3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 0, 1}, {}}, {{0}, {1}, {3, 1, 0}, {}}, {{0}, {1}, {1, 1}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{{}, {3}, {}, {}}, {{2}, {3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 1, 0}, {}}, {{0}, {1}, {3, 1, 0}, {}}, {{0}, {1}, {0, 0}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-2"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{Sort, {}, 2}, 4],
	{{{}, {3}, {}, {}}, {{2}, {3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 0, 1}, {}}, {{0}, {1}, {3, 0, 1}, {}}, {{0}, {1}, {1, 1}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-3"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	{{{}, {4}, {4, 4}, {}, {}}, {{3}, {4, 4, 4, 3}, {4, 4, 4, 4, 4, 4, 3}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 4, 4, 0, 0}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 4, 0, 1}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 0, 2}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 1, 0}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 1, 1}, {}}, {{0}, {1}, {2}, {4, 4, 4, 1, 2}, {}}, {{0}, {1}, {2}, {4, 4, 2, 0}, {}}, {{0}, {1}, {2}, {4, 2, 1}, {}}, {{0}, {1}, {2}, {2, 2}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{3}, {4, 3}, {4, 4, 3}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {4, 4, 0}, {}}, {{0}, {1}, {2}, {4, 1}, {}}, {{0}, {1}, {2}, {2}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-4"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{}, 3],
	{},
	TestID -> "Regression-ORM-NCTRule-5"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[10, {{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	160,
	TestID -> "Regression-ORM-NCTSteps-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[4, {}, 3],
	4,
	TestID -> "Regression-ORM-NCTSteps-2"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{}, {0, 0, 0, 1}, {}, {}, {0, 0, 1, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {1, 0, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}},
	TestID -> "Regression-ORM-Rule-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	{{}, {0, 0, 0, 1, 0, 0}, {}, {}, {}, {}, {0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-ORM-Rule-2"
]

VerificationTest[
	regressionHash[ObliviousRingMachineToCyclicTagRule[{{Reverse, {}, 3}, 2}, 5, 3]],
	"8f1239d6f6e09cb22860e89d59748b3a3e4b9024542b051e2d81ef0adecf519e",
	TestID -> "Regression-ORM-Rule-3"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagInit[{0, 1, 1, 0}, {x_, y_} :> {y, x}],
	{1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0},
	TestID -> "Regression-ORM-Init-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagInit[{0, 2, 1, 1, 0}, {{Reverse, {}, 3}, 2}, 3],
	{1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0},
	TestID -> "Regression-ORM-Init-2"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagSteps[6, {{Reverse, {}, 3}, 2}, 5, 3],
	1080,
	TestID -> "Regression-ORM-Steps-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagSteps[6, {x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	396,
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
	"0d26a6c93d3faf0e6e4a4e94656d14956bfe11cc7da61cb98b4df076668db37d",
	TestID -> "Regression-CA-Rule-1"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[110, 4, 2, "InfiniteSteps" -> True]],
	"6b49b5d8883cef4fad255943e40b5464cdd863ade1e8a88dafb2abd5ac39ecdc",
	TestID -> "Regression-CA-Rule-2"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[{2007, 3, 1}, 4]],
	"920e566292e9af9df09c6d48c07ee0b2adffe6be7e6cf2857611f5109e10cae6",
	TestID -> "Regression-CA-Rule-3"
]

VerificationTest[
	CellularAutomatonToCyclicTagRule[{6, 2, 1/2}, 4, 2, "TargetSystem" -> "Rule110"],
	{{}, {0, 0, 0, 1, 0, 0}, {}, {}, {}, {}, {0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-CA-Rule-4"
]

VerificationTest[
	CellularAutomatonToCyclicTagInit[{0, 1, 1, 0, 1}],
	{1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0},
	TestID -> "Regression-CA-Init-1"
]

VerificationTest[
	CellularAutomatonToCyclicTagInit[{0, 2, 1, 0}, 3, 1, "InfiniteSteps" -> True],
	{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0},
	TestID -> "Regression-CA-Init-2"
]

VerificationTest[
	CellularAutomatonToCyclicTagSteps[3, 5],
	960,
	TestID -> "Regression-CA-Steps-1"
]

VerificationTest[
	CellularAutomatonToCyclicTagSteps[3, 5, 2, 1/2, "InfiniteSteps" -> True],
	1080,
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
	"fc8f27690c537881c779bfacada8318fbece433d1654cc68afee035b1033ab50",
	TestID -> "Regression-AN-Rule-1"
]

VerificationTest[
	regressionHash[AutomataNetworkToCyclicTagRule[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}, 2, "TargetSystem" -> "Rule110"]],
	"753fdf0be963d325f0a020f8f77b3448e3dfc0857d575cd2bf2d5a6a51793970",
	TestID -> "Regression-AN-Rule-2"
]

VerificationTest[
	AutomataNetworkToCyclicTagInit[{1, 0, 1}, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	{0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0},
	TestID -> "Regression-AN-Init-1"
]

VerificationTest[
	AutomataNetworkToCyclicTagSteps[2, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	2576,
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
