(* ::Package:: *)

(* ::Title:: *)
(*Automata network to oblivious ring machine*)


(* ::Text:: *)
(*An automata network is a list of automata {rules, inputs, label}. Each step, every automaton applies its rules to the*)
(*states of the automata listed in inputs, all at the same time. On the ring machine tape each automaton has a block*)
(*of cells: one for each of its inputs, plus extra cells if more automata read its state than it has inputs.*)
(*One network step is one pass through three phases:*)
(*  grow:  fill the extra cells of each block with copies of the automaton's state,*)
(*  sort:  bubble-sort the cells so that each automaton's input cells hold the states of its inputs,*)
(*  apply: apply each automaton's rules to its input cells, writing its new state into all of them.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* ::Section:: *)
(*Ring machine function steps*)


anSkipTransformation[states_Integer] := {Identity, states, 1}


swap[states_Integer] := {Reverse, states, 2}


copy[states_Integer] := {Table[First[#], 2] &, states, 2}


(* ::Section:: *)
(*Grow*)


(* The blocks up to and including the last one with extra cells. *)
growingOnes[gates_List] :=
	Replace[
		gatesToInMultipleOut[gates],
		{Longest[x___], y_ /; MemberQ[y, {_}], z___} :> {x, y}]


growPart[states_Integer][{ins_Integer, outs_Integer}] :=
	Join[
		Table[anSkipTransformation[states], ins - 1],
		Table[copy[states], outs - ins],
		{anSkipTransformation[states]}]


(* The position the grow phase stops at, and its steps, without trailing skips. *)
growTransformations[gates_List, states_Integer] :=
	Comap[{Length, Identity},
		Replace[
			Catenate[
				growPart[states]@*
						Comap[{Count[{_, _}], Length}] /@
					growingOnes[gates]],
			{most___, anSkipTransformation[states] ...} :> {most}]]


(* ::Section:: *)
(*Sort*)


(* One step of a bubble sort that records the ring machine step it takes. *)
bubbleSortRecordedStep[states_Integer][{{xs___}, {y_, z_, w___}}] :=
	(Sow[swap[states]]; {{xs, z}, {y, w}}) /; z < y


bubbleSortRecordedStep[states_Integer][{{xs___}, {y_, z___}}] :=
	(Sow[anSkipTransformation[states]]; {{xs, y}, {z}})


bubbleSortRecordedStep[states_Integer][{xs_List, {}}] :=
	{{}, xs}


(* Give the "extraOut" cells the positions of the extra cells, in order. *)
extraOutsToNewIndices[inMultipleOuts : {___List}] :=
	ResourceFunction["ReplaceByOccurrence"][
		inMultipleOuts,
		{"extraOut", _} -> First /@ Position[inMultipleOuts, {_}, 1, Heads -> False]]


(* Give the k-th copy of each automaton's state the position of the k-th cell that reads it. *)
normalOutsToNewindices[inMultipleOuts : {___List}] :=
	ResourceFunction["ReplaceByOccurrence"][
		inMultipleOuts,
		{#, ___} -> First /@ Position[inMultipleOuts, {_, #}] & /@
			DeleteDuplicates@Cases[Catenate[inMultipleOuts], Except["extraOut"]]]


(* The sort key of each cell: the position its copy of a state has to move to. *)
gatesToSwapIndices[gates_List] :=
	FirstCase[_Integer] /@
		Transpose[
			Comap[
				{normalOutsToNewindices, extraOutsToNewIndices},
				Catenate@gatesToInMultipleOut[gates]]]


gatesToORMLength[gates_List] :=
	Length@Catenate@gatesToInMultipleOut[gates]


(* Skips that bring the ring machine back to the start of the tape. *)
resync[gates_List, states_Integer, initPos_Integer] :=
	Table[anSkipTransformation[states], gatesToORMLength[gates] - initPos]


swapTransformations[gates_List, states_Integer, startIndex_Integer] :=
	Replace[
		Reap[
			NestWhile[
				bubbleSortRecordedStep[states],
				TakeDrop[gatesToSwapIndices[gates], startIndex],
				Not@*OrderedQ@*Catenate]],
		{newState_, hist_} :>
			Join[
				Replace[hist, x : Except[{}] :> First[x]],
				resync[gates, states, Length@First[newState]]]]


(* ::Section:: *)
(*Apply*)


(* Each automaton's rules, writing the new state into every one of its input cells,
   followed by skips over the extra cells of its block. *)
toTransformation[states_Integer][{gates_, in_List, _}, inMultipleOut : {___List}] :=
	Prepend[
		{
			Replace[ruleType_[lhs_, rhs_] :> With[{n = Length[lhs]}, ruleType[lhs, Table[rhs, n]]]] /@ gates,
			Length@First@Keys[gates]
		}][
		Table[anSkipTransformation[states], Count[inMultipleOut, {_}]]]


gateTransformations[gates_List, states_Integer] :=
	Catenate@
		MapThread[
			toTransformation[states],
			{gates, gatesToInMultipleOut[gates]}]


(* ::Section:: *)
(*Public functions*)


AutomataNetworkToObliviousRingMachineRule[gates_List, initStates_Integer : 2] :=
	Module[{growI, growHist, states},
		states = gatesToStates[gates, initStates];
		{growI, growHist} = growTransformations[gates, states];
		Join[
			growHist,
			swapTransformations[gates, states, growI],
			gateTransformations[gates, states]]]


toInitPart[s_, inMultipleOut_List] :=
	Table[s, Length[inMultipleOut]]


AutomataNetworkToObliviousRingMachineInit[init : {___Integer}, gates_List] :=
	Catenate@MapThread[toInitPart, {init, gatesToInMultipleOut[gates]}]


(* One network step is one pass through the whole ring machine rule. *)
AutomataNetworkToObliviousRingMachineSteps[
		t_Integer?NonNegative,
		gates_List,
		states_Integer : 2] :=
	t Length@AutomataNetworkToObliviousRingMachineRule[gates, states]


(* Keep the tape after each full pass, and the first cell of each automaton's block. *)
DecodeObliviousRingMachineToAutomataNetwork[
		history_?ArrayQ,
		gates_List,
		states_Integer : 2] :=
	history[[;; ;; Length[AutomataNetworkToObliviousRingMachineRule[gates, states]]]][[
		All,
		Most@Accumulate[Prepend[1]@Map[Length, gatesToInMultipleOut[gates]]]]]


End[];


EndPackage[];
