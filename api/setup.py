from setuptools import find_packages, setup

with open("engineapi/version.txt") as ifp:
    VERSION = ifp.read().strip()

long_description = ""
with open("README.md") as ifp:
    long_description = ifp.read()

setup(
    name="engineapi",
    version=VERSION,
    packages=find_packages(),
    install_requires=[
        "boto3",
        "bugout>=0.2.2",
        "eip712",
        "eth-typing>=2.3.0",
        "fastapi",
        "psycopg2-binary",
        "pydantic",
        "sqlalchemy",
        "tqdm",
        "uvicorn",
        "web3>=5.30.0",
        "tabulate",
    ],
    extras_require={
        "dev": ["alembic", "brownie", "black", "mypy", "isort"],
        "distribute": ["setuptools", "twine", "wheel"],
    },
    description="Command line interface for Moonstream Engine API",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Moonstream",
    author_email="engineering@moonstream.to",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Programming Language :: Python",
        "License :: OSI Approved :: Apache Software License",
        "Topic :: Software Development :: Libraries",
    ],
    python_requires=">=3.8",
    entry_points={
        "console_scripts": [
            "engineapi=engineapi.cli:main",
        ]
    },
    package_data={"engineapi": ["contracts/*.json"]},
    include_package_data=True,
)
