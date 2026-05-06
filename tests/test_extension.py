import os
import sys
import unittest

import torch
from torch.testing._internal.optests import opcheck

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import extension_cpp


def reference_muladd(a, b, c):
    return a * b + c


class TestExtensionCpp(unittest.TestCase):
    def sample_inputs(self, device, requires_grad=False):
        def tensor(*shape):
            return torch.randn(*shape, device=device, requires_grad=requires_grad)

        def nondiff_tensor(*shape):
            return torch.randn(*shape, device=device)

        return [
            (tensor(3), tensor(3), 1.0),
            (tensor(20), tensor(20), 3.14),
            (tensor(20), nondiff_tensor(20), -123.0),
            (nondiff_tensor(2, 3), tensor(2, 3), -0.3),
        ]

    def check_correctness(self, device):
        for args in self.sample_inputs(device):
            actual = extension_cpp.ops.mymuladd(*args)
            expected = reference_muladd(*args)
            torch.testing.assert_close(actual, expected)

    def test_correctness_cpu(self):
        self.check_correctness("cpu")

    @unittest.skipIf(not torch.cuda.is_available(), "requires cuda")
    def test_correctness_cuda(self):
        self.check_correctness("cuda")

    def check_gradients(self, device):
        for args in self.sample_inputs(device, requires_grad=True):
            diff_tensors = [x for x in args if isinstance(x, torch.Tensor) and x.requires_grad]
            grad_out = torch.randn_like(extension_cpp.ops.mymuladd(*args))
            actual = torch.autograd.grad(extension_cpp.ops.mymuladd(*args), diff_tensors, grad_out)
            expected = torch.autograd.grad(reference_muladd(*args), diff_tensors, grad_out)
            torch.testing.assert_close(actual, expected)

    def test_gradients_cpu(self):
        self.check_gradients("cpu")

    @unittest.skipIf(not torch.cuda.is_available(), "requires cuda")
    def test_gradients_cuda(self):
        self.check_gradients("cuda")

    def check_myadd_out(self, device):
        a = torch.randn(20, device=device)
        b = torch.randn(20, device=device)
        out = torch.empty_like(a)
        extension_cpp.ops.myadd_out(a, b, out)
        torch.testing.assert_close(out, a + b)

    def test_myadd_out_cpu(self):
        self.check_myadd_out("cpu")

    @unittest.skipIf(not torch.cuda.is_available(), "requires cuda")
    def test_myadd_out_cuda(self):
        self.check_myadd_out("cuda")

    def test_opcheck_cpu(self):
        for args in self.sample_inputs("cpu", requires_grad=True):
            opcheck(torch.ops.extension_cpp.mymuladd.default, args)

    @unittest.skipIf(not torch.cuda.is_available(), "requires cuda")
    def test_opcheck_cuda(self):
        for args in self.sample_inputs("cuda", requires_grad=True):
            opcheck(torch.ops.extension_cpp.mymuladd.default, args)

    @unittest.skipIf(not torch.cuda.is_available(), "requires cuda")
    def test_torch_compile_cuda(self):
        def fn(x):
            return extension_cpp.ops.mymuladd(x, x, 1.0)

        x = torch.randn(1000, device="cuda")
        compiled_fn = torch.compile(fn, mode="reduce-overhead", fullgraph=True)
        torch.testing.assert_close(compiled_fn(x), fn(x))


if __name__ == "__main__":
    unittest.main()
