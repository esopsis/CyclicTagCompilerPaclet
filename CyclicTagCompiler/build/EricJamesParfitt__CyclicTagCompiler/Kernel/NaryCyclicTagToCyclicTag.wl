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


Options[replacement]={"TargetSystem" -> Automatic};


getStates[rule : {___?nctRulePartQ}] := Max[Length /@ rule, 0]


replacement[rule : {___?nctRulePartQ}, opts:OptionsPattern[]][state_Integer] := 
	state -> 
	Replace[
		Replace[
			Position[
					Complement[
						Range[0, getStates[rule] - 1], 
						deleteds[rule]],
					state],
			{
				{}->Table[0, 
					targetSystemStates[replacedStates[rule], OptionValue["TargetSystem"]]],
				{{x_}}:>
					UnitVector[
						targetSystemStates[replacedStates[rule], OptionValue["TargetSystem"]], 
						x]}],
		{} -> {0}]


Options[replacements]=Options[replacement];


replacements[rule : {___?nctRulePartQ},opts:OptionsPattern[]] :=
	replacement[rule,opts] /@ Range[0, getStates[rule] - 1]


replacedStates[rule : {___?nctRulePartQ}]:=
	getStates[rule] - Length@deleteds[rule]


(* ::Text:: *)
(*Note: Right now the decoder is coded to perform a certain optimization when there are NCT symbols that are always deleted. Upon decoding it ends up changing the numbers and the rules, but it still has the same general behavior. When compiling from oblivious ring machines it ends up working out the same, and so works as an optimization for compiling that system.*)
(*In the future there could be an un-optimized version that always round-trips correctly for any input but isn't as optimized for some uses, so I have set an "Optimization" -> "DeletedSymbolsHighest" for now.*)


Options[NaryCyclicTagToCyclicTagSteps] = 
	Append[Options[replacements], "Optimization" -> "DeletedSymbolsHighest"];


NaryCyclicTagToCyclicTagSteps[steps_Integer?NonNegative, nCTRule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	steps *
	targetSystemStates[
		Max[replacedStates[nCTRule], 1], 
		OptionValue["TargetSystem"]]


Options[NaryCyclicTagToCyclicTagRule] = Options[NaryCyclicTagToCyclicTagSteps];


myDeleteColumns[array_, cspec_] := DeleteColumns[array, cspec]


myDeleteColumns[{}, {}] = {};


NaryCyclicTagToCyclicTagRule[rule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	With[
			{myReplacedStates=replacedStates[rule]},
			{myReplacements = replacements[rule, FilterRules[{opts}, Options[replacements]]]},
			{states=targetSystemStates[myReplacedStates, OptionValue["TargetSystem"]]},
			Replace[Catenate@
				ParallelMap[
					Catenate[# /. myReplacements] &,
					PadRight[#, states, {{}}]& /@ myDeleteColumns[rule, deleteds[rule] + 1],
					{2}],
					{} -> {{}}]]/;
		OptionValue["Optimization"] ==="DeletedSymbolsHighest"


Options[NaryCyclicTagToCyclicTagInit] = Options[NaryCyclicTagToCyclicTagRule];


NaryCyclicTagToCyclicTagInit[init : {___Integer?NonNegative}, nCTRule : {___?nctRulePartQ}, opts : OptionsPattern[]] :=
	Catenate[
			init/.
				replacements[
					nCTRule,
					FilterRules[{opts}, Options[replacements]]]]/;
		OptionValue["Optimization"] === "DeletedSymbolsHighest"


decodeTape[states_Integer, blockSize_Integer][tape_List] :=
	First@FirstPosition[#, 1, {states + 1}]& /@ 
			Partition[tape, Max[blockSize, 1]] - 
		1


Options[DecodeCyclicTagToNaryCyclicTag] = Options[NaryCyclicTagToCyclicTagRule];


DecodeCyclicTagToNaryCyclicTag[history : {___List}, nCTRule : {___?nctRulePartQ}, opts:OptionsPattern[]] :=
	With[
			{myReplacedStates=replacedStates[nCTRule]},
			{blockSize = targetSystemStates[myReplacedStates, OptionValue["TargetSystem"]]},
			decodeTape[
				myReplacedStates,blockSize] /@ 
					history[[;; All ;; Max[blockSize, 1]]]]/;
	OptionValue["Optimization"] === "DeletedSymbolsHighest"


End[];


EndPackage[];
