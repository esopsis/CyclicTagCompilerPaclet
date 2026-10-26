(* ::Package:: *)

(* ::Title:: *)
(*Oblivious ring machine rules and their compilation to n-ary cyclic tag*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


Begin["`Private`"];


(* ::Section:: *)
(*Rule forms*)


(* ::Text:: *)
(*These predicates accept the same rule forms as ResourceFunction["ObliviousRingMachine"]:*)
(*a step is lhs :> rhs, a list of rules, a function step {f, {}, n}, or any of these with an offset {step, k}.*)
(*A list whose elements are all steps is a sequence of steps; a flat list of rules is a single step.*)


ruleQ[{(_Rule | _RuleDelayed) ...}] = True;

ruleQ[_] = False;


functionQ[{_, {} | _Integer, _Integer}] = True;

functionQ[_] = False;


singleRulePartQ[(Rule | RuleDelayed)[_List, Except[_Condition]] | _?functionQ] = True;

singleRulePartQ[_] = False;


singleRuleQ[_?singleRulePartQ | {_?singleRulePartQ, _Integer}] = True;

singleRuleQ[_] = False;


replacementsPartQ[{(Rule | RuleDelayed)[_List, Except[_Condition]] ...} | _?functionQ] = True;

replacementsPartQ[_] = False;


replacementsQ[expr_] :=
	replacementsPartQ[expr] ||
	MatchQ[expr, {_?replacementsPartQ | _?singleRulePartQ, _Integer}]


ormRuleQ[rule_] :=
	MatchQ[rule, {___?replacementsQ}] || singleRuleQ[rule] || replacementsQ[rule]


(* ::Section:: *)
(*Normalization*)


(* ::Text:: *)
(*A function step {f, {}, n} becomes a single rule that applies f to the first n symbols.*)
(*The pattern variables are created by Module, so they live in this private context rather than the user's context.*)


functionToReplacement[l_List] := l

functionToReplacement[{f_, {} | _Integer, d_Integer}] :=
	With[{vars = Table[Module[{v}, v], d]},
		{Pattern[#, _] & /@ vars :> f[vars]}]

functionToReplacement[r : _Rule | _RuleDelayed] := {r}


ormRuleNormalizePart[rule_List] :=
	Replace[
		Replace[rule, {x : Except[{_, _Integer}] :> {x, 1}}],
		{rulePart_, offset_} :> {functionToReplacement[rulePart], offset}]


(* Every accepted rule form becomes a list of steps {rules, offset}. *)
ormRuleNormalize[rule_] :=
	ormRuleNormalizePart /@
		Replace[rule,
			{
				r : {___List} :> r,
				r_List :> {r},
				r_ :> {{r}}
			}]


ObliviousRingMachineToNaryCyclicTagRule::nni = "Negative offsets not currently implemented";


(* ::Section:: *)
(*Compilation to n-ary cyclic tag*)


(* ::Text:: *)
(*The n-ary cyclic tag system uses the ring machine's symbols 0, ..., states - 1, plus two marker symbols: states and states + 1.*)
(*Each ring machine step reads replacementSize symbols, turns them into a delay (a sum of digit weights) made of marker symbols,*)
(*skips around the tape, uses the delay to select the appendant for the right replacement, and skips to the next step's position.*)


(* A step with no rules still reads (and rewrites unchanged) one symbol, then rotates. *)
stepReplacementSize[{}] = 1;

stepReplacementSize[rule_List] := Length[First[Keys[rule]]]


ormSkipSelector[states_Integer] :=
	List /@ Range[0, states - 1]


ormSkips[states_Integer, replacementSize_Integer, tapeLength_Integer, extraSkips_Integer] :=
	Table[
		Append[ormSkipSelector[states], {}],
		tapeLength - replacementSize + extraSkips]


selectors[rule_?ruleQ, states_Integer] :=
	With[{orderedRule =
			Replace[rule] /@
				Reverse /@
					Tuples[Range[0, states - 1], stepReplacementSize[rule]]},
		MapIndexed[
			Append[
				ormSkipSelector[states],
				Join[
					Table[states + 1, Length[orderedRule] - First[#2]],
					#1]] &,
			orderedRule]]


digitWeights[states_Integer, replacementSize_Integer] :=
	Table[v * states^i,
		{i, 0, replacementSize - 1},
		{v, states}]


numberedPads[states_Integer, replacementSize_Integer] :=
	Append[{}] /@ digitWeights[states, replacementSize] /.
		n_Integer :> Append[Table[states + 1, n - 1], states]


ormToNCTStepI[{rule_List, offset_Integer}, tapeLength_Integer, states_Integer] :=
	With[{replacementSize = stepReplacementSize[rule]},
		Append[{}] /@
			Join[
				numberedPads[states, replacementSize],
				ormSkips[states, replacementSize, tapeLength,
					Total[Min /@ digitWeights[states, replacementSize]] - 1],
				selectors[rule, states],
				ormSkips[states, replacementSize, tapeLength, offset]]] /;
	If[Negative[offset], Message[ObliviousRingMachineToNaryCyclicTagRule::nni]; False, True]


(* The number of tape symbols: one more than the largest symbol the rules mention explicitly, and at least tapeStates.
   A right-hand side counts only if it is an integer or a list of integers, since in a right-hand side such as
   Mod[x + 1, 3] the integers are not symbols. *)
maxStates[rules_List, tapeStates_Integer] :=
	Max[
		Cases[
			rules /.
				(h : Rule | RuleDelayed)[lhs_, rhs_] /; ! MatchQ[Unevaluated[rhs], _Integer | {___Integer}] :>
					h[lhs, {}],
			_Integer,
			Infinity] + 1,
		tapeStates]


ormToNCTStep[tapeLength_Integer, states_Integer][{rule_?ruleQ /; AllSameBy[Keys[rule], Length], offset_Integer}] :=
	ormToNCTStepI[{rule, offset}, tapeLength, maxStates[First /@ rule, states]]


ObliviousRingMachineToNaryCyclicTagRule[rule_?ormRuleQ, tapeLength_Integer, tapeStates_Integer : 2] :=
	With[{modified = ormRuleNormalize[rule]},
		Catenate[
			ormToNCTStep[tapeLength, maxStates[First /@ modified, tapeStates]] /@ modified]]


End[];


EndPackage[];
