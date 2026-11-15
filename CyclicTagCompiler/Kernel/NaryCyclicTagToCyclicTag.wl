(* ::Package:: *)

(* ::Title:: *)
(*n-ary cyclic tag to cyclic tag*)


(* ::Text:: *)
(*Each n-ary symbol s becomes a block of states bits that is all 0 except for a 1 at position s + 1.*)
(*Each n-ary rule becomes states cyclic tag appendants, one per symbol, so one n-ary step takes states cyclic tag steps.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


deleteds[rule : {___?nctRulePartQ}]:=
	First /@ 
			Position[Transpose[rule], {{}...}, 1] - 
		1


targetSystemStates[states_Integer, targetSystem_] :=
	Switch[targetSystem,
		"Rule110", Ceiling[states, 6],
		Automatic, states]


Options[replacement]={"TargetSystem" -> Automatic};


replacement[states_Integer, rule : {___?nctRulePartQ},opts:OptionsPattern][state_Integer] := 
	state -> Replace[
		Position[
				Complement[
					Range[0, states - 1], 
					deleteds[rule]],
				state],
		{
			{}->Table[0, targetSystemStates[states,OptionsValue["TargetSystem"]]],
			{{x_}}:>
				UnitVector[targetSystemStates[states,OptionsValue["TargetSystem"]], x]}]


replacedStates[rule : {___?nctRulePartQ}]:=
	Max[Length /@ rule] - Length@deleteds[rule]


Options[replacements]=Options[replacement]


replacements[states:{___Integer}, rule : {___?nctRulePartQ},opts:OptionsPattern[]] :=
	replacement[states,rule,opts] /@ Range[0, Length /@ rule - 1]


Options[NaryCyclicTagToCyclicTagRule] = Options[replacements];


NaryCyclicTagToCyclicTagRule[rule : {___?nctRulePartQ}, tapeStates_Integer : 2, opts:OptionsPattern[]] :=
	With[
		{myReplacedStates=replacedStates[rule,opts]},
		{myReplacements = replacements[myReplacedStates,rule,opts]},
		Catenate@
			ParallelMap[
				Catenate[# /. myReplacements] &,
				PadRight[#, myReplacedStates, {{}}] & /@ rule,
				{2}]]


Options[NaryCyclicTagToCyclicTagInit] = Options[NaryCyclicTagToCyclicTagRule];


NaryCyclicTagToCyclicTagInit[init : {___Integer?NonNegative}, nCTRule : {___?nctRulePartQ}, opts : OptionsPattern[]] :=
	Catenate[
		UnitVector[
			targetSystemStates[Max[init + 1, replacedStates[nCTRule,opts]], OptionValue["TargetSystem"]],
			# + 1] & /@ init]


Options[NaryCyclicTagToCyclicTagSteps] = Options[NaryCyclicTagToCyclicTagRule];


NaryCyclicTagToCyclicTagSteps[steps_Integer?NonNegative, nCTRule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	steps targetSystemStates[replacedStates[nCTRule,opts], OptionValue["TargetSystem"]]


Options[DecodeCyclicTagToNaryCyclicTag] = Options[NaryCyclicTagToCyclicTagRule];


DecodeCyclicTagToNaryCyclicTag[history : {___List}, nCTRule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	With[{blockSize = targetSystemStates[replacedStates[nCTRule,opts], OptionValue["TargetSystem"]]},
		First@*FirstPosition[1] /@ Partition[#, blockSize] - 1 & /@
			history[[;; All ;; blockSize]]]


decodeTape[blockSize_Integer][tape_List]:=
	First@FirstPosition[#,1,{blockSize}]& /@ 
				Partition[tape, blockSize] - 1


DecodeCyclicTagToNaryCyclicTag[history : {___List}, nCTRule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	With[{blockSize = targetSystemStates[replacedStates[nCTRule,opts], OptionValue["TargetSystem"]]},
		 decodeTape[blockSize]/@history[[;; All ;; blockSize]]]


End[];


EndPackage[];
