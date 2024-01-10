function love.load()
    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 0)

    camera = require 'libraries/camera'
    cam = camera()
   

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")


    sti = require('libraries/sti')
    gameMap = sti('maps/RPG1.lua')

    player = {}
    player.size = 1.1
    
    player.spriteSheet = love.graphics.newImage('sprites/Steve.png')
    player.grid = anim8.newGrid(16, 20, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    --Sword
    
    world:addCollisionClass('Player')
    player.collider = world:newCircleCollider(500, 500, 30/player.size)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass('Player')
    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-9', 1), 0.07)
    player.animations.up = anim8.newAnimation( player.grid('1-9', 2), 0.07 )
    
    player.anim = player.animations.down

    player.speed = 350
    player.x = 400
    player.y = 300
    player.dir = "down"

    effect = {}
    mx = 1
    my = 1
    
    effect.swordSheet = love.graphics.newImage('sprites/sliceAnim.png')
    effect.swordGrid = anim8.newGrid(23, 39, effect.swordSheet:getWidth(), effect.swordSheet:getHeight())
    effect.swipe = anim8.newAnimation( effect.swordGrid('1-6', 1), 0.1)
    effect.sword = anim8.newAnimation(effect.swordGrid('1-2', 2), 0.1 )
    effect.swipe.frame = 1
    effect.sword.frame = 1
    effect.anim = effect.swipe
    effect.anim:gotoFrame(1)
    effect.dir = math.pi
    effect.dx = 0
    effect.dy = 0
    love.window.setMode(900,600)

    flipX = 1
    timer = 13
    world:addCollisionClass('Wall')
    walls = {}
    if gameMap.layers["blocks"] then
       for i, obj in pairs(gameMap.layers["blocks"].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
          wall:setType('static')
          wall:setCollisionClass('Wall')
         table.insert(walls, wall)
       end        
    end
end
-------------------------------------UPDDATE
function love.update(dt)
    player.anim:update(dt)
    effect.anim:update(dt)
    effect.sword:update(dt)
    local isMoving = false
    local vy = 0
    local vx = 0
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    player.dir = "down"
    player.x = player.collider:getX()
    player.y = player.collider:getY()-17
    effect.pause = true
    effect.dir = math.pi
    effect.dx = (cam.x - player.x) * -1
    effect.dy = (cam.y - player.y) * -1
    

    if love.keyboard.isDown("a") and player.x > 24 then
        vx = player.speed*-1
        isMoving = true
        flipX = -1
    end
    if love.keyboard.isDown("d") and player.x < mapW - 20 then
        vx = player.speed
        isMoving = true
        flipX = 1
    end
    
    if love.keyboard.isDown("w") and player.y > 40 then
        vy = player.speed*-1
        isMoving = true
        player.dir = "up"
    end
    if love.keyboard.isDown("s") and player.y < mapH - 18 then
        vy = player.speed
        isMoving = true
        player.dir = "down"
    end
    
    if isMoving == false then
        player.anim:gotoFrame(1)        
    end

    player.collider:setLinearVelocity(vx, vy)
    world:update(dt)

    cam:lookAt(player.x, player.y)
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    
    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH -h/2) then
        cam.y = (mapH - h/2)
    end

    if player.dir == "up" then
        player.anim = player.animations.up
    elseif player.dir == "down" then
        player.anim = player.animations.down
    end

    function love.mousereleased(button)
        timer = timer - math.ceil(dt)
        mx = love.mouse.getX()
        my = love.mouse.getY()
       --targets = world:queryCircleArea(400, 300, 100)
        
    end
    --direction
    if mx < effect.dx+400 and my > effect.dy+350 then 
        effect.dir = (3*(math.pi))/4    -- down Left
    elseif mx > effect.dx+400 and mx < effect.dx+500 and my > effect.dy+350 then 
        effect.dir = (math.pi)/2    -- down
    elseif mx > effect.dx+400 and mx < effect.dx+500 and my < effect.dy+350 then 
        effect.dir = (3*(math.pi))/2   -- up
    elseif mx < effect.dx+400 and my < effect.dy+250 then 
        effect.dir = (5*math.pi)/4 -- up Left
    elseif mx < effect.dx+400  and my > effect.dy+250 and my < effect.dy+350 then 
        effect.dir = (math.pi) -- left
    elseif mx > effect.dx+500 and my < effect.dy+350 and my > effect.dy+250 then 
        effect.dir = 0 -- right
    elseif mx > effect.dx+500 and my < effect.dy+250 then 
        effect.dir = (7*math.pi)/4
    elseif mx > effect.dx+500 and my > effect.dy+350 then 
        effect.dir = (math.pi)/4
    end
    

    if effect.swipe.frame == 1 and timer == 12 then
        timer = timer - math.ceil(dt)
        effect.sword.frame = 2
    elseif  effect.swipe.frame == 1 and timer <= 10 then  
        effect.swipe.frame = 2
        effect.sword.frame = 1 
        timer = timer - math.ceil(dt)
    elseif effect.swipe.frame == 2 and timer <= 8 then
        effect.swipe.frame = 3
        timer = timer - math.ceil(dt)
    elseif effect.swipe.frame == 3 and timer <= 5 then
        effect.swipe.frame = 4
        timer = timer - math.ceil(dt)
    elseif effect.swipe.frame == 4 and timer <= 3 then
        effect.swipe.frame = 5
    elseif effect.swipe.frame == 5 and timer <= 1 then
        effect.swipe.frame = 1
    end
    
    if timer <= 11 and timer > 9 then
        timer = timer - math.ceil(dt)/2
    elseif timer <= 9 and timer > 7 then
        timer = timer - math.ceil(dt)/2
    elseif timer <= 7 and timer > 5 then
        timer = timer - math.ceil(dt)/2
    elseif timer <= 4  and timer > 3 then
        timer = timer - math.ceil(dt)/2
    elseif timer <= 4 and timer > 3 then 
        timer = timer - math.ceil(dt)/2
    elseif timer <= 3 and timer > 1 then
        timer = timer - math.ceil(dt)/2
    elseif effect.swipe.frame == 6 or effect.swipe.frame == 1 then
        timer = 13
        
    end

    effect.sword:gotoFrame(effect.sword.frame)
    effect.anim:gotoFrame(effect.swipe.frame)

end

function love.draw()
    
    cam:attach()
    
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
    
    effect.swipe:draw(effect.swordSheet, player.x, player.y, effect.dir, 4, 4*flipX,nil,18*player.size)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5/player.size*flipX, 5/player.size, 8*player.size, 9*player.size)
    effect.sword:draw(effect.swordSheet, player.x, player.y, effect.dir, 4, 4*flipX,nil,18*player.size)

    gameMap:drawLayer(gameMap.layers["Tile Layer 3"])

    --world:draw()
    cam:detach()
    --[[love.graphics.print(love.mouse.getX(),0,0,nil,3)
    love.graphics.print(love.mouse.getY(),0,30,nil,3)
    love.graphics.print(effect.dx,400,0,nil,3)
    love.graphics.print(effect.dy,400,30,nil,3)]]
end


  
