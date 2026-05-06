# xmake-torch-extension-template

A minimal PyTorch C++/CUDA extension template built with [xmake](https://xmake.io/), adapted from PyTorch's official [`extension-cpp`](https://github.com/pytorch/extension-cpp) example.

## Layout

```text
.
├── extension_cpp/
│   ├── __init__.py
│   ├── ops.py
│   ├── xmake.lua
│   └── csrc/
│       ├── muladd.cpp
│       └── cuda/muladd.cu
├── tests/test_extension.py
├── xmake.lua
└── xmake/
    ├── modules/find_python.lua
    ├── packages/pytorch.lua
    └── rules/
        ├── cuda_rules.lua
        └── python_rules.lua
```

## Build

```bash
xmake f -m release
xmake
```

The extension module is built directly into `extension_cpp/_C*.so`, so local imports work without installing the package.

## Test

```bash
python tests/test_extension.py
```
