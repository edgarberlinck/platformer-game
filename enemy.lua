enemies = {}

function spawnEnemy(x, y)
  local enemy = world:newRectangleCollider(x, y, 70, 90, { collision_class = "Danger" })
  enemy.direction = 1
  enemy.speed = 200
  enemy.animation = animations.enemy
  table.insert(enemies, enemy)
end

function updateEnemies(deltaTime)
  for i, enemy in ipairs(enemies) do
    enemy.animation:update(deltaTime)
    local ex, ey = enemy:getPosition()

    local colliders = world:queryRectangleArea(ex + (40 * enemy.direction), ey + 40, 10, 10, { "Platform" })
    if #colliders == 0 then
      enemy.direction = enemy.direction * -1
    end

    enemy:setX(ex + enemy.speed * deltaTime * enemy.direction)
  end
end

function drawEnemies()
  for i, enemy in ipairs(enemies) do
    local ex, ey = enemy:getPosition()
    enemy.animation:draw(sprites.enemySheet, ex, ey, nil, enemy.direction, 1, 50, 65)
  end
end
