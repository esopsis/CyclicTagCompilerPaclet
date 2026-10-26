(* ::Package:: *)

(* ::Title:: *)
(*Resource functions used by CyclicTagCompiler*)


(* ::Text:: *)
(*Resource functions are looked up when they are first used, not when the paclet loads, so loading never needs a network connection.*)
(*Each function is looked up by name in the Wolfram Function Repository. Functions that have not been published yet fall back to the author's deployed copies.*)
(*Each function is looked up only once per session.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


$deployedResourceFunctionBase = "https://www.wolframcloud.com/obj/ericp/DeployedResources/Function/";


(* These deployed copies are newer than the published versions, so they are tried first:
   the published CellularAutomatonFromNumber (version 1.0.0) does not handle half-integer ranges,
   and the published CyclicTagSystemEvolveList (version 1.1.0) does not have the "IncludeRules" option. *)
$deployedFirst = {"CellularAutomatonFromNumber", "CyclicTagSystemEvolveList"};


$resourceFunctionCache = <||>;


resourceFunctionQ[rf_] := MatchQ[rf, _ResourceFunction]


publishedResourceFunction[name_String] := Quiet[ResourceFunction[name]]


deployedResourceFunction[name_String] :=
	Quiet[ResourceFunction[CloudObject[$deployedResourceFunctionBase <> name]]]


(* The look-ups are tried in order, and only until one of them works. *)
lookUpResourceFunction[name_String] :=
	Replace[
		FirstCase[
			If[MemberQ[$deployedFirst, name],
				{deployedResourceFunction, publishedResourceFunction},
				{publishedResourceFunction, deployedResourceFunction}],
			lookUp_ :> With[{rf = lookUp[name]}, rf /; resourceFunctionQ[rf]]],
		_Missing ->
			Failure["ResourceFunctionUnavailable",
				<|
					"MessageTemplate" -> "The resource function `1` could not be loaded.",
					"MessageParameters" -> {name}
				|>]]


resourceFunction[name_String] :=
	Lookup[
		$resourceFunctionCache,
		name,
		With[{rf = lookUpResourceFunction[name]},
			If[resourceFunctionQ[rf], $resourceFunctionCache[name] = rf];
			rf]]


End[];


EndPackage[];
