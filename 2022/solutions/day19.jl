using Dates

"Bag of resources"
struct Resources
    ores::Int64
    clays::Int64
    obsidians::Int64
    geodes::Int64
end

function gte(r1::Resources, r2::Resources)
    (
        (r1.ores >= r2.ores) &&
        (r1.clays >= r2.clays) &&
        (r1.obsidians >= r2.obsidians) &&
        (r1.geodes >= r2.geodes)
    )
end

function add(resources::Resources, price::Resources)
    Resources(
        resources.ores + price.ores,
        resources.clays + price.clays,
        resources.obsidians + price.obsidians,
        resources.geodes + price.geodes,
    )
end

function subtract(resources::Resources, price::Resources)
    Resources(
        resources.ores - price.ores,
        resources.clays - price.clays,
        resources.obsidians - price.obsidians,
        resources.geodes - price.geodes,
    )
end

"Robot factory blueprint"
struct Blueprint
    id::Int64
    ore_price::Resources
    clay_price::Resources
    obsidian_price::Resources
    geode_price::Resources

    function Blueprint(line::String)
        x = split(line, " ")
        int(s) = parse(Int64, s)
        new(
            int(replace(x[2], ":" => "")),
            Resources(int(x[7]), 0, 0, 0),
            Resources(int(x[13]), 0, 0, 0),
            Resources(int(x[19]), int(x[22]), 0, 0),
            Resources(int(x[28]), 0, int(x[31]), 0),
        )
    end
end

"Utility function to load the blueprints"
function get_blueprints()
    root = dirname(dirname(@__FILE__))
    path = joinpath(root, "data", "day19.txt")
    open(path) do file
        return [Blueprint(line) for line in readlines(file)]
    end
end

"Current state"
struct State
    resources::Resources
    robots::Resources
    remaining_minutes::Int64
end

now_string() = Dates.format(now(), "YYYY-mm-dd HH:MM:SS")

"Calculate quality of a blueprint"
function calc_quality(blueprint::Blueprint, remaining_minutes::Int64)
    print(now_string(), " Quality of blueprint ", blueprint.id, " is ... ")
    resources = Resources(0, 0, 0, 0)
    robots = Resources(1, 0, 0, 0)
    cache = Dict{State, Int64}()
    quality = calc_quality(
        blueprint,
        resources,
        robots,
        remaining_minutes,
        0,
        cache,
    )
    println(quality)
    quality
end

function calc_quality(
    blueprint::Blueprint,
    resources::Resources,
    robots::Resources,
    remaining_minutes::Int64,
    current_max::Int64,
    cache::Dict{State, Int64},
)
    # 1. we've reached the end!
    if remaining_minutes == 0
        return resources.geodes
    end

    # 2. check the cache
    key = State(resources, robots, remaining_minutes)
    if haskey(cache, key)
        return cache[key]
    end

    # 3. check best case scenario, if its not good enough, give up!
    max_possible = resources.geodes + sum(robots.geodes + i for i = 0:remaining_minutes - 1)
    if max_possible <= current_max
        cache[key] = 0
        return 0
    end

    # 4. do nothing
    next_resources = add(resources, robots)
    max_quality = calc_quality(
        blueprint,
        next_resources,
        robots,
        remaining_minutes - 1,
        current_max,
        cache,
    )

    # 5. try buying robots
    for (new_robot, price) in [
        (Resources(1, 0, 0, 0), blueprint.ore_price),
        (Resources(0, 1, 0, 0), blueprint.clay_price),
        (Resources(0, 0, 1, 0), blueprint.obsidian_price),
        (Resources(0, 0, 0, 1), blueprint.geode_price),
    ]
        if gte(resources, price)
            quality = calc_quality(
                blueprint,
                subtract(next_resources, price),
                add(robots, new_robot),
                remaining_minutes - 1,
                max(max_quality, current_max),
                cache,
            )
            max_quality = max(max_quality, quality)
        end
    end

    # 6. update cache
    cache[key] = max_quality
    max_quality
end

"Part 1"
function part1()
    total_quality = sum(b.id * calc_quality(b, 24) for b in get_blueprints())
    println(now_string(), " PART 1: $total_quality")
end

"Part 2"
function part2()
    println(now_string(), " PART 2:")
end

# 1.5 hours for part 1
part1()
part2()
