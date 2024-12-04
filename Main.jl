### Advent of Code 2024

# Day 1

function read_lists(filename)
    data = parse.(Int64,hcat(split.(readlines(filename),"   ")...))
    return permutedims(data)
end

function day1_part1()
    lists = read_lists("Data\\Day1.txt")
    total_dif =  sum(abs.(sort(lists[:,1]) .- sort(lists[:,2])))
    return print("Total Distance between lists is $total_dif")
end

function day1_part2()
    lists = read_lists("Data\\Day1.txt")
    list_counts = [sum(lists[:,2] .== x) for x in lists[:,1]]
    answer = sum(list_counts .* lists[:,1])
    return print("Total similarity score of $answer")
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
    return print("Number of safe lines is $test_results")
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
    return print("Number of safe lines is $final_total")
end

@time day2_part1()
@time day2_part2()

# Day 3

function find_mul_prods(line)
    total = 0
    mul_sections = split(line,"mul(")
    for part in mul_sections
        if length(part) == 0
            continue
        else
            p1 = findfirst(.!([isdigit(x) for x in part]))
            if p1 == length(part) || p1 == 1
                continue
            elseif part[p1] == ','
                p2 = findfirst(.!([isdigit(x) for x in part[p1+1:end]]))
                if p2 == 1
                    continue
                elseif part[p2+p1] == ')'
                    total += prod(parse.(Int64,[part[1:p1-1],part[p1+1:p1+p2-1]]))
                else
                    continue
                end
            else
                continue
            end
        end
    end
    return total
end

function day3_part1()
    raw = readlines("Data\\Day3.txt")
    answer = sum(find_mul_prods.(raw))
    return print("Total multiply amount is $answer")
end

function do_dont_multiply(line)
    dont_sections = split(line,"don't()")
    total = find_mul_prods(dont_sections[1])
    for sect in dont_sections[2:end]
        do_sections = split(sect,"do()")
        if length(do_sections) == 1
            continue
        else
            total += sum(find_mul_prods.(do_sections[2:end]))
        end
    end
    return total
end

function day3_part2()
    raw = prod(readlines("Data\\Day3.txt"))
    answer = do_dont_multiply(raw)
    return print("Total multiply amount is $answer")
end  

@time day3_part1()
@time day3_part2()

# Day 4

function search_string(line,word)
    word_count = 0
    p = 1
    n = length(word)
    starts = findall([x .== word[1] for x in line[1:end-n+1]])
    for s in starts
        if line[s:s+n-1] == word
            word_count += 1
        end
    end
    return word_count
end

function find_words(lines,word)
    return sum([search_string(line,word) + search_string(reverse(line),word) for line in lines])
end

function turn_square(lines)
    n = length(lines[1])
    return [prod(getindex.(lines,m)) for m in 1:n]
end

function tilt_square(lines)
    n = length(lines[1])
    return [prod([lines[j][k-j+1] for j in min(n,k):-1:max(1,k-n+1)]) for k in 1:n*2-1]
end
    
function day4_part1()
    puzzle = readlines("Data\\Day4.txt")
    all_squares = [puzzle,turn_square(puzzle),tilt_square(puzzle),tilt_square(reverse.(puzzle))]
    total = sum(find_words.(all_squares,Ref("XMAS")))
    return print("Total word count of $total")
end

function count_xmas(lines)
    xmas_count = 0
    n = length(lines)
    for r in 2:n-1
        mid_as = findall([x .== 'A' for x in lines[r][2:end-1]]) .+ 1
        for s in mid_as
            if all([lines[r-1][s-1] == 'M', # M.M
                lines[r-1][s+1] == 'M',     # .A.
                lines[r+1][s-1] == 'S',     # S.S
                lines[r+1][s+1] == 'S'])
                xmas_count += 1
            end
        end
    end
    return xmas_count
end

function day4_part2()
    puzzle = readlines("Data\\Day4.txt")
    all_squares = [puzzle,reverse(puzzle),turn_square(puzzle),reverse(turn_square(puzzle))]
    total = sum(count_xmas.(all_squares))
    return print("Total xmas count of $total")
end

@time day4_part1()
@time day4_part2()