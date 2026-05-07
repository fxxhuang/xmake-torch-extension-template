# xmake-torch-extension-template

A minimal PyTorch C++/CUDA extension template built with [xmake](https://xmake.io/), adapted from PyTorch's official [`extension-cpp`](https://github.com/pytorch/extension-cpp) example.

## Prerequisites

- [xmake](https://xmake.io/) v2.5+
- Python 3.x with PyTorch installed (CPU or CUDA variant)
- (Optional) CUDA toolkit for GPU support

The build system auto-detects your PyTorch installation and CUDA availability. No manual path configuration is needed.

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
    ├── modules/
    │   ├── cuda.lua
    │   └── find_python.lua
    ├── packages/pytorch.lua
    └── rules/
        ├── cuda_rules.lua
        └── python_rules.lua
```

## Quick Start

```bash
# Ensure PyTorch is installed in your Python environment
pip install torch

# Configure and build
xmake f -m release
xmake

# Run tests
python tests/test_extension.py
```

## Build

The extension module is built directly into `extension_cpp/_C*.so`, so local imports work without installing the package.

### CPU-only build

If your PyTorch installation does not have CUDA support, the CUDA source files are automatically skipped. No extra configuration required.

### CUDA build

When PyTorch reports CUDA as available, `.cu` files are compiled with `nvcc` automatically. You can optionally pass a PTX virtual architecture for forward compatibility:

```bash
xmake f -m release --cuda_ptx=compute_80
xmake
```

## How it works

| Component | Purpose |
|-----------|---------|
| `xmake/packages/pytorch.lua` | Auto-detects PyTorch include/lib paths from the active Python environment |
| `xmake/modules/cuda.lua` | Conditionally adds CUDA source files when PyTorch CUDA is available |
| `xmake/rules/python_rules.lua` | Builds shared objects with correct Python extension suffix and includes |
| `xmake/rules/cuda_rules.lua` | Applies sensible `nvcc` defaults (native SASS, C++17, relaxed constexpr, -fPIC) |

## Test

```bash
python tests/test_extension.py
```
