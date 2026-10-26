(* ::Package:: *)

(* ::Title:: *)
(*Oblivious ring machine to n-ary cyclic tag*)


(* ::Text:: *)
(*ObliviousRingMachineToNaryCyclicTagRule itself is defined in ObliviousRingMachineRules.wl.*)
(*The n-ary cyclic tag tape is the ring machine tape itself, so no initial-condition conversion is needed.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* An empty rule never changes the tape, and each of its steps is one n-ary step. *)
ObliviousRingMachineToNaryCyclicTagSteps[steps_Integer?NonNegative, {}, tapeLength_Integer, tapeStates_Integer : 2] :=
	steps


ObliviousRingMachineToNaryCyclicTagSteps[
		steps_Integer?NonNegative,
		rule_?ormRuleQ,
		tapeLength_Integer,
		tapeStates_Integer : 2] :=
	Total@Array[Cyclic[ormToNCTLengths[rule, tapeLength, tapeStates]], steps]


DecodeNaryCyclicTagToObliviousRingMachine[history_List, {}, tapeStates_Integer : 2] :=
	history


(* The n-ary tape has the same length as the ring machine tape, so the tape length is read from the history. *)
DecodeNaryCyclicTagToObliviousRingMachine[
		history_List,
		rule_?ormRuleQ,
		tapeStates_Integer : 2] :=
	First /@
		ResourceFunction["CyclicPartition"][
			history,
			ormToNCTLengths[rule, Length[First[history]], tapeStates],
			"Remainder" -> True]


End[];


EndPackage[];
