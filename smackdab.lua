-- title:  SmackDab
-- author: Kysonn Dela Cerna
-- desc:   Dab on the haters
-- script: lua
-- saveid: smackdab

jumpSpeed=6
fallSpeed=3
moveSpeed=4

gameState="title"
menuSelect=0
endSelect=0

deathParticles={}
particleColors={3,4,5,6,7,8,9}
screenShake=0

gameStartCount=0
gameEndCount=0

playMusic=false

winner=0

p1={
	x=40,
	y=8,
	facing=0,
	grounded=true,
	state="idle",
	jump=0,
	SPR={
		IDLE=256,
		RUN=260,
		BLOCK=294,
		JUMP_START=288,
		JUMP=268,
		FALL=290,
		DAB_START=300,
		DAB=302,
		HURT=296,
		CLAP=320,
		INDICATOR=324,
	},
	BTN={
		MOVE_LEFT=2,
		MOVE_RIGHT=3,
		JUMP=0,
		BLOCK=1,
		DAB=4,
	},
	channel=1,
	stock=3,
	damage=0,
	draw_stock={x=38,y=116,s_bg=128,s_st=132,},
 canMove=false,
	dabCooldown=0,
	number=1,
	blockCooldown=0,
}

p2={
	x=199,
	y=8,
	facing=1,
	grounded=true,
	state="idle",
	jump=0,
	SPR={
		IDLE=384,
		RUN=388,
		BLOCK=422,
		JUMP_START=416,
		JUMP=396,
		FALL=418,
		DAB_START=428,
		DAB=430,
		HURT=424,
		CLAP=448,
		INDICATOR=452,
	},
	BTN={
		MOVE_LEFT=10,
		MOVE_RIGHT=11,
		JUMP=8,
		BLOCK=9,
		DAB=12,
	},
	channel=2,
	stock=3,
	damage=0,
	draw_stock={x=158,y=116,s_bg=130,s_st=133,},
	canMove=false,
	dabCooldown=0,
	number=2,
	blockCooldown=0,
}

p1.other=p2
p2.other=p1

function renderPlayer(p)
	if p.state=="idle" then
        spr(p.SPR.IDLE+time()//256%2*2,p.x-8,p.y-8,6,1,p.facing,0,2,2)
	end
	if p.state=="run" then
	    spr(p.SPR.RUN+time()//128%4*2,p.x-8,p.y-8,6,1,p.facing,0,2,2)
	end
	if p.state=="block" then
		spr(p.SPR.BLOCK,p.x-8,p.y-8,6,1,p.facing,0,2,2)
	end
	if p.state=="fall" then
		spr(p.SPR.FALL+time()//256%2*2,p.x-8,p.y-8,6,1,p.facing,0,2,2)
	end
	if p.state=="jump" then
		if btnp(p.BTN.JUMP) then
			spr(p.SPR.JUMP_START,p.x-8,p.y-8,6,1,p.facing,0,2,2)
		else
			spr(p.SPR.JUMP+time()//256%2*2,p.x-8,p.y-8,6,1,p.facing,0,2,2)
		end
	end
	if p.state=="dab" then
		if btnp(p.BTN.DAB) then
			spr(p.SPR.DAB_START,p.x-8,p.y-8,6,1,p.facing,0,2,2)
		else
			spr(p.SPR.DAB,p.x-8,p.y-8,6,1,p.facing,0,2,2)
		end
	end
	if p.state=="hit" then
		spr(p.SPR.HURT+time()//256%2*2,p.x-8,p.y-8,6,1,p.facing,0,2,2)
	end
	
	if p.y<-8 then
		spr(p.SPR.INDICATOR,p.x-8,0,6,1,1,0,2,2)
	end
	
	spr(p.draw_stock.s_bg,p.draw_stock.x,p.draw_stock.y,0,1,0,0,2,2)
	spr(p.SPR.IDLE,p.draw_stock.x,p.draw_stock.y,6,1,0,0,2,2)
	print(p.damage.."%",p.draw_stock.x+20,p.draw_stock.y+1,12,true)
	for x=1,p.stock do
		spr(p.draw_stock.s_st,p.draw_stock.x+12+(x*8),p.draw_stock.y+8,6)
	end
end

function renderMap(i)
	map(i*30,0,30,17)
end

function isGrounded(p)
	p.grounded=(fget(mget((p.x+4)//8,p.y//8+1),0)) or (fget(mget((p.x-4)//8,p.y//8+1),0))
end

function renderDeathParticles()
	for i, p in ipairs(deathParticles) do
		for c=0,p.t*2//1 do
			local x
			if p.x < 120 then
			 x=math.random(0,p.t//1+3)
			else
				x=math.random(239-p.t//1-3,239)
			end
			local y=math.random(p.y//1-10,p.y//1+10)
			local s=math.random(3,5)
			rect(x,y,s,s,particleColors[math.random(1,7)])
		end
		p.t=p.t*.85
		if p.t < 1 then table.remove(deathParticles,i) end
	end
	
	if screenShake > 0 then
		poke(0x3FF9,math.random(-2,2))
		poke(0x3FF9+1,math.random(-2,2))
	    screenShake=screenShake-1		
		if screenShake==0 then memset(0x3FF9,0,2) end
	end
end

function distance(a,b)
    return math.abs(a.x-b.x)+math.abs(a.y-b.y)
end

function calculateDamage(a,h)
	h.damage=h.damage+((21-distance(a,h))*0.5)
	h.damage=math.floor(h.damage+0.5)
end

function updatePlayer(p)
	if p.state=="dead" then return end
	if p.dabCooldown>0 then p.dabCooldown=p.dabCooldown-1 end
	if p.blockCooldown>0 then p.blockCooldown=p.blockCooldown-1 end

	if p.dabCooldown<=30 and not (p.state=="hit") then
	    isGrounded(p)
		if p.canMove and btnp(p.BTN.DAB) and p.dabCooldown==0 then
			if btnp(p.BTN.DAB) then sfx(3,8,15,p.channel) end
			p.state="dab"
			p.dabCooldown=45
			isGrounded(p)
			if p.grounded then p.y=(p.y//8)*8 end
			if distance(p,p.other)<=20 then
				p.dabCooldown=p.dabCooldown-5
			 calculateDamage(p,p.other) 
				if p.other.state=="dab" then
					calculateDamage(p.other,p)
					p.state="hit"
					p.jump=0.8*p.damage
					if p.other.x > p.x then
						p.facing=0
					else
						p.facing=1
					end
				end
				if not (p.other.state=="block") then
					p.other.state="hit"
					p.other.jump=0.8*p.other.damage
					if p.x>p.other.x then
						p.other.facing=0
					else
						p.other.facing=1
					end
				else
					sfx(5,6,0,3)
					p.other.blockCooldown=30
				end
			end
		else
			if p.canMove and p.grounded and btnp(p.BTN.JUMP) then
				p.jump=jumpSpeed
				p.state="jump"
				p.grounded=false
				sfx(1,40,4,p.channel)
			end
			if not (p.grounded or p.state=="jump") then
				p.state="fall"
			end
			if p.canMove and btn(p.BTN.BLOCK) and p.grounded and p.blockCooldown==0 then
				if btnp(p.BTN.BLOCK) then
					sfx(1,95,4,p.channel)
				end
				p.state="block"
			else
				if p.canMove and ((btn(p.BTN.MOVE_LEFT) and not btn(p.BTN.MOVE_RIGHT)) or (not btn(p.BTN.MOVE_LEFT) and btn(p.BTN.MOVE_RIGHT))) then
					if btn(p.BTN.MOVE_LEFT) then 
						p.x=p.x-moveSpeed
						p.facing=1
					end
					if btn(p.BTN.MOVE_RIGHT) then
					 p.x=p.x+moveSpeed
						p.facing=0
					end
					if p.grounded and not (p.state=="jump") then p.state="run"	end
				else
					if p.grounded and not (p.state=="jump") then p.state="idle" end
				end
			end
		end
	end
	
	if p.state=="fall" then 
		if p.jump<fallSpeed then
			if p.jump==0 then
				p.jump=0.25
			else
				p.jump=p.jump*1.5
			end
		end
		p.y=p.y+p.jump
		isGrounded(p)
		if p.grounded then
			p.jump=0
			if not (p.y%8==0) then	p.y=(p.y//8)*8 end
		end
	else
		if p.state=="jump" then
			p.y=p.y-p.jump
			if p.jump>0 then
				p.jump=p.jump*0.9
			end
			if p.jump<0.25 or not btn(p.BTN.JUMP) then
				isGrounded(p)
				if p.grounded then p.y=(p.y//8-1)*8 end
				p.jump=0
				p.state="fall"
			end
		else
			if p.state=="hit" then
				p.y=p.y-math.floor(0.7071*p.jump+0.5)
				if p.facing==0 then
					p.x=p.x-math.floor(0.7071*p.jump+0.5)
				else
					p.x=p.x+math.floor(0.7071*p.jump+0.5)
				end
				p.jump=p.jump*0.75
				if p.jump<0.25 then
					isGrounded(p)
					if p.grounded then p.y=(p.y//8-1)*8 end
					p.jump=0
					p.state="fall"
				end
			end
		end
	end
	
	if p.y > 144 or p.x < -6 or p.x > 245 then
		local y
		if p.y > 104 then
			y=104
		else
			if p.y < 8 then
				y=8
			else
				y=p.y
			end
		end
		table.insert(deathParticles,{x=p.x,y=y,t=30})
		screenShake=30
		p.stock=p.stock-1
		if p.stock==0 then
			winner=p.other.number
			gameEndCount=60
			p1.canMove=false
			p2.canMove=false
			p.state="dead"
		else
			p.jump=0
			p.state="idle"
		end
		p.x=120
		p.y=8
		p.damage=0
		sfx(4,0,30,p.channel)
	end
end

function initializeGame()
	p1.x=40
	p1.y=8
	p1.facing=0
	p1.grounded=true
	p1.state="idle"
	p1.jump=0
	p1.stock=3
	p1.damage=0
	p1.canMove=false
	p1.dabCooldown=0
	p1.blockCooldown=0

	p2.x=199
	p2.y=8
	p2.facing=1
	p2.grounded=true
	p2.state="idle"
	p2.jump=0
	p2.stock=3
	p2.damage=0
	p2.canMove=false
	p2.dabCooldown=0
	p2.blockCooldown=0
	
	gameStartCount=125
	gameEndCount=0
	
	winner=0
end

function overlayText()
	if gameStartCount > 0 then
		if gameStartCount > 90 and gameStartCount <= 120 then
			if gameStartCount==105 then sfx(5,8,6,3) end
			print("3",110,50,0,true,4)
			print("3",108,48,2,true,4)
		end
		if gameStartCount > 60 and gameStartCount <= 90 then
			if gameStartCount==75 then sfx(5,9,6,3) end
			print("2",110,50,0,true,4)
			print("2",108,48,2,true,4)
		end
		if gameStartCount > 30 and gameStartCount <= 60 then
			if gameStartCount==45 then sfx(5,10,6,3) end
			print("1",110,50,0,true,4)
			print("1",108,48,2,true,4)
		end
		if gameStartCount <= 30 then
			if gameStartCount==15 then sfx(5,15,6,3) end
			print("DAB!",78,50,0,true,4)
			print("DAB!",76,48,2,true,4)
		end
		gameStartCount=gameStartCount-1
		if gameStartCount==0 then
			p1.canMove=true
			p2.canMove=true
		end
	end
	
	if gameEndCount > 0 then
		if gameEndCount==60 then sfx(5,0,6,3) end
		print("GAME!",66,50,0,true,4)
		print("GAME!",64,48,2,true,4)
		gameEndCount=gameEndCount-1
		if gameEndCount==0 then
			gameState="end"
		end
	end
end

function TIC()
	if gameState=="title" then
		renderMap(1)
		spr(p2.SPR.HURT,110,6,6,6,1,0,2,2)
		spr(p1.SPR.DAB,34,6,6,6,0,0,2,2)
		print("SMACKDAB!",17,8,0,true,4)
		print("SMACKDAB!",15,6,12,true,4)
		print("Start",105,98,12,true)
		print("Controls",96,106,12,true)
		if time()//512%2==0 then
			spr(195,95+menuSelect*-9,96+menuSelect*8)
		end
		if btnp(4) or btnp(12) then
			sfx(1,55,4,1)
			if menuSelect==0 then 
				initializeGame()
				gameState="game"
			else
				gameState="controls"
			end
		end
		if (btnp(0) or btnp(8)) and menuSelect > 0 then
			sfx(1,49,4,1)
			menuSelect=menuSelect-1
		end
		if (btnp(1) or btnp(9)) and menuSelect < 1 then
			sfx(1,48,4,1)
			menuSelect=menuSelect+1
		end
	end
	if gameState=="controls" then
		renderMap(2)
		print("move left",55,33,12,true)
		print("move right",132,33,12,true)
		print("jump",85,49,12,true)
		print("block",132,49,12,true)
		print("confirm/dab",43,65,12,true)
		print("back",132,65,12,true)
		print("check tic-80 menu",69,89,12,true)
		print("to change default controls",42,97,12,true)
		if btnp(5) or btnp(13) then
			sfx(2,8,6,1)
			gameState="title"
		end
	end
	if gameState=="game" then
		renderMap(0)
		updatePlayer(p1)
		updatePlayer(p2)
		renderPlayer(p1)
		renderPlayer(p2)
		renderDeathParticles()
		overlayText()
	end
	if gameState=="end" then
		renderMap(3)
		print("WINS!",7,52,0,true,4)
		print("WINS!",5,50,12,true,4)
		if winner==1 then
			spr(p1.SPR.DAB,124,0,6,6,time()//512%2,0,2,2)
			spr(p2.SPR.CLAP+time()//128%2*2,48,92,6,2,0,0,2,2)
			print("P1",7,28,0,true,4)
			print("P1",5,26,8,true,4)
		end
		if winner==2 then
			spr(p2.SPR.DAB,124,0,6,6,time()//512%2,0,2,2)
			spr(p1.SPR.CLAP+time()//128%2*2,48,92,6,2,0,0,2,2)
			print("P2",7,28,0,true,4)
			print("P2",5,26,3,true,4)
		end
		
		print("Main Menu",49,130,12,true)
		print("Play Again",130,130,12,true)
		if time()//512%2==0 then
			spr(195,39+endSelect*81,128)
		end
		if btnp(4) or btnp(12) then
			sfx(1,55,4,1)
			if endSelect==1 then 
				initializeGame()
				gameState="game"
			else
				gameState="title"
			end
		end
		if (btnp(2) or btnp(10)) and endSelect > 0 then
			sfx(1,49,4,1)
			endSelect=endSelect-1
		end
		if (btnp(3) or btnp(11)) and endSelect < 1 then
			sfx(1,48,4,1)
			endSelect=endSelect+1
		end
	end
	
	if not playMusic and (gameState=="title" or gameState=="controls" or gameState=="end") then
		playMusic=true
		music(0,0,0)
	end
	if playMusic and (gameState=="game") then
		playMusic=false
		music()
	end
end