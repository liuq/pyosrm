from __future__ import annotations

import os
import shutil

from pathlib import Path

from Cython.Build import cythonize
from setuptools import Distribution
from setuptools import Extension
from setuptools.command.build_ext import build_ext
from config import config as _config

def build() -> None:
    config = _config()

    extensions = [
        Extension(
            "*",
            sources=config['sources'],
            include_dirs=config['include_dirs'],
            library_dirs=config['library_dirs'],
            libraries=config['libraries'],
            language='c++',
            extra_compile_args=["-std=c++17"],
            extra_link_args=config['extra_link_args'],
        )
    ]
    ext_modules = cythonize(
        extensions,
        include_path=config['include_dirs'],
        compiler_directives={"binding": True, "language_level": 3},
    )

    distribution = Distribution({
        "name": "pyosrm",
        "ext_modules": ext_modules
    })

    cmd = build_ext(distribution)
    cmd.ensure_finalized()
    cmd.run()

    # Copy built extensions back to the project
    for output in cmd.get_outputs():
        output = Path(output)
        relative_extension = Path("src") / output.relative_to(cmd.build_lib)

        shutil.copyfile(output, relative_extension)
        mode = os.stat(relative_extension).st_mode
        mode |= (mode & 0o444) >> 2
        os.chmod(relative_extension, mode)

if __name__ == "__main__":
    build()
