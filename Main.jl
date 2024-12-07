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

# Day 5

function read_ordering(filepath)
    raw = split(read(filepath,String),"\r\n\r\n")
    rules = parse.(Int64,hcat(split.(readlines(IOBuffer(raw[1])),'|')...))
    lists = [parse.(Int64,x) for x in split.(readlines(IOBuffer(raw[2])),',')]
    return rules, lists
end

function find_valid_lists(rules,lists)
    total = 0
    valid_lists = []
    fail_lists = []
    for list in lists
        n = length(list)
        for p in 2:n
            val =  list[p]
            afters = rules[2,findall(rules[1,:] .== val)]
            if any(in.(afters,[list[1:p-1]]))
                push!(fail_lists,list)
                break
            elseif p == n
                push!(valid_lists,list)
            end
        end
    end
    return valid_lists,fail_lists
end

function day5_part1()
    rules, lists = read_ordering("Data\\Day5test.txt")
    good,_ = find_valid_lists(rules,lists)
    total = sum([x[Int((length(x)+1)/2)] for x in good])
    return print("Total mid values add to $total")
end

function fix_order(list,rules)
    n = length(list)
    for p in 2:n
        val =  list[p]
        afters = rules[2,findall(rules[1,:] .== val)]
        fails = in.(list[1:p-1],[afters])
        if any(fails)
            if all(fails)
                list = vcat(val,list[1:p-1],list[p+1:end])
            else
                list = vcat(list[1:p-1][.!(fails)],val,list[1:p-1][fails],list[p+1:end])
            end
        end
    end
    return list
end

function day5_part2()
    rules, lists = read_ordering("Data\\Day5.txt")
    _, bad = find_valid_lists(rules,lists)
    fixed = fix_order.(bad,Ref(rules))
    total = sum([x[Int((length(x)+1)/2)] for x in fixed])
    return print("Total fixed mid values add to $total")
end

@time day5_part1()
@time day5_part2()

# Day 6

function read_map(filename)
    raw = readlines(filename)
    as_array = permutedims(hcat(collect.(raw)...))
    return as_array
end

function next_position(guard)
    pos = guard[1]
    if guard[2] == 1
        next_pos = [pos[1]-1,pos[2]]
    elseif guard[2] == 2
        next_pos = [pos[1],pos[2]+1]
    elseif guard[2] == 3
        next_pos = [pos[1]+1,pos[2]]
    else
        next_pos = [pos[1],pos[2]-1]
    end
    return next_pos
end

function left_map_test(map_array,pos)
    n,m = size(map_array)
    if any([minimum(pos) == 0, maximum(pos) == n+1])
        return true
    else
        return false
    end
end

function find_guard(map_array)
    loc = findfirst(map_array .== '^')
    return [loc[1],loc[2]]
end

function day6_part1()
    map_array = read_map("Data\\Day6.txt")
    loc1 = find_guard(map_array)
    guard = [loc1,1] # 1 up 2 right 3 down 4 left, turning order
    map_array[loc1[1],loc1[2]] = '.'
    count = length(find_covered_places(guard,map_array))
    return print("Total covered placed equals $count\n")
end

function find_covered_places(guard,map_array)
    pos_history = []
    while true
        next_pos =  next_position(guard)
        if left_map_test(map_array,next_pos)
            break
        elseif getindex(map_array,next_pos...) == '#'
            guard = [guard[1],mod(guard[2],4)+1]
        else
            guard = [next_pos,guard[2]]
            push!(pos_history,guard[1])
        end
    end
    return unique(pos_history)
end


function loop_test(map_array,guard,obstruction)
    new_map = copy(map_array)
    new_map[obstruction[1],obstruction[2]] = '#'
    pos_history = []
    while true
        next_pos = next_position(guard)
        if in(guard,pos_history)
            return 1
        elseif left_map_test(new_map,next_pos)
            return 0
        elseif getindex(new_map,next_pos...) == '#'
            guard = [guard[1],mod(guard[2],4)+1]
        else
            push!(pos_history,guard)
            guard = [next_pos,guard[2]]
        end
    end
end

function day6_part2()
    map_array = read_map("Data\\Day6.txt")
    loc1 = find_guard(map_array)
    guard = [loc1,1] # 1 up 2 right 3 down 4 left, turning order
    possible_positions = find_covered_places(guard,map_array)
    map_array[loc1[1],loc1[2]] = '.'
    total = sum([loop_test(map_array,guard,obstruction) for obstruction in possible_positions])
    return print("Total looping positions is $total\n")
end

@time day6_part1()
@time day6_part2() # Took 1291 seconds (21.5 minutes) when testing

# Day 7

function read_equations(filename)
    raw_lines = split.(readlines(filename),": ")
    targets = parse.(Int64,getindex.(raw_lines,1))
    operator_lists = [parse.(Int64,split(x," ")) for x in getindex.(raw_lines,2)]
    return targets, operator_lists
end
 
function f(x,y,num)
    if num == 0
        return x + y
    elseif num == 1
        return x * y
    elseif num == 2
        return parse(Int,prod(string.([x,y])))
    end
end

function brute_force_test(target,operators,r)
    n =  length(operators)-1
    perms = digits.(0:r^n-1,base=r,pad=n)
    for funcs in perms
        val = operators[1]
        for i in 1:n
            val = f(val,operators[i+1],funcs[i])
        end
        if val == target
            return true
        end
    end
    return false
end

function day7_part1()
    targets, operator_lists = read_equations("Data\\Day7.txt")
    total = sum(targets[brute_force_test.(targets,operator_lists,2)])
    return print("Calibration result is $total\n")
end

function day7_part2()
    targets, operator_lists = read_equations("Data\\Day7.txt")
    total = sum(targets[brute_force_test.(targets,operator_lists,3)])
    return print("Calibration result is $total\n")
end
    
    
@time day7_part1()
@time day7_part2()