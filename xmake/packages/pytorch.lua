package("pytorch")
    set_homepage("https://pytorch.org/")
    set_description("Tensors and Dynamic neural networks in Python with strong GPU acceleration (C++ API)")

    on_fetch(function (package, opt)
        import("core.base.json")
        import("find_python", {rootdir = os.projectdir() .. "/xmake/modules"})

        local program = find_python()
        local outdata = try { function()
            return os.iorunv(program, {"-c",
                "import json,torch,os;d=torch.__path__[0];print(json.dumps({" ..
                "'version':torch.__version__," ..
                "'includedir':os.path.join(d,'include')," ..
                "'linkdir':os.path.join(d,'lib')}))"
            })
        end }
        if not outdata then return nil end

        local info = json.decode(outdata)
        if not info or not os.isdir(info.includedir) then return nil end

        -- collect shared libraries (platform-aware)
        local libfiles = {}
        if package:is_plat("macosx") then
            libfiles = os.files(path.join(info.linkdir, "*.dylib"))
        elseif package:is_plat("windows") then
            libfiles = os.files(path.join(info.linkdir, "*.lib"))
        else
            libfiles = os.files(path.join(info.linkdir, "*.so"))
        end

        local links = {}
        for _, libfile in ipairs(libfiles) do
            local name = path.basename(libfile)
            name = name:gsub("^lib", "")
            name = name:gsub("%.dylib$", ""):gsub("%.so[%.%d]*$", ""):gsub("%.lib$", "")
            table.insert(links, name)
        end

        local result = {
            version = info.version,
            links = links,
            linkdirs = {info.linkdir},
            includedirs = {
                info.includedir,
                path.join(info.includedir, "torch", "csrc", "api", "include"),
            },
        }

        if not package:is_plat("windows") then
            result.ldflags = {"-Wl,-rpath," .. info.linkdir}
        end

        return result
    end)
package_end()
