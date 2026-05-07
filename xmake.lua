add_rules("mode.debug", "mode.release")

includes("xmake/packages/pytorch.lua")
includes("xmake/modules/cuda.lua")
includes("xmake/rules/python_rules.lua")
includes("xmake/rules/cuda_rules.lua")

add_requires("pytorch")
add_requires("openmp")

set_languages("c++17")

includes("extension_cpp")
