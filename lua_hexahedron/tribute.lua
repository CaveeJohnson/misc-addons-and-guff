do return end

tribute = {}

function tribute.giveMoney(ply, t)
	ply:GiveMoney(t.amt)
end

tribute.rewardTable = {
	{
		name   = "£10,000",
		icon   = "coins",

		func   = tribute.giveMoney,
		amt    = 1e4,
		skew   = 100,
	},
	{
		name   = "£100,000",
		icon   = "coins_add",

		func   = tribute.giveMoney,
		amt    = 1e5,
		skew   = 60,
	},
	{
		name   = "£1,000,000",
		icon   = "money",

		func   = tribute.giveMoney,
		amt    = 1e6,
		skew   = 20,
	},
	{
		name   = "£10,000,000",
		icon   = "money_add",

		func   = tribute.giveMoney,
		amt    = 1e7,
		skew   = 5,
	},
	{
		name   = "£100,000,000",
		icon   = "money_pound",

		func   = tribute.giveMoney,
		amt    = 1e7,
		skew   = 5,
	},
}

do
	local total = 0

	for _, v in ipairs(tribute.rewardTable) do
		total = total + v.skew
	end

	tribute.totalSkew = total
end

function tribute.getItem()
	local f = (math.random() * 0.99999999999) + 0.00000000001
	local cF = f * tribute.totalSkew

	for i, v in RandomPairs(tribute.rewardTable) do
		local new = cF - v.skew

		if new <= 0 then
			return i
		end

		cF = new
	end

	error("what the flying fuck", 2)
end

local cache = {}
function tribute.matCache(path)
	if cache[path] then return cache[path] end
	cache[path] = Material(path)
	return cache[path]
end

local namebar_size = 36
function tribute.drawItem(v, x, y, w, h, i)
	surface.SetDrawColor(200, 200, 200, 150)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(160, 160, 160, 15 )
	surface.DrawRect(x, y, w, h)

	local imgs = h * 0.5
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(tribute.matCache("icon16/" .. v.icon .. ".png"))
	surface.DrawTexturedRect(x + w/2 - imgs/2, y + h/2 - imgs/2, imgs * (v.iconAspect or 1), imgs)

	surface.SetDrawColor(0  , 0  , 0  , 95 )
	surface.DrawRect(x + 1, y + h - namebar_size, w - 2, namebar_size - 1)

	draw.SimpleText(v.name, "DermaLarge", x + 8, y + h - namebar_size/2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(i, "DermaLarge", x + 2, y + 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local function movement_func(f, startVal, endVal)
	return Lerp(f, startVal, endVal) -- lerp looks bad
end

function tribute.renderSpin(rand, count, idx, f)
	local w, h = 400, 290
	local spac = 32
	local midH = ScrH() / 2
	local midW = ScrW() / 2

	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawLine(midW, midH + h/2 + 40, midW, midH + h/2 + 10)

	local size = (w + spac) * count
	local iStart = idx * (size / count)
	local x = movement_func(f, -iStart, ScrW())
	print(idx, iStart, size, f)

	for i, v in pairs(rand) do
		tribute.drawItem(v, x, midH - h/2, w, h, i)
		x = x + w + spac
	end
end

function tribute.getRandomizedRewards(itemIndex)
	local a = {}
	local idx = 0
	local c = 0
	for i, v in RandomPairs(tribute.rewardTable) do
		c = c + 1
		a[c] = v

		if i == itemIndex then idx = c end
	end
	return a, c, idx
end

local testSpin = tribute.getItem()
local rand, count, idx = tribute.getRandomizedRewards(testSpin)
local length = 10
local endTime = CurTime() + length
function tribute.testDraw()
	local tween = math.Clamp((endTime - CurTime()) / length, 0, 1)
	tribute.renderSpin(rand, count, idx, tween)
end
hook.Add("HUDPaint", "testdraw_tribute", tribute.testDraw)
