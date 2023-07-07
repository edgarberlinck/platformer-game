function love.load()
  love.window.setMode(1000, 768)

  anim8 = require 'lib.anim8.anim8'
  sti = require 'lib.Simple-Tiled-Implementation.sti'
  cameraFile = require 'lib.hump.camera'

  camera = cameraFile()

  sprites = {}
  sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
  sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')

  local grid = anim8.newGrid(
    614,
    564,
    sprites.playerSheet:getWidth(),
    sprites.playerSheet:getHeight())

  local enemyGrid = anim8.newGrid(
    100,
    79,
    sprites.enemySheet:getWidth(),
    sprites.enemySheet:getHeight()
  )

  animations = {}
  animations.idle = anim8.newAnimation(
    grid('1-15', 1),
    0.05
  )
  animations.jump = anim8.newAnimation(
    grid('1-7', 2),
    0.05
  )
  animations.run = anim8.newAnimation(
    grid('1-15', 3),
    0.05
  )

  animations.enemy = anim8.newAnimation(
    enemyGrid("1-2", 1),
    0.03
  )

  wf = require "lib.windfield.windfield"

  local gravity = {
    y = 800,
    x = 0
  }

  Directions = {
    RIGHT = 1,
    LEFT = -1
  }

  ColiderType = {
    STATIC = "static",
    DYNAMIC = "dynamic",
    KINEMATIC = "kinematic"
  }

  world = wf.newWorld(gravity.x, gravity.y, false)
  world:setQueryDebugDrawing(true)

  world:addCollisionClass('Platform')
  world:addCollisionClass('Danger')
  world:addCollisionClass('Player')

  require 'player'
  require 'enemy'
  require "lib.show"
  -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, { collision_class = "Danger" })
  -- dangerZone:setType(ColiderType.STATIC)

  platforms = {}

  flagX = 0
  flagY = 0
  savedData = {}
  savedData.currentLevel = "level1"
  if love.filesystem.getInfo('data.lua') then
    local data = love.filesystem.load('data.lua')
    data()
  end

  loadMap(savedData.currentLevel)
end

function love.update(deltaTime)
  world:update(deltaTime)
  gameMap:update(deltaTime)
  playerUpdate(deltaTime)
  updateEnemies(deltaTime)

  local px = player:getPosition()
  camera:lookAt(px, love.graphics.getHeight() / 2)

  local colliders = world:queryCircleArea(flagX, flagY, 10, { "Player" })

  if #colliders > 0 then
    loadMap("level2")
    -- @TODO: Check which level we are
  end
end

function love.draw()
  camera:attach()
  gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
  world:draw()
  drawPlayer()
  drawEnemies()
  camera:detach()
end

function love.keypressed(key)
  if key == 'up' then
    if player.grounded then
      player:applyLinearImpulse(0, -4000)
    end
  end
end

function spawnPlatform(x, y, width, height)
  if width > 0 and height > 0 then
    local platform = world:newRectangleCollider(x, y, width, height, { collision_class = "Platform" })
    platform:setType(ColiderType.STATIC)

    table.insert(platforms, platform)
  end
end

function destroyAll()
  destroyPlatforms()
  destroyEnemies()
end

function destroyPlatforms()
  local i = #platforms

  while i > -1 do
    if platforms[i] ~= nil then
      platforms[i]:destroy()
    end
    table.remove(platforms, i)
    i = i - 1
  end
end

function destroyEnemies()
  local i = #enemies

  while i > -1 do
    if enemies[i] ~= nil then
      enemies[i]:destroy()
    end
    table.remove(enemies, i)
    i = i - 1
  end
end

function loadMap(mapName)
  savedData.currentLevel = mapName
  love.filesystem.write(
    'data.lua',
    table.show(savedData, "saveData")
  )
  destroyAll()
  player:setPosition(300, 100)
  gameMap = sti('maps/' .. mapName .. '.lua')

  for i, platform in ipairs(gameMap.layers["Platforms"].objects) do
    spawnPlatform(platform.x, platform.y, platform.width, platform.height)
  end
  for i, enemy in ipairs(gameMap.layers["Enemies"].objects) do
    spawnEnemy(enemy.x, enemy.y)
  end

  for i, flag in ipairs(gameMap.layers["Flag"].objects) do
    flagX = flag.x
    flagY = flag.y
  end
end
