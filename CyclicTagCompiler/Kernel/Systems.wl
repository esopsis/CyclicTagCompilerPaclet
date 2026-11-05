(* ::Package:: *)

(* ::Title:: *)
(*The systems the paclet compiles between*)


(* ::Text:: *)
(*These are Wolfram Function Repository functions, each looked up the first time it is used,*)
(*so loading the paclet needs no network connection. CyclicTagSystem is defined in CyclicTagSystem.wl.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


NaryCyclicTag := resourceFunction["NaryCyclicTag"]


ObliviousRingMachine := resourceFunction["ObliviousRingMachine"]


AutomataNetworkRun := ResourceFunction["AutomataNetworkRun"]


End[];


EndPackage[];
