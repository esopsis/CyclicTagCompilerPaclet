# Project state: the dropped-symbol optimization

Status as of 2026-11-20. Author: Eric Parfitt. Originally written to hand the work to a
different LLM assistant mid-stream; now kept as a description of where the optimization
landed and what is left.

**Short version:** the optimization is finished, verified, documented and tested. The
whole test suite passes (191 / 191) and every stored example in the documentation
notebooks matches what the current code produces. The version bump and the rebuild are
deliberately **not** done yet: Eric may land another optimization first and wants to
switch versions once, for both.

## 1. What this repo is

A Wolfram Language paclet (`EricJamesParfitt/CyclicTagCompiler`, still v2.1.0 — see
section 8) that compiles
several computational systems down to **ordinary (binary) cyclic tag systems**:

```
cellular automaton  ─┐
automata network    ─┴─> oblivious ring machine ─> n-ary cyclic tag ─> cyclic tag
```

The method is Seth Marshall's; the implementation is Eric's. Background article:
<https://community.wolfram.com/t/a-simpler-polynomial-time-compilation-to-cyclic-tag-for-bounded-computation>
(note: that page truncates under automated fetching — read it in a real browser).

Each layer ships four functions: `…Rule`, `…Init`, `…Steps`, and `Decode…`.
`Kernel/CyclicTagCompiler.wl` holds all the usage messages and loads the
implementation files in dependency order.

## 2. The optimization

**Goal:** shrink the n-ary → cyclic tag blow-up.

Baseline encoding: n-ary symbol `s` becomes a one-hot block of `states` bits, so one
n-ary step costs `states` cyclic tag steps.

**The optimization:** some n-ary symbols are *never appended for* — their column is `{}`
in every rule part (`deleteds` finds these). Those columns can be dropped, shrinking the
block from `getStates[rule]` to `replacedStates[rule]`. On the oblivious-ring-machine
path this is a real win, because the ORM compiler's top marker symbol (`states+1`,
the delay marker) always has an all-empty column:

| ORM rule | full block | optimized | saving |
|---|---|---|---|
| `{{{0,1}->{1,0}},2}` | 4 | 3 | 25% |
| `{{{0,1}->{1,2},{2,0}->{0,1}},2}` | 5 | 4 | 20% |

The saving shows up directly in the step counts (these are the `Tests/Regression.wlt`
golden values, before and after):

| | before | after |
|---|---|---|
| `ObliviousRingMachineToCyclicTagSteps[6, {{Reverse,{},3},2}, 5, 3]` | 1080 | **864** |
| `CellularAutomatonToCyclicTagSteps[3, 5]` | 960 | **720** |
| `AutomataNetworkToCyclicTagSteps[2, …]` | 2576 | **1932** |

Every *decoded* evolution is unchanged — the optimization only narrows the cyclic tag
encoding the compilation passes through, so it is invisible at the ORM level and above.

**The accepted trade-off.** Dropping columns renumbers the symbols, so decoding no
longer returns the original n-ary evolution — it returns an *isomorphic* one. Eric has
explicitly decided this is fine, and gated it behind `"Optimization"` so a full-fidelity
mode can be added later. The contract:

- a **surviving** symbol decodes to its 0-based rank among survivors;
- **every dropped** symbol decodes to `replacedStates` (one shared label, outside the
  survivors' range `0 … replacedStates-1`, so it can never collide);
- dropped symbols collapsing together is acceptable *because they are never read* —
  though note they can still be **written** onto the tape by another symbol's
  appendant, so they do show up in the decoded history.

**This contract is met, and fully verified.** Measured over 200 random n-ary systems
(`handoff/isomorphism-check.wls`), recovering the relabeling empirically from each round
trip rather than assuming it:

| | `Automatic` | `"Rule110"` |
|---|---|---|
| relabeling is a well-defined function | 200/200 | 200/200 |
| injective on surviving symbols | 200/200 | 200/200 |
| dropped images never collide with survivors' | 200/200 | 200/200 |
| **true isomorphism (all three)** | **200/200** | **200/200** |
| exact equality (no relabeling needed) | 172/200 | 172/200 |

The relabeling is **identical under both target systems** (200/200 same map), and the
Rule110 multiple-of-6 invariant holds on all 200 cases. `decodeTape`'s not-found default
is `{states+1}`, so a dropped symbol decodes to `replacedStates` regardless of target.

`Tests/NaryCyclicTag.wlt` now checks this same contract as part of the suite, via its
`isomorphicQ` helper — so the sweep script is a diagnostic, not the only guard.

### Full compilation chains — all verified

| chain | `Automatic` | `"Rule110"` |
|---|---|---|
| ORM → CT (45 cases) | 45/45 | 45/45 |
| CA → CT, vs light-cone region (24 cases) | 24/24 | 24/24 |
| CA → CT, `"InfiniteSteps" -> True`, vs full cyclic CA | 24/24 | 24/24 |
| `CompiledCellularAutomatonToCyclicTag` | 24/24 | 24/24 (`Mod6CyclicTag`) |
| automata network → CT + `CompiledAutomataNetworkToCyclicTag` | pass | pass |

**Careful with the CA reference.** Without `"InfiniteSteps"`, the compiled system
reproduces only the cells whose light cones stay inside the tape — `2r` fewer cells each
step, shifted by `Ceiling[r]`, for `Quotient[tapeLength-1, 2r]+1` rows. Comparing against
a plain cyclic `CellularAutomaton[rule, init, {t, All}]` shows a spurious 0/24. Use the
`reliableRegion` helper at the top of `Tests/CellularAutomaton.wlt`. With
`"InfiniteSteps" -> True` the correct reference *is* the plain cyclic
`CellularAutomaton[rule, init, t]`.

### Test suite — all green

| file | result |
|---|---|
| `Loading.wlt` | 8 / 8 |
| `CyclicTagSystem.wlt` | 11 / 11 |
| `ResourceFunctions.wlt` | 11 / 11 |
| `NaryCyclicTag.wlt` | 36 / 36 |
| `ObliviousRingMachine.wlt` | 24 / 24 |
| `CellularAutomaton.wlt` | 23 / 23 |
| `AutomataNetwork.wlt` | 21 / 21 |
| `Regression.wlt` | 57 / 57 |

`NaryCyclicTag.wlt` and `Regression.wlt` were rewritten for the current signatures;
`Regression.wlt`'s golden values were recomputed for the optimization. The other six
files were never affected by it.

## 3. The current API

The n-ary layer takes the **rule**, not a symbol count. The old second argument is gone,
so whenever the version is next bumped it needs to be a **major** one.

```wolfram
NaryCyclicTagToCyclicTagRule[rule]                 (* was [rule, states] *)
NaryCyclicTagToCyclicTagInit[init, rule]           (* was [init, states] *)
NaryCyclicTagToCyclicTagSteps[steps, rule]         (* was [steps, states] *)
DecodeCyclicTagToNaryCyclicTag[history, rule]      (* was [history, states] *)
```

All four, and the twelve matching functions at the ORM / CA / automata-network layers,
declare `"Optimization" -> "DeletedSymbolsHighest"`. The number of symbols is now the
length of a rule part.

`…Rule`, `…Init` and `Decode…` are gated with `/;` on the option, so an unimplemented
setting leaves them unevaluated rather than quietly compiling something else. `…Steps`
is deliberately **not** gated — it keeps working, and its result already accounts for the
dropped symbols even though it never reads the setting.

## 4. Accepted as-is — do not "fix" these

Eric has explicitly signed off on all of the following:

- **Ragged rule parts no longer compile.** Dropping a column needs a rectangular rule:
  `deleteds` calls `Transpose` and `myDeleteColumns` calls `DeleteColumns`, and both
  require equal-length parts. A rule like `{{{1}}, {{0},{1,1}}}` used to give
  `{{0,1},{},{1,0},{0,1,0,1}}` and now fails with `Transpose::nmtx` then
  `DeleteColumns::tabularc`. This is intended; the docs and
  `NaryCyclicTag-Rule-RaggedPartsDoNotCompile` both say so. `getStates` still uses
  `Max[Length /@ rule, 0]` and `…Rule` still pads parts with `PadRight`, which Eric is
  keeping in case he revisits this later — so the `Max` is not dead code to clean up.
  Worth knowing: `ResourceFunction["NaryCyclicTag"]` can't run ragged rules either
  (`Part::partw`), so the n-ary system itself never really supported them.
- **Out-of-range init symbols.** A symbol beyond the rule's column count isn't covered
  by `replacements`, so it falls through as a bare integer and you get
  `Catenate::invrp` plus an unevaluated `Catenate[{{1,0},{0,1},5}]`. He wants *some*
  hint, and that counts.
- **Unknown `"TargetSystem"` values.** `targetSystemStates` in `Kernel/Utilities.wl:22`
  is a `Switch` with no default, so a typo yields a symbolic `Switch[…]` that propagates
  into `PadRight`/`Table`. Again — a hint is enough. Note the contract is
  **capitalized `"Rule110"` only**; lowercase `"rule110"` support was deliberately
  removed.
- **Dropped symbols collapsing to one label**, and decoding to an isomorphic rather than
  identical system.

## 5. Fixed — do not re-report

- The `"DeletedSymbolsHighest"` vs `"DeletedSymbols"` option-value mismatch.
- The ORM plumbing that passed `"Optimization"` as a 4th argument to
  `ObliviousRingMachineToNaryCyclicTagRule`, which takes no options.
- The `-Infinity` / `DeleteColumns::tabularc` cascade on the empty rule `{}`.
- Dropped symbols decoding to a different label under `"Rule110"` than under `Automatic`.
- **`OptionValue::nodef` on every chained call.** `Options[NaryCyclicTagToCyclicTagSteps]`
  now declares `"Optimization"` and `Options[…Rule]` inherits from it, so all sixteen
  chain functions are clean on every path, including both `Compiled…` wrappers. Nothing
  needs a `Quiet[…, {OptionValue::nodef}]` wrapper any more.
- **All-columns-empty rules.** `…Rule[{{{},{}}}]` returns `{{}}` — one empty appendant,
  which `CyclicTagSystem` can actually run — instead of `{}`, which used to stick on an
  unevaluated `Cyclic[{}][1]` and never complete the round trip.
- **Stale docs and tests.** Usage messages, 16 reference pages, the guide, the tutorial
  and `ResourceDefinition.nb` all describe the current API and the optimization.

## 6. How to test (important — the obvious routes don't work)

**Use `wolframscript`, not an MCP Wolfram evaluator.**

```bash
wolframscript -file handoff/isomorphism-check.wls
```

Traps that have already burned time here:

1. **An MCP Wolfram server shares one kernel and one paclet registry across its
   "sessions."** `PacletDirectoryLoad` on a second copy of the paclet does *not* isolate
   it: the first-registered directory wins, and `PacletObject[…]["Location"]` cheerfully
   reports the path you just registered while the live definitions come from the other
   one. To tell what is actually loaded, check a definition, not the location:
   ```wolfram
   Definition @@ {Symbol["EricJamesParfitt`CyclicTagCompiler`Private`targetSystemStates"]}
   ```
   For a real A/B of two revisions, give the copies different paclet `Version`s, or use
   separate OS-level kernels (`wolframscript` does this naturally).
2. **An MCP `TestReport` tool runs in a kernel that hasn't loaded the paclet**, so every
   test fails with `Get::noopen` / `Needs::nocont`. Call `TestReport[…]` inside a script
   that does `PacletDirectoryLoad` + `Needs` first.
3. **`$MessageList` is only populated at the end of an evaluation.** Reading it inside
   `Block[{$MessageList={}}, expr; …]` always returns `{}` even while the message is
   visibly printing. Use `Check` to detect messages.
4. **`Check` fires on warnings too**, not just errors, so `Check[expr, $Failed]` around a
   call that merely warns reports total failure on working code.
5. **`ParallelMap` subkernel messages escape `Quiet` sometimes.** `…Rule` uses
   `ParallelMap`, and a message raised inside its body is forwarded from the subkernel and
   can still be recorded by `VerificationTest`, which then reports the test as failing
   with messages. Prefer asserting through a non-parallel path (`…Steps`) when you need a
   message-free test of a bad-input case.
6. Private symbols need qualifying. `Begin["…`Private`"]` in the same input cell does not
   help, because the cell is parsed before the context changes. Use
   `Symbol["EricJamesParfitt`CyclicTagCompiler`Private`deleteds"]`.
7. **Regenerating notebook boxes through a pipe loses named characters.**
   `ToString[boxes, InputForm]` emits `\[Rule]` and `\[LeftSkeleton]` as literal
   characters that can vanish in transit, silently turning an operator into `""`. Pass
   `CharacterEncoding -> "ASCII"`.

Reference systems for differential testing come from the resource-function resolver,
`EricJamesParfitt`CyclicTagCompiler`Private`resourceFunction`, e.g.
`resourceFunction["NaryCyclicTag"]` and `resourceFunction["ObliviousRingMachine"]`.
These need network access.

## 7. Building

`PacletTools` is installed (14.0.1.0), so the build runs headless without the definition
notebook:

```wolfram
Needs["PacletTools`"]
PacletTools`PacletBuild[
  "/home/ericp/Repos/CyclicTagCompilerPaclet/CyclicTagCompiler",
  "/home/ericp/Repos/CyclicTagCompilerPaclet/CyclicTagCompiler/build"]
```

It takes about two minutes, nearly all of it the documentation build (35 notebooks). Two
things to expect:

- **The Wolfram front end segfaults on exit.** The documentation build needs a front end,
  and the headless one dies with `SIGSEGV` *after* the build finishes. `PacletBuild`
  still returns `Success[…]`, `wolframscript` still exits 0, and the artifact is intact.
  Check the result expression, not the stderr noise.
- **`PacletManifest.wl` records the host's path separators.** The committed manifest was
  built on Windows (`Kernel\Utilities.wl`); a Linux build rewrites all 105 entries to
  `Kernel/Utilities.wl`. It flips back on the next Windows build, so it is noise in the
  diff rather than a real change.

This has been run once, as a dry run against a 3.0.0 `PacletInfo.wl`: the build succeeded,
and the resulting archive reported v3.0.0 and passed all 191 tests when unpacked on its
own in a kernel where the working tree was not registered. Both the version bump and the
build were then backed out, so `build/` still holds the 1.0.0 and 2.1.0 archives and an
unpacked tree built from the pre-optimization code.

Note that the committed tree is stale in more ways than the version: its
`Kernel/Utilities.wl` still has the lowercase `"rule110"` branch, because the last build
predated the WIP commit that removed it. A rebuild will clear that up along with
everything else.

## 8. What is left

1. **Possibly another optimization.** Eric is considering one, and wants to bump the
   version once for both rather than twice.
2. **Bump the version and rebuild** once that settles — a major bump, per section 3 —
   and commit the resulting archive alongside the 1.0.0 and 2.1.0 ones.
3. **Merge to `main`.** This work lives on `Optimizations`; `main` is still at
   `5e12cd9 Rebuild the paclet at version 2.1.0`.
4. **Update the Community article** to describe the optimization, the relabeling contract
   and the new n-ary signatures. Eric is doing this himself.

## 9. Working agreement with Eric

- He writes the bug fixes. Diagnose precisely, cite `file:line`, show the failing input
  and actual output — then stop.
- Report measurements, not impressions. "200/200 true isomorphism" beats "looks right".
- Don't re-litigate the accepted trade-offs in section 4.
