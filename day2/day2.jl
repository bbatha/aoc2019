using DelimitedFiles

program = reshape(readdlm("day2/input.txt", ',', Int64, '\n'), 1, :)

function interpret(program::Array{Int64}, x::Int64, y::Int64)
    memory = copy(program)
    memory[2] = x
    memory[3] = y

    for op in Iterators.partition(memory, 4)
        opcode = op[1]
        args = op[2:end] .+ 1
        (xix, yix, outix) = args
        x = memory[xix]
        y = memory[yix]
        if opcode == 99
            return memory[1]
        elseif opcode == 1
            memory[outix] = x + y
        elseif opcode == 2
            memory[outix] = x * y
        else
            error("Unsupported opcode $(opcode)")
        end
    end
end

function find_inputs(program::Array{Int64}, target::Int64)::Tuple{Int64, Int64}
    for x = 0:99, y = 0:99
        if target == interpret(program, x, y)
            return x, y
        end
    end
    error("Result not found")
end

part1 = interpret(program, 12, 2)
println("Program 1: $(part1)")

(noun, verb) = find_inputs(program, 19690720)
part2 = 100 * noun + verb
println("Program 2: $(part2)")