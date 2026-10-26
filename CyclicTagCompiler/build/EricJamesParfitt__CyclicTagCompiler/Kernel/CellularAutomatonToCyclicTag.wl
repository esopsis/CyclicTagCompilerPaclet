(* ::Package:: *)

(* ::Title:: *)
(*Cellular automaton to cyclic tag*)


(* ::Text:: *)
(*These chain the cellular automaton to oblivious ring machine and oblivious ring machine to cyclic tag compilations.*)
(*Init, Steps and Decode only need the number of colors k and the range r, not the rule itself:*)
(*the sizes of the compiled pieces are the same for every rule with the same k and r,*)
(*so they use the k-color, range-r rule 0 in place of the actual rule.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* The ring machine rule of any cellular automaton with k colors and range r, used for sizes only. *)
caRepresentativeORMRule[k_Integer, r_, tapeLength_Integer, opts___] :=
	CellularAutomatonToObliviousRingMachineRule[{0, k, r}, tapeLength, k,
		FilterRules[{opts}, Options[CellularAutomatonToObliviousRingMachineRule]]]


Options[CellularAutomatonToCyclicTagRule] =
	Join[
		Options[CellularAutomatonToObliviousRingMachineRule],
		Options[ObliviousRingMachineToCyclicTagRule]];


CellularAutomatonToCyclicTagRule[
		rule_,
		tapeLength_Integer,
		tapeStates_Integer : 2,
		opts : OptionsPattern[]] :=
	With[{expandedRule = cellularAutomatonRuleExpand[rule]},
		ObliviousRingMachineToCyclicTagRule[
			CellularAutomatonToObliviousRingMachineRule[expandedRule, tapeLength, tapeStates,
				FilterRules[{opts}, Options[CellularAutomatonToObliviousRingMachineRule]]],
			infiniteStepsChecker[OptionValue["InfiniteSteps"], tapeLength, ruleToRadius[expandedRule]],
			tapeStates,
			FilterRules[{opts}, Options[ObliviousRingMachineToCyclicTagRule]]]]


Options[CellularAutomatonToCyclicTagInit] = Options[CellularAutomatonToCyclicTagRule];


CellularAutomatonToCyclicTagInit[
		init : {___Integer},
		k_Integer : 2,
		r : _Rational | _Integer : 1,
		opts : OptionsPattern[]] :=
	ObliviousRingMachineToCyclicTagInit[
		CellularAutomatonToObliviousRingMachineInit[init, r,
			FilterRules[{opts}, Options[CellularAutomatonToObliviousRingMachineInit]]],
		caRepresentativeORMRule[Max[init+1,k], r, Length[init], opts],
		k,
		FilterRules[{opts}, Options[ObliviousRingMachineToCyclicTagInit]]]


Options[CellularAutomatonToCyclicTagSteps] = Options[CellularAutomatonToCyclicTagRule];


CellularAutomatonToCyclicTagSteps[
		steps_Integer?NonNegative,
		tapeLength_Integer,
		k_Integer : 2,
		r : _Rational | _Integer : 1,
		opts : OptionsPattern[]] :=
	ObliviousRingMachineToCyclicTagSteps[
		CellularAutomatonToObliviousRingMachineSteps[steps, tapeLength, r,
			FilterRules[{opts}, Options[CellularAutomatonToObliviousRingMachineSteps]]],
		caRepresentativeORMRule[k, r, tapeLength, opts],
		infiniteStepsChecker[OptionValue["InfiniteSteps"], tapeLength, r],
		k,
		FilterRules[{opts}, Options[ObliviousRingMachineToCyclicTagSteps]]]


Options[DecodeCyclicTagToCellularAutomaton] = Options[CellularAutomatonToCyclicTagRule];


DecodeCyclicTagToCellularAutomaton[
		history : {___List},
		tapeLength_Integer,
		k_Integer : 2,
		r : _Rational | _Integer : 1,
		opts : OptionsPattern[]] :=
	DecodeObliviousRingMachineToCellularAutomaton[
		DecodeCyclicTagToObliviousRingMachine[
			history,
			caRepresentativeORMRule[k, r, tapeLength, opts],
			infiniteStepsChecker[OptionValue["InfiniteSteps"], tapeLength, r],
			k,
			FilterRules[{opts}, Options[DecodeCyclicTagToObliviousRingMachine]]],
		r,
		FilterRules[{opts}, Options[DecodeObliviousRingMachineToCellularAutomaton]]]


Options[CompiledCellularAutomatonToCyclicTag] = {"InfiniteSteps" -> False, "Mod6CyclicTag" -> False};


(* The cyclic tag rule is compiled once; the function returned compiles each initial condition and step count,
   runs the cyclic tag system and decodes the result. *)
CompiledCellularAutomatonToCyclicTag[
		rule_,
		tapeLength_Integer,
		tapeStates_Integer : 2,
		OptionsPattern[]] :=
	With[{
			expandedRule = cellularAutomatonRuleExpand[rule],
			compilerOptions = {
				"InfiniteSteps" -> OptionValue["InfiniteSteps"],
				"TargetSystem" -> compiledTargetSystem[OptionValue["Mod6CyclicTag"]]}},
		With[{
				r = ruleToRadius[expandedRule],
				states = maxStates[expandedRule, tapeStates],
				ctRule = CellularAutomatonToCyclicTagRule[expandedRule, tapeLength, tapeStates, compilerOptions]},
			Function[{init, steps},
				DecodeCyclicTagToCellularAutomaton[
					resourceFunction["CyclicTagSystemEvolveList"][
						ctRule,
						CellularAutomatonToCyclicTagInit[init, states, r, compilerOptions],
						CellularAutomatonToCyclicTagSteps[steps, tapeLength, states, r, compilerOptions]],
					tapeLength,
					states,
					r,
					compilerOptions]]]]


End[];


EndPackage[];
