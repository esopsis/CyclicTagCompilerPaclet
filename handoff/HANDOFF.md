# Project state: the two cyclic tag encoding optimizations

Status as of 2026-11-22. Author: Eric Parfitt. Originally written to hand the work to a
different LLM assistant mid-stream; now kept as a description of where the optimizations
landed and what is left.

**Short version:** both optimizations are finished, verified, documented and tested, and
they are now merged together on `Optimizations`. The whole test suite passes (191 / 191)
and every stored example in the documentation notebooks matches what the current code
produces. The paclet has been bumped to **3.0.0** and rebuilt. What is left is merging to
`main` and updating the Community article.

## 1. What this repo is

A Wolfram Language paclet (`EricJamesParfitt/CyclicTagCompiler`, v3.0.0) that compiles
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

## 2. The optimizations

**Goal:** shrink the n-ary → cyclic tag blow-up. There are two independent optimizations,
and they compose.

Baseline encoding: n-ary symbol `s` becomes a one-hot block of `states` bits, so one
n-ary step costs `states` cyclic tag steps.

### 2a. Dropped symbols (`"Optimization" -> "DeletedSymbolsHighest"`)

Some n-ary symbols are *never appended for* — their column is `{}` in every rule part
(`deleteds` finds these). Those columns can be dropped, shrinking the block from
`getStates[rule]` to `replacedStates[rule]`. On the oblivious-ring-machine path this is a
real win, because the ORM compiler's delay marker always has an all-empty column.

### 2b. Symbol reuse in the ORM → n-ary compilation

The ORM compiler used to need **two** marker symbols: one to build the delay and one
(`states+1`) to trigger the appendant. It now needs only **one**. A step that reads a
window of `replacementSize` symbols turns the leading `replacementSize - 1` of them into
a delay, exactly as before, but that delay now only selects a *group* of appendants.
The last symbol of the window is appended to the tape as itself, and selects the
appendant *within* that group — so the tape's own symbols do the final selection.

This drops the n-ary alphabet from `states + 2` to `states + 1` and removes one rule part
per ORM step. Selector groups go from `states^replacementSize` to
`states^(replacementSize-1)`, which more than pays for the extra trailing skips.

The two stack: the symbol-reuse output still leaves exactly one always-empty column, so
2a then removes it. A 2-state ring machine ends up with 2-bit blocks where the
unoptimized encoding used 4.

### Combined effect

`Tests/Regression.wlt` golden values across the three stages:

| | baseline | +2a | +2a +2b |
|---|---|---|---|
| `ObliviousRingMachineToCyclicTagSteps[6, {{Reverse,{},3},2}, 5, 3]` | 1080 | 864 | **468** |
| `CellularAutomatonToCyclicTagSteps[3, 5]` | 960 | 720 | **450** |
| `CellularAutomatonToCyclicTagSteps[3, 5, 2, 1/2, "InfiniteSteps"->True]` | 1080 | 810 | **504** |
| `AutomataNetworkToCyclicTagSteps[2, …]` | 2576 | 1932 | **1200** |

One exception worth knowing: `"TargetSystem" -> "Rule110"` pads the symbol count up to a
multiple of 6, which can swallow the saving entirely —
`ObliviousRingMachineToCyclicTagSteps[6, swap, 4, 2, "Rule110"]` is 360 both with and
without 2b.

Every *decoded* evolution is unchanged by either optimization — they only narrow the
cyclic tag encoding the compilation passes through, so they are invisible at the ORM
level and above.

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
`Regression.wlt`'s golden values were recomputed for both optimizations. The other six
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
  and `ResourceDefinition.nb` all describe the current API and both optimizations.
- **The symbol-reuse WIP bugs.** `numberedPads` was called with two arguments but defined
  with three; the trailing skip count was missing a term and is now
  `tapeLength - replacementSize + Length@selectors[rule, states] - 1 + offset`, which is
  `states^(replacementSize-1)` groups minus the ones already paid for. The superseded
  `selectors` definition (with a leftover `//Echo`) and the unused `skips` are gone.
- **`ormStatesCheck` inferring the alphabet from the largest symbol.** At
  `replacementSize == 1` there is only one selector group, so symbol reuse removes the
  marker from the compiled rule entirely and `Max[rule + 1]` undercounted — the rule got
  wider blocks than the init, steps and decoder. The function is gone: the merged ORM
  layer passes the compiled rule down and lets `getStates[rule] = Max[Length /@ rule, 0]`
  do it, which reads the alphabet off the rule's arity. **The alphabet size is the number
  of appendants per rule part, never one more than the largest symbol present** — both
  branches arrived at this independently, and it is the invariant to preserve.

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
8. **`MakeBoxes` has `HoldAllComplete`.** `MakeBoxes[v, StandardForm]` where `v` is your
   local variable produces boxes for the *symbol name* (`Global`got$38459`), not its
   value, and the result looks plausible until you read the diff. Use `ToBoxes`.
9. **Number Output cells consistently.** A generator that pairs each Output with the
   preceding Input and a text splicer that counts every `Cell[…, "Output", …]` in
   document order disagree wherever a notebook has an Output with no Input before it
   (`ResourceDefinition.nb` has one), and you silently patch the wrong cells. Count every
   Output cell in document order on both sides, and compare only where the
   *immediately* preceding cell is an Input.
10. **Walk nested cells.** `Cell[CellGroupData[{…}]]` wraps the real cells, so a text
    scanner that skips past each matched `Cell[…]` never sees them and finds nothing.
11. **Stored Output cells carry front-end formatting options.** `Grid`/`Column` outputs
    come back with `ItemSize -> {Automatic, Automatic}` that re-evaluating the input
    never produces, so a naive comparison reports a mismatch on cells that are fine.
    Normalize with something like `e //. (h:Grid|Column|TableForm)[a_, ___] :> h[a]`.
12. **Graphics cells can be regenerated headlessly**, but only after you prove they are
    stale — evaluate the input against the old and new trees and compare
    `Hash[ToString[ToBoxes[…], InputForm]]`, rather than guessing from the input text
    (most plots here show *decoded* evolutions, which never change). `ToBoxes` gives a
    `GraphicsBox` with an uncompressed `RasterBox`, ~17× larger than the front end's
    `CompressedData`. `CompressedData[…]` evaluates in the kernel, so build the text with
    a placeholder and substitute `"CompressedData[\"" <> Compress[data] <> "\"]"`.

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

**The 3.0.0 build has been done and committed.** It took 67 s, built all 35 documentation
notebooks with 0 failures, and produced
`build/EricJamesParfitt__CyclicTagCompiler-3.0.0.paclet`, which now sits alongside the
1.0.0 and 2.1.0 archives. The front end did *not* segfault this time, so treat that as
intermittent rather than guaranteed.

Verified by unpacking the archive and loading **only** that directory, in a kernel where
the working tree was never registered: it reports v3.0.0, all 13 `Kernel/*.wl` files are
byte-identical to the working tree, `ormStatesCheck`, `skips` and the stray `//Echo` are
all absent, `getStates` is the merged `Max[Length /@ rule, 0]`, and it passes 191 / 191.
The rebuild also cleared the stale lowercase `"rule110"` branch that the previously
committed tree still carried in `Kernel/Utilities.wl`.

Checking provenance this way is worth the trouble — `PacletObject[…]["Location"]` is not
evidence (see trap 1 in section 6). Note that `Definition @@ {sym}` is a poor emptiness
test: for an undefined symbol its string form is not `"Null"`, so a check like
`ToString[Definition @@ {sym}] === "Null"` reports a false negative. Grep the archive's
source instead.

## 8. What is left

1. **Merge to `main`.** This work lives on `Optimizations`; `main` is still at
   `5e12cd9 Rebuild the paclet at version 2.1.0`. The symbol-reuse branch
   (`ORMToNCTNoXsWIP`) has already been merged into `Optimizations`.
2. **Push.** Nothing here has been pushed; `origin/Optimizations` is still at the older
   `7da39bc`.
3. **Update the Community article** to describe both optimizations, the relabeling
   contract and the new n-ary signatures. Eric is doing this himself.

One known cosmetic leftover: the `ObliviousRingMachine.nb` "Neat Examples" output that
plots `Grid[Prepend[{"Tape","Rule"}][ObliviousRingMachine[…]]]` cannot be verified by the
notebook-checking harness, because the resource function does not resolve inside the
sandbox context it evaluates in. It is upstream of both optimizations and
`ObliviousRingMachine.wlt` is 24/24, so the stored output is believed correct — it is
simply unchecked.

## 9. Working agreement with Eric

- He writes the bug fixes. Diagnose precisely, cite `file:line`, show the failing input
  and actual output — then stop.
- Report measurements, not impressions. "200/200 true isomorphism" beats "looks right".
- Don't re-litigate the accepted trade-offs in section 4.
