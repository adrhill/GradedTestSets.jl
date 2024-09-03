# Modified from DefaultTestSet's `print_test_results` in Test.jl
# https://github.com/JuliaLang/julia/blob/72aec423c2ab9f80c249d63fdd68b35833cfd7ed/stdlib/Test/src/Test.jl#L1070-L1119
# Copyright (c) 2009-2022: Jeff Bezanson, Stefan Karpinski, Viral B. Shah,
# and other contributors: https://github.com/JuliaLang/julia/contributors

function Base.show(io::IO, ts::GradedTestSet)
    print_graded_results(io, result(ts), 0)
end

function print_graded_results(io::IO, ts::GradedTestSet, depth_pad=0)
    return print_graded_results(io, result(ts), depth_pad)
end

# Convert number to integer if reasonable to avoid floating point representation
function display_number(n::Number)
    if n == round(n)
        return Int(n)
    else
        return n
    end
end

function print_graded_results(io::IO, res::GradingResult, depth_pad=0)
    scored = res.points_scored
    total = res.points_total
    fails = total - scored

    # For each category, take max of digits and header width if there are tests of that type
    pass_width  = _category_width("Scored", scored)
    fail_width  = _category_width("Missed", fails)
    total_width = _category_width("Total", total)

    # Calculate alignment of the test result counts by recursively walking tree of test sets
    align = max(get_alignment(res, 0), length("Grading Summary:"))

    # Print the outer test set header once
    pad = total == 0 ? "" : " "
    printstyled(io, rpad("Grading Summary:", align, " "), " |", pad; bold=true)
    pass_width > 0 &&
        printstyled(io, lpad("Scored", pass_width, " "), "  "; bold=true, color=:green)
    fail_width > 0 && printstyled(
        io, lpad("Missed", fail_width, " "), "  "; bold=true, color=Base.error_color()
    )
    total_width > 0 && printstyled(
        io, lpad("Total", total_width, " "), "  "; bold=true, color=Base.info_color()
    )
    println(io)
    # Recursively print a summary at every level
    print_counts(io, res, depth_pad, align, pass_width, fail_width, total_width)

    # Print Final score:
    line_width = align + pass_width + fail_width + total_width + 7
    println(io, "≡"^line_width)
    print(io, "Final score: ")
    printstyled(io, scored; color=:green)
    print(io, " / ")
    printstyled(io, total; color=Base.info_color())
    println(io)
end

function _category_width(category_name, count)
    digits = length(string(count))
    return digits > 0 ? max(length(category_name), digits) : 0
end

# Recursive function that finds the column that the result counts can begin at
# by taking into account the width of the descriptions and the amount of indentation.
# If a test set had no failures, and no failures in child test sets,
# there is no need to include those in calculating the alignment.
function get_alignment(res::GradingResult, depth::Int)
    res_width = 2 * depth + length(res.description) # minimum width at given depth
    isempty(res.subresults) && return res_width

    # Return maximum of this width and minimum width for all children (if they exist)
    child_widths = map(t -> get_alignment(t, depth + 1), res.subresults)
    return max(res_width, maximum(child_widths))
end
get_alignment(res, depth::Int) = 0

function print_counts(
    io::IO, res::GradingResult, depth, align, pass_width, fail_width, total_width
)
    scored = res.points_scored
    total = res.points_total
    fails = total - scored

    # Print header, with alignment that ensures all test results appear above each other
    print(io, rpad(string("  "^depth, res.description), align, " "), " | ")

    if scored > 0
        printstyled(io, lpad(string(scored), pass_width, " "), "  "; color=:green)
    elseif pass_width > 0 # No scored at this level, but some at another level
        print(io, lpad(" ", pass_width), "  ")
    end

    if fails > 0
        printstyled(
            io, lpad(string(fails), fail_width, " "), "  "; color=Base.error_color()
        )
    elseif fail_width > 0 # No fails at this level, but some at another level
        print(io, lpad(" ", fail_width), "  ")
    end

    if scored == 0 && fails == 0
        printstyled(io, lpad("None", total_width, " "), "  "; color=Base.info_color())
    else
        printstyled(
            io, lpad(string(total), total_width, " "), "  "; color=Base.info_color()
        )
    end
    println(io)

    if fails > 0
        for r in res.subresults
            print_counts(io, r, depth + 1, align, pass_width, fail_width, total_width)
        end
    end
end
