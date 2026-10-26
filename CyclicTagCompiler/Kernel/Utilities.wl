(* ::Package:: *)

(* ::Title:: *)
(*Shared helpers*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* ::Section:: *)
(*The "TargetSystem" option*)


(* ::Text:: *)
(*"TargetSystem" -> "Rule110" pads the number of cyclic tag symbols up to a multiple of 6,*)
(*which is what the cyclic tag systems emulated in Matthew Cook's rule 110 construction need.*)


targetSystemStates[states_Integer, targetSystem_] :=
	Switch[targetSystem,
		"Rule110" | "rule110", Ceiling[states, 6],
		Automatic, states]


(* The "Mod6CyclicTag" option of the compiled functions chooses the "TargetSystem" of the compilers. *)
compiledTargetSystem[mod6_] := If[TrueQ[mod6], "Rule110", Automatic]


(* ::Section:: *)
(*n-ary cyclic tag rules*)


nctRulePartQ[{{___Integer?NonNegative} ...}] = True;

nctRulePartQ[_] = False;


(* ::Section:: *)
(*Oblivious ring machine step lengths*)


(* The number of n-ary cyclic tag steps that emulate each step of an oblivious ring machine rule. *)
ormToNCTLengths[rule_, tapeLength_Integer, tapeStates_Integer] :=
	With[{modified = ormRuleNormalize[rule]},
		With[{states = maxStates[First /@ modified, tapeStates]},
			Length[ObliviousRingMachineToNaryCyclicTagRule[{#}, tapeLength, states]] & /@ modified]]


(* ::Section:: *)
(*Cellular automata*)


cellularAutomatonDiameter[r : _Integer | _Rational] := 2 r + 1


cellularAutomatonRuleExpand[{n_Integer?NonNegative, k_Integer : 2, r : _Rational | _Integer : 1}] :=
	resourceFunction["CellularAutomatonFromNumber"][n, k, r]

cellularAutomatonRuleExpand[n_Integer] := cellularAutomatonRuleExpand[{n}]

cellularAutomatonRuleExpand[rule : {(_Rule | _RuleDelayed) ...}] := rule


ruleToRadius[rule_List] := (Length[First[Keys[rule]]] - 1) / 2


(* With "InfiniteSteps" -> True the ring machine tape carries diameter - 1 extra cells. *)
infiniteStepsChecker[infiniteStepsQ : True | False, tapeLength_Integer, radius : _Rational | _Integer] :=
	If[infiniteStepsQ, tapeLength + cellularAutomatonDiameter[radius] - 1, tapeLength]


(* ::Section:: *)
(*Automata networks*)


(* The number of states: one more than the largest state the automata's rules mention explicitly, and at least states. *)
gatesToStates[gates_List, states_Integer] :=
	maxStates[First /@ gates, states]


(* For each automaton, a list of tape cells. Cell j holds output copy j of the automaton (or "extraOut" when no
   automaton needs that copy) together with input j, if the automaton has that many inputs. *)
gatesToInMultipleOutPart[gates_List][{_, in_List, out_}] :=
	ResourceFunction["RaggedTranspose"][
		{
			ResourceFunction["PadRightToMinLength"][
				Table[out, Count[#[[2]] & /@ gates, out, {2}]],
				Length[in],
				"extraOut"],
			in
		}]


gatesToInMultipleOut[gates_List] :=
	gatesToInMultipleOutPart[gates] /@ gates


End[];


EndPackage[];
