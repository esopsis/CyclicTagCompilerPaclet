(* ::Package:: *)

(* ::Title:: *)
(*n-ary cyclic tag to cyclic tag*)


(* ::Text:: *)
(*Each n-ary symbol s becomes a block of states bits that is all 0 except for a 1 at position s + 1.*)
(*Each n-ary rule becomes states cyclic tag appendants, one per symbol, so one n-ary step takes states cyclic tag steps.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


Options[NaryCyclicTagToCyclicTagRule] = {"TargetSystem" -> Automatic};


NaryCyclicTagToCyclicTagRule[rule : {___?nctRulePartQ}, tapeStates_Integer : 2, OptionsPattern[]] :=
	With[{states =
			targetSystemStates[
				Max[{rule + 1, Max[Length /@ rule, tapeStates]}],
				OptionValue["TargetSystem"]]},
		Catenate@
			ParallelMap[
				Catenate[# /. n_Integer :> UnitVector[states, n + 1]] &,
				PadRight[#, states, {{}}] & /@ rule,
				{2}]]


Options[NaryCyclicTagToCyclicTagInit] = Options[NaryCyclicTagToCyclicTagRule];


NaryCyclicTagToCyclicTagInit[init : {___Integer?NonNegative}, states_Integer : 2, OptionsPattern[]] :=
	Catenate[
		UnitVector[
			targetSystemStates[Max[init + 1, states], OptionValue["TargetSystem"]],
			# + 1] & /@ init]


Options[NaryCyclicTagToCyclicTagSteps] = Options[NaryCyclicTagToCyclicTagRule];


NaryCyclicTagToCyclicTagSteps[steps_Integer?NonNegative, states_Integer?Positive, OptionsPattern[]] :=
	steps targetSystemStates[states, OptionValue["TargetSystem"]]


Options[DecodeCyclicTagToNaryCyclicTag] = Options[NaryCyclicTagToCyclicTagRule];


DecodeCyclicTagToNaryCyclicTag[history : {___List}, states_Integer : 2, OptionsPattern[]] :=
	With[{blockSize = targetSystemStates[states, OptionValue["TargetSystem"]]},
		First@*FirstPosition[1] /@ Partition[#, blockSize] - 1 & /@
			history[[;; All ;; blockSize]]]


End[];


EndPackage[];
