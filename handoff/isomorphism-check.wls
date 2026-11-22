PacletDirectoryLoad["/home/ericp/Repos/CyclicTagCompilerPaclet/CyclicTagCompiler"];
Needs["EricJamesParfitt`CyclicTagCompiler`"];
p="EricJamesParfitt`CyclicTagCompiler`Private`";
del=Symbol[p<>"deleteds"]; rs=Symbol[p<>"replacedStates"]; gs=Symbol[p<>"getStates"];
reps=Symbol[p<>"replacements"]; tss=Symbol[p<>"targetSystemStates"];
nct=Symbol[p<>"resourceFunction"]["NaryCyclicTag"];
OPT="Optimization"->"DeletedSymbolsHighest";
(* Q used to swallow OptionValue::nodef, which fired on every chained call. That is fixed, so Q is a
   pass-through now and any message you see here is a real one. *)
Q[e_]:=e;
SetAttributes[noisy,HoldAll];
(* $MessageList is only filled at the END of an evaluation, so reading it mid-evaluation always gives {}.
   Check is what actually detects a message. *)
noisy[e_]:=TrueQ[Check[(e;False),True]];
okQ[x_]:=MatchQ[x,{{___Integer}...}];

Print["### 1. does passing the option down emit anything? ###"];
Print["  Options[Steps] = ", Options[NaryCyclicTagToCyclicTagSteps]];
Scan[
  Print["  ", #[[1]], " noisy? ", #[[2]]]&,
  {{"NCT Rule  +Opt", noisy[NaryCyclicTagToCyclicTagRule[{{{1},{0,0}},{{},{1,1}}}, OPT]]},
   {"NCT Steps +Opt", noisy[NaryCyclicTagToCyclicTagSteps[5, {{{1},{0,0}},{{},{1,1}}}, OPT]]},
   {"ORM Steps     ", noisy[ObliviousRingMachineToCyclicTagSteps[4, {{{0,1}->{1,0},{1,1}->{0,0}},2}, 5]]},
   {"CA  Steps     ", noisy[CellularAutomatonToCyclicTagSteps[3, 5]]},
   {"Compiled CA   ", noisy[CompiledCellularAutomatonToCyclicTag[30, 6][{0,0,1,0,0,1}, 2]]}}];

Print[]; Print["### 2. empty rule {} ###"];
Print["  getStates[{}]=", gs[{}], " replacedStates[{}]=", rs[{}]];
Print["  replacements[{}] = ", Q@reps[{}]];
Print["  Rule   = ", Q@NaryCyclicTagToCyclicTagRule[{}, OPT]];
Print["  Init   = ", Q@NaryCyclicTagToCyclicTagInit[{}, {}, OPT]];
Print["  Decode = ", Q@DecodeCyclicTagToNaryCyclicTag[{{}}, {}, OPT]];

(* Rule returns the single empty appendant {{}}, not {}, so CyclicTagSystem has something runnable. *)
Print[]; Print["### 3. all columns empty {{{},{}}} ###"];
r0={{{},{}}};
Print["  deleteds=", del[r0], " replacedStates=", rs[r0]];
Print["  Rule   = ", Q@NaryCyclicTagToCyclicTagRule[r0, OPT]];
Print["  Init   = ", Q@NaryCyclicTagToCyclicTagInit[{0,1}, r0, OPT]];
Print["  Steps  = ", Q@NaryCyclicTagToCyclicTagSteps[3, r0]];
Print["  Decode = ", Q@DecodeCyclicTagToNaryCyclicTag[{{0,1}}, r0, OPT]];
Print["  full round trip = ", Q@DecodeCyclicTagToNaryCyclicTag[
   CyclicTagSystem[NaryCyclicTagToCyclicTagRule[r0,OPT], NaryCyclicTagToCyclicTagInit[{0,1},r0,OPT],
     NaryCyclicTagToCyclicTagSteps[3,r0]], r0, OPT]];
Print["  reference       = ", nct[r0,{0,1},3]];

Print[]; Print["### 4. Rule110 now gives the SAME erased label as Automatic? ###"];
r2={{{},{0},{1}},{{},{2},{}}};
Print["  rs=", rs[r2], " Rule110 block=", tss[rs[r2],"Rule110"]];
Print["  Automatic: encode {0,1,2} -> decode = ",
  Q@DecodeCyclicTagToNaryCyclicTag[{Q@NaryCyclicTagToCyclicTagInit[{0,1,2},r2,OPT]}, r2, OPT]];
Print["  Rule110  : encode {0,1,2} -> decode = ",
  Q@DecodeCyclicTagToNaryCyclicTag[{Q@NaryCyclicTagToCyclicTagInit[{0,1,2},r2,OPT,"TargetSystem"->"Rule110"]},
     r2, OPT, "TargetSystem"->"Rule110"]];

Print[]; Print["### 5. isomorphism sweep ###"];
viaCT[rule_,init_,t_,o_List]:=Q@DecodeCyclicTagToNaryCyclicTag[
  CyclicTagSystem[NaryCyclicTagToCyclicTagRule[rule,OPT,Sequence@@o],
    NaryCyclicTagToCyclicTagInit[init,rule,OPT,Sequence@@o],
    NaryCyclicTagToCyclicTagSteps[t,rule,Sequence@@o]], rule, OPT, Sequence@@o];
SeedRandom[42];
randRule[k_]:=Table[Table[RandomInteger[k-1,RandomInteger[{0,3}]],k],RandomInteger[{1,4}]];
cases=Table[With[{k=RandomInteger[{2,4}]},
  {randRule[k],RandomInteger[k-1,RandomInteger[{1,5}]],RandomInteger[{0,8}]}],200];
audit[c_,o_List]:=Module[{rule=c[[1]],ref,got,pairs,phi,surv,era},
  ref=nct@@c; got=viaCT[c[[1]],c[[2]],c[[3]],o];
  If[!okQ[got]||Length/@ref=!=Length/@got,Return["broken"]];
  pairs=Union@Catenate@MapThread[Transpose[{#1,#2}]&,{ref,got}];
  If[!DuplicateFreeQ[pairs,First[#1]===First[#2]&],Return["notfunction"]];
  phi=Association[Rule@@@pairs];
  surv=Complement[Range[0,gs[rule]-1],del[rule]]; era=del[rule];
  {DuplicateFreeQ[Lookup[phi,Intersection[surv,Keys[phi]]]],
   Intersection[Lookup[phi,Intersection[era,Keys[phi]],Nothing],
                Lookup[phi,Intersection[surv,Keys[phi]],Nothing]]==={},
   phi}];
Do[Module[{a=audit[#,o]&/@cases},
  Print["  === ",If[o==={},"Automatic","Rule110"]," ==="];
  Print["    exact equality        : ",Count[cases,c_/;(nct@@c)===viaCT[c[[1]],c[[2]],c[[3]],o]],"/200"];
  Print["    injective on survivors: ",Count[a,{True,_,_}],"/200"];
  Print["    erased disjoint       : ",Count[a,{_,True,_}],"/200"];
  Print["    TRUE ISOMORPHISM      : ",Count[a,{True,True,_}],"/200"];
  Print["    broken/notafunction   : ",Count[a,_String],"/200"]],
 {o,{{},{"TargetSystem"->"Rule110"}}}];
Print["  same phi under both targets? ",
  Count[cases, c_/; (audit[c,{}]/._Association->0) === (audit[c,{"TargetSystem"->"Rule110"}]/._Association->0)
        && Last[audit[c,{}]] === Last[audit[c,{"TargetSystem"->"Rule110"}]]], "/200"];
