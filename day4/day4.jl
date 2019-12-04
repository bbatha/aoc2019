function counter(nums::Array{Char})::Array{Int8}
    counts = zeros(Int8, 10)
    for n in nums
        counts[n - '/'] += 1
    end
    counts
end

function combinations(start, fin, tester)
    count = 0
    for target in start:fin
        chars = collect(string(target))
        if issorted(chars) && tester(counter(chars))
            count += 1
        end
    end
    count
end

test_part1(counts) = maximum(counts) >= 2

part1 = combinations(234208, 765869, test_part1)
println("Part 1 $(part1)")

test_part2(counts) = any(c -> c == 2, counts)

part2 = combinations(234208, 765869, test_part2)
println("Part 2 $(part2)")