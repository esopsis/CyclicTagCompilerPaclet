(* Tests for loading the paclet. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "Loading-Needs"
]

(* Loading the paclet again redefines everything without messages. *)
VerificationTest[
	Get["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "Loading-Get"
]

$cyclicTagCompilerSymbols = {
	"CyclicTagSystem", "NaryCyclicTag", "ObliviousRingMachine", "AutomataNetworkRun",
	"AutomataNetworkToCyclicTagInit", "AutomataNetworkToCyclicTagRule", "AutomataNetworkToCyclicTagSteps",
	"AutomataNetworkToObliviousRingMachineInit", "AutomataNetworkToObliviousRingMachineRule",
	"AutomataNetworkToObliviousRingMachineSteps", "CellularAutomatonToCyclicTagInit", "CellularAutomatonToCyclicTagRule",
	"CellularAutomatonToCyclicTagSteps", "CellularAutomatonToObliviousRingMachineInit",
	"CellularAutomatonToObliviousRingMachineRule", "CellularAutomatonToObliviousRingMachineSteps",
	"CompiledAutomataNetworkToCyclicTag", "CompiledCellularAutomatonToCyclicTag", "DecodeCyclicTagToAutomataNetwork",
	"DecodeCyclicTagToCellularAutomaton", "DecodeCyclicTagToNaryCyclicTag", "DecodeCyclicTagToObliviousRingMachine",
	"DecodeNaryCyclicTagToObliviousRingMachine", "DecodeObliviousRingMachineToAutomataNetwork",
	"DecodeObliviousRingMachineToCellularAutomaton", "NaryCyclicTagToCyclicTagInit", "NaryCyclicTagToCyclicTagRule",
	"NaryCyclicTagToCyclicTagSteps", "ObliviousRingMachineToCyclicTagInit", "ObliviousRingMachineToCyclicTagRule",
	"ObliviousRingMachineToCyclicTagSteps", "ObliviousRingMachineToNaryCyclicTagRule",
	"ObliviousRingMachineToNaryCyclicTagSteps"};

VerificationTest[
	Sort[Names["EricJamesParfitt`CyclicTagCompiler`*"]],
	Sort[$cyclicTagCompilerSymbols],
	TestID -> "Loading-PublicSymbols"
]

VerificationTest[
	Sort[FirstCase[PacletObject["EricJamesParfitt/CyclicTagCompiler"]["Extensions"], {"Kernel", ___, "Symbols" -> s_, ___} :> s]],
	Sort["EricJamesParfitt`CyclicTagCompiler`" <> # & /@ $cyclicTagCompilerSymbols],
	TestID -> "Loading-DeclaredSymbols"
]

VerificationTest[
	Select[$cyclicTagCompilerSymbols, ! StringQ[ToExpression["EricJamesParfitt`CyclicTagCompiler`" <> # <> "::usage"]] &],
	{},
	TestID -> "Loading-Usage"
]

VerificationTest[
	Select[Contexts["EricJamesParfitt`*"], ! StringStartsQ[#, "EricJamesParfitt`CyclicTagCompiler`"] &],
	{},
	TestID -> "Loading-Contexts"
]

(* The contexts of the packages the paclet was made from are not used. *)
VerificationTest[
	Intersection[
		Contexts[],
		{"NaryCyclicTagToCyclicTag`", "ObliviousRingMachineToNaryCyclicTag`", "ObliviousRingMachineToNaryCyclicTagRule`",
			"ObliviousRingMachineToCyclicTag`", "CellularAutomatonToObliviousRingMachine`", "CellularAutomatonToCyclicTag`",
			"AutomataNetworkToObliviousRingMachine`", "AutomataNetworkToCyclicTag`",
			"CyclicTagViaObliviousRingMachineHelper`", "CyclicTagCompilerViaObliviousRingMachine`"}],
	{},
	TestID -> "Loading-NoLegacyContexts"
]

VerificationTest[
	Select[$cyclicTagCompilerSymbols, Context[#] =!= "EricJamesParfitt`CyclicTagCompiler`" &],
	{},
	TestID -> "Loading-SymbolsResolve"
]
