read_globals = {
	"vim",
}

ignore = {
	"122", -- Setting a read-only field of a global variable.
	"212", -- Unused argument, In the case of callback function, _arg_name is easier to understand than _, so this option is set to off.
}
