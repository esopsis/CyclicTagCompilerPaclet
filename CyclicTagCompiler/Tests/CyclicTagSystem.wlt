(* Tests for CyclicTagSystem. *)

VerificationTest[
	Needs["EricJamesParfitt`CyclicTagCompiler`"],
	Null,
	TestID -> "CyclicTagSystem-Load"
]

VerificationTest[
	CyclicTagSystem[{{1, 1}, {1, 0}}, {1}, 6],
	{{1}, {1, 1}, {1, 1, 0}, {1, 0, 1, 1}, {0, 1, 1, 1, 0}, {1, 1, 1, 0}, {1, 1, 0, 1, 0}},
	TestID -> "CyclicTagSystem-Basic"
]

VerificationTest[
	CyclicTagSystem[{{1, 1}, {1, 0}}, {1}, 6, "States"] === CyclicTagSystem[{{1, 1}, {1, 0}}, {1}, 6],
	True,
	TestID -> "CyclicTagSystem-States"
]

VerificationTest[
	CyclicTagSystem[{{1, 1}, {1, 0}, {0}}, {1}, 4, "Rules"],
	{{1, 1}, {1, 0}, {0}, {1, 1}, {1, 0}},
	TestID -> "CyclicTagSystem-Rules"
]

VerificationTest[
	CyclicTagSystem[{{1, 1}, {1, 0}}, {1}, 3, {"States", "Rules"}],
	{{{1}, {1, 1}}, {{1, 1}, {1, 0}}, {{1, 1, 0}, {1, 1}}, {{1, 0, 1, 1}, {1, 0}}},
	TestID -> "CyclicTagSystem-PropertyList"
]

VerificationTest[
	CyclicTagSystem[{{1}, {0}}, {1, 0}, 0],
	{{1, 0}},
	TestID -> "CyclicTagSystem-ZeroSteps"
]

(* Once the tape is empty, it stays empty. *)
VerificationTest[
	CyclicTagSystem[{{0, 1}, {0}, {0, 1, 1}}, {0, 1, 1, 1}, 200][[-3 ;;]],
	{{}, {}, {}},
	TestID -> "CyclicTagSystem-Halts"
]

VerificationTest[
	CyclicTagSystem[{}, {1, 0}, 2, "Rules"],
	{{}, {}, {}},
	TestID -> "CyclicTagSystem-NoBlocksRules"
]

(* The tapes are the same as those of the Wolfram Function Repository function CyclicTagSystemEvolveList. *)
VerificationTest[
	With[{ctsel = ResourceFunction["CyclicTagSystemEvolveList"]},
		BlockRandom[
			Select[
				Table[{RandomInteger[1, #] & /@ RandomInteger[{0, 4}, RandomInteger[{1, 5}]], RandomInteger[1, RandomInteger[{0, 6}]], RandomInteger[{0, 40}]}, 200],
				CyclicTagSystem @@ # =!= ctsel @@ # &],
			RandomSeeding -> 31]],
	{},
	TestID -> "CyclicTagSystem-SameAsCyclicTagSystemEvolveList"
]
