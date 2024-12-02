### Advent of Code 2024

# Day 1

function read_lists(filename)
    data = parse.(Int64,hcat(split.(readlines(filename),"   ")...))
    return permutedims(data)
end

function day1_part1()
    lists = read_lists("Data\\Day1.txt")
    total_dif =  sum(abs.(sort(lists[:,1]) .- sort(lists[:,2])))
    print("Total Distance between lists is $total_dif")
    return nothing
end

function day1_part2()
    lists = read_lists("Data\\Day1.txt")
    list_counts = [sum(lists[:,2] .== x) for x in lists[:,1]]
    answer = sum(list_counts .* lists[:,1])
    print("Total similarity score of $answer")
    return nothing
end

@time day1_part1()
@time day1_part2()

# Day 2

function read_reports(filename)
    data = split.(readlines(filename)," ")
    return [parse.(Int64,x) for x in data]
end

function same_direction_test(line)
    return length(unique(sign.(line))) == 1
end
    
function bounds_test(line)
    return all(0 .< extrema(abs.(line)) .< 4)
end

function day2_part1()
    data = read_reports("Data\\day2.txt")
    increments = [x[2:end] .- x[1:end-1] for x in data]
    test_results = sum([same_direction_test(x) && bounds_test(x) for x in increments])
    print("Number of safe lines is $test_results")
    return nothing
end

function test_dampened_levels(line)
    n = length(line)
    for i in 1:n
        dampened_line = line[1:n .!= i]
        new_increments = dampened_line[2:end] .- dampened_line[1:end-1]
        if same_direction_test(new_increments) && bounds_test(new_increments)
            return true
        end
    end
    return false
end

function day2_part2()
    data = read_reports("Data\\day2.txt")
    increments = [x[2:end] .- x[1:end-1] for x in data]
    safe_levels = [same_direction_test(x) && bounds_test(x) for x in increments]
    damp_results = test_dampened_levels.(data[.!(safe_levels)])
    final_total = sum(safe_levels) + sum(damp_results)
    print("Number of safe lines is $final_total")
    return nothing
end

@time day2_part1()
@time day2_part2()