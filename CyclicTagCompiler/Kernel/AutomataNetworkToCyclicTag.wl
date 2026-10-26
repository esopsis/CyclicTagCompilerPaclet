(* ::Package:: *)

(* ::Title:: *)
(*Automata network to cyclic tag*)


(* ::Text:: *)
(*These chain the automata network to oblivious ring machine and oblivious ring machine to cyclic tag compilations.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


Options[AutomataNetworkToCyclicTagRule] = Options[ObliviousRingMachineToCyclicTagRule];


AutomataNetworkToCyclicTagRule[
		gates_List,
		states_Integer : 2,
		opts : OptionsPattern[]] :=
	ObliviousRingMachineToCyclicTagRule[
		AutomataNetworkToObliviousRingMachineRule[gates, states],
		gatesToORMLength[gates],
		gatesToStates[gates, states],
		opts]


Options[AutomataNetworkToCyclicTagInit] = Options[ObliviousRingMachineToCyclicTagInit];


AutomataNetworkToCyclicTagInit[
		init : {___Integer},
		gates_List,
		states_Integer : 2,
		opts : OptionsPattern[]] :=
	ObliviousRingMachineToCyclicTagInit[
		AutomataNetworkToObliviousRingMachineInit[init, gates],
		AutomataNetworkToObliviousRingMachineRule[gates, states],
		gatesToStates[gates, states],
		opts]


Options[AutomataNetworkToCyclicTagSteps] = Options[ObliviousRingMachineToCyclicTagSteps];


AutomataNetworkToCyclicTagSteps[
		t_Integer?NonNegative,
		gates_List,
		states_Integer : 2,
		opts : OptionsPattern[]] :=
	ObliviousRingMachineToCyclicTagSteps[
		AutomataNetworkToObliviousRingMachineSteps[t, gates, states],
		AutomataNetworkToObliviousRingMachineRule[gates, states],
		gatesToORMLength[gates],
		gatesToStates[gates, states],
		opts]


Options[DecodeCyclicTagToAutomataNetwork] = Options[DecodeCyclicTagToObliviousRingMachine];


DecodeCyclicTagToAutomataNetwork[
		history : {___List},
		gates_List,
		states_Integer : 2,
		opts : OptionsPattern[]] :=
	DecodeObliviousRingMachineToAutomataNetwork[
		DecodeCyclicTagToObliviousRingMachine[
			history,
			AutomataNetworkToObliviousRingMachineRule[gates, states],
			gatesToORMLength[gates],
			gatesToStates[gates, states],
			opts],
		gates,
		states]


Options[CompiledAutomataNetworkToCyclicTag] = {"Mod6CyclicTag" -> False};


(* The cyclic tag rule is compiled once; the function returned compiles each initial condition and step count,
   runs the cyclic tag system and decodes the result. *)
CompiledAutomataNetworkToCyclicTag[
		gates_List,
		states_Integer : 2,
		OptionsPattern[]] :=
	With[{compilerOptions = {"TargetSystem" -> compiledTargetSystem[OptionValue["Mod6CyclicTag"]]}},
		With[{ctRule = AutomataNetworkToCyclicTagRule[gates, states, compilerOptions]},
			Function[{init, t},
				DecodeCyclicTagToAutomataNetwork[
					resourceFunction["CyclicTagSystemEvolveList"][
						ctRule,
						AutomataNetworkToCyclicTagInit[init, gates, states, compilerOptions],
						AutomataNetworkToCyclicTagSteps[t, gates, states, compilerOptions]],
					gates,
					states,
					compilerOptions]]]]


End[];


EndPackage[];
