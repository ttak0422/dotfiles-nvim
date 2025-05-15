{:settings {:Lua {:runtime {:version :LuaJIT :special {:reload :require}}
                  :diagnostics {:globals [:vim]}}
            :workspace {:library [(vim.fn.expand :$VIMRUNTIME/lua)]}
            :telemetry {:enable false}}}
