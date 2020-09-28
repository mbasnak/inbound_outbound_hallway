from setuptools import setup
from setuptools import find_packages
import os


here = os.path.abspath(os.path.dirname(__file__))

setup(
    name='fictrac_2d',
    version='0.0.0',
    description='FicTrac client - conditioned menotaxis - triggers optogenetic stimulus, ... etc.',
    long_description=__doc__,
    author='Jenny Lu, modified from Will Dickson',
    author_email='jenny_lu@hms.harvard.edu',
    license='MIT',

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Science/Research',
        'Topic :: Scientific/Engineering :: Biology',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
    ],

    packages=find_packages(exclude=['examples', 'bin', 'pulse_firmware']),
    scripts=[]
)
