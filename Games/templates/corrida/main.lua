largura_tela = love.graphics.getWidth()
altura_tela = love.graphics.getHeight()

function love.load()
	fundo = {}
	fundo.ceu = love.graphics.newImage("img/ceu.png")
	fundo.montanhas = love.graphics.newImage("img/montanhas.png")
	fundo.arvores = love.graphics.newImage("img/arvores.png")
	ceuX = 0
	montanhasX = 0
	arvoresX = 0
	
	posicao = 0
	velocidade = 0
	maxVelocidade = 200
	aceleracao = maxVelocidade/5
	freio = -maxVelocidade
	desaceleracao = -maxVelocidade/6
	
	jogador = {}
	jogador.x = 0
	jogador.img = love.graphics.newImage("img/carro.png")
	jogador.w = jogador.img:getWidth()
	jogador.h = jogador.img:getHeight()
end

function love.update(dt)
	posicao = posicao + dt*velocidade
	
	dx = dt * velocidade
	
	if love.keyboard.isDown("left") then
        jogador.x = jogador.x - dx
    elseif love.keyboard.isDown("right") then
        jogador.x = jogador.x + dx
	end
      
	if love.keyboard.isDown("up") then
		velocidade = velocidade + aceleracao*dt
		velocidade = math.min(velocidade, maxVelocidade)

		arvoresX = arvoresX - dx*0.1
    elseif love.keyboard.isDown("down") then
		velocidade = velocidade + freio*dt
		velocidade = math.max(velocidade, 0)
    else
		velocidade = velocidade + desaceleracao*dt
		velocidade = math.max(velocidade, 0)

		arvoresX = arvoresX - dx*0.09
    end
	
end

function love.draw()
	love.graphics.draw(fundo.ceu, ceuX, 0)
	love.graphics.draw(fundo.montanhas, montanhasX, 0)
	love.graphics.draw(fundo.arvores, arvoresX, 0)
	
	--grama
	love.graphics.setColor(0.5,0.8,0)
	love.graphics.rectangle("fill", 0, 400, 800, 200)
	
	--estrada
	love.graphics.setColor(0.4,0.4,0.45)
	love.graphics.polygon('fill', -150, 600, 390, 400, 410, 400, 950, 600)

	love.graphics.setColor(1,1,1)
	
	love.graphics.draw(jogador.img, jogador.x + largura_tela/2 - jogador.w/2, 500)

	love.graphics.print("VEL: "..math.floor(velocidade).." km/h", 30, 350, 0, 2)
end
