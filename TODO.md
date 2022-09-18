# TODO and status updates

## May 28, 2022

Gateway update

- Control pane: I have implemented control pane, with heartbeat/processor/doctor tasks. There is a convenient function to run control pane in a loop. The main function is a little ugly... may want to refactor that again later. Logs are directed to a file with timestamp.

- Event types: Some gateway event object types are defined (guild create, message create/update, message reaction events). Still need to define the rest of the gateway event object types and make sure that they can be dispatched.

- Event dispatch: Current strategy for dispatch is just send them off to a Channel. Need to think about if that's good enough or do something more elaborate like Discord.jl's subscription technique. The parsing procedure is a little hacky at the moment -- parsing from JSON to Dict's, then it's written to String and parsed again into an event object. Should find a better way to do that.

- Testing: none so far
## Apr 24, 2022

- I have updated all known resource objects but I probably missed some. I have also pasted links to the API reference so the structs can be maintained more easily going forward. The only way to find out if it's complete is to write tests against all endpoints (see task below)

