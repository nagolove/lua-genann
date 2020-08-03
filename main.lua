local inspect = require "inspect"
require "example1"
require "example2"
local mnist = require "mnist"

love.load = function()
    --example1()
    --example2()
    mnist.init()
end

local mx, my

love.mousemoved = function(x, y, dx, dy)
    if love.mouse.isDown(1) then
        mx, my = x, y
    else
        mx, my = nil, nil
    end
end

local canvas = love.graphics.newCanvas()
local result

love.draw = function()
    love.graphics.setCanvas(canvas)
    if mx and my then
        love.graphics.setColor{1, 0, 0}
        love.graphics.circle("fill", mx, my, 16)
    end
    love.graphics.setCanvas()
    love.graphics.draw(canvas)

    if result then
        love.graphics.print(result, 0, 0)
    end
end

function prepareAndRecognize()
    local smallSize = mnist.getImageSize()
    --local smallSize = 128
    local smallCanvas = love.graphics.newCanvas(smallSize, smallSize, {msaa = 2})
    local w, h = love.graphics.getDimensions()

    --print("smallCanvas size", smallCanvas:getDimensions())
    canvas:newImageData():encode("png", "canvas.png")

    love.graphics.setCanvas(smallCanvas)
    --love.graphics.translate(- w/2, -h/2)
    --love.graphics.translate( w/2, h/2)
    print("scale ratio", w / smallSize, h / smallSize)
    love.graphics.scale(smallSize / w, smallSize / h)
    --love.graphics.translate(-w/2, -h/2)
    --love.graphics.translate(w/2, h/2)
    love.graphics.draw(canvas)
    love.graphics.setCanvas()

    smallCanvas:newImageData():encode("png", "small.png")

    local res = mnist.recognize(smallCanvas:newImageData())
    print(inspect(res))
    
    print("smallCanvas msaa", smallCanvas:getMSAA())
end

love.keypressed = function(_, key)
    if key == "space" then
        prepareAndRecognize()
    elseif key == "backspace" then
        love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.setCanvas()
    end
end
