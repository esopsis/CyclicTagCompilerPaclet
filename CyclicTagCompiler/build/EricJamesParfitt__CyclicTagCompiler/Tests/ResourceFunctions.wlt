(* Tests for the resource functions the paclet uses, and for how it finds them. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "ResourceFunctions-Load"
]

resourceFunction = EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction;

(* The functions the paclet calls, and the reference systems the tests and documentation use. *)
$usedResourceFunctions = {
	"ArraySkew", "CellularAutomatonFromNumber", "CyclicPartition", "CyclicTagSystemEvolveList",
	"PadRightToMinLength", "RaggedTranspose", "ReplaceByOccurrence"};
$referenceResourceFunctions = {"AutomataNetworkRun", "NaryCyclicTag", "ObliviousRingMachine"};

VerificationTest[
	Select[Join[$usedResourceFunctions, $referenceResourceFunctions], ! MatchQ[resourceFunction[#], _ResourceFunction] &],
	{},
	TestID -> "ResourceFunctions-Found"
]

VerificationTest[
	{
		resourceFunction["CyclicPartition"] === resourceFunction["CyclicPartition"],
		KeyExistsQ[EricJamesParfitt`CyclicTagCompiler`Private`$resourceFunctionCache, "CyclicPartition"]
	},
	{True, True},
	TestID -> "ResourceFunctions-Cached"
]

VerificationTest[
	{
		Head[resourceFunction["NoSuchFunctionForCyclicTagCompilerTests"]],
		KeyExistsQ[EricJamesParfitt`CyclicTagCompiler`Private`$resourceFunctionCache, "NoSuchFunctionForCyclicTagCompilerTests"]
	},
	{Failure, False},
	TestID -> "ResourceFunctions-Unavailable"
]


(* The behavior the paclet relies on *)

VerificationTest[
	resourceFunction["CyclicPartition"][Range[9], {2, 3}, "Remainder" -> True],
	{{1, 2}, {3, 4, 5}, {6, 7}, {8, 9}},
	TestID -> "ResourceFunctions-CyclicPartition"
]

VerificationTest[
	{
		resourceFunction["PadRightToMinLength"][{"a", "b"}, 4, "x"],
		resourceFunction["PadRightToMinLength"][{"a", "b", "c"}, 2, "x"]
	},
	{{"a", "b", "x", "x"}, {"a", "b", "c"}},
	TestID -> "ResourceFunctions-PadRightToMinLength"
]

VerificationTest[
	resourceFunction["RaggedTranspose"][{{1, 2, 3}, {4, 5}}],
	{{1, 4}, {2, 5}, {3}},
	TestID -> "ResourceFunctions-RaggedTranspose"
]

VerificationTest[
	resourceFunction["ReplaceByOccurrence"][{"a", "b", "a", "a"}, "a" -> {1, 2, 3}],
	{1, "b", 2, 3},
	TestID -> "ResourceFunctions-ReplaceByOccurrence"
]

VerificationTest[
	resourceFunction["ArraySkew"][{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}, 1],
	{{1, 2, 3}, {6, 4, 5}, {8, 9, 7}},
	TestID -> "ResourceFunctions-ArraySkew"
]

VerificationTest[
	{
		resourceFunction["CellularAutomatonFromNumber"][30, 2, 1],
		resourceFunction["CellularAutomatonFromNumber"][6, 2, 1/2]
	},
	{
		Thread[Tuples[{1, 0}, 3] -> IntegerDigits[30, 2, 8]],
		{{1, 1} -> 0, {1, 0} -> 1, {0, 1} -> 1, {0, 0} -> 0}
	},
	TestID -> "ResourceFunctions-CellularAutomatonFromNumber"
]

VerificationTest[
	resourceFunction["CyclicTagSystemEvolveList"][{{1, 1}, {0}}, {1}, 3],
	{{1}, {1, 1}, {1, 0}, {0, 1, 1}},
	TestID -> "ResourceFunctions-CyclicTagSystemEvolveList"
]

VerificationTest[
	resourceFunction["CyclicTagSystemEvolveList"][{{1, 1}, {1, 0}}, {1}, 3, "IncludeRules" -> True],
	{{{1}, {1, 1}}, {{1, 1}, {1, 0}}, {{1, 1, 0}, {1, 1}}, {{1, 0, 1, 1}, {1, 0}}},
	TestID -> "ResourceFunctions-CyclicTagSystemEvolveList-IncludeRules"
]

(* The systems are the resource functions themselves. *)
VerificationTest[
	{CyclicTagSystem, NaryCyclicTag, ObliviousRingMachine, AutomataNetworkRun} ===
		(resourceFunction /@ {"CyclicTagSystemEvolveList", "NaryCyclicTag", "ObliviousRingMachine", "AutomataNetworkRun"}),
	True,
	TestID -> "ResourceFunctions-Systems"
]
