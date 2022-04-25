# Developer Guide

## Generating BrokenRecord data files

The test suite uses BrokenRecord.jl to capture HTTP responses so that subsequent tests can be executed more quickly (as well as being able to test in DevOps/CI without actually hitting the Discord server). If you change any tests, you must regenerate the BSON files in the test/fixtures directory.

Here's how:
1. Define environment variable `DISCORD_TOKEN` with your own bot's token
2. Delete all BSON files in test/fixtures directory
3. Run the test suite

## Productivity tools

### tools/check_includes.jl

Run this script to find out if any new source files are added to the src/objects but have not been included in the main objects.jl script.
