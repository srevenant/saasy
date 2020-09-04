# apps to suppress from the output
# - Erlang applications can show up in the diagram from dependencies. Those can
#   be explicitly suppressed by adding the name (as an atom) to the list.
#   Example: `suppressed = MapSet.new([:csv])`
suppressed = MapSet.new([])

deps = Mix.Dep.loaded([]) |> Enum.filter(& &1.top_level)

fun = fn dep, deps ->
  dep = Enum.find(deps, & &1.app == dep.app)
  children = Enum.filter(dep.deps, & Keyword.get(&1.opts, :in_umbrella))
  {{dep.app, nil}, children}
end

# Remove any root-level dependencies that are in the "suppressed" list.
deps =
  Enum.filter(deps, fn(dep) ->
    # return false if "app" is in the suppressed list.
    # Otherwise return true, to include the dependency
    !MapSet.member?(suppressed, dep.app)
  end)

Mix.Utils.print_tree(deps, fn dep -> fun.(dep, deps) end)
Mix.Utils.write_dot_graph!("diagram.dot", "deps", deps, fn dep -> fun.(dep, deps) end)

System.cmd("dot", ["-Tpng", "diagram.dot", "-odiagram.png"])
