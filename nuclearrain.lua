-- title:  Nuclear Rain
-- author: Kysonn Dela Cerna
-- desc:   can I get uhhh
-- script: lua
-- input: mouse keyboard

STATES={
	STARTMENU="S",
	GAME="G",
	OVER="O",
	CONTROLS="C",
	ITEMS="I",
	HANDBOOK="H",
}

GAMESTATE=STATES.STARTMENU
SCORE=0

function getSpeed()
	local killBonus=player.kill>0 and player.items.yzy*0.5 or 0
	return (player.baseSpeed+0.1*(player.items.sws+player.items.irp))+2*math.log10(player.items.cpb+1)+killBonus
end

function getDamage()
	return math.ceil((player.baseDamage+20*(player.level-1)+25*player.items.bs)*(1+0.1*(player.items.bpc+player.items.irp)))
end

function getHealth()
	return math.ceil((player.baseHealth+40*(player.level-1)+150*(player.items.sc+player.items.irp))*(1+0.2*player.items.ab))/(1+0.25*player.items.ujs)
end

function getCritChance()
	return 0.1*player.items.cr-(0.05*player.items.acl)-(0.05*player.items.ilb)
end

function getCritDamage()
	return player.baseCritDamage*(1+0.1*(player.items.bb+player.items.irp)+0.2*player.items.acl)
end

function getAttackSpeed()
	local killBonus=player.kill>0 and player.items.wxe or 0
	return math.max(1,player.baseAttackSpeed-0.5*(player.items.pc+player.items.irp)-killBonus)
end

function getProjectileSpeed()
	return math.min(10,player.baseProjVel+0.25*player.items.ht)
end

function getProjectileSize()
	return math.min(10,math.ceil(player.baseProjSize+0.5*player.items.hc))
end

function getDamageTaken(p)
	local damage
	if player.invincible>0 or math.random()<0.25*math.log10(player.items.wb+1) then
		damage=0
	else
		damage=math.max(0,p.damage*(2.72^(player.items.ar/-10)))
		damage=damage*(1+0.5*player.items.hov)
	end
	return damage
end

function getMaxShield()
	return (30+150*(player.items.cf+player.items.irp)+50*(player.level-1))*(1+player.items.ujs*2)
end

function getShieldRecharge()
	return 0.5+0.1*(player.items.pa+player.items.irp)
end

function getShieldTimer()
	return math.max(10,180-15*(player.items.pa+player.items.irp))
end

function getDashCharges()
	return player.baseDashCharges+player.items.bup+player.items.irp
end

function getDashDistance()
	return player.baseDashDistance+16*(player.items.ccs+player.items.irp)
end

function getDashCooldown()
	return math.max(10,player.baseDashCooldown-30*player.items.ce)
end

function gainHealth(h)
	local ah=h*(player.items.hov>0 and player.items.hov+1 or 1)
	local excess=player.health+ah-player.maxHealth()
	player.health=math.min(player.maxHealth(),player.health+ah)
	if excess>0 then
		player.barrier=player.barrier+excess*player.items.pss
	end
end

function startGame()
	GAMESTATE=STATES.GAME
	DIFFICULTY=0
	TIME=0
	
	player={
		x=120,
		y=64,
		facing=0,
		sprite=320,
		reload=0,
		baseProjSize=1,
		projSize=getProjectileSize,
		baseProjVel=3,
		projVel=getProjectileSpeed,
		baseAttackSpeed=15,
		attackSpeed=getAttackSpeed,
		baseDamage=20,
		damage=getDamage,
		health=300,
		baseHealth=300,
		maxHealth=getHealth,
		shield=30,
		maxShield=getMaxShield,
		shieldRecharge=getShieldRecharge,
		shieldTimer=getShieldTimer,
		critChance=getCritChance,
		baseCritDamage=2,
		critDamage=getCritDamage,
		deathTimer=120,
		damageTimer=0,
		level=1,
		xp=0,
		baseSpeed=2,
		speed=getSpeed,
		levelUp=0,
		items={
			cpb=0,
			wb=0,
			bpc=0,
			ab=0,
			ps=0,
			cr=0,
			bb=0,
			pc=0,
			ht=0,
			hc=0,
			ar=0,
			cf=0,
			bs=0,
			pa=0,
			sws=0,
			sc=0,
			bcn=0,
			ccs=0,
			ce=0,
			otf=0,
			bup=0,
			php=0,
			dmc=0,
			fos=0,
			prd=0,
			rs=0,
			yzy=0,
			wxe=0,
			emp=0,
			tb=0,
			cbu=0,
			ddg=0,
			fsg=0,
			snc=0,
			has=0,
			ooi=0,
			rvr=0,
			eoo=0,
			bfl=0,
			bfr=0,
			isg=0,
			str=0,
			hvb=0,
			vpb=0,
			lce=0,
			pss=0,
			acl=0,
			ilb=0,
			rsk=0,
			pnd=0,
			hov=0,
			ujs=0,
			pbf=0,
			htt=0,
			tfr=0,
			smm=0,
			dex=0,
			cax=0,
			nou=0,
			sin=1,
			eks=0,
			cog=0,
			irp=0,
			rwt=0,
		},
		dashTimer=0,
		baseDashCharges=1,
		maxDashCharges=getDashCharges,
		dashCharges=1,
		dashAttack=false,
		baseDashDistance=56,
		dashDistance=getDashDistance,
		baseDashCooldown=300,
		dashCooldown=getDashCooldown,
		mr=false,
		color=5,
		invincible=0,
		kill=0,
		barrier=0,
	}
	
	cam.x=0
	cam.y=0
	
	playerProjectiles={}
	particles={}
	enemies={}
	enemyProjectiles={}
	items={}
	chests={}
	popUps={}
end

function openControls()
	GAMESTATE=STATES.CONTROLS
end

function openItems()
	GAMESTATE=STATES.ITEMS
end

function openStartMenu()
	GAMESTATE=STATES.STARTMENU
end

function openHandbook()
	GAMESTATE=STATES.HANDBOOK
end

function openOver()
	GAMESTATE=STATES.OVER
end

function step(v)
	return v[1]*DIFFICULTY//v[2]
end

function linear(f)
	return f*(DIFFICULTY-1)/200
end

menuSelect=1
menuOptions={
	{
		text="New Game",
		action=startGame,
	},
	{
		text="How to Play",
		action=openControls,
	},
	{
		text="Item Compendium",
		action=openItems,
	},
	{
		text="Monster Handbook",
		action=openHandbook,
	},
}
itemSelect=1
itemList={}

particles={}
cam={
	x=0,
	y=0,
}
monsterSelect=1
enemyList={}
enemyDict={
	crystal={
		name="Eldritch Rune",
		sprite=322,
		baseHealth=500,
		baseSpeed=0,
		baseAttackSpeed=7,
		color=2,
		baseProjSize=2,
		baseProjVel=3,
		baseDamage=10,
		baseXp=10,
		growth={
			baseSpeed={step,{0.5,100}},
			baseDamage={linear,30},
			baseHealth={linear,20},
			baseXp={linear,10},
		},
	},
	slime={
		name="Mire Ooze",
		sprite=324,
		baseHealth=300,
		baseSpeed=0.5,
		baseAttackSpeed=30,
		color=9,
		baseProjSize=2,
		baseProjVel=2,
		baseDamage=30,
		baseXp=15,
		growth={
			baseDamage={linear,35},
			baseHealth={linear,10},
			baseProjSize={step,{1,100}},
			baseXp={linear,8},
		},
	},
	sprout={
		name="Mandrake",
		sprite=326,
		baseHealth=100,
		baseSpeed=1.2,
		baseAttackSpeed=5,
		color=4,
		baseProjSize=1,
		baseProjVel=3,
		baseDamage=5,
		baseXp=10,
		growth={
			baseDamage={linear,30},
			baseHealth={linear,7},
			baseXp={linear,8},
		},
	},
	snake={
		name="Python 3.8.6",
		sprite=328,
		baseHealth=150,
		baseSpeed=1.5,
		baseAttackSpeed=40,
		color=1,
		baseProjSize=1,
		baseProjVel=4,
		baseDamage=25,
		baseXp=10,
		growth={
			baseDamage={linear,30},
			baseHealth={linear,5},
			baseXp={linear,10},
		},
	},
	pumpkin={
		name="Bodyless Pumpkin",
		sprite=330,
		baseHealth=340,
		baseSpeed=0.5,
		baseAttackSpeed=35,
		color=4,
		baseProjSize=3,
		baseProjVel=3,
		baseDamage=50,
		baseXp=15,
		growth={
			baseProjSize={step,{1,100}},
			baseDamage={linear,25},
			baseHealth={linear,15},
			baseXp={linear,9},
		},
	},
	imposter={
		name="Academy Dropout",
		sprite=332,
		baseHealth=300,
		baseSpeed=1,
		baseAttackSpeed=15,
		color=2,
		baseProjSize=1,
		baseProjVel=3,
		baseDamage=20,
		baseXp=20,
		growth={
			baseSpeed={step,{0.5,25}},
			baseAttackSpeed={linear,-0.5},
			baseProjSize={step,{1,100}},
			baseProjVel={step,{1,50}},
			baseDamage={linear,15},
			baseHealth={linear,15},
			baseXp={linear,20},
		},
	},
	shade={
		name="Minor Shade",
		sprite=336,
		baseHealth=50,
		baseSpeed=2,
		baseAttackSpeed=10,
		color=0,
		baseProjSize=1,
		baseProjVel=4,
		baseDamage=5,
		baseXp=10,
		growth={
			baseSpeed={step,{1,25}},
			baseDamage={linear,25},
			baseHealth={linear,7},
			baseXp={linear,9},
		},
	},
	computer={
		name="T.H.A.N. OS()",
		sprite=338,
		baseHealth=350,
		baseSpeed=0.5,
		baseAttackSpeed=60,
		color=12,
		baseProjSize=1,
		baseProjVel=7,
		baseDamage=60,
		baseXp=25,
		growth={
			baseDamage={linear,40},
			baseHealth={linear,15},
			baseXp={linear,10},
		},
	},
	rune={
		name="Bound Magic",
		sprite=340,
		baseHealth=500,
		baseSpeed=0,
		baseAttackSpeed=80,
		color=10,
		baseProjSize=3,
		baseProjVel=10,
		baseDamage=70,
		baseXp=25,
		growth={
			baseSpeed={step,{1,100}},
			baseDamage={linear,35},
			baseHealth={linear,30},
			baseXp={linear,11},
		},
	},
	bat={
		name="Viral Hotspot",
		sprite=342,
		baseHealth=40,
		baseSpeed=2,
		baseAttackSpeed=6,
		color=15,
		baseProjSize=1,
		baseProjVel=10,
		baseDamage=10,
		baseXp=10,
		growth={
			baseDamage={linear,25},
			baseHealth={linear,10},
			baseXp={linear,9},
		},
	},
	bugsnax={
		name="Insect-Hors-D'oeuvres",
		sprite=344,
		baseHealth=75,
		baseSpeed=1.5,
		baseAttackSpeed=10,
		color=4,
		baseProjSize=1,
		baseProjVel=5,
		baseDamage=20,
		baseXp=10,
		growth={
			baseDamage={linear,30},
			baseHealth={linear,15},
			baseXp={linear,10},
		},
	},
	butterfly={
		name="Metamorphed Catkin",
		sprite=346,
		baseHealth=30,
		baseSpeed=4,
		baseAttackSpeed=25,
		color=4,
		baseProjSize=2,
		baseProjVel=6,
		baseDamage=10,
		baseXp=15,
		growth={
			baseDamage={linear,20},
			baseHealth={linear,10},
			baseXp={linear,9},
		},
	},
	spider={
		name="Tobey's Fan",
		sprite=348,
		baseHealth=120,
		baseSpeed=0.9,
		baseAttackSpeed=15,
		color=0,
		baseProjSize=1,
		baseProjVel=5,
		baseDamage=20,
		baseXp=10,
		growth={
			baseDamage={linear,20},
			baseHealth={linear,10},
			baseXp={linear,9},
		},
	},
	eye={
		name="Cornea Virus",
		sprite=352,
		baseHealth=100,
		baseSpeed=2,
		baseAttackSpeed=10,
		color=12,
		baseProjSize=3,
		baseProjVel=2,
		baseDamage=50,
		baseXp=10,
		growth={
			baseProjVel={step,{1,50}},
			baseDamage={linear,25},
			baseHealth={linear,15},
			baseXp={linear,11},
		},
	},
}

for k,v in pairs(enemyDict) do
	table.insert(enemyList,k)
end
debuffs={
	fear=506,
	slow=504,
	burn=510,
	stun=508,
	magnify=502,
}
itemDict={
	cpb={
		sprite=256,
		name="Chempunk Beans",
		rarity="Stable",
		color=12,
		desc="Increases total speed",
	},
	wb={
  sprite=257,
  name="Warding Bands",
		rarity="Stable",
		color=12,
		desc="Has a chance to\ncompletely block\nincoming damage",
 },
	bpc={
  sprite=258,
  name="Blackpowder Composite",
		rarity="Stable",
		color=12,
		desc="Increases total damage",
 },
	ab={
  sprite=259,
  name="Alien Breakfast",
		rarity="Stable",
		color=12,
		desc="Increases maximum\nhealth",
 },
	ps={
  sprite=260,
  name="Parasitic Sprouts",
		rarity="Stable",
		color=12,
		desc="Increases experience\ngained from killing\nmonsters",
 },
	cr={
  sprite=261,
  name="Ceremonial Rites",
		rarity="Stable",
		color=12,
		desc="Increases critical\nstrike chance",
 },
	bb={
  sprite=262,
  name="Briarbloom",
		rarity="Stable",
		color=12,
		desc="Increases critical\nstrike damage",
 },
	pc={
  sprite=263,
  name="Plastic Condensator",
		rarity="Stable",
		color=12,
		desc="Decreases reload time",
 },
	ht={
  sprite=264,
  name="Handheld Terminal",
		rarity="Stable",
		color=12,
		desc="Increases projectile\nvelocity",
 },
	hc={
  sprite=265,
  name="Hydrogen Crystals",
		rarity="Stable",
		color=12,
		desc="Increases projectile\nsize",
 },
	ar={
  sprite=266,
  name="Apiaric Roots",
		rarity="Stable",
		color=12,
		desc="Decreases damage taken\nfrom enemy projectiles",
 },
	cf={
  sprite=267,
  name="Contained Frost",
		rarity="Stable",
		color=12,
		desc="Increases total shield\ncapacity",
 },
	bs={
  sprite=268,
  name="Bonesaw",
		rarity="Stable",
		color=12,
		desc="Increases base damage",
	},
	pa={
  sprite=269,
  name="Paraffin Afterburners",
		rarity="Stable",
		color=12,
		desc="Increases shield\nrecharge rate and\ndecreases shield\nrecharge delay",
 },
	sws={
  sprite=270,
  name="Sheer Wool Socks",
		rarity="Stable",
		color=12,
		desc="Increases base movement\nspeed",
 },
	sc={
  sprite=271,
  name="Spritfire Container",
		rarity="Stable",
		color=12,
		desc="Increases base health",
 },
	bcn={
  sprite=272,
  name="Battlecat's Necklace",
		rarity="Stable",
		color=12,
		desc="Gain health on kill",
 },
	ccs={
  sprite=273,
  name="Compressed Coil Spring",
		rarity="Stable",
		color=12,
		desc="Increases dash distance",
 },
	ce={
  sprite=274,
  name="Coca-Energy",
		rarity="Stable",
		color=12,
		desc="Decrease dash cooldown",
 },
	otf={
  sprite=275,
  name="On the Fly",
		rarity="Stable",
		color=12,
		desc="Gain health on dash",
 },
	bup={
  sprite=276,
  name="Backup Plan",
		rarity="Stable",
		color=12,
		desc="Gain an additional\ndash charge",
 },
	php={
		sprite=277,
		name="Phosphorus Pyrotechnics",
		rarity="Alpha",
		color=5,
		desc="Fire multiple\nprojectiles upon\nfinishing a dash",
	},
	dmc={
		sprite=278,
		name="Duskmantle Cloak",
		rarity="Alpha",
		color=5,
		desc="Temporarily become\ninvincible upon dashing",
	},
	fos={
		sprite=279,
		name="Fury of Steel",
		rarity="Alpha",
		color=5,
		desc="Refresh a dash charge\nupon landing a critical\nstrike",
	},
	prd={
		sprite=280,
		name="Priming Detonators",
		rarity="Alpha",
		color=5,
		desc="Monsters explode into\nprojectiles upon dying",
	},
	rs={
		sprite=281,
		name="Reflecting Spectacles",
		rarity="Alpha",
		color=5,
		desc="Your projectiles bounce\noff of walls",
	},
	yzy={
		sprite=282,
		name="Yeezys",
		rarity="Alpha",
		color=5,
		desc="Gain movement speed\nupon killing monsters",
	},
	wxe={
		sprite=283,
		name="Wax Effigy",
		rarity="Alpha",
		color=5,
		desc="Gain attack speed\nupon killing monsters",
	},
	emp={
		sprite=284,
		name="Automated E.M.P.",
		rarity="Alpha",
		color=5,
		desc="Your shield explodes\ninto projectiles\nwhen depleted",
	},
	tb={
		sprite=285,
		name="Temper's Bulwark",
		rarity="Alpha",
		color=5,
		desc="Gain a temporary\nbarrier upon landing a\ncritical strike",
	},
	cbu={
		sprite=286,
		name="Celebratorous Uproar",
		rarity="Alpha",
		color=5,
		desc="Nukes explode upon\nopening",
	},
	ddg={
		sprite=287,
		name="Double-Dose Gummies",
		rarity="Alpha",
		color=5,
		desc="Nukes refresh a dash\ncharge upon opening",
	},
	fsg={
		sprite=288,
		name="Festive Gateau",
		rarity="Alpha",
		color=5,
		desc="Gain additional stats\nupon leveling up",
	},
	snc={
		sprite=289,
		name="Snapper Carapace",
		rarity="Alpha",
		color=5,
		desc="Gain a large barrier\nupon leveling up",
	},
	has={
		sprite=290,
		name="Halting Symbols",
		rarity="Alpha",
		color=5,
		desc="Become temporarily\ninvincible upon\nleveling up",
	},
	ooi={
		sprite=291,
		name="Orb of Illumination",
		rarity="Alpha",
		color=5,
		desc="Nukes give experience\nupon opening",
	},
	rvr={
		sprite=292,
		name="Revitalizing Rosary",
		rarity="Alpha",
		color=5,
		desc="Nukes heal you upon\nopening",
	},
	eoo={
		sprite=293,
		name="Eyes of the Occult",
		rarity="Alpha",
		color=5,
		desc="Projectiles have a\nchance to fear monsters\non hit",
	},
	bfl={
		sprite=294,
		name="Band of Flame",
		rarity="Alpha",
		color=5,
		desc="Projectiles have a\nchance to burn monsters\non hit",
	},
	bfr={
		sprite=295,
		name="Band of Frost",
		rarity="Alpha",
		color=5,
		desc="Projectiles have a\nchance to slow monsters\non hit",
	},
	isg={
		sprite=296,
		name="Inspecting Gadget",
		rarity="Alpha",
		color=5,
		desc="Projectiles slowly\nincrease in damage\nwhen hitting the\nsame target",
	},
	str={
		sprite=297,
		name="Satanic Ritual",
		rarity="Alpha",
		color=5,
		desc="Do more damage to\nmonsters with debuffs",
	},
	hvb={
		sprite=298,
		name="Heavy Bullets",
		rarity="Alpha",
		color=5,
		desc="Projectiles have a\nchance to stun monsters\non hit",
	},
	vpb={
		sprite=299,
		name="Vampiric Blood",
		rarity="Alpha",
		color=5,
		desc="Gain health when\nhitting monsters",
	},
	lce={
		sprite=300,
		name="Leeching Edge",
		rarity="Alpha",
		color=5,
		desc="Gain health upon\nlanding critical\nstrikes",
	},
	pss={
		sprite=301,
		name="Persistent Spiral",
		rarity="Alpha",
		color=5,
		desc="Excess healing is\nconverted into a\nbarrier",
	},
	acl={
		sprite=302,
		name="Acrid Cell",
		rarity="Beta",
		color=10,
		desc="Critical strikes\ndo more damage but\nyou lower critical\nchance",
	},
	ilb={
		sprite=303,
		name="Illegal Bounties",
		rarity="Beta",
		color=10,
		desc="Execute enemies but\nyou have less chance\nto critically strike",
	},
	rsk={
		sprite=304,
		name="Risk Factor",
		rarity="Beta",
		color=10,
		desc="The less health you\nhave, the more damage\nyou deal",
	},
	pnd={
		sprite=305,
		name="Pandemic Blues",
		rarity="Beta",
		color=10,
		desc="When you have no shield\nyou do more damage",
	},
	hov={
		sprite=306,
		name="Honor of Valor",
		rarity="Beta",
		color=10,
		desc="Heal more health\ntake more damage",
	},
	ujs={
		sprite=307,
		name="Unjust Scales",
		rarity="Beta",
		color=10,
		desc="Increases your shield\ndecreases your health",
	},
	pbf={
		sprite=308,
		name="Personal Bubble Force",
		rarity="Beta",
		color=10,
		desc="Shields and barriers\ntake less damage",
	},
	htt={
		sprite=309,
		name="Hateful Thorns",
		rarity="Beta",
		color=10,
		desc="Do more damage when\nyou have a shield",
	},
	tfr={
		sprite=310,
		name="Tornadoforce",
		rarity="Beta",
		color=10,
		desc="Dashing causes next\nattack to do more\ndamage",
	},
	smm={
		sprite=311,
		name="Silvermere Mirror",
		rarity="Gamma",
		color=2,
		desc="Shoot all around you\n",
	},
	dex={
		sprite=312,
		name="Demonic Exterminator",
		rarity="Gamma",
		color=2,
		desc="All shots spread",
	},
	cax={
		sprite=313,
		name="Collecting Axe",
		rarity="Gamma",
		color=2,
		desc="Moving makes you reload\nfaster",
	},
	nou={
		sprite=314,
		name="No U",
		rarity="Gamma",
		color=2,
		desc="Chance to reflect\nincoming bullets",
	},
	sin={
		sprite=315,
		name="The Singularity",
		rarity="Gamma",
		color=2,
		desc="Dashing destroys all\nbullets",
	},
	eks={
		sprite=316,
		name="Electrokinesis",
		rarity="Gamma",
		color=2,
		desc="Doing damage creates\nbarriers",
	},
	cog={
		sprite=317,
		name="Compulsive Gambling",
		rarity="Gamma",
		color=2,
		desc="Wow lucky",
	},
	irp={
		sprite=318,
		name="Irradiating Pearl",
		rarity="Gamma",
		color=2,
		desc="Increase all stats",
	},
	rwt={
		sprite=319,
		name="Rewind Time",
		rarity="Gamma",
		color=2,
		desc="When you die you just\ndon't",
	},
}
commonItems={}
uncommonItems={}
rareItems={}
legendaryItems={}
for k,v in pairs(itemDict) do
	if v.rarity=="Stable" then
		table.insert(commonItems,k)
	end
	if v.rarity=="Alpha" then
		table.insert(uncommonItems,k)
	end
	if v.rarity=="Beta" then
		table.insert(rareItems,k)
	end
	if v.rarity=="Gamma" then
		table.insert(legendaryItems,k)
	end
	table.insert(itemList,k)
end

function popUpInit(t,d,c)
	local p={
		text=t,
		duration=d,
		color=c,
	}
	table.insert(popUps,p)
end

function chestInit()
	local c={}
	local valid=false
	while not valid do
		local x=math.random(1,119)*8
		local y=math.random(1,84)*8
		if checkFlag(x,y,0,0,0,0) then
			local overlap=false
			for k,v in pairs(chests) do
				if v.x==x and v.y==y then
					overlap=true
					break
				end
			end
			if not overlap then
				valid=true
				c.x=x
				c.y=y
			end
		end
	end
	c.despawn=3000
	c.open=0
	c.sacrifice=math.ceil(DIFFICULTY)*2+1
	c.sprite=350
	c.color=5
	table.insert(chests,c)
	particlePop(c,20,4)
end

function impaired(e)
	return e.fear>0 or e.burn>0 or e.slow>0 or e.stun>0 or e.magnify>1
end

function enemyInit(t)
	local e={
		sprite=t.sprite,
		baseHealth=t.baseHealth,
		baseSpeed=t.baseSpeed,
		baseAttackSpeed=t.baseAttackSpeed,
		color=t.color,
		baseProjSize=t.baseProjSize,
		baseProjVel=t.baseProjVel,
		angle=math.random()*6.28,
		reload=20,
		baseDamage=t.baseDamage,
		spawn=0,
		despawn=300,
		baseXp=t.baseXp,
	}
	for k,v in pairs(t.growth) do
		if v[1]==step then
			e[k]=e[k]+step(v[2])
		end
		if v[1]==linear then
			e[k]=e[k]*(1+linear(v[2]))
		end
	end
	e.fear=0
	e.burn=0
	e.slow=0
	e.magnify=1
	e.stun=0
	e.maxHealth=e.baseHealth
	return e
end

function randItem()
	local maxr=0
	for i=0,player.items.cog do
		local r=math.random()
		if r>maxr then
			maxr=r
		end
	end
	local i={}
	local type
	if maxr<0.5 then
		type=commonItems[math.random(1,#commonItems)]
	else
		if maxr<0.85 then
			type=uncommonItems[math.random(1,#uncommonItems)]
		else
			if maxr<0.95 then
				type=rareItems[math.random(1,#rareItems)]
			else
				type=legendaryItems[math.random(1,#legendaryItems)]
			end
		end
	end
	i=itemDict[type]
	i.type=type
	return i
end

function itemInit(x,y)
	local r=randItem()
	local i={
		x=x,
		y=y,
		despawn=3000,
		sprite=r.sprite,
		type=r.type,
		rarity=r.rarity,
		color=r.color,
	}
	table.insert(items,i)
end

function projectileInit(x,y,a,v,c,r,s,b,d)
	local p={
		x=x,
		y=y,
		angle=a,
		vel=v,
		color=c,
		r=r,
		steps=s,
		bounce=b,
		damage=d,
	}
	return p
end

function particleInit(x,y,angle,steps,color)
	local p={
		x=x,
		y=y,
		angle=angle,
		steps=steps,
		color=color,
	}
	return p
end

function getMouseAngle()
	local mx,my=mouse()
	return math.atan(my-player.y+4-cam.y,mx-player.x+4-cam.x)
end

function getPlayerParticle(angle)
	local c={
		x=player.x+(10+player.projSize())*math.cos(angle)+4,
		y=player.y+(10+player.projSize())*math.sin(angle)+4,
	}
	return c
end

function drawPlayer()
	if player.levelUp>0 then
		local x=player.x+(30-player.levelUp)//5-1
		local y=player.y+8
		rect(x+cam.x,cam.y,10-((30-player.levelUp)//5*2),y,4)
		player.levelUp=player.levelUp-1
	end
	if player.health>0 then
		spr(player.sprite+time()//256%2,player.x+cam.x,player.y+cam.y,6,1,player.facing,0,1,1)
		local angle=getMouseAngle()
		local arc=6.28/(player.items.smm+1)
		for i=0,player.items.smm do
			local offset=arc*i
			local c=getPlayerParticle(angle+offset)
			drawProjectile(c.x,c.y,player.projSize(),5)
		end
	else
		if player.deathTimer>90 then
			spr(player.sprite,player.x+cam.x,player.y+cam.y,6,1,player.facing,0,1,1)
		end
		if player.deathTimer==90 then
			sfx(4,'C-1',29)
		end
		if player.deathTimer<90 and player.deathTimer>60 then
			if math.random()<0.5 then
				local r=math.random(10,100)
				particlePop(player,r,4)
			end
		end
		player.deathTimer=player.deathTimer-1
	end
end

function checkFlag(x,y,velx,vely,off,f)
	--f=0 -> can't pass
	--f=1 -> can't shoot through
	return	not (fget(mget((x+velx)//8,(y+vely)//8),f) or
		           fget(mget((x+off+velx)//8,(y+vely)//8),f) or
													fget(mget((x+velx)//8,(y+off+vely)//8),f) or
													fget(mget((x+off+velx)//8,(y+off+vely)//8),f))
end

function neededXP(l)
	return math.ceil(30*1.5^(l-1))
end

function playerProjectileInit(p,a)
	local vel=player.projVel()
	local r=player.projSize()
	local color=player.color
	local steps=120
	local bounce=player.items.rs*5
	local damage=player.damage()
	table.insert(playerProjectiles,projectileInit(p.x,p.y,a,vel,color,r,steps,bounce,damage))
end

function explode(p,o,n)
	local po={
		x=p.x+o,
		y=p.y+o,
	}
	for i=1,n do
		local angle=math.random()*6.28
		playerProjectileInit(p,angle)
	end
end

function refreshDash(n)
	local md=player.maxDashCharges()
	if player.dashCharges<md then
		for i=1,n do
			player.dashCharges=player.dashCharges+1
			if player.dashCharges>=md then
				player.dashTimer=0
				break
			end
		end
	end
end

function updatePlayer()
	if player.health>0 then
		local need=neededXP(player.level)
		if player.xp>=need then
			player.xp=player.xp-need
			player.level=player.level+1
			player.health=player.maxHealth()
			player.levelUp=30
			player.baseHealth=player.baseHealth+player.items.fsg*50
			player.baseDamage=player.baseDamage+player.items.fsg*30
			player.baseSpeed=player.baseSpeed+player.items.fsg*0.05
			player.barrier=player.barrier+300*player.items.snc
			player.invincible=player.invincible+60*player.items.has
			sfx(2,'B-5',6,2,15,0)
		end
		if player.damageTimer>=player.shieldTimer() then
			player.shield=math.min(player.shield+player.shieldRecharge(),player.maxShield())
		end
		local speed=player.speed()
		local dx=false
		local dy=false
		local mx=0
		local my=0
		local ax=0
		local ay=0
		if btn(0) or btn(1) then
			dy=true
			my=speed
		end
		if btn(2) or btn(3) then
			dx=true
			mx=speed
		end
		if dx and dy then
			mx=mx*0.71
			my=my*0.71
		end
		if btn(1) then
			ay=1
		else
			if btn(0) then
				ay=-1
			end
		end
		if btn(3) then
			ax=1
		else
			if btn(2) then
				ax=-1
			end
		end
		if dx or dy then
			player.reload=player.reload-player.items.cax
		end
		while my>0 do
			local vely=my>1 and ay or ay*my
			if checkFlag(player.x,player.y,0,vely,7,0) then
				player.y=player.y+vely
			else
				break
			end
			if my>1 then
				my=my-1
			else
				my=0
			end
		end
		while mx>0 do
			local velx=mx>1 and ax or ax*mx
			if checkFlag(player.x,player.y,velx,0,7,0) then
				player.x=player.x+velx
			else
				break
			end
			if mx>1 then
				mx=mx-1
			else
				mx=0
			end
		end
		
		local mx,my,ml,mm,mr=mouse()
		if mx<=player.x+cam.x then
			player.facing=1
		else
			player.facing=0
		end
		
		if ml and player.reload<=0 then
			local angle=getMouseAngle()
			local arc=6.28/(player.items.smm+1)
			for i=0,player.items.smm do
				local offset=arc*i
				local c=getPlayerParticle(angle+offset)
				playerProjectileInit(c,angle+offset)
				for i=1,player.items.dex*2 do
					local r=math.random()*0.79-0.39
					local sc=getPlayerParticle(angle+offset+r)
					playerProjectileInit(sc,angle+offset+r)
				end
			end
			player.reload=player.attackSpeed()
			sfx(0,46,7,0,15,0)
		end
		
		if mr and (not player.mr) and player.dashCharges>0 then
			local ox=player.x+4
			local oy=player.y+4
			local m={
				x=mx-cam.x,
				y=my-cam.y,
			}
			local maxd=player.dashDistance()
			local	moused=distance(player,m,4)
			local d=math.min(maxd,moused)
			local wallClip=moused<maxd and (not checkFlag(m.x-4,m.y-4,0,0,7,0))
			local angle=getMouseAngle()
			local valid=false
			player.dashAttack=true
			if player.items.sin>0 then
				for i,p in pairs(enemyProjectiles) do
					particlePop(p,4,0)
					table.remove(enemyProjectiles,i)
				end
				for i,p in pairs(enemies) do
					p.reload=60
				end
				sfx(7,"C-2",7,1)
			end
			while not valid and d>0 do
				local nx=ox+d*math.cos(angle)
				local ny=oy+d*math.sin(angle)
				if checkFlag(nx-4,ny-4,0,0,7,0) then
				 if player.dashTimer<=0 then
						player.dashTimer=player.dashCooldown()
					end
					player.dashCharges=player.dashCharges-1
					valid=true
					particlePop(player,5,4)
					player.x=nx-4
					player.y=ny-4
					particlePop(player,60,4)
					gainHealth(30*player.items.otf)
					explode(player,4,player.items.php*3)
					player.invincible=player.invincible+30*player.items.dmc
					sfx(5,'B-4',9,0)
				end
				if wallClip then
					d=d+0.05
					if d>maxd then
						wallClip=false
					end
				else
					d=d-0.05
				end
			end
		end
		
		if mr~=player.mr then
			player.mr=not player.mr
		end
		
		player.dashTimer=player.dashTimer-1
		if player.dashTimer<=0 and player.dashCharges<player.maxDashCharges() then
			player.dashCharges=player.dashCharges+1
			if player.dashCharges<player.maxDashCharges() then
				player.dashTimer=player.dashCooldown()
			end
		end
		player.reload=player.reload-1
		player.kill=player.kill-1
		if player.invincible>0 then
			player.invincible=player.invincible-1
		end
		if player.barrier>0 then
			player.barrier=player.barrier-1
		end
	end
	if player.deathTimer<=0 then
		SCORE=math.ceil(DIFFICULTY)
		openOver()
		particles={}
		cam.x=0
		cam.y=0
	end
end

function particleHit(p,n,off)
	for j=1,n do
		local angle=p.angle+(math.random()*4.20)-5.24
		local x=p.x+off
		local y=p.y+off
		local color=p.color
		local steps=math.random(5,20)
		table.insert(particles,particleInit(x,y,angle,steps,color))
	end
end

function particlePop(p,n,off)
	for j=1,n do
		local angle=math.random()*6.28
		local x=p.x+off
		local y=p.y+off
		local color=p.color
		local steps=math.random(5,20)
		table.insert(particles,particleInit(x,y,angle,steps,color))
	end
end

function sign(x)
	if x>0 then
		return 1
	else
		if x<0 then
			return -1
		else
			return 0
		end
	end
end

function updateProjectiles()
	for i,p in pairs(playerProjectiles) do
		local velx=p.vel*math.cos(p.angle)
		local vely=p.vel*math.sin(p.angle)
		if not checkFlag(p.x+velx,p.y+vely,sign(velx)*p.r,sign(vely)*p.r,0,1) then
			if p.bounce>0 then
				p.bounce=p.bounce-1
				p.angle=p.angle+3.14
			else
				particleHit(p,4,0)
				table.remove(playerProjectiles,i)
			end
		else
			if p.steps<=0 then
				particlePop(p,4,0)
				table.remove(playerProjectiles,i)
			else
				local hit=false
				local e=nil
				for k,v in pairs(enemies) do
					if distance(v,p,4)<=p.r+5.66 then
						hit=true
						e=v
						break
					end
				end
				if hit then
					local crit=math.random(100)<player.critChance()*100 and player.critDamage() or 1
					local fear=math.random(100)<player.items.eoo*10
					local burn=math.random(100)<player.items.bfl*10
					local slow=math.random(100)<player.items.bfr*10
					local stun=math.random(100)<player.items.hvb*10
					local impairedDamage=impaired(e) and player.items.str*0.5+1 or 1
					local damage=p.damage*crit*e.magnify*impairedDamage
					if fear then
						e.fear=player.items.eoo*60
					end
					if burn then
						e.burn=player.items.bfl*60
					end
					if slow then
						e.slow=player.items.bfr*60
					end
					if stun then
						e.stun=player.items.hvb*30
					end
					if crit>1 then
						refreshDash(player.items.fos)
						player.barrier=player.barrier+player.items.tb*100
						gainHealth(0.1*player.items.lce*damage)
					end
					
					--bonus
					if player.items.rsk>0 then
						damage=damage*(player.maxHealth()-player.health)/player.maxHealth()*player.items.rsk
					end
					if player.items.pnd>0 and player.shield<=0 then
						damage=damage*2*player.items.pnd
					end
					if player.items.htt>0 and player.shield>0 then
						damage=damage*3*player.items.htt
					end
					if player.dashAttack then
						player.dashAttack=false
						damage=damage*(2+player.items.tfr)
					end
					player.barrier=player.barrier+(damage*player.items.eks)
					
					e.baseHealth=e.baseHealth-(damage)
					
					if e.baseHealth<=player.items.ilb*0.1*e.maxHealth then
						e.baseHealth=0
					end
					
					e.magnify=e.magnify+0.05*player.items.isg
					gainHealth(10*player.items.vpb)
					particleHit(p,4,0)
					table.remove(playerProjectiles,i)
				else
					p.x=p.x+velx
					p.y=p.y+vely
					p.steps=p.steps-1
				end
			end
		end
	end
	
	local playerHit=false
	for i,p in pairs(enemyProjectiles) do
		local velx=p.vel*math.cos(p.angle)
		local vely=p.vel*math.sin(p.angle)
		if not checkFlag(p.x,p.y,sign(velx)*p.r,sign(vely)*p.r,0,1) then
			particleHit(p,4,0)
			table.remove(enemyProjectiles,i)
		else
			if p.steps<=0 then
				particlePop(p,4,0)
				table.remove(enemyProjectiles,i)
			else
				if distance(player,p,4)<=p.r+5.66 then
					local reflect=math.random()
					if reflect<=player.items.nou*0.1 then
						local angle=p.angle+3.14
						local c={
							x=p.x,
							y=p.y
						}
						playerProjectileInit(c,angle)
						table.remove(enemyProjectiles,i)
						sfx(6,"A-6",2,1)
					else
						local damage=getDamageTaken(p)
						if player.barrier>0 and damage>0 then
							damage=damage/(1+player.items.pbf)
							if player.barrier<=damage then
								damage=damage-player.barrier
								player.barrier=0
							else
								player.barrier=player.barrier-damage
								damage=0
							end
						end
						if player.shield>0 and damage>0 then
							damage=damage/(1+player.items.pbf)
							if player.shield<=damage then
								damage=damage-player.shield
								player.shield=0
								explode(player,4,3*player.items.emp)
							else
								player.shield=player.shield-damage
								damage=0
							end
						end
						player.health=player.health-damage
						
						if player.health<0 and player.items.rwt>0 then
							sfx(13,"C-1",13,1)
							player.items.rwt=player.items.rwt-1
							player.health=player.maxHealth()
							player.shield=player.maxShield()
							player.barrier=player.maxHealth()
							for i,p in pairs(enemies) do
								p.reload=30
							end
						end
						
						particleHit(p,4,0)
						table.remove(enemyProjectiles,i)
						playerHit=true
					end
				else
					p.x=p.x+velx
					p.y=p.y+vely
					p.steps=p.steps-1
				end
			end
		end
	end
	if playerHit then
		player.damageTimer=0
	else
		player.damageTimer=player.damageTimer+1
	end
end

function drawProjectile(x,y,r,color)
	circ(x+cam.x,y+cam.y,r,color)
end

function drawProjectiles()
	for k,v in pairs(playerProjectiles) do
		drawProjectile(v.x,v.y,v.r,v.color)
	end
	for k,v in pairs(enemyProjectiles) do
		drawProjectile(v.x,v.y,v.r,v.color)
	end
end

function updateParticles()
	for i,p in ipairs(particles) do
		p.x=p.x+math.cos(p.angle)
		p.y=p.y+math.sin(p.angle)
		p.steps=p.steps-1
		if p.steps<= 0 then
			table.remove(particles,i)
		end
	end
end

function drawParticles()
	for k,p in pairs(particles) do
		rect(p.x+cam.x,p.y+cam.y,1,1,p.color)
	end
end

function distance(a,b,off)
	return math.abs(a.x-b.x+off)+math.abs(a.y-b.y+off)
end

function updateEnemies()
	for i,e in ipairs(enemies) do
		if e.burn>0 then
			e.baseHealth=e.baseHealth-player.items.bfl
		end
		if e.spawn>=20 then
			local dist=distance(e,player,0)
			if dist<=255 then
				e.despawn=900
				if e.baseHealth<=0 then
					player.xp=player.xp+e.baseXp*(1+0.5*player.items.ps)
					particlePop(e,10,4)
					explode(e,4,player.items.prd*3)
					player.kill=60
					gainHealth(30*player.items.bcn)
					table.remove(enemies,i)
					for k,v in pairs(chests) do
						if distance(e,v,0)<255 then
							v.sacrifice=v.sacrifice-1
							particlePop(v,10,4)
						end
					end
				else
					if dist<=11.32 then
						player.health=player.health-1
					end	
					if e.stun<=0 then
						local slow=e.slow>0 and math.max(0.05,1-player.items.bfr*0.25) or 1
						local feared=e.fear>0
						local angle=feared and getPlayerAngle(e.x,e.y)+3.14 or e.angle
						local velx=e.baseSpeed*slow*math.cos(angle)
						local vely=e.baseSpeed*slow*math.sin(angle)
						if checkFlag(e.x,e.y,velx,vely,7,0) then
							e.x=e.x+velx
							e.y=e.y+vely
						end
						e.angle=e.angle+(math.random()*1.57-0.79)
						if e.angle>6.28 then
							e.angle=e.angle-6.28
						end
						if e.angle<0 then
							e.angle=e.angle+6.28
						end
						if e.reload<=0 and not feared then
							local angle=getPlayerAngle(e.x,e.y)
							local c=getEnemyParticle(e,angle)
							local damage=e.baseDamage
							table.insert(enemyProjectiles,projectileInit(c.x,c.y,angle,e.baseProjVel,e.color,e.baseProjSize,120,0,damage))
							e.reload=e.baseAttackSpeed
							sfx(0,24,7,1,15,0)
						end
						e.reload=e.reload-1
					end
				end
			else
				e.despawn=e.despawn-1
				if e.despawn<=0 then
					table.remove(enemies,i)
				end
			end
		else
			e.spawn=e.spawn+1
		end
		e.fear=e.fear-1
		e.burn=e.burn-1
		e.slow=e.slow-1
		e.stun=e.stun-1
	end
end

function getPlayerAngle(x,y)
	return math.atan(player.y-y,player.x-x)
end

function getEnemyParticle(e,angle)
	local c={
		x=e.x+(10+e.baseProjSize)*math.cos(angle)+4,
		y=e.y+(10+e.baseProjSize)*math.sin(angle)+4,
	}
	return c
end

function drawEnemies()
	for	k,e in pairs(enemies) do
		local facing=0
		if e.spawn<20 then
			local x=e.x+e.spawn//5
			local y=e.y+8
			rect(x+cam.x,cam.y,8-(e.spawn//5*2),y,e.color)
		end
		if e.x>player.x then
			facing=1
		end
		local x=e.x+cam.x
		local y=e.y+cam.y
		spr(e.sprite+time()//256%2,x,y,6,1,facing,0,1,1)
		if e.fear>0 then
			spr(debuffs.fear+time()//256%2,x,y-5,0,1,facing)
		end
		if e.burn>0 then
			spr(debuffs.burn+time()//256%2,x,y,0,1,facing)
		end
		if e.slow>0 then
			spr(debuffs.slow+time()//256%2,x,y,0,1,facing)
		end
		if e.stun>0 then
			spr(debuffs.stun+time()//256%2,x,y-5,0,1,facing)
		end
		if e.magnify>1 then
			spr(debuffs.magnify+time()//256%2,x,y-2,0,1,facing)
		end
		local angle=getPlayerAngle(e.x,e.y)
		local c=getEnemyParticle(e,angle)
		drawProjectile(c.x,c.y,e.baseProjSize,e.color)
		if e.baseHealth<e.maxHealth then
			rect(e.x+cam.x,e.y-2+cam.y,1+7*(e.baseHealth/e.maxHealth),1,e.color)
		end
	end
end

function digits(n)
	if n<=0 then
		return 1
	else
		return math.floor(math.log10(n))+1
	end
end

function HUD()
	local d=math.ceil(DIFFICULTY)
	local need=neededXP(player.level)
	local have=player.xp>need and need or player.xp
	local totalShield=player.maxShield()
	local totalHealth=player.maxHealth()
	local effectiveHealth=totalHealth+totalShield+player.barrier
	local healthBar=math.ceil(60*player.health/effectiveHealth)
	local shieldBar=math.floor(60*player.shield/effectiveHealth)
	local barrierBar=math.floor(60*player.barrier/effectiveHealth)
	local dcd=player.dashCooldown()
	local dx=0
	local hc=player.invincible>0 and 8 or 2
	
	print("HP",0,0,12,true)
	rectb(13,0,62,5,12)
	rect(14,1,healthBar,3,hc)
	rect(14+healthBar,1,shieldBar,3,10)
	rect(14+healthBar+shieldBar,1,barrierBar,3,4)
	print("LV",0,6,12,true)
	print(player.level,18,6,12,true)
	rectb(37,6,38,3,12)
	rect(38,7,36*have/need,1,10)
	if player.dashTimer>0 then
		rect(0,15,75*player.dashTimer/dcd,2,12)
	end
	for i=1,player.dashCharges do
		rect(dx,12,2,2,12)
		dx=dx+3
	end
	print("DIFFICULTY:",174-digits(d)*6,0,12,true)
	print(d,240-digits(d)*6,0,12,true)
	local ix=0
	local iy=121
	for k,v in pairs(player.items) do
		local sprite=itemDict[k].sprite
		for i=1,v do
			spr(sprite,ix,iy,1)
			ix=ix+1
			if ix>=233 then
				ix=0
				iy=iy+1
			end
		end
	end
	if #popUps>0 then
		local popUp=popUps[1]
		local x=120-string.len(popUp.text)*3
		local y=114
		print(popUp.text,x+1,y+1,0,true)
		print(popUp.text,x,y,popUp.color,true)
		popUp.duration=popUp.duration-1
		if popUp.duration<=0 then
			table.remove(popUps,1)
		end
	end
end

function lerp(a,b,t)
	return (1-t)*a+t*b
end

function drawMap()
	cam.x=lerp(cam.x,120-player.x,0.07)
	cam.y=lerp(cam.y,64-player.y,0.07)
	cam.x=math.min(0,cam.x)
	cam.y=math.min(0,cam.y)
	cam.x=math.max(-719,cam.x)
	cam.y=math.max(-543,cam.y)
	local ccx=cam.x/8+(cam.x%8==0 and 1 or 0)
	local ccy=cam.y/8+(cam.y%8==0 and 1 or 0)
	map(-ccx,-ccy,31,18,cam.x%8-8,cam.y%8-8)
end

function handleChestSpawn()
	if #chests<DIFFICULTY//5+1 then
		chestInit()
	end
end

function updateChests()
	for k,v in pairs(chests) do
		if distance(v,player,0)<285 then
			v.despawn=3000
			if v.sacrifice<=0 then
				table.remove(chests,k)
				explode(v,4,player.items.cbu*5)
				refreshDash(player.items.ddg)
				player.xp=player.xp+100*player.items.ooi
				gainHealth(50*player.items.rvr)
				itemInit(v.x,v.y)
				sfx(3,'B-3',6,2)
			end
		else
			v.despawn=v.despawn-1
			if v.despawn==0 then
				table.remove(chests,k)
			end
		end
	end
end

function updateItems()
	for k,v in pairs(items) do
		v.despawn=v.despawn-1
		if v.despawn<0 then
			table.remove(items,k)
		end
		if distance(player,v,0)<11.52 then
			particlePop(v,10,4)
			player.items[v.type]=player.items[v.type]+1
			popUpInit(itemDict[v.type].name,90,v.color)
			table.remove(items,k)
		end
	end
end

function drawItems()
	for k,i in pairs(items) do
		particlePop(i,1,4)
		spr(i.sprite,i.x+cam.x,i.y+cam.y,1)
	end
end

function drawChests()
	for k,c in pairs(chests) do
		local x=c.x+cam.x+4-digits(c.sacrifice)*3
		local y=c.y-7+cam.y
		print(c.sacrifice,x,y,12,true)
		spr(c.sprite+time()//512%2,c.x+cam.x,c.y+cam.y,1)
	end
end

function handleEnemySpawn()
	local rand=math.random(0,250)
	if rand<DIFFICULTY then
		if #enemies<math.min(DIFFICULTY,100) then
			local r=math.random(1,#enemyList)
			local e=enemyInit(enemyDict[enemyList[r]])
			local valid=false
			while not valid do
				local od=math.random(64,96)
				local oa=math.random()*6.28
				e.x=math.floor(player.x+od*math.cos(oa))
				e.y=math.floor(player.y+od*math.sin(oa))
				if checkFlag(e.x,e.y,0,0,7,0) then
					valid=true
				end
			end
			sfx(4,'A-2',8,1)
			table.insert(enemies,e)
		end
	end
end

function updateDifficulty()
	TIME=TIME+1
	local SEC=math.max(1,TIME//60)
	local n=40
	local o=0
	if SEC>=300 and SEC<600 then
		n=30
		o=2
	end
	if SEC>=600 and SEC<900 then
		n=20
		o=11
	end
	if SEC>=900 and SEC<1200 then
		n=10
		o=55
	end
	if SEC>=1200 then
		n=5
		o=173
	end
	
	DIFFICULTY=SEC/n-0
end

function rain()
	if math.random()<0.1 then
		local p=particleInit(math.random(0,240),0,math.random()*0.34+1.4,300,5)
		table.insert(particles,p)
	end
	updateParticles()
	drawParticles()
end

function TIC()
	if GAMESTATE==STATES.STARTMENU then
		map(210,119,30,17,0,0)
		print("NUCLEAR",59,42,15,true,3)
		print("RAIN",86,58,15,true,3)
		print("NUCLEAR",57,40,12,true,3)
		print("RAIN",84,56,12,true,3)
		for i,v in ipairs(menuOptions) do
			local t=v.text
			local x=120-string.len(t)*3
			local y=88+7*i
			print(t,x,y,12,true)
			if i==menuSelect then
				spr(334,x-9,y-1)
			end
		end
		rain()
		if btnp(1) and menuSelect<#menuOptions then
			menuSelect=menuSelect+1
			sfx(2,'B-2',7)
		end
		if btnp(0) and menuSelect>1 then
			menuSelect=menuSelect-1
			sfx(2,'A-2',7)
		end
		if btnp(4) then
			menuOptions[menuSelect].action()
			sfx(3,'B-2',8)
		end
	end
	if GAMESTATE==STATES.CONTROLS then
		map(180,119,30,17,0,0)
		print("MOVE UP",57,17,12,true)
		print("MOVE DOWN",141,17,12,true)
		print("MOVE LEFT",45,33,12,true)
		print("MOVE RIGHT",141,33,12,true)
		print("CONFIRM",57,49,12,true)
		print("CANCEL",141,49,12,true)
		print("AIM",111,82,12,true)
		print("SHOOT",77,69,12,true)
		print("DASH",133,69,12,true)
		print("Shoot and don't get shot",48,100,12,true)
		print("Sacrifice monsters to nukes",39,110,12,true)
		print("to receive items",72,117,12,true)
		rain()
		if btnp(5) then
			openStartMenu()
			sfx(4,'A-2',7)
		end
	end
	if GAMESTATE==STATES.ITEMS then
		map(150,119,30,17,0,0)
		local moreRight=itemSelect<#itemList
		local moreLeft=itemSelect>1
		local i=itemDict[itemList[itemSelect]]
		spr(i.sprite,48,40,1,7)
		print(i.name,120,34,12,true,1,true)
		print("Rarity:",120,46,12,true,1,true)
		print(i.rarity,150,46,i.color,true,1,true)
		print("Description:",120,58,12,true,1,true)
		print(i.desc,120,65,12,true,1,true)
		if moreRight then
			spr(100,216,60,0,1,0,0,1,2)
		end
		if moreLeft then
			spr(99,16,60,0,1,0,0,1,2)
		end
		rain()
		if btnp(3) and moreRight then
			itemSelect=itemSelect+1
			sfx(2,'B-2',7)
		end
		if btnp(2) and moreLeft then
			itemSelect=itemSelect-1
			sfx(2,'A-2',7)
		end
		if btnp(5) then
			openStartMenu()
			sfx(4,'A-2',7)
		end
	end
	if GAMESTATE==STATES.HANDBOOK then
		map(120,119,30,17,0,0)
		local moreRight=monsterSelect<#enemyList
		local moreLeft=monsterSelect>1
		local m=enemyDict[enemyList[monsterSelect]]
		spr(m.sprite+time()//256%2,48,40,6,7)
		print(m.name,120,34,12,true,1,true)
		print("Base Stats:",120,46,12,true,1,true)
		print(" Health:",120,53,12,true,1,true)
		print(m.baseHealth,152,53,12,true,1,true)
		print(" Speed:",120,60,12,true,1,true)
		print(m.baseSpeed,148,60,12,true,1,true)
		print(" Attack Speed:",120,67,12,true,1,true)
		print(tonumber(string.format("%.2f", m.baseAttackSpeed/60)),176,67,12,true,1,true)
		print(" Projectile Size:",120,74,12,true,1,true)
		print(m.baseProjSize,188,74,12,true,1,true)
		print(" Projectile Speed:",120,81,12,true,1,true)
		print(m.baseProjVel,192,81,12,true,1,true)
		print(" Damage:",120,88,12,true,1,true)
		print(m.baseDamage,152,88,12,true,1,true)
		print(" Experience:",120,95,12,true,1,true)
		print(m.baseXp,168,95,12,true,1,true)
		if moreRight then
			spr(100,216,60,0,1,0,0,1,2)
		end
		if moreLeft then
			spr(99,16,60,0,1,0,0,1,2)
		end
		rain()
		if btnp(3) and moreRight then
			monsterSelect=monsterSelect+1
			sfx(2,'B-2',7)
		end
		if btnp(2) and moreLeft then
			monsterSelect=monsterSelect-1
			sfx(2,'A-2',7)
		end
		if btnp(5) then
			openStartMenu()
			sfx(4,'A-2',7)
		end
	end
	if GAMESTATE==STATES.GAME then
		poke(0x3FFB,0x4F)
		drawMap()
		if player.health>0 then
			handleChestSpawn()
			updateChests()
			updateItems()
			updateProjectiles()
			updateEnemies()
			updateDifficulty()
			handleEnemySpawn()
		end
		updatePlayer()
		updateParticles()
		drawChests()
		drawItems()
		drawEnemies()
		drawParticles()
		drawProjectiles()
		drawPlayer()
		HUD()
	end
	if GAMESTATE==STATES.OVER then
		map(90,119,30,17,0,0)
		print("RADIOACTIVE",23,45,15,true,3)
		print("MELTDOWN",50,61,15,true,3)
		print("RADIOACTIVE",21,43,12,true,3)
		print("MELTDOWN",48,59,12,true,3)
		local space=print("FINAL SCORE:",84-digits(SCORE)*3,95,12,true)
		print(SCORE,84-digits(SCORE)*3+space,95,12,true)
		rain()
		if btnp(5) or btnp(4) then
			openStartMenu()
			sfx(4,'A-2',7)
		end
	end
end
