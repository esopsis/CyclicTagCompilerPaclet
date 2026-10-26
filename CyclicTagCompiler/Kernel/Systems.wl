(* ::Package:: *)

(* ::Title:: *)
(*The systems the paclet compiles between*)


(* ::Text:: *)
(*These are the Wolfram Function Repository functions that run each kind of system.*)
(*Each is looked up the first time it is used, so loading the paclet needs no network connection.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


CyclicTagSystem := resourceFunction["CyclicTagSystemEvolveList"]


NaryCyclicTag := resourceFunction["NaryCyclicTag"]


ObliviousRingMachine := resourceFunction["ObliviousRingMachine"]


AutomataNetworkRun := ResourceFunction["AutomataNetworkRun"]


End[];


EndPackage[];
