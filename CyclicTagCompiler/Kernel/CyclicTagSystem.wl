(* ::Package:: *)

(* ::Title:: *)
(*Cyclic tag systems*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* One step on a tape, given the block in use: delete the first cell of the tape, and append the block if that cell was 1.
   An empty tape stays empty. Only the tapes are kept, since keeping the rotated rule list at each step takes memory
   proportional to the number of blocks times the number of steps. *)
cTStep[{0, a___}, _List] := {a}

cTStep[{1, a___}, {rs___}] := {a, rs}

cTStep[{}, _] = {};


CyclicTagSystem[rule : {___List}, init_List, t_Integer?NonNegative, property : "States" | "Rules" : "States"] :=
	If[property === "States",
		FoldList[cTStep, init, Array[Cyclic[rule], t]],
		If[rule === {},
			Table[{}, t + 1],
			Array[Cyclic[rule], t + 1]]]


CyclicTagSystem[rule : {___List}, init_List, t_Integer?NonNegative, properties : {___String}] :=
	Transpose[CyclicTagSystem[rule, init, t, #] & /@ properties]


End[];


EndPackage[];
