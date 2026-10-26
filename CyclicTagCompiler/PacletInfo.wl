(* ::Package:: *)

PacletObject[
	<|
		"Name" -> "EricJamesParfitt/CyclicTagCompiler",
		"Description" -> "Compile n-ary cyclic tag systems, oblivious ring machines, cellular automata and automata networks to cyclic tag systems",
		"Creator" -> "Eric James Parfitt, Seth Marshall",
		"License" -> "MIT",
		"PublisherID" -> "EricJamesParfitt",
		"Version" -> "1.0.0",
		"WolframVersion" -> "15.0+",
		"PrimaryContext" -> "EricJamesParfitt`CyclicTagCompiler`",
		"Keywords" -> {
			"cyclic tag system",
			"n-ary cyclic tag system",
			"oblivious ring machine",
			"cellular automaton",
			"automata network",
			"Boolean network",
			"universality",
			"Turing completeness",
			"rule 110",
			"compiler"
		},
		"Loading" -> Manual,
		"Extensions" -> {
			{
				"Kernel",
				"Root" -> "Kernel",
				"Context" -> {"EricJamesParfitt`CyclicTagCompiler`"},
				"Symbols" -> {
					"EricJamesParfitt`CyclicTagCompiler`CyclicTagSystem",
					"EricJamesParfitt`CyclicTagCompiler`NaryCyclicTag",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachine",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkRun",
					"EricJamesParfitt`CyclicTagCompiler`NaryCyclicTagToCyclicTagRule",
					"EricJamesParfitt`CyclicTagCompiler`NaryCyclicTagToCyclicTagInit",
					"EricJamesParfitt`CyclicTagCompiler`NaryCyclicTagToCyclicTagSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeCyclicTagToNaryCyclicTag",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToNaryCyclicTagRule",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToNaryCyclicTagSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeNaryCyclicTagToObliviousRingMachine",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToCyclicTagRule",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToCyclicTagInit",
					"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToCyclicTagSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeCyclicTagToObliviousRingMachine",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToObliviousRingMachineRule",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToObliviousRingMachineInit",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToObliviousRingMachineSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeObliviousRingMachineToCellularAutomaton",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToCyclicTagRule",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToCyclicTagInit",
					"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToCyclicTagSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeCyclicTagToCellularAutomaton",
					"EricJamesParfitt`CyclicTagCompiler`CompiledCellularAutomatonToCyclicTag",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToObliviousRingMachineRule",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToObliviousRingMachineInit",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToObliviousRingMachineSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeObliviousRingMachineToAutomataNetwork",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToCyclicTagRule",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToCyclicTagInit",
					"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToCyclicTagSteps",
					"EricJamesParfitt`CyclicTagCompiler`DecodeCyclicTagToAutomataNetwork",
					"EricJamesParfitt`CyclicTagCompiler`CompiledAutomataNetworkToCyclicTag"
				}
			},
			{
				"Documentation",
				"Root" -> "Documentation",
				"Language" -> "English"
			},
			{
				"Test",
				"Root" -> "Tests",
				"Method" -> "Experimental-v1"
			},
			{
				"Asset",
				"Assets" -> {{"License", "./LICENSE"}}
			}
		}
	|>
]
