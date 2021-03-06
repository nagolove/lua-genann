genann = require "genann"

function example1()
    local ntwk = genann.init(2, 1, 2, 1)

    local input = {{0, 0}, {0, 1}, {1, 0}, {1, 1}}
    local output = {{0}, {1}, {1}, {0}}

    for i = 1, 300 do
        --ntwk.train(input[1], output[1], 3)
        --ntwk.train(input[2], output[2], 3)
        --ntwk.train(input[3], output[3], 3)
        --ntwk.train(input[4], output[4], 3)
        genann.train(ntwk, input[1], output[1], 3)
        genann.train(ntwk, input[2], output[2], 3)
        genann.train(ntwk, input[3], output[3], 3)
        genann.train(ntwk, input[4], output[4], 3)
    end

    --print(string.format("output for [%1.f, %1.f] is %1.f", input[1][1], input[1][2], ntwk.run(input[1])))
    --print(string.format("output for [%1.f, %1.f] is %1.f", input[2][1], input[2][2], ntwk.run(input[2])))
    --print(string.format("output for [%1.f, %1.f] is %1.f", input[3][1], input[3][2], ntwk.run(input[3])))
    --print(string.format("output for [%1.f, %1.f] is %1.f", input[4][1], input[4][2], ntwk.run(input[4])))
    function prnt(inpt1, inpt2, res)
        print(string.format("output for [%1.f, %1.f] is %1.f", inpt1, inpt2, table.concat(res, ",")))
    end
    prnt(input[1][1], input[1][2], genann.run(ntwk, input[1]))
    prnt(input[2][1], input[2][2], genann.run(ntwk, input[2]))
    prnt(input[3][1], input[3][2], genann.run(ntwk, input[3]))
    prnt(input[4][1], input[4][2], genann.run(ntwk, input[4]))
end

