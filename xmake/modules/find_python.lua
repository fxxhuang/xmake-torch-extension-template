-- find python from current environment (cross-platform)
-- usage: import("find_python"); local program = find_python()
function main()
    local outdata = try { function()
        return os.iorunv("python", {"-c", "import sys;print(sys.executable)"})
    end }
    if outdata then return outdata:trim() end

    outdata = try { function()
        return os.iorunv("python3", {"-c", "import sys;print(sys.executable)"})
    end }
    if outdata then return outdata:trim() end

    raise("python not found in PATH")
end
