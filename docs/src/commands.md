# High level commands abstraction

Working with gateway directly is powerful but it would be nicer if there's a command-based interface. Rather than parsing strings all the time and dispatching to some function, perhaps it would be better to allow registering commands & arguments, similar to how CLIs are implemented. Another thought is that slash commands should be supported somehow.

Let's use HoJ bot as example:

,tz yyyy-mm-dd hh:mm:ss
,ig view
,ig perf
,ig chart aapl 2y
,ig buy 100 ibm
,ig sell 200 ibm
,discourse latest
,discourse traits

Most of these are handled by matching some regex. So maybe we can take the command name & regex captures as a "command config". Prefix should be auto handled as well.

Slash commands are also quite interesting as it takes named arguments if I remember correctly.
