--[[
Ping Pong
v1.0.0 | May 2026

A reimagining of Pong (Atari, 1972), built as a learning project following CS50's Introduction to Game Development.
Adapted for touch input on Android.

Author : Bandari Srikanth (https://github.com/srikanth9x)

Assets : CS50 Game Development — Harvard University
https://github.com/games50

MIT License — Copyright (c) 2026 Bandari Srikanth
]]

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

push = require 'lib.push'
Class = require 'lib.class'

require 'src.Ball'
require 'src.Paddle'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  love.window.setTitle('Ping Pong')
  
  math.randomseed(os.time())
  
  scoreFont = love.graphics.newFont('fonts/pressstart.ttf', 32)
  largeFont = love.graphics.newFont('fonts/pressstart.ttf', 16)
  smallFont = love.graphics.newFont('fonts/pressstart.ttf', 8)
  
  sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.mp3', 'static')
  }
  
  player1Score = 0
  player2Score = 0
  
  servingPlayer = 1
  
  player1 = Paddle(10, 10, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)
  
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  
  touchEnabled = false
  touchTimer = 0
  
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    resizable = false,
    vsync = true,
    fullscreen = false
  })

  push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {upscale = 'normal'})
  
  gameState = 'start'
end

--[[
function love.resize(w, h)
  push.resize(w, h)
end
]]

function love.update(dt)
  if gameState == 'serve' then
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else ball.dx = -math.random(140, 200)
    end
  
  elseif gameState == 'play' then
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5
      
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end
    
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 5
      
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()
    end
    
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end
    
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
      sounds['wall_hit']:play()
    end
    
    if ball.x < 0 then
    servingPlayer = 1
    player2Score = player2Score + 1
    sounds['score']:play()
      if player2Score == 10 then
        winningPlayer = 2
        gameState = 'done'
        sounds['victory']:play()
      else
        gameState = 'serve'
        ball:reset()
      end
    end
  
    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      sounds['score']:play()
      if player1Score == 10 then
        winningPlayer = 1
        gameState = 'done'
        sounds['victory']:play()
      else
        gameState = 'serve'
        ball:reset()
      end
    end
  elseif gameState == 'done' then
    touchTimer = touchTimer + dt
    if touchTimer >= 1 then
      touchEnabled = true
    end
  end

  if gameState == 'play' then
    ball:update(dt)
  end
  
  player1:update(dt)
  player2:update(dt)
end

function love.touchpressed(id, x, y)
  local screenH = love.graphics.getHeight()
  local screenW = love.graphics.getWidth()
  
  local servingPlayerTouched = false
  
  if servingPlayer == 1 and x < screenW / 2 then
    servingPlayerTouched = true
  elseif servingPlayer == 2 and x > screenW / 2 then
    servingPlayerTouched = true
  end
  
  if servingPlayerTouched then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
    elseif gameState == 'done' then
      if not touchEnabled then
        return
      else
        gameState = 'serve'
        ball:reset()
      
        player1Score = 0
        player2Score = 0
        
        touchEnabled = false
        touchTimer = 0
      
        if winningPlayer == 1 then
        servingPlayer = 2
        else 
          servingPlayer = 1
        end
      end
    end
  end
  
  if x < screenW / 2 then
    if y < screenH / 2 then
      player1.dy = -PADDLE_SPEED
    else
      player1.dy = PADDLE_SPEED
    end
  else
    if y < screenH / 2 then
      player2.dy = -PADDLE_SPEED
    else
      player2.dy = PADDLE_SPEED
    end
  end
end

function love.touchreleased(id, x, y)
  local screenH = love.graphics.getHeight()
  local screenW = love.graphics.getWidth()
  
  if x <  screenW / 2 then
    player1.dy = 0
    servingPlayerTouched = false
  else
    player2.dy = 0
    servingPlayerTouched = false
  end
end

function love.draw()
  push.start()
  love.graphics.clear(40/255, 45/255, 52/255, 255/255)
  
  if gameState == 'start' then
    love.graphics.setFont(largeFont)
    love.graphics.printf('Welcome to Ping Pong', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player '.. tostring(servingPlayer) .. ' touch to start!', 0, 30, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' touch to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'play' then
  elseif gameState == 'done' then
    love.graphics.setFont(largeFont)
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf('Player ' .. tostring(winningPlayer).. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(smallFont)
    if touchEnabled then
      love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' touch to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
  end

  displayScore()
  
  player1:draw()
  player2:draw()
  
  ball:draw()
  
 -- displayFPS()
  
  push.finish()
end

function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 10)
  love.graphics.setColor(1,1,1,1)
end

function displayScore()
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/ 2 - 64, 44)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 32, 44)
end
  