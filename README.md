Prompter
========

Small utility that enables interaction with Lua programs using the command line.

###Usage

Simply include the library into your code:
```
local prm = require("prompter")
```
Call the init function with the functions table as parameter, and finally call the run method.
```
prm.init(functions_table)
prm.run()
```

The user will be able to enter function names through the CLI, which will be called after pressing [Return].


Enrique CR.
