(* ::Package:: *)

(* ::Title:: *)
(*The systems the paclet compiles between*)


(* ::Text:: *)
(*CyclicTagSystem is defined here. The others are Wolfram Function Repository functions,*)
(*each looked up the first time it is used, so loading the paclet needs no network connection.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* One step on {rules, tape}: delete the first cell of the tape, append the first block if that cell was 1,
   and rotate the blocks. An empty tape stays empty. *)
cTStep[{{r_, s___}, {0, a___}}] := {{s, r}, {a}}

cTStep[{{r : {rs___}, s___}, {1, a___}}] := {{s, r}, {a, rs}}

cTStep[l : {_List, {}}] := l


CyclicTagSystem[rule : {___List}, init_List, t_Integer?NonNegative, property : "States" | "Rules" : "States"] :=
	If[property === "States",
		Last /@ NestList[cTStep, {rule, init}, t],
		If[rule === {},
			Table[{}, t + 1],
			Array[Cyclic[rule], t + 1]]]


CyclicTagSystem[rule : {___List}, init_List, t_Integer?NonNegative, properties : {___String}] :=
	Transpose[CyclicTagSystem[rule, init, t, #] & /@ properties]


NaryCyclicTag := resourceFunction["NaryCyclicTag"]


ObliviousRingMachine := resourceFunction["ObliviousRingMachine"]


AutomataNetworkRun := ResourceFunction["AutomataNetworkRun"]


End[];


EndPackage[];
