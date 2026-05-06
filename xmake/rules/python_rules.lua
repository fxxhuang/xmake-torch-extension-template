-- rule: build python extension module (based on xmake official python.module rule)
-- @see https://github.com/xmake-io/xmake/issues/1896
rule("python.module")
    on_config(function (target)
        import("core.base.json")
        import("find_python", {rootdir = os.projectdir() .. "/xmake/modules"})

        target:set("kind", "shared")
        target:set("prefixname", "")
        target:add("runenvs", "PYTHONPATH", target:targetdir())

        local program = find_python()
        local outdata = os.iorunv(program, {"-c",
            "import json,sysconfig;print(json.dumps({" ..
            "'ext_suffix':sysconfig.get_config_var('EXT_SUFFIX')," ..
            "'include':sysconfig.get_path('include')}))"
        })
        local info = json.decode(outdata)

        local soabi = target:extraconf("rules", "python.module", "soabi")
        if soabi == nil or soabi then
            if info.ext_suffix and info.ext_suffix ~= "None" then
                target:set("extension", info.ext_suffix)
            end
        else
            if target:is_plat("windows", "mingw") then
                target:set("extension", ".pyd")
            else
                target:set("extension", ".so")
            end
        end

        target:add("includedirs", info.include)
    end)
rule_end()
