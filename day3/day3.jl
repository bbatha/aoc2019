using DelimitedFiles

input = "day3/input.txt"

(wire1, wire2) = open(input) do f
    wires = []
    for l in eachline(f)
        parsed = split(l, ',')
        push!(wires, parsed)
    end
    wires
end

interpret(s) = (s[1], parse(Int64, s[2:end]))

struct Line
    start::Tuple{Int64,Int64}
    fin::Tuple{Int64,Int64}
    steps::Int64
end


function to_lines(directions::Array{SubString{String}})::Array{Line}
    last = (0,0)
    total_distance = 0
    coords = []
    for raw in directions
        (dir, distance) = interpret(raw)
        total_distance += distance
        next = (if dir == 'R'
            (last[1] + distance, last[2])
        elseif dir == 'L'
            (last[1] - distance, last[2])
        elseif dir == 'U'
            (last[1], last[2] + distance)
        elseif dir == 'D'
            (last[1], last[2] - distance)
        else
            error("Unknown direction $(dir)")
        end)
        push!(coords, Line(last, next, total_distance))
        last = next
    end
    coords
end

struct Intersection
    point::Tuple{Int64, Int64}
    steps::Int64
end

function pick_horizontal(line_a, line_b)::Union{Nothing, Line}
    is_only_horizontal(a, b) = a.start[2] == a.fin[2] && b.start[2] != b.fin[2]
    if is_only_horizontal(line_a, line_b)
        line_a
    elseif is_only_horizontal(line_b, line_a)
        line_b
    else
        nothing
    end
end

function pick_vertical(line_a, line_b)::Union{Nothing, Line}
    is_only_vertical(a, b) = a.start[1] == a.fin[1] && b.start[1] != b.fin[1]
    if is_only_vertical(line_a, line_b)
        line_a
    elseif is_only_vertical(line_b, line_a)
        line_b
    else
        nothing
    end
end

function in_bounds(point, horizontal, vertical)::Bool
    if point == (0,0)
        return false
    end
    (x, y) = point
    (x_begin, x_end) = extrema([horizontal.start[1], horizontal.fin[1]])
    (y_begin, y_end) = extrema([vertical.start[2], vertical.fin[2]])
    x_inbounds = x >= x_begin && x <= x_end
    y_inbounds = y >= y_begin && y <= y_end
    x_inbounds && y_inbounds
end

function intersect(line_a::Line, line_b::Line)::Union{Nothing, Intersection}
    horizontal = pick_horizontal(line_a, line_b)
    if horizontal == nothing
        return nothing
    end
    vertical = pick_vertical(line_a, line_b)
    if vertical == nothing
        return nothing
    end
    intersect = (vertical.start[1], horizontal.start[2])

    if !in_bounds(intersect, horizontal, vertical)
        return nothing
    end

    steps_x = horizontal.steps - abs(horizontal.fin[1] - intersect[1])
    steps_y = vertical.steps - abs(vertical.fin[2] - intersect[2])
    Intersection(intersect, steps_x + steps_y)
end

function intersections(a::Array{Line}, b::Array{Line})::Array{Intersection}
    intersections = Dict{Tuple{Int64, Int64}, Intersection}()
    for line_a in a, line_b in b
        it = intersect(line_a, line_b)
        if it == nothing
            continue
        end
        if haskey(intersections, it.point)
            if intersections[it.point].steps > it.steps
                intersections[it.point] = it
            end
        else
            intersections[it.point] = it
        end
    end
    collect(values(intersections))
end

intersections(a::Array{SubString{String}}, b::Array{SubString{String}}) = intersections(to_lines(a), to_lines(b))
distance(x::Intersection) = abs(0 - x.point[1]) + abs(0 - x.point[2])

intersects = intersections(wire1, wire2)
dist = minimum(distance(i) for i in intersects)
println("Part 1 $(dist)")

steps = minimum(i.steps for i in intersects)
println("Part 2 $(steps)")