(* ::Package:: *)

(* ::Title:: *)
(*Cellular automaton to oblivious ring machine*)


(* ::Text:: *)
(*The ring machine sweeps along the tape. At each step it reads a window of diameter 2 r + 1 cells,*)
(*writes the cellular automaton's new value into the first cell of the window, and moves one cell on.*)
(*So after one sweep the new row is shifted r cells to the left of the old one.*)
(**)
(*By default the tape has exactly tapeLength cells and wraps around, so the cells near the end*)
(*of the tape see already-updated neighbors and the reliable region shrinks by 2 r cells each step.*)
(*With "InfiniteSteps" -> True the tape gets 2 r extra cells in front. Before each sweep the ring machine*)
(*copies the first 2 r cells of the tape into them. The windows at the end of the sweep wrap around into*)
(*these copies and so see old values, which emulates the cyclic cellular automaton exactly.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* The rule step that writes the new value of a window into its first cell. *)
cAWindowRule[lhs : {_, rest___} -> rhs_] := lhs -> {rhs, rest}


(* The function step that copies the last cell of a window to its first. *)
cAWrapStep[states_Integer, diameter_Integer] :=
	{Replace[{_, x___, y_} :> {y, x, y}], states, diameter}


Options[CellularAutomatonToObliviousRingMachineRule] = {"InfiniteSteps" -> False};


CellularAutomatonToObliviousRingMachineRule[
		rule_,
		tapeLength : _Integer | None : None,
		tapeStates_Integer : 2,
		OptionsPattern[]] :=
	With[{expandedRule = cellularAutomatonRuleExpand[rule]},
		With[{
				windowRule = cAWindowRule /@ expandedRule,
				diameter = Length[First[Keys[expandedRule]]]},
			If[OptionValue["InfiniteSteps"],
				Join[
					Table[
						cAWrapStep[maxStates[expandedRule, tapeStates], diameter], 
						diameter - 1],
					Table[windowRule, tapeLength]],
				{windowRule}]]]


Options[CellularAutomatonToObliviousRingMachineInit] = Options[CellularAutomatonToObliviousRingMachineRule];


CellularAutomatonToObliviousRingMachineInit[
		init : {___Integer},
		r : _Rational | _Integer : 1,
		OptionsPattern[]] :=
	If[OptionValue["InfiniteSteps"],
		ArrayPad[init, {cellularAutomatonDiameter[r] - 1, 0}],
		init]


Options[CellularAutomatonToObliviousRingMachineSteps] = Options[CellularAutomatonToObliviousRingMachineRule];


(* One cellular automaton step is one sweep of the ring machine around its tape. *)
CellularAutomatonToObliviousRingMachineSteps[
		steps_Integer?NonNegative,
		tapeLength_Integer?NonNegative,
		r : _Rational | _Integer : 1,
		OptionsPattern[]] :=
	steps * infiniteStepsChecker[OptionValue["InfiniteSteps"], tapeLength, r]


Options[DecodeObliviousRingMachineToCellularAutomaton] = Options[CellularAutomatonToObliviousRingMachineRule];


(* With "InfiniteSteps" -> True, drop the extra cells and undo the shift of each sweep.
   Otherwise keep only the cells that never saw an updated neighbor: 2 r fewer each step,
   so there are rows only while some cells are left. *)
DecodeObliviousRingMachineToCellularAutomaton[
		history : {___List},
		r : _Rational | _Integer : 1,
		OptionsPattern[]] :=
	With[{
			diameter = cellularAutomatonDiameter[r],
			sweeps = history[[;; ;; Length[First[history]]]]},
		If[OptionValue["InfiniteSteps"],
			ResourceFunction["ArraySkew"][sweeps[[All, diameter ;;]], Ceiling[r]],
			MapIndexed[
				#1[[;; -((diameter - 1) (First[#2] - 1) + 1)]] &,
				sweeps[[1 ;; UpTo[Quotient[Length[First[history]] - 1, diameter - 1] + 1]]]]]]


End[];


EndPackage[];
