local downloads =
{
	"913756000", -- CW2.0 Ammo Supplies
	"349050451", -- CW2.0
	"359830105", -- Unofficial Extra CW2.0
	"358608166", -- Extra CW2.0
	"104482086", -- Precision Tool
	--"243902601", -- gm_bluehils_test3
	"430352929", -- CW2.0 XM1014
	"151830991", -- Spawnable Kevlar Armor
	"409225672", -- CW2.0 MK11
	"174057684", -- Sci-Fi AUG Prop
	"689675000", -- CW2.0 Sci-Fi AUG
	"612955177", -- CW2.0 M79GL
	"411141331", -- CW2.0 PPSH-41
	"732062721", -- CW2.0 Sci-Fi Knife
	"707343339", -- CW2.0 Melee
	"730880014", -- CW2.0 Sci-Fi Pistol
	"354842171", -- CW2.0 Hk416
	"400665331", -- CW2.0 Attachment Pack
	"388725208", -- Graffiti SWEP
	"131736822", -- Flamethrower SWEP
	"922947756", -- Synthesizer (Playable)
	"116690393", -- Gascan
	"104607228", -- Fire Extinguisher
	--"295680095", -- JI Defense Solutions
	--"669642096", -- Drones Rewrite
	--"296828130", -- rp_evocity basewars
	"546392647", -- Media Player
	"110286060", -- rp_downtown_v4c_v2
	"415143062",  -- TFA Base
	"712848264",  -- TFA CSO part 1
	"1309914309", -- TFA CSO part 2
	"1538229351", -- TFA CSO part 3

}

for _,v in ipairs(downloads) do
	resource.AddWorkshop(v)
end