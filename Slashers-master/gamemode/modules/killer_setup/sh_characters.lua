-- Slashers — Killer Characters Registry (Shared)

if SERVER then AddCSLuaFile() end

GM.KillerCharacters = {
	["ghostface"] = {
		name  = "Ghostface",
		model = "models/player/screamplayermodel/scream/scream.mdl",
		walk  = 190,
		run   = 240,
		desc  = "You can see doors opening and closing. Strike from the shadows."
	},
	["jason"] = {
		name  = "Jason",
		model = "models/player/mkx_jason.mdl",
		walk  = 190,
		run   = 240,
		desc  = "Fastest killer. Track footprints left by survivors."
	},
	["myers"] = {
		name  = "Michael Myers",
		model = "models/player/dewobedil/mike_myers/default_p.mdl",
		walk  = 200,
		run   = 200,
		desc  = "Slow but deadly. Focus on one survivor to stalk them."
	},
	["proxy"] = {
		name  = "The Proxy",
		model = "models/slender_arrival/chaser.mdl",
		walk  = 200,
		run   = 200,
		desc  = "Appear and disappear when out of survivor sight."
	},
	["intruder"] = {
		name  = "The Intruder",
		model = "models/steinman/slashers/intruder_pm.mdl",
		walk  = 200,
		run   = 200,
		desc  = "Place bear traps and alert ropes to trap your prey."
	},
	["bates"] = {
		name  = "Norman Bates",
		model = "models/steinman/slashers/bates_pm.mdl",
		walk  = 200,
		run   = 200,
		desc  = "Use your mother's corpse to locate and hunt survivors."
	}
}
