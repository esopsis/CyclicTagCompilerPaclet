(* ::Package:: *)

(* ::Title:: *)
(*CyclicTagCompiler*)


(* ::Text:: *)
(*Compile n-ary cyclic tag systems, oblivious ring machines, finite cellular automata and automata networks to ordinary cyclic tag systems, and decode cyclic tag evolutions back.*)
(*The method was devised by Seth Marshall; this Wolfram Language implementation is by Eric James Parfitt.*)


BeginPackage["EricJamesParfitt`CyclicTagCompiler`"];


(* ::Section:: *)
(*The systems*)


CyclicTagSystem::usage =
"CyclicTagSystem[rules, init, t] returns the list of states attained from evolving init, using cyclic tag system rules over t steps.
CyclicTagSystem[rules, init] gives the result of evolving init for one step.
CyclicTagSystem[rules, init, t, dt] returns the states attained at every step dt.
CyclicTagSystem[rules, init, t, dt, prop] returns the specified prop of states attained at every step.
CyclicTagSystem[rules] is an operator form of CyclicTagSystem that represents one step of evolution.";

NaryCyclicTag::usage =
"NaryCyclicTag[{rule1, rule2, \[Ellipsis]}, init, t] gives a list of the tapes in t steps of the n-ary cyclic tag system that uses the rules rulei in turn, starting from the tape init.";

ObliviousRingMachine::usage =
"ObliviousRingMachine[{step1, step2, \[Ellipsis]}, init, t] gives a list of the results of t steps of an oblivious ring machine that starts from the list init and uses the step specifications stepi in turn.
ObliviousRingMachine[step, init, t] uses the single step specification step at every step.";

AutomataNetworkRun::usage =
"AutomataNetworkRun[{{rules1, inputs1, label1}, {rules2, inputs2, label2}, \[Ellipsis]}, init, t] gives the states at each of t steps of the automata network in which each automaton labeli updates its state by applying the rules rulesi to the states of the automata inputsi, starting from the states init.
AutomataNetworkRun[{{{rules1, s1}, inputs1, label1}, {{rules2, s2}, inputs2, label2}, \[Ellipsis]}, t] gives the complete network at each of t steps, where si is the current state of the automaton labeli.";


(* ::Section:: *)
(*n-ary cyclic tag to cyclic tag*)


NaryCyclicTagToCyclicTagRule::usage =
"NaryCyclicTagToCyclicTagRule[rule] converts the n-ary cyclic tag rule rule to a cyclic tag rule.
NaryCyclicTagToCyclicTagRule[rule, states] uses at least states tape symbols.";

NaryCyclicTagToCyclicTagInit::usage =
"NaryCyclicTagToCyclicTagInit[init, states] converts the n-ary cyclic tag tape init with states tape symbols to a cyclic tag tape.";

NaryCyclicTagToCyclicTagSteps::usage =
"NaryCyclicTagToCyclicTagSteps[steps, states] gives the number of cyclic tag steps that emulate steps steps of an n-ary cyclic tag system with states tape symbols.";

DecodeCyclicTagToNaryCyclicTag::usage =
"DecodeCyclicTagToNaryCyclicTag[history, states] decodes the cyclic tag evolution history to the evolution of the n-ary cyclic tag system with states tape symbols that it emulates.";


(* ::Section:: *)
(*Oblivious ring machine to n-ary cyclic tag*)


ObliviousRingMachineToNaryCyclicTagRule::usage =
"ObliviousRingMachineToNaryCyclicTagRule[rule, tapeLength] compiles the oblivious ring machine rule rule for a tape of length tapeLength to an n-ary cyclic tag rule.
ObliviousRingMachineToNaryCyclicTagRule[rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

ObliviousRingMachineToNaryCyclicTagSteps::usage =
"ObliviousRingMachineToNaryCyclicTagSteps[steps, rule, tapeLength] gives the number of n-ary cyclic tag steps that emulate steps steps of the oblivious ring machine rule on a tape of length tapeLength.
ObliviousRingMachineToNaryCyclicTagSteps[steps, rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

DecodeNaryCyclicTagToObliviousRingMachine::usage =
"DecodeNaryCyclicTagToObliviousRingMachine[history, rule] decodes the n-ary cyclic tag evolution history to the evolution of the oblivious ring machine rule that it emulates.
DecodeNaryCyclicTagToObliviousRingMachine[history, rule, tapeStates] uses at least tapeStates tape symbols.";


(* ::Section:: *)
(*Oblivious ring machine to cyclic tag*)


ObliviousRingMachineToCyclicTagRule::usage =
"ObliviousRingMachineToCyclicTagRule[rule, tapeLength] compiles the oblivious ring machine rule rule for a tape of length tapeLength to a cyclic tag rule.
ObliviousRingMachineToCyclicTagRule[rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

ObliviousRingMachineToCyclicTagInit::usage =
"ObliviousRingMachineToCyclicTagInit[init, rule] converts the oblivious ring machine tape init for the rule rule to a cyclic tag tape.
ObliviousRingMachineToCyclicTagInit[init, rule, tapeStates] uses at least tapeStates tape symbols.";

ObliviousRingMachineToCyclicTagSteps::usage =
"ObliviousRingMachineToCyclicTagSteps[steps, rule, tapeLength] gives the number of cyclic tag steps that emulate steps steps of the oblivious ring machine rule on a tape of length tapeLength.
ObliviousRingMachineToCyclicTagSteps[steps, rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

DecodeCyclicTagToObliviousRingMachine::usage =
"DecodeCyclicTagToObliviousRingMachine[history, rule, tapeLength] decodes the cyclic tag evolution history to the evolution of the oblivious ring machine rule on a tape of length tapeLength.
DecodeCyclicTagToObliviousRingMachine[history, rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";


(* ::Section:: *)
(*Cellular automaton to oblivious ring machine*)


CellularAutomatonToObliviousRingMachineRule::usage =
"CellularAutomatonToObliviousRingMachineRule[rule] gives an oblivious ring machine rule that emulates the cellular automaton rule on a finite region of its tape.
CellularAutomatonToObliviousRingMachineRule[rule, tapeLength] gives a rule for a tape of length tapeLength.
CellularAutomatonToObliviousRingMachineRule[rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

CellularAutomatonToObliviousRingMachineInit::usage =
"CellularAutomatonToObliviousRingMachineInit[init] converts the cellular automaton initial condition init to an oblivious ring machine tape.
CellularAutomatonToObliviousRingMachineInit[init, r] converts init for a cellular automaton of range r.";

CellularAutomatonToObliviousRingMachineSteps::usage =
"CellularAutomatonToObliviousRingMachineSteps[steps, tapeLength] gives the number of oblivious ring machine steps that emulate steps steps of a range-1 cellular automaton on a tape of length tapeLength.
CellularAutomatonToObliviousRingMachineSteps[steps, tapeLength, r] gives the number of steps for a cellular automaton of range r.";

DecodeObliviousRingMachineToCellularAutomaton::usage =
"DecodeObliviousRingMachineToCellularAutomaton[history] decodes the oblivious ring machine evolution history to the evolution of the range-1 cellular automaton it emulates.
DecodeObliviousRingMachineToCellularAutomaton[history, r] decodes history for a cellular automaton of range r.";


(* ::Section:: *)
(*Cellular automaton to cyclic tag*)


CellularAutomatonToCyclicTagRule::usage =
"CellularAutomatonToCyclicTagRule[rule, tapeLength] compiles the cellular automaton rule for a tape of length tapeLength to a cyclic tag rule.
CellularAutomatonToCyclicTagRule[rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.";

CellularAutomatonToCyclicTagInit::usage =
"CellularAutomatonToCyclicTagInit[init] converts the initial condition init of a 2-color, range-1 cellular automaton to a cyclic tag tape.
CellularAutomatonToCyclicTagInit[init, k] converts init for a cellular automaton with k colors.
CellularAutomatonToCyclicTagInit[init, k, r] converts init for a cellular automaton with k colors and range r.";

CellularAutomatonToCyclicTagSteps::usage =
"CellularAutomatonToCyclicTagSteps[steps, tapeLength] gives the number of cyclic tag steps that emulate steps steps of a 2-color, range-1 cellular automaton on a tape of length tapeLength.
CellularAutomatonToCyclicTagSteps[steps, tapeLength, k] gives the number of steps for a cellular automaton with k colors.
CellularAutomatonToCyclicTagSteps[steps, tapeLength, k, r] gives the number of steps for a cellular automaton with k colors and range r.";

DecodeCyclicTagToCellularAutomaton::usage =
"DecodeCyclicTagToCellularAutomaton[history, tapeLength] decodes the cyclic tag evolution history to the evolution of a 2-color, range-1 cellular automaton on a tape of length tapeLength.
DecodeCyclicTagToCellularAutomaton[history, tapeLength, k] decodes history for a cellular automaton with k colors.
DecodeCyclicTagToCellularAutomaton[history, tapeLength, k, r] decodes history for a cellular automaton with k colors and range r.";

CompiledCellularAutomatonToCyclicTag::usage =
"CompiledCellularAutomatonToCyclicTag[rule, tapeLength] gives a function that runs the cellular automaton rule on a tape of length tapeLength by compiling it to a cyclic tag system, running that system and decoding the result.
CompiledCellularAutomatonToCyclicTag[rule, tapeLength, tapeStates] uses at least tapeStates tape symbols.
CompiledCellularAutomatonToCyclicTag[\[Ellipsis]][init, steps] runs the cellular automaton from init for steps steps.";


(* ::Section:: *)
(*Automata network to oblivious ring machine*)


AutomataNetworkToObliviousRingMachineRule::usage =
"AutomataNetworkToObliviousRingMachineRule[network] gives an oblivious ring machine rule that emulates the automata network network.
AutomataNetworkToObliviousRingMachineRule[network, states] uses at least states tape symbols.";

AutomataNetworkToObliviousRingMachineInit::usage =
"AutomataNetworkToObliviousRingMachineInit[init, network] converts the list of automaton states init of the automata network network to an oblivious ring machine tape.";

AutomataNetworkToObliviousRingMachineSteps::usage =
"AutomataNetworkToObliviousRingMachineSteps[steps, network] gives the number of oblivious ring machine steps that emulate steps steps of the automata network network.
AutomataNetworkToObliviousRingMachineSteps[steps, network, states] uses at least states tape symbols.";

DecodeObliviousRingMachineToAutomataNetwork::usage =
"DecodeObliviousRingMachineToAutomataNetwork[history, network] decodes the oblivious ring machine evolution history to the evolution of the automata network network.
DecodeObliviousRingMachineToAutomataNetwork[history, network, states] uses at least states tape symbols.";


(* ::Section:: *)
(*Automata network to cyclic tag*)


AutomataNetworkToCyclicTagRule::usage =
"AutomataNetworkToCyclicTagRule[network] compiles the automata network network to a cyclic tag rule.
AutomataNetworkToCyclicTagRule[network, states] uses at least states tape symbols.";

AutomataNetworkToCyclicTagInit::usage =
"AutomataNetworkToCyclicTagInit[init, network] converts the list of automaton states init of the automata network network to a cyclic tag tape.
AutomataNetworkToCyclicTagInit[init, network, states] uses at least states tape symbols.";

AutomataNetworkToCyclicTagSteps::usage =
"AutomataNetworkToCyclicTagSteps[steps, network] gives the number of cyclic tag steps that emulate steps steps of the automata network network.
AutomataNetworkToCyclicTagSteps[steps, network, states] uses at least states tape symbols.";

DecodeCyclicTagToAutomataNetwork::usage =
"DecodeCyclicTagToAutomataNetwork[history, network] decodes the cyclic tag evolution history to the evolution of the automata network network.
DecodeCyclicTagToAutomataNetwork[history, network, states] uses at least states tape symbols.";

CompiledAutomataNetworkToCyclicTag::usage =
"CompiledAutomataNetworkToCyclicTag[network] gives a function that runs the automata network network by compiling it to a cyclic tag system, running that system and decoding the result.
CompiledAutomataNetworkToCyclicTag[network, states] uses at least states tape symbols.
CompiledAutomataNetworkToCyclicTag[\[Ellipsis]][init, steps] runs the network from the automaton states init for steps steps.";


Begin["`Private`"];


(* The implementation files are loaded in dependency order: each file can use the
   helpers and public functions defined by the files before it. *)
Scan[
	Get,
	{
		"EricJamesParfitt`CyclicTagCompiler`ResourceFunctions`",
		"EricJamesParfitt`CyclicTagCompiler`Systems`",
		"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineRules`",
		"EricJamesParfitt`CyclicTagCompiler`Utilities`",
		"EricJamesParfitt`CyclicTagCompiler`NaryCyclicTagToCyclicTag`",
		"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToNaryCyclicTag`",
		"EricJamesParfitt`CyclicTagCompiler`ObliviousRingMachineToCyclicTag`",
		"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToObliviousRingMachine`",
		"EricJamesParfitt`CyclicTagCompiler`CellularAutomatonToCyclicTag`",
		"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToObliviousRingMachine`",
		"EricJamesParfitt`CyclicTagCompiler`AutomataNetworkToCyclicTag`"
	}];


End[];


EndPackage[];
