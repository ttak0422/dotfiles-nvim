# Command fixture

The optional `poc-picker` package registers `PocPick`. The runtime preserves the first
command's arguments, bang, range and modifiers, after removing its proxy and loading
the package. This is not Telescope compatibility testing. Completion is out of scope.

Proxy ownership is released for both command activation and loading through
`requires`. The adjacent `dependency-test.lua` checks that runtime cleanup leaves
the real plugin command registered and callable after dependency-driven loading.
