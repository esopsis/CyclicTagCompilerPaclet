(* ::Package:: *)

(* ::Title:: *)
(*Oblivious ring machine to cyclic tag*)


(* ::Text:: *)
(*These chain the oblivious ring machine to n-ary cyclic tag and n-ary cyclic tag to cyclic tag compilations.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


Options[ObliviousRingMachineToCyclicTagRule] = Options[NaryCyclicTagToCyclicTagRule];


ObliviousRingMachineToCyclicTagRule[rule_?ormRuleQ, tapeLength_Integer, tapeStates_Integer : 2, opts : OptionsPattern[]] :=
	NaryCyclicTagToCyclicTagRule[#, opts] &@
		ObliviousRingMachineToNaryCyclicTagRule[rule, tapeLength, tapeStates]


Options[ObliviousRingMachineToCyclicTagInit] = Options[NaryCyclicTagToCyclicTagInit];


ObliviousRingMachineToCyclicTagInit[init_List, rule_?ormRuleQ, tapeStates_Integer : 2, opts : OptionsPattern[]] :=
	NaryCyclicTagToCyclicTagInit[
		init,
		ObliviousRingMachineToNaryCyclicTagRule[rule, Length[init], tapeStates],
		opts]


Options[ObliviousRingMachineToCyclicTagSteps] = Options[NaryCyclicTagToCyclicTagSteps];


ObliviousRingMachineToCyclicTagSteps[
		steps_Integer?NonNegative,
		rule_?ormRuleQ,
		tapeLength_Integer,
		tapeStates_Integer : 2,
		opts : OptionsPattern[]] :=
	NaryCyclicTagToCyclicTagSteps[
		ObliviousRingMachineToNaryCyclicTagSteps[steps, rule, tapeLength, tapeStates],
		ObliviousRingMachineToNaryCyclicTagRule[rule, tapeLength, tapeStates],
		opts]


Options[DecodeCyclicTagToObliviousRingMachine] = Options[DecodeCyclicTagToNaryCyclicTag];


DecodeCyclicTagToObliviousRingMachine[
		history : {___List},
		rule_?ormRuleQ,
		tapeLength_Integer,
		states_Integer : 2,
		opts : OptionsPattern[]] :=
	DecodeNaryCyclicTagToObliviousRingMachine[
		DecodeCyclicTagToNaryCyclicTag[
			history,
			ObliviousRingMachineToNaryCyclicTagRule[rule, tapeLength, states],
			opts],
		rule,
		states]


End[];


EndPackage[];
