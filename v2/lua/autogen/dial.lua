-- [nfnl] v2/fnl/dial.fnl
local config = require("dial.config")
local augend = require("dial.augend")
local default = {augend.integer.alias.decimal, augend.integer.alias.hex, augend.date.alias["%Y/%m/%d"], augend.date.alias["%Y-%m-%d"], augend.constant.alias.bool, augend.semver.alias.semver}
return config.augends:register_group({default = default})
