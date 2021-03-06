local inspect = require "inspect"
local struct = require "struct"
local genann = require "genann"

local testImagesPath = "mnist/t10k-images-idx3-ubyte"
local testLabeslPath = "mnist/t10k-labels-idx1-ubyte"
local trainImagesPath = "mnist/train-images-idx3-ubyte"
local trainLabelsPath = "mnist/train-labels-idx1-ubyte"

local imageSize
local ntwk

function saveImage(data, columns, rows, num)
    print("#data", #data)

    function getPixel(x, y)
        local i = y * rows + x + 1
        print("i", i, x, y)
        return data:byte(i)
    end

    local img = love.image.newImageData(columns, rows)
    img:mapPixel(function(x, y, r, g, b, a)
        local c = getPixel(x, y)
        print(x, y, c)
        return c, 1, 1, 1
    end)
    img:encode("png", string.format("%d.png", num))
end

function getLabels()
    local trainLabelsData = love.filesystem.read(trainLabelsPath)
    local magic = struct.unpack(">I", trainLabelsData:sub(1, 4))
    print("magic", magic)
    local labelsNum = struct.unpack(">I", trainLabelsData:sub(5, 8))
    print("num", labelsNum)
    local res = {}
    local index = 9
    for i = 1, labelsNum - 1 do
        table.insert(res, trainLabelsData:byte(index))
        index = index + 1
    end
    return res
end

local function str2array(str)
    local res = {}
    for i = 1, str:len() do
        table.insert(res, str:byte(i))
    end
    return res
end

local function init()
    local labels = getLabels()
    print("#labels", labels)
    for i = 1, 100 do 
        print(i, labels[i])
    end

    local trainImagesData = love.filesystem.read(trainImagesPath)

    local magic = struct.unpack(">I", trainImagesData:sub(1, 4))
    local imagesNum = struct.unpack(">I", trainImagesData:sub(5, 8))
    local rows = struct.unpack(">I", trainImagesData:sub(9, 12))
    local columns = struct.unpack(">I", trainImagesData:sub(13, 16))
    local index = 17
    local imgSize = rows * columns
    imageSize = rows
    print("imageSize", imageSize, rows)
    local num = 1

    print("magic", magic)
    print("imagesNum", imagesNum)
    print("rows, columns", rows, columns)

    --local ntwk = genann.init(imgSize, 1, math.floor(imgSize / 2), 10)
    ntwk = genann.init(imgSize, 0, 0, 10)

    local output = {}
    for i = 1, 10 do
        output[i] = 0
    end

    local function setupOutput(label)
        --print("label", label)
        for i = 1, 10 do
            output[i] = 0
        end
        output[label + 1] = 1
    end

    while index < #trainImagesData do
        local data = trainImagesData:sub(index, index + imgSize - 1)
        local array = str2array(data)

        --saveImage(data, columns, rows, num)
        setupOutput(labels[num])
        --print("output", inspect(output))
        genann.train(ntwk, array, output, 0.01)

        num = num + 1
        index = index + imgSize - 0

        if num > 800 then
            break
        end

    end

    print("#trainImagesData", #trainImagesData)
end

local function vector2png(vec)
    local imgdata = love.image.newImageData(28, 28)
    local index = 1
    imgdata:mapPixel(function(x, y, r, g, b, a)
        local r = vec[index]
        index = index + 1
        return r, 0, 0, 1
    end)
    imgdata:encode("png", "vector.png")
end

local function getMax(vec)
    local max = 0
    local index = -1
    for i, v in pairs(vec) do
        if v > max then
            max = v
            index = i
        end
    end
    return index + 1
end

local function recognize(imageData)
    local vec = {}
    imageData:mapPixel(function(x, y, r, g, b, a)
        print("x, y, color sum", x, y, r + g + b)
        if r + g + b > 0.1 then
            table.insert(vec, 1)
        else
            table.insert(vec, 0)
        end
        return 1, 1, 1, 1
    end)

    local out = genann.run(ntwk, vec)
    print("#out", #out)
    print("out", inspect(out))

    --print("vec", inspect(vec))
    vector2png(vec)

    local value = getMax(out)
    print("value", value)
end

local function getImageSize()
    return imageSize
end

return {
    init = init,
    recognize = recognize,
    getImageSize = getImageSize,
}
