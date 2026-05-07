function add_cuda_files(...)
    local files = {...}
    on_load(function (target)
        import("find_python", {rootdir = os.projectdir() .. "/xmake/modules"})
        local program = find_python()
        local outdata = try { function()
            return os.iorunv(program, {"-c", "import torch; print(torch.cuda.is_available())"})
        end }
        if outdata and outdata:trim() == "True" then
            target:add("rules", "cuda.auto")
            for _, file in ipairs(files) do
                target:add("files", file)
            end
        else
            print("warning: CUDA is not available in current PyTorch environment, skipping CUDA files")
        end
    end)
end
