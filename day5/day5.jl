using DelimitedFiles

program = reshape(readdlm("day5/input.txt", ',', Int64, '\n'), 1, :)


ADD_OPCODE = 1
MUL_OPCODE = 2
INPUT_OPCODE = 3
OUTPUT_OPCODE = 4
JUMP_IF_TRUE = 5
JUMP_IF_FALSE = 6
LESS_THAN_OPCODE = 7
EQUALS_OPCODE = 8
HALT_OPCODE = 99

OPCODES_ARG_COUNT = Dict([
    (ADD_OPCODE, 3)
    (MUL_OPCODE, 3)
    (LESS_THAN_OPCODE, 3)
    (EQUALS_OPCODE, 3)
    (JUMP_IF_FALSE, 2)
    (JUMP_IF_TRUE, 2)
    (INPUT_OPCODE, 1)
    (OUTPUT_OPCODE, 1)
])

MAX_OPCODE_ARGS = maximum([k for (k, _) in OPCODES_ARG_COUNT])

function parse_opcode(raw)
    str = string(raw)
    if length(str) == 1
        return [raw, zeros(Int8, MAX_OPCODE_ARGS)...]
    end
    opcode = parse(Int8, str[end-1:end])
    modes = [parse(Int8, x) for x in reverse(str[1:end-2])]
    [opcode, modes..., zeros(Int8, MAX_OPCODE_ARGS - length(modes))...] # pad extra zeros as they're default
end

function readmem(memory::Array{Int64}, ix::Int64, mode::Int8)::Int64
    raw = memory[ix]
    if mode == IMMEDIATE
        raw
    elseif mode == POSITION
        memory[raw + 1]
    else
        error("Unsupported mode $(mode)")
    end
end

function writemem(memory::Array{Int64}, ix::Int64, val::Int64)
    memory[ix + 1] = val
end

POSITION = 0
IMMEDIATE = 1

function interpret(program::Array{Int64}, input::Int64)
    memory = copy(program)

    pc = 1
    test = 1
    last_output = 0
    while true
        op = parse_opcode(memory[pc])
        opcode = op[1]
        modes = op[2:end]
        if opcode == HALT_OPCODE
            return last_output
            pc += 1
        elseif !haskey(OPCODES_ARG_COUNT, opcode)
            error("Unsupported opcode $(opcode)")
        elseif OPCODES_ARG_COUNT[opcode] == 3
            x = readmem(memory, pc + 1, modes[1])
            y = readmem(memory, pc + 2, modes[2])
            outix = memory[pc + 3]
            if opcode == ADD_OPCODE
                writemem(memory, outix, x + y)
            elseif opcode == MUL_OPCODE
                writemem(memory, outix, x * y)
            elseif opcode == LESS_THAN_OPCODE
                writemem(memory, outix, Int64(x < y))
            elseif opcode == EQUALS_OPCODE
                writemem(memory, outix, Int64(x == y))
            end
            pc += 4
        elseif OPCODES_ARG_COUNT[opcode] == 2
            cond = readmem(memory, pc + 1, modes[1])
            target = readmem(memory, pc + 2, modes[2]) + 1
            pc += 3
            if opcode == JUMP_IF_TRUE
                if cond != 0
                    pc = target
                end
            elseif opcode == JUMP_IF_FALSE
                if cond == 0
                    pc = target
                end
            end
        elseif OPCODES_ARG_COUNT[opcode] == 1
            if opcode == INPUT_OPCODE
                outaddr = memory[pc + 1] + 1
                memory[outaddr] = input
            elseif opcode == OUTPUT_OPCODE
                last_output = readmem(memory, pc + 1, modes[1])
                if last_output != 0
                    println("Test $(test) failed: $(last_output) off stored in $(pc+1)")
                end
                test += 1
            end
            pc += 2
        else
            error("Unsupported opcode $(opcode)")
        end
    end
end

diagnostic_code = interpret(program, 1)
println("Part 1: $(diagnostic_code)")

test1 = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
diagnostic_code = interpret(test1, 0)
println("Test 1: $(diagnostic_code)")
diagnostic_code = interpret(test1, 1)
println("Test 2: $(diagnostic_code)")

diagnostic_code = interpret(program, 5)
println("Part 2: $(diagnostic_code)")