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
        love.graphics.circle("fill", mx, my, 6)
    end
    love.graphics.setCanvas()
    love.graphics.draw(canvas)

    if result then
        love.graphics.print(result, 0, 0)
    end
end

function prepareAndRecognize()
    local smallCanvas = love.graphics.newCanvas(mnist.imageSize, mnist.imageSize)

    love.graphics.setCanvas(smallCanvas)
    love.graphics.draw(canvas)
    love.graphics.setCanvas()

    smallCanvas:newImageData():encode("png", "small.png")

    local res = mnist.recognize(smallCanvas:newImageData())
    print(inspect(res))
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
