local inspect = require "inspect"
local ffi = require "ffi"

local clib = ffi.load("libgenann.so")

ffi.cdef([[
struct genann;

typedef double (*genann_actfun)(const struct genann *ann, double a);

typedef struct genann {
    /* How many inputs, outputs, and hidden neurons. */
    int inputs, hidden_layers, hidden, outputs;

    /* Which activation function to use for hidden neurons. Default: gennann_act_sigmoid_cached*/
    genann_actfun activation_hidden;

    /* Which activation function to use for output. Default: gennann_act_sigmoid_cached*/
    genann_actfun activation_output;

    /* Total number of weights, and size of weights buffer. */
    int total_weights;

    /* Total number of neurons + inputs and size of output buffer. */
    int total_neurons;

    /* All weights (total_weights long). */
    double *weight;

    /* Stores input array and output of each neuron (total_neurons long). */
    double *output;

    /* Stores delta of each hidden and output neuron (total_neurons - inputs long). */
    double *delta;

} genann;

/* Creates and returns a new ann. */
genann *genann_init(int inputs, int hidden_layers, int hidden, int outputs);

/* Creates ANN from file saved with genann_write. */
//genann *genann_read(FILE *in);

/* Sets weights randomly. Called by init. */
void genann_randomize(genann *ann);

/* Returns a new copy of ann. */
genann *genann_copy(genann const *ann);

/* Frees the memory used by an ann. */
void genann_free(genann *ann);

/* Runs the feedforward algorithm to calculate the ann's output. */
double const *genann_run(genann const *ann, double const *inputs);

/* Does a single backprop update. */
void genann_train(genann const *ann, double const *inputs, double const *desired_outputs, double learning_rate);

/* Saves the ann. */
//void genann_write(genann const *ann, FILE *out);

void genann_init_sigmoid_lookup(const genann *ann);
double genann_act_sigmoid(const genann *ann, double a);
double genann_act_sigmoid_cached(const genann *ann, double a);
double genann_act_threshold(const genann *ann, double a);
double genann_act_linear(const genann *ann, double a);
]])


local function init(inputs, hidden_layers, hidden, outputs)
    print("init", inputs, hidden_layers, hidden, outputs)
    --local obj = ffi.C.genann_init(inputs, hidden_layers, hidden, outputs)
    print("clib", clib)
    local obj = clib.genann_init(inputs, hidden_layers, hidden, outputs)
    print("obj total_neurons", obj.total_neurons)
    print("obj total_weights", obj.total_weights)
    print("obj outputs", obj.outputs)
    return obj
end

local function genann_randomize(ann)
end

local function genann_copy(ann)
end

local function genann_free(ann)
end

local function genann_free()
end

local function genann_run(ann, inputs)
    local newinputs = ffi.new("double[?]", #inputs)
    for i = 0, #inputs - 1 do
        newinputs[i] = inputs[i + 1]
    end
    local res = {}
    local output = clib.genann_run(ann, newinputs)
    for i = 0, ann.outputs - 1 do
        table.insert(res, output[i])
    end
    return res
end

local function genann_train(ann, inputs, desired_outputs, learning_rate)
    --print("inputs", inspect(inputs), inspect(desired_outputs), inspect(learning_rate))
    --local newinputs = ffi.cast("double*", inputs)
    local newinputs = ffi.new("double[?]", #inputs)
    for i = 0, #inputs - 1 do
        newinputs[i] = inputs[i + 1]
    end
    local newdesired_outputs = ffi.new("double[?]", #desired_outputs)
    for i = 0, #desired_outputs - 1 do
        newdesired_outputs[i] = desired_outputs[i + 1]
    end
    clib.genann_train(ann, newinputs, newdesired_outputs, learning_rate)
end

local function genann_init_sigmoid_lookup(ann)
end

local function genann_act_sigmoid(ann, a)
end

local function genann_act_sigmoid_cached(ann, a)
end

local function genann_act_threshold(ann, a)
end

local function genann_act_linear(ann, a)
end

return {
    init = init,
    randomize = genann_randomize,
    copy = genann_copy,
    free = genann_free,
    free = genann_free,
    run = genann_run,
    train = genann_train,
    init_sigmoid_lookup = genann_init_sigmoid_lookup,
    act_sigmoid = genann_act_sigmoid,
    act_sigmoid_cached = genann_act_sigmoid_cached,
    act_threshold = genann_act_threshold,
    act_linear = genann_act_linear,
}
