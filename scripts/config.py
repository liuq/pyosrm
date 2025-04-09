from __future__ import annotations

import os
from pathlib import Path
import platform
from ctypes.util import find_library
import sys

def config() -> dict:
    """
    Configures the directories, library paths, and dependencies required for the project.

    This function determines the appropriate include directories, library directories, and 
    libraries based on the operating system and processor architecture. It also validates 
    the existence of required `.pyx` source files and ensures that all necessary libraries 
    are available.

    Raises:
        ValueError: If no `.pyx` files are found in the expected source directory.
        SystemExit: If a required library cannot be located or if the platform is unsupported.

    Platform-specific behavior:
        - macOS (Darwin):
            - Differentiates between ARM and non-ARM processors.
            - Sets include and library directories for Homebrew and system paths.
            - Configures dynamic and static library resolution for Boost and OSRM libraries.
            - Sets the `DYLD_FALLBACK_LIBRARY_PATH` environment variable.
        - Linux:
            - Sets include and library directories for OSRM and Boost.
            - Configures dynamic and static library resolution for Boost, OSRM, and Python libraries.
            - Adds extra linker arguments to prevent undefined symbols.
        - Unsupported platforms:
            - Raises a `SystemExit` exception.

    Returns:
        dict: A dictionary containing the following keys:
        - 'sources': List of `.pyx` source files.
        - 'include_dirs': List of include directories.
        - 'library_dirs': List of library directories.
        - 'libraries': List of required libraries.
        - 'extra_link_args': List of extra linker arguments.
    """
    package_directory = Path(__file__).resolve().parent.parent

    # Read the sources files
    source_dir = (package_directory / "src" / "pyosrm")
    sources = [str(path) for path in source_dir.glob("**/*.pyx")]
    if not sources:
        raise ValueError(f"No .pyx files found using the pattern '{source_dir}/**/*.pyx'")

    if platform.system() == 'Darwin':
        if platform.processor() == 'arm':
            include_dirs = [
                '/opt/homebrew/include',
                '/opt/homebrew/include/osrm',
                '/usr/local/include',
                '/usr/local/include/osrm'
            ]
            library_dirs = [
                '/opt/homebrew/lib',
                '/usr/local/lib',
            ]       
        else:        
            include_dirs = [
                '/usr/local/include',
                '/usr/local/include/osrm',
            ]
            library_dirs = [
                '/usr/local/lib',
                '/usr/lib',
            ]

        libraries = [
            "boost_system",
            "boost_filesystem",
            "boost_iostreams",
            "boost_thread",
            "osrm"
        ]
        os.environ['DYLD_FALLBACK_LIBRARY_PATH'] = ":".join(library_dirs)
        for i, library in enumerate(libraries):
            # Try dynamic libraries first
            if find_library(library):
                continue
            if library.startswith('boost') and not find_library(library) and find_library(library + '-mt'):
                # Try with the multithreading version
                library += '-mt'
                libraries[i] = library
                continue
            # fallback to static library
            found = False
            for d in map(Path, library_dirs):
                if (d / f'lib{library}.a').is_file():
                    found = True
                    break
                if library.startswith('boost') and (d / f'lib{library}-mt.a').is_file():
                    library += '-mt'
                    libraries[i] = library
                    found = True
                    break
            if found:
                continue
            raise SystemExit(f'Could not locate library {library}')    
        extra_link_args = []
    elif platform.system() == 'Linux':
        include_dirs = [
            '/usr/local/include/osrm',
            '/usr/include/boost',
            '/usr/local/include/boost'
        ]
        library_dirs = [ '/usr/local/lib', '/usr/lib/x86_64-linux-gnu' ]
        libraries = [
            "osrm",
            "boost_system",
            "boost_filesystem",
            "boost_iostreams",
            "boost_thread",
            'rt',
            f'boost_python{"".join(map(str, sys.version_info[:2]))}',
            f'python{".".join(map(str, sys.version_info[:2]))}'
        ]
        extra_link_args = ["-Wl,--no-undefined"]
        for i, library in enumerate(libraries):
            # Try dynamic libraries first
            found = False
            if find_library(library):            
                found = True
            else:
                for d in map(Path, library_dirs):
                    if (d / f'lib{library}.a').is_file():
                        found = True
                        break
                    if library.startswith('boost') and (d /f'lib{library}-mt.a').is_file():
                        library += '-mt'
                        libraries[i] = library
                        found = True
                        break
            if found:
                continue
            else:
                raise SystemExit(f'Could not locate library {library}')
    else:
        raise SystemExit(f'Platform {platform.system()} is currently unsupported')
    
    return { 
        'sources': sources, 
        'include_dirs': include_dirs, 
        'library_dirs': library_dirs, 
        'libraries': libraries,         
        'extra_link_args': extra_link_args 
    }

