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

## Best practices

This library makes use of async processes heavily. Some best practices include:

1. Always run async code within a try/catch block and 1) display the error when an exception occurs and 2) rethrow. Exceptions are by default not displayed to the console and the task just gets to a failed state. This can happen quite often especially when you make changes to the code and introduce bugs like runtime errors.

2. When you stop an async task using `Base.throwto`, you must run that with `@async`. The `throwto` function yields to a different task and never comes back to the current task.
