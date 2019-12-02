using DelimitedFiles

fuel_required(mass::Int64)::Int64 = max(div(mass, 3) - 2, 0)

function fuel_required_pt1(modules::Array{Int64})::Int64
    total = 0
    for mod in modules
        total += fuel_required(mod)
    end
    return total
end

function fuel_required_pt2(modules::Array{Int64})::Int64
    total = 0
    for mod in modules
        module_fuel = fuel_required(mod)
        while module_fuel != 0
            total += module_fuel
            module_fuel = fuel_required(module_fuel)
        end
    end
    return total
end


modules = readdlm("day1/input.txt", '\t', Int64, '\n')
fuel = fuel_required_pt1(modules)
println("Fuel required pt1: $(fuel)")

fuel2 = fuel_required_pt2(modules)
println("Fuel required pt2: $(fuel2)")