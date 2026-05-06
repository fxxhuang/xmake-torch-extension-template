-- rule: cuda.auto - configure CUDA build with native GPU + sensible defaults
--
-- Usage:
--   add_rules("cuda.auto")                        -- native only
--   add_rules("cuda.auto", {ptx = "compute_80"})  -- native SASS + PTX fallback
--   add_rules("cuda.auto", {cxx = "c++17"})       -- explicit C++ std for nvcc host
--
-- What it does:
--   1. add_cugencodes("native") — SASS for the current host GPU (auto-detect)
--   2. optional PTX virtual arch for forward compatibility on newer GPUs
--   3. common nvcc flags: -std=c++17, --expt-relaxed-constexpr, -Xcompiler=-fPIC
rule("cuda.auto")
    on_config(function (target)
        -- SASS code for current host GPU (auto-detected)
        target:add("cugencodes", "native")

        -- Optional PTX virtual architecture for forward compat
        local ptx = target:extraconf("rules", "cuda.auto", "ptx")
        if ptx then
            target:add("cugencodes", ptx)
        end

        -- C++ std for nvcc (defaults to c++17)
        local cxx = target:extraconf("rules", "cuda.auto", "cxx") or "c++17"
        target:add("cuflags", "-std=" .. cxx)

        -- Common flags: relaxed constexpr lets nvcc accept constexpr host funcs,
        -- -fPIC forwarded to host compiler for shared-library targets.
        target:add("cuflags", "--expt-relaxed-constexpr")
        if not target:is_plat("windows") then
            target:add("cuflags", "-Xcompiler=-fPIC")
        end
    end)
rule_end()
