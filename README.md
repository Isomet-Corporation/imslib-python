# imslib Python Library

![PyPI Version](https://img.shields.io/pypi/v/imslib)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Python Versions](https://img.shields.io/pypi/pyversions/imslib)

## Overview

**imslib** is a Python library for controlling **Isomet Corporation's Acousto-Optic Synthesisers (AOS)**. It provides a comprehensive high-level API for:

* Generating test tones, images, and sequences
* Downloading and playing them on Isomet hardware
* Power control and signal compensation
* System diagnostics and configuration
* And much more

The package is designed to simplify development workflows while providing full access to the capabilities of Isomet AOS hardware.

## Installation

It is recommended to install **Python 3.8 or newer** from the official source:

* [https://www.python.org/downloads/](https://www.python.org/downloads/)

Using the official installer ensures compatibility with prebuilt wheels and avoids issues caused by third‑party Python distributions.

### Creating a Virtual Environment

Before installing imslib, create and activate a virtual environment:

**Windows:**

```
python -m venv venv
venv\Scripts\activate
```

**Ubuntu / Linux:**

```
python3 -m venv venv
source venv/bin/activate
```

Once activated, you can install packages inside the isolated environment.

You do **not** need to build the imslib library yourself unless you are on an unsupported platform. Prebuilt packages are available for Windows and Ubuntu 24.04.

### 1. Windows (64-bit only)

Create and activate a Python virtual environment, then install directly from PyPI:

```
pip install imslib
```

### 2. Ubuntu 24.04

Create a virtual environment, then download the latest precompiled wheel from the Isomet website:

* [https://isomet.com/ims4_sw.html](https://isomet.com/ims4_sw.html)

Install it with:

```
pip install ./imslib-<version>.whl
```

### Running the Tests

Clone the GitHub repository:

```
git clone https://github.com/Isomet-Corporation/imslib-python.git
```

Activate your virtual environment and run the test scripts:

```
python3 <repo>/tests/<testfile>.py
```

Some tests require the `matplotlib` package.

### Installing matplotlib

If you need to run tests that use plotting, install `matplotlib` within your virtual environment:

```
pip install matplotlib
```

---

## Quick Start

A minimal workflow to verify your installation:

```
git clone https://github.com/Isomet-Corporation/imslib-python.git
cd imslib-python
python3 tests/test01_scan.py
```

Ensure your hardware is connected before running the test (see Hardware Connection Guide below).

---

## Hardware Connection Guide

### Linux

Use **Ethernet** to communicate with Isomet AOS hardware. USB drivers are not currently supported on Linux.

### Windows

Windows supports **all available interfaces**, including:

* USB
* Ethernet
* Serial (if applicable)

---

## Building

If you are on a platform without prebuilt wheels, you can build the Python package locally.

### 1. Clone the repository (with submodules)

```
git clone --recurse-submodules https://github.com/Isomet-Corporation/imslib-python.git
```

### 2. Install dependencies

Example for Ubuntu:

```
sudo apt install python3 python3-dev python3-venv python3-pip cmake ninja-build swig gcc-multilib g++-multilib
```

Then install the required Python packages:

```
python3 -m pip install --upgrade pip
python3 -m pip install setuptools build scikit-build-core ninja cmake conan swig
```

### 3. Configure Conan

```
conan profile detect -f
```

### 4. Build the wheel

From the project root:

```
python3 -m build --wheel --outdir wheelhouse .
```

Preconfigured helper scripts are provided:

* `build_wheels.bat`
* `build_wheels.sh`

These automate the wheel-building process where supported.
