{:settings {:Lua {:runtime {:version :LuaJIT :special {:reload :require}}
                  :diagnostics {:globals [:vim]}}
            :workspace {:library [(vim.fn.expand :$VIMRUNTIME/lua)
                                  "${3rd}/luv/library"]}
            :telemetry {:enable false}}}
