from setuptools import setup, Extension
from Cython.Build import cythonize
from scripts.config import config as _config

with open('README.md') as f:
    long_description = f.read()

config = _config()

ext = cythonize(
    [
        Extension(
            '*',
            sources=config['sources'],
            include_dirs=config['include_dirs'],
            library_dirs=config['library_dirs'],
            libraries=config['libraries'],
            language='c++',
            extra_compile_args=["-std=c++17"],
            extra_link_args=config['extra_link_args']
        )
    ],
    compiler_directives={
        'language_level' : "3"
    },
)

setup(
    name='pyosrm',
    version='0.1.1',
    license='MIT',
    description='Cython wrapper of osrm-backend to be used in Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Enrico Davini, Luca Di Gaspero',
    url='https://github.com/liuq/pyosrm',
    zip_safe=False,
    ext_modules=ext,
    include_package_data=True,
    package_data={'pyosrm': ['*.so', '*.pyd', '*.dylib']}, 
    install_requires=[],
    extras_require={
        'dev': ['pytest']
    }
)
