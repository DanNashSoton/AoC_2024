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
            if val > target
                break
            end
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

# Day 8

function in_map(antenna_map,p)
    if 0 < p[1] <= size(antenna_map,1) && 0 < p[2] <= size(antenna_map,1)
        return true
    end
    return false
end

function find_antinodes(antenna_map,signal)
    loc = findall(antenna_map .== signal)
    n = length(loc)
    antinodes = []
    for i in 1:n-1
        for j in i+1:n
            dif = loc[i] - loc[j]
            p1 = loc[i] + dif
            p2 = loc[j] - dif
            [if in_map(antenna_map,p) push!(antinodes,p) end for p in [p1,p2]]
        end
    end
    return antinodes
end

function day8_part1()
    antenna_map = hcat(collect.(readlines("Data\\Day8.txt"))...)
    signals = unique(antenna_map)[2:end]
    total = length(unique(vcat(find_antinodes.(Ref(antenna_map),signals)...)))
    return print("Number of valid antinodes is $total")
end

function find_pair_antinodes(antenna_map,p1,p2)
    dif = p1 - p2
    divisor = gcd(dif[1],dif[2])
    if divisor > 1
        dif = CartesianIndex(Int.([dif[1]/divisor,dif[2]/divisor])...)
    end
    locations = [p1]
    p = p1 + dif
    while in_map(antenna_map,p)
        push!(locations,p)
        p = p + dif
    end
    p = p1 - dif
    while in_map(antenna_map,p)
        push!(locations,p)
        p = p - dif
    end
    return locations
end

function find_all_antinodes(antenna_map,signal)
    loc = findall(antenna_map .== signal)
    n = length(loc)
    antinodes = []
    for i in 1:n-1
        for j in i+1:n
            push!(antinodes,find_pair_antinodes(antenna_map,loc[i],loc[j]))
        end
    end
    return unique(vcat(antinodes...))
end

function day8_part2()
    antenna_map = hcat(collect.(readlines("Data\\Day8.txt"))...)
    signals = unique(antenna_map)[2:end]
    total = length(unique(vcat(find_all_antinodes.(Ref(antenna_map),signals)...)))
    return print("Number of valid antinodes is $total")
end

@time day8_part1()
@time day8_part2()

# Day 9

function create_disk(vals)
    disk = ones(Int64,sum(vals)) .* -1
    counter = 0
    p = 1
    is_group = true
    for val in vals
        if val > 0
            if is_group
                disk[p:p+val-1] .= counter
                counter += 1
            end
            p += val
        end
        is_group = !(is_group)
    end
    return disk
end

function compact_file(disk)
    n = count(disk .>= 0)
    while length(disk) .> n
        p = findfirst(disk .== -1)
        x = pop!(disk)
        while x .== -1
            x = pop!(disk)
        end
        disk[p] = x
    end
    return disk
end

function day9_part1()
    vals = parse.(Int,collect(read("Data\\Day9.txt",String)))
    disk = create_disk(vals)
    reduced = compact_file(disk)
    checksum = sum(reduced .* collect(0:length(reduced)-1))
    return print("Filesystem Checksum is $checksum")
end

function create_group_list(vals)
    list = Vector{Vector{Int64}}(undef,length(vals))
    counter = 0
    p = 1
    is_group = true
    for val in vals
        if is_group
            list[p] = [counter for _ in 1:val]
            counter += 1
        else
            list[p] = [-1 for _ in 1:val]
        end
        p += 1
        is_group = !(is_group)
    end
    return list
end

function find_first_space(list,n)
    for (i,x) in enumerate(list)
        if count(x .== -1) >= n
            return i
        end
    end
    return 0
end

function compact_list(list)
    actual_groups = findall(sum.(list) .> 0)
    for i in reverse(actual_groups)
        n = length(list[i])
        x = find_first_space(list[1:i],n)
        if x == 0
            continue
        else
            if list[x][1] == -1
                list[x][1:n] .= list[i]
            else
                p = findfirst(list[x] .== -1)
                list[x][p:p+n-1] .= list[i]
            end
            list[i] = [-1 for _ in 1:n]
        end
    end
    return vcat(list...)
end

function day9_part2()
    vals = parse.(Int,collect(read("Data\\Day9.txt",String)))
    list = create_group_list(vals)
    compacted = compact_list(list)
    checksum = sum(max.(0,compacted .* collect(0:length(compacted)-1)))
    return print("Filesystem Checksum is $checksum")
end


@time day9_part1()
@time day9_part2()

# Day 10

function pad_map(topo_map)
    n = size(topo_map,1)
    padded = hcat(fill(-1,n),topo_map,fill(-1,n))
    return vcat(fill(-1,1,n+2),padded,fill(-1,1,n+2))
end

function find_neighbours(padded_map,index)
    positions =  Ref(index) .+ directions
    valid = padded_map[positions] .== padded_map[index] + 1
    return positions[valid]
end

function find_trailhead_score1(padded_map,index)
    queue = find_neighbours(padded_map,index)
    locations = []
    while !(isempty(queue))
        x = popfirst!(queue)
        if padded_map[x] == 9
            push!(locations,x)
        else
            queue = vcat(queue,find_neighbours(padded_map,x))
        end
    end
    return length(unique(locations))
end

function find_trailhead_score2(padded_map,index)
    queue = find_neighbours(padded_map,index)
    score = 0
    while !(isempty(queue))
        x = popfirst!(queue)
        if padded_map[x] == 9
            score += 1
        else
            append!(queue,find_neighbours(padded_map,x))
        end
    end
    return score
end

function day10_part1()
    topo_map = parse.(Int64,hcat(collect.(readlines("Data\\Day10.txt"))...))
    padded_map = pad_map(topo_map)
    start_positions = findall(padded_map .== 0)
    score = sum(find_trailhead_score1.(Ref(padded_map),start_positions))
    return print("Total trailhead score is $score")
end

function day10_part2()
    topo_map = parse.(Int64,hcat(collect.(readlines("Data\\Day10.txt"))...))
    padded_map = pad_map(topo_map)
    start_positions = findall(padded_map .== 0)
    score = sum(find_trailhead_score2.(Ref(padded_map),start_positions))
    return print("Total trailhead score is $score")
end

const directions = [CartesianIndex(-1,0),CartesianIndex(1,0),CartesianIndex(0,1),CartesianIndex(0,-1)]

@time day10_part1()
@time day10_part2()

# Day 11

using Memoize

function split_int(val)
    n = Int(length(digits(val))/2)
    return [Int(floor(val,sigdigits=n) / 10^n), mod(val,10^n)]
end

function build_indexes()
    v1 = Vector{Int64}(undef,N)
    v2 = Vector{Int64}(undef,N)
    for i in 1:N
        if iseven(length(digits(i)))
            x = split_int(i)
            v1[i] = x[2]
            v2[i] = x[1]
        else
            v1[i] = i * 2024
        end
    end
    return v1, v2
end

function too_big(val)
    n = length(digits(val))
    if iseven(n)
        n2 = Int(n/2)
        return [Int(floor(val,sigdigits=n2) / 10^n2), mod(val,10^n2)]
    else
        return [0,val * 2024,0]
    end
end

function blink_faster(list)
    x1 = zeros(Int,length(list))
    x2 = zeros(Int,length(list))
    for i in eachindex(list)
        if list[i] == 0
            x1[i] = 1
        elseif list[i] <= N
            x1[i] = v1[list[i]]
            x2[i] = v2[list[i]]
        else
            x = too_big(list[i])
            x1[i] = x[2]
            x2[i] = x[1]
        end
    end
    return vcat(x1,x2[x2 .> 0])
end

@memoize function n_blinks(list,n)
    for _ in 1:n
        list = blink_faster(list)
    end
    return list
end

const N = 10_000_000
const v1,v2 = build_indexes()

@memoize function jump_to_answer(val)
    return length(vcat(n_blinks.(n_blinks(val,15),15)...))
end

function blink_list_n(list,p)
    n = length(list)
    out = Vector{Vector{Int64}}(undef,n)
    for i in 1:n
        out[i] = n_blinks(list[i],p)
    end
    return vcat(out...)
end

@memoize function jump_to_answer(val)
    return length(n_blinks(val,25))
end


function sum_jumps(list)
    counter = 0
    for val in list
        counter += jump_to_answer(val)
    end
    return counter
end

function day11_part1()
    list = parse.(Int64,split(read("Data\\Day11.txt",String)))
    answer = sum_jumps(list)
    return print("Answer is $answer")
end

function day11_part2()
    list = parse.(Int64,split(read("Data\\Day11.txt",String)))
    for x in 1:2
        list = blink_list_n(list,25)
    end
    answer = sum_jumps(list)
    return print("Answer is $answer \n")
end

@time day11_part1()
@time day11_part2()

# Day 12

function distance(c1,c2)
    dif = c1 - c2
    return abs(dif[1]) + abs(dif[2])
end

function calculate_perimeter(table,region)
    points = zeros(Int,size(table))
    points[region] .= 1
    perim = 0
    for p in findall(points .== 0)
        perim += count(distance.(Ref(p),region) .== 1)
    end
    return perim
end

function find_price(table,start)
    type = table[start]
    all_possible = findall(table .== type)
    region = [start]
    n = 1
    while true
        distances = [minimum(distance.(Ref(x),region)) for x in all_possible]
        region =  all_possible[distances .<= 1]
        if length(region) == n
            break
        else
            n = length(region)
        end
    end
    perim = calculate_perimeter(table,region)
    return n * perim, region
end

function pad_table(table)
    a,b = size(table)
    padded = vcat(fill('#',1,a+2),hcat(fill('#',a),table,fill('#',a)),fill('#',1,a+2))
    visited = zeros(Int,a+2,b+2)
    visited[1,:] .= 1
    visited[end,:] .= 1
    visited[:,1] .= 1
    visited[:,end] .= 1
    return padded, visited
end

function day12_part1()
    table =  hcat(collect.(readlines("Data\\Day12.txt"))...)
    visited = zeros(size(table))
    table, visited = pad_table(table)
    answer = 0
    while in(0,visited)
        start = findfirst(visited .== 0)
        price,locations = find_price(table,start)
        answer += price
        visited[locations] .= 1
    end
    return print("Total price is $answer")
end

function count_corners(region,p)
    counter = 0
    for i in 1:4
        corner = p + diag_directions[i]
        side1 = p + side_directions[i]
        side2 = p + side_directions[mod(i,4) + 1]
        if in(side1,region) && in(side2,region) #Concave corner
            counter += 1
        elseif in(corner,region) && !in(side1,region) && !in(side2,region) #Convex Corner
            counter += 1
        end
    end
    return counter
end

function count_sides(table,region)
    points = zeros(Int,size(table))
    points[region] .= 1
    sides = 0
    non_region = findall(points .== 0)
    relevant_only = non_region[[minimum(distance.(Ref(x),region)) for x in non_region] .<= 2]
    for p in relevant_only
        sides += count_corners(region,p)
    end
    return sides
end

function find_price_sides(table,start)
    type = table[start]
    all_possible = findall(table .== type)
    region = [start]
    n = 1
    while true
        distances = [minimum(distance.(Ref(x),region)) for x in all_possible]
        region =  all_possible[distances .<= 1]
        if length(region) == n
            break
        else
            n = length(region)
        end
    end
    sides = count_sides(table,region)
    return n * sides, region
end

const diag_directions = [CartesianIndex(1,1),CartesianIndex(-1,1),CartesianIndex(-1,-1),CartesianIndex(1,-1)]
const side_directions = [CartesianIndex(1,0),CartesianIndex(0,1),CartesianIndex(-1,0),CartesianIndex(0,-1)]

function day12_part2()
    table =  hcat(collect.(readlines("Data\\Day12.txt"))...)
    table, visited = pad_table(table)
    answer = 0
    while in(0,visited)
        start = findfirst(visited .== 0)
        price,locations = find_price_sides(table,start)
        answer += price
        visited[locations] .= 1
    end
    return print("Total price is $answer")
end

@time day12_part1()
@time day12_part2()

# Day 13

function find_numbers(button_string)
    p1 = findfirst(isdigit.(collect(button_string)))
    p2 = findfirst(.!isdigit.(collect(button_string[p1:end])))
    x_dist = parse(Int64,button_string[p1:p1+p2-2])
    y_dist = parse(Int64,button_string[p1+p2+3:end])
    return [x_dist,y_dist]
end

function parse_q(raw_q)
    parts = split(raw_q,"\r\n")
    return hcat(find_numbers.(parts)...)
end

function adjust_q(q)
    return hcat(q[:,1:2],q[:,3] .+ 10000000000000)
end

function matrix_det(A)
    return A[4]*A[1] - A[2]*A[3]
end

function algorithmic_solve(q) # Cramer Formula 
    A = q[:,1:2]
    b = q[:,3]
    x1 = matrix_det(hcat(b,q[:,2]))/matrix_det(A)
    x2 = matrix_det(hcat(q[:,1],b))/matrix_det(A)
    if all(isinteger.([x1,x2]))
        return Int(x1*3 + x2)
    else
        return 0
    end
end

function day13_part1()
    qs = [parse_q(x) for x in split.(read("Data\\Day13.txt",String),"\r\n\r\n")]
    results = sum(algorithmic_solve.(qs))
    return print("Fewest tokens needed is $results")
end

function day13_part2()
    qs = [adjust_q(parse_q(x)) for x in split.(read("Data\\Day13.txt",String),"\r\n\r\n")]
    results = sum(algorithmic_solve.(qs))
    return print("Fewest tokens needed is $results")
end

@time day13_part1()
@time day13_part2()

# Day 14

function parse_robot(line)
    return [parse(Int,line[x]) for x in findall(r"\d+|-\d+",line)]
end

function find_pos(robot,t,n,m)
    x = mod(robot[1] + robot[3] * t,n)
    y = mod(robot[2] + robot[4] * t,m)
    return [x,y]
end

function count_quadrants(positions,n,m)
    n_mid = (n-1)/2
    m_mid = (m-1)/2
    x_coords = getindex.(positions,1)
    y_coords = getindex.(positions,2)
    q1 = count((x_coords .< n_mid) .& (y_coords .< m_mid))
    q2 = count((x_coords .< n_mid) .& (y_coords .> m_mid))
    q3 = count((x_coords .> n_mid) .& (y_coords .< m_mid))
    q4 = count((x_coords .> n_mid) .& (y_coords .> m_mid))
    return prod([q1,q2,q3,q4])
end

function test_display(positions,n,m)
    visual = zeros(m,n)
    for p in positions
        visual[p[2]+1,p[1]+1] += 1
    end
    return visual
end

function day14_part1()
    robots = parse_robot.(readlines("Data\\Day14.txt"))
    positions = find_pos.(robots,100,101,103)
    answer = count_quadrants(positions,101,103)
    return print("Product of Safety scores is $answer")
end

using PlotlyJS

function produce_display(t)
    robots = parse_robot.(readlines("Data\\Day14.txt"))
    positions = find_pos.(robots,100,101,103)
    return test_display2(positions,101,103)
end

function test_display2(positions,n,m)
    visual = zeros(m,n)
    for p in positions
        visual[p[2]+1,p[1]+1] += 1
    end
    return plot(heatmap(x=n:-1:1,y=m:-1:1,z=visual))
end

#=

robots = parse_robot.(readlines("Data\\Day14.txt"))

Part 2 solved by sequentially looking at heatmaps of the results, 
    spotting a recurring pattern, then looking at results in that pattern

for t in 1:1000
    positions = find_pos.(robots,t,101,103)
    display(test_display2(positions,101,103))
    sleep(1)
    print(t)
    print("\n")
end

m = 103
n = 101

t_range = 63:103:10000

for t in t_range
    positions = find_pos.(robots,t,101,103)
    display(test_display2(positions,n,m))
    sleep(1)
    print(t)
    print("\n")
end

t = 6243
positions = find_pos.(robots,t,101,103)
test_display(positions,101,103)
display(test_display2(positions,101,103))

=#

# Day 15

function read_map_and_instructions(filename)
    raw_bits =  split(read(filename,String),"\r\n\r\n")
    grid = permutedims(hcat(collect.(readlines(IOBuffer(raw_bits[1])))...))
    instructions = prod(readlines(IOBuffer(raw_bits[2])))
    return grid, parse_instructions(instructions)
end

function parse_instructions(instructions)
    return [findfirst(['^','>','v','<'] .== x) for x in instructions]
end

function find_line(grid,current,instruct)
    boxes = [current + moves[instruct]]
    while grid[last(boxes) + moves[instruct]] == 'O'
        push!(boxes,last(boxes) + moves[instruct])
    end
    return vcat(current,boxes)
end

function apply_move(grid,instruct)
    current = findfirst(grid .== '@')
    next =  current + moves[instruct]
    if grid[next] == '.'
        grid[next] = '@'
        grid[current] = '.'
    elseif grid[next] == 'O'
        all_boxes = find_line(grid,current,instruct)
        if grid[last(all_boxes) + moves[instruct]] == '.'
            grid[all_boxes .+ Ref(moves[instruct])] = grid[all_boxes]
            grid[current] = '.'
        end
    end
    return grid
end

function calculate_location(box)
    return (box[1] - 1) * 100 + box[2] - 1
end

function enlarge_map(grid)
    char_swapped = [swap_grid[:,2][findfirst(x .== swap_grid[:,1])] for x in grid]
    return permutedims(hcat(collect.(prod(char_swapped,dims=2))...))
end

function find_box(grid,p)
    if grid[p] == '['
        return [p,p + CartesianIndex(0,1)]
    else
        return [p + CartesianIndex(0,-1),p]
    end
end

function find_moveable_boxes(grid,current,instruct)
    move = moves[instruct]
    next = current + move
    moveable_boxes = []
    box_queue = [find_box(grid,next)]
    while !isempty(box_queue)
        box = popfirst!(box_queue)
        if instruct == 2
            to_check = [box[2] + move]
        elseif instruct == 4
            to_check = [box[1] + move]
        else
            to_check = box .+ Ref(move)
        end
        for p in to_check
            if grid[p] == '#'
                return []
            elseif in(grid[p],['[',']'])
                push!(box_queue,find_box(grid,p))
            end
            push!(moveable_boxes,box)
        end
    end
    return moveable_boxes
end

function apply_move2(grid,instruct)
    current = findfirst(grid .== '@')
    move = moves[instruct]
    next =  current + move
    if grid[next] == '.'
        grid[next] = '@'
        grid[current] = '.'
    elseif in(grid[next],['[',']'])
        moveable_boxes = find_moveable_boxes(grid,current,instruct)
        if !isempty(moveable_boxes)
            for box in moveable_boxes
                grid[box[1]] = '.'
                grid[box[2]] = '.'
            end
            for box in moveable_boxes
                grid[box[1]+move] = '['
                grid[box[2]+move] = ']'
            end
            grid[next] = '@'
            grid[current] = '.'
        end
    end
    return grid
end

const moves = [CartesianIndex(-1,0),CartesianIndex(0,1),CartesianIndex(1,0),CartesianIndex(0,-1)] # ^ > v <
const swap_grid = ['#' "##" ; '@' "@." ; '.' ".." ; 'O' "[]"]

function day15_part1()
    grid, instructions = read_map_and_instructions("Data\\Day15.txt")
    # grid, instructions = read_map_and_instructions("Data\\Day15test.txt")
    for instruct in instructions
        grid = apply_move(grid,instruct)
    end
    all_boxes = findall(grid .== 'O')
    answer = sum(calculate_location.(all_boxes))
    return print("Final position of boxes is $answer")
end

function day15_part2()
    grid, instructions = read_map_and_instructions("Data\\Day15.txt")
    # grid, instructions = read_map_and_instructions("Data\\Day15test.txt")
    grid = enlarge_map(grid)
    for instruct in instructions
        grid = apply_move2(grid,instruct)
    end
    all_boxes = findall(grid .== '[')
    answer = sum(calculate_location.(all_boxes))
    return print("Final position of boxes is $answer")
end

@time day15_part1()
@time day15_part2()

# Day 16

function solve_maze_with_memory(maze)
    start_position = findfirst(maze .== 'S')
    position_queue = PriorityQueue([[CartesianIndex(0,0),start_position],2] => 0)
    memory_queue = PriorityQueue([[CartesianIndex(0,0),start_position],2] => 0)
    while true
        current = dequeue_pair!(position_queue)
        pos = current[1]
        loc = pos[1][2]
        cost = current[2]
        for dir in mod1.(collect(pos[2]-1:pos[2]+1),4)
            next_pos = loc + moves[dir]
            !in(maze[next_pos],['.','E']) && continue
            if dir == pos[2]
                next_cost = cost + 1
            else
                next_cost = cost + 1000
                next_pos = loc
            end
            next_pos == pos[1][1] && continue
            maze[next_pos] == 'E' && return next_cost, memory_queue
            history = [loc,next_pos]
            if haskey(position_queue,[history,dir])
                position_queue[[history,dir]] = min(position_queue[[history,dir]],next_cost)
            else
                enqueue!(position_queue,[history,dir],next_cost)
            end
            if haskey(memory_queue,[history,dir])
                memory_queue[[history,dir]] = min(memory_queue[[history,dir]],next_cost)
            else
                enqueue!(memory_queue,[history,dir],next_cost)
            end  
        end
    end
end

function arrange_memory(memory_queue)
    rearranged = Array{Any}(undef,length(memory_queue),4)
    for i in 1:length(memory_queue)
        data = dequeue_pair!(memory_queue)
        rearranged[i,:]= [data[1][1][1] data[1][1][2] data[1][2] data[2]]
    end
    return rearranged
end

function find_predecssors(memory_array,current_id)
    current = memory_array[current_id,:]
    at_previous = findall(memory_array[:,2] .== Ref(current[1]))
    direction_difs = abs.(memory_array[at_previous,3] .- current[3])
    required_costs = current[4] .- 1000 .^ min.(direction_difs,4 .- direction_difs)
    return at_previous[memory_array[at_previous,4] .== required_costs]
end

function parse_memory(maze,memory_array)
    finish = findfirst(maze .== 'E')
    next = memory_array[:,2] .+ moves[memory_array[:,3]]
    queue = findall(next .== Ref(finish))
    maze_tracker = copy(maze)
    [maze_tracker[p] = 'O' for p in vcat(finish,memory_array[queue,2])]
    while length(queue) > 0
        current_id = popfirst!(queue)
        prior_ids = find_predecssors(memory_array,current_id)
        [maze_tracker[p] = 'O' for p in memory_array[prior_ids,2]]
        append!(queue,prior_ids)
    end
    return sum(length(findall(maze_tracker .== 'O')))
end

using DataStructures
const moves = [CartesianIndex(-1,0),CartesianIndex(0,1),CartesianIndex(1,0),CartesianIndex(0,-1)]

function day16_part1()
    maze = permutedims(hcat(collect.(readlines("Data\\Day16.txt"))...))
    answer, _ = solve_maze_with_memory(maze)
    return print("Lowest cost is $answer")
end

function day16_part2()
    maze = permutedims(hcat(collect.(readlines("Data\\Day16.txt"))...))
    _, memory_queue = solve_maze_with_memory(maze)
    memory_array = arrange_memory(memory_queue)
    answer = parse_memory(maze,memory_array)
    return print("Number of tiles is $answer")
end

@time day16_part1()
@time day16_part2()