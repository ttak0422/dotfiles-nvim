# Synthetic counter feature

`definition.lua` builds cooperative generations for the adjacent `tests.lua`.
Version 1 stores `count`; version 2 stores `total`. Both preserve counters for
events/timer ticks and the most recent accepted simulated asynchronous response.

Activation acquires one owned User autocmd. The tests deliberately fail activation,
migration, or cleanup to distinguish safe retention of the previous managed state
from a `restartRequired` outcome. These failure options are fixture controls, not
production feature flags.

The feature uses no downloaded plugin. `evidence.json` identifies this local
fixture; it is not release-note evidence or a record of successful test execution.
