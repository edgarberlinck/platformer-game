function love.load()
  love.window.setMode(1000, 768)

  anim8 = require 'lib.anim8.anim8'
  sti = require 'lib.Simple-Tiled-Implementation.sti'
  cameraFile = require 'lib.hump.camera'

  camera = cameraFile()

  sprites = {}
  sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

  local grid = anim8.newGrid(
    614,
    564,
    sprites.playerSheet:getWidth(),
    sprites.playerSheet:getHeight())

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

  -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, { collision_class = "Danger" })
  -- dangerZone:setType(ColiderType.STATIC)

  platforms = {}

  loadMap()
end

function love.update(deltaTime)
  world:update(deltaTime)
  gameMap:update(deltaTime)
  playerUpdate(deltaTime)

  local px = player:getPosition()
  camera:lookAt(px, love.graphics.getHeight() / 2)
end

function love.draw()
  camera:attach()
  gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
  world:draw()
  drawPlayer()
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

function loadMap()
  gameMap = sti('maps/level1.lua')

  for i, platform in ipairs(gameMap.layers["Platforms"].objects) do
    spawnPlatform(platform.x, platform.y, platform.width, platform.height)
  end
end
