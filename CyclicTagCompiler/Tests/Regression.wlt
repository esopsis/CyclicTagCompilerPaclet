(* Regression tests: each expected value was computed by the original CyclicTagCompiler packages
   that this paclet was made from, using CyclicTagCompilerDev/regression/captureGolden.wls.
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
	DecodeCyclicTagToNaryCyclicTag[ResourceFunction["CyclicTagSystemEvolveList"][NaryCyclicTagToCyclicTagRule[{{{2}, {0, 1}, {}}, {{1, 1}, {2}, {0}}}], NaryCyclicTagToCyclicTagInit[{2, 0, 1}, 3], NaryCyclicTagToCyclicTagSteps[6, 3]], 3],
	{{2, 0, 1}, {0, 1}, {1, 1, 1}, {1, 1, 0, 1}, {1, 0, 1, 2}, {0, 1, 2, 0, 1}, {1, 2, 0, 1, 1, 1}},
	TestID -> "Regression-NCT-Decode-1"
]

VerificationTest[
	DecodeCyclicTagToNaryCyclicTag[ResourceFunction["CyclicTagSystemEvolveList"][NaryCyclicTagToCyclicTagRule[{{{1}, {0, 0}}, {{}, {1, 1}}}, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagInit[{0, 1}, 2, "TargetSystem" -> "Rule110"], NaryCyclicTagToCyclicTagSteps[5, 2, "TargetSystem" -> "Rule110"]], 2, "TargetSystem" -> "Rule110"],
	{{0, 1}, {1, 1}, {1, 1, 1}, {1, 1, 0, 0}, {1, 0, 0, 1, 1}, {0, 0, 1, 1, 0, 0}},
	TestID -> "Regression-NCT-Decode-2"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{x_, y_} :> {y, x}, 4],
	{{{2}, {3, 2}, {}, {}}, {{3, 2}, {3, 3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 0, 1}, {}}, {{0}, {1}, {3, 1, 0}, {}}, {{0}, {1}, {1, 1}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{{2}, {3, 2}, {}, {}}, {{3, 2}, {3, 3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 1, 0}, {}}, {{0}, {1}, {3, 1, 0}, {}}, {{0}, {1}, {0, 0}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-2"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{Sort, {}, 2}, 4],
	{{{2}, {3, 2}, {}, {}}, {{3, 2}, {3, 3, 3, 2}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {3, 3, 3, 0, 0}, {}}, {{0}, {1}, {3, 3, 0, 1}, {}}, {{0}, {1}, {3, 0, 1}, {}}, {{0}, {1}, {1, 1}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}, {{0}, {1}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-3"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	{{{3}, {4, 3}, {4, 4, 3}, {}, {}}, {{4, 4, 3}, {4, 4, 4, 4, 4, 3}, {4, 4, 4, 4, 4, 4, 4, 4, 3}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 4, 4, 0, 0}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 4, 0, 1}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 4, 0, 2}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 4, 1, 0}, {}}, {{0}, {1}, {2}, {4, 4, 4, 4, 1, 1}, {}}, {{0}, {1}, {2}, {4, 4, 4, 1, 2}, {}}, {{0}, {1}, {2}, {4, 4, 2, 0}, {}}, {{0}, {1}, {2}, {4, 2, 1}, {}}, {{0}, {1}, {2}, {2, 2}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{3}, {4, 3}, {4, 4, 3}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {4, 4, 0}, {}}, {{0}, {1}, {2}, {4, 1}, {}}, {{0}, {1}, {2}, {2}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}, {{0}, {1}, {2}, {}, {}}},
	TestID -> "Regression-ORM-NCTRule-4"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagRule[{}, 3],
	{},
	TestID -> "Regression-ORM-NCTRule-5"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[10, {{{{x_, y_} :> {y, x}}, 2}, {{x_} :> {x}}}, 5, 3],
	175,
	TestID -> "Regression-ORM-NCTSteps-1"
]

VerificationTest[
	ObliviousRingMachineToNaryCyclicTagSteps[4, {}, 3],
	4,
	TestID -> "Regression-ORM-NCTSteps-2"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
	{{0, 0, 1, 0}, {0, 0, 0, 1, 0, 0, 1, 0}, {}, {}, {0, 0, 0, 1, 0, 0, 1, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {1, 0, 0, 0, 1, 0, 0, 0}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}, {1, 0, 0, 0}, {0, 1, 0, 0}, {}, {}},
	TestID -> "Regression-ORM-Rule-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagRule[{x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	{{0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
	TestID -> "Regression-ORM-Rule-2"
]

VerificationTest[
	regressionHash[ObliviousRingMachineToCyclicTagRule[{{Reverse, {}, 3}, 2}, 5, 3]],
	"3a837e013d7de53983ff42a3acfb18bc718aef56bbada391a2e4dee5787dac3c",
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
	1440,
	TestID -> "Regression-ORM-Steps-1"
]

VerificationTest[
	ObliviousRingMachineToCyclicTagSteps[6, {x_, y_} :> {y, x}, 4, 2, "TargetSystem" -> "Rule110"],
	468,
	TestID -> "Regression-ORM-Steps-2"
]

VerificationTest[
	DecodeCyclicTagToObliviousRingMachine[ResourceFunction["CyclicTagSystemEvolveList"][ObliviousRingMachineToCyclicTagRule[{{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5], ObliviousRingMachineToCyclicTagInit[{0, 1, 1, 0, 1}, {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}], ObliviousRingMachineToCyclicTagSteps[4, {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5]], {{{0, 1} -> {1, 0}, {1, 1} -> {0, 0}}, 2}, 5],
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
	"ec5023e2f8e2c3480228f62650b91407c4121e3ad60c3895e745be570c1a84d9",
	TestID -> "Regression-CA-Rule-1"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[110, 4, 2, "InfiniteSteps" -> True]],
	"e0da6b623282c5ed8f1ca9012c59b3ec0a1b82435ce98641e4cb9def822ae23f",
	TestID -> "Regression-CA-Rule-2"
]

VerificationTest[
	regressionHash[CellularAutomatonToCyclicTagRule[{2007, 3, 1}, 4]],
	"a03014dc4767437ecac3fb63bd7fa81a1e747c0ff150a1559cba674fb1870345",
	TestID -> "Regression-CA-Rule-3"
]

VerificationTest[
	CellularAutomatonToCyclicTagRule[{6, 2, 1/2}, 4, 2, "TargetSystem" -> "Rule110"],
	{{0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}, {1, 0, 0, 0, 0, 0}, {0, 1, 0, 0, 0, 0}, {}, {}, {}, {}},
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
	1320,
	TestID -> "Regression-CA-Steps-1"
]

VerificationTest[
	CellularAutomatonToCyclicTagSteps[3, 5, 2, 1/2, "InfiniteSteps" -> True],
	1224,
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
	"b271cc618fc71b8ad86ebc562cabf4d7dccadc07b36a4fa0d073cf5fc103acc6",
	TestID -> "Regression-AN-Rule-1"
]

VerificationTest[
	regressionHash[AutomataNetworkToCyclicTagRule[{{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}, 2, "TargetSystem" -> "Rule110"]],
	"5c314c36500eea5f5543f71a2f4c0956238c5ae7a365b1af944d71ee6ef97228",
	TestID -> "Regression-AN-Rule-2"
]

VerificationTest[
	AutomataNetworkToCyclicTagInit[{1, 0, 1}, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	{0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0},
	TestID -> "Regression-AN-Init-1"
]

VerificationTest[
	AutomataNetworkToCyclicTagSteps[2, {{{{0, 0} -> 0, {0, 1} -> 1, {1, 0} -> 1, {1, 1} -> 0}, {2, 3}, 1}, {{{0} -> 1, {1} -> 0}, {1}, 2}, {{{0, 0} -> 1, {0, 1} -> 0, {1, 0} -> 0, {1, 1} -> 1}, {1, 1}, 3}}],
	2768,
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
