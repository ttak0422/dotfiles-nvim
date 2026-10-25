-- Keep the IDE's exit status: formatter_factory ignores stderr and can return
-- the unchanged temp file after a failed process.
return function(args)
  local helpers = require('null-ls.helpers')
  local utils = require('null-ls.utils')
  local loop = require('null-ls.loop')
  return helpers.make_builtin({
    name = 'idea',
    method = require('null-ls.methods').internal.FORMATTING,
    filetypes = { 'java', 'groovy', 'kotlin' },
    runtime_condition = function()
      return vim.g.idea_format ~= nil
    end,
    generator_opts = { command = args.idea, timeout = 60000 },
    factory = function(opts)
      local runtime, busy
      return {
        async = true,
        opts = opts,
        fn = function(params, done)
          local cleanup
          local function finish(err, output)
            if cleanup then
              cleanup()
            end
            busy = false
            if err then
              local message = '[idea] ' .. err
              vim.notify(message, vim.log.levels.ERROR)
              -- A failed attempt must produce no edits, and remain retryable.
              done()
            else
              done({ { text = output } })
            end
          end
          if busy then
            vim.notify('[idea] Formatting is already running', vim.log.levels.ERROR)
            done()
            return
          end
          busy = true
          local ok, err = pcall(function()
            if vim.fn.executable(opts.command) ~= 1 then
              error('Formatter is not executable: ' .. opts.command, 0)
            end
            local cwd = utils.get_root()
            local style = vim.g.idea_format
            if type(style) ~= 'string' or style == '' then
              error('idea_format must name a code style XML file', 0)
            end
            if style:sub(1, 1) ~= '/' then
              style = cwd .. '/' .. style
            end
            if vim.fn.filereadable(style) ~= 1 then
              error('Code style file is not readable: ' .. style, 0)
            end
            if not runtime then
              -- Private to this generator/session: never lock the GUI IDE's
              -- config/system dirs or import its settings/plugins.
              runtime = vim.fn.tempname() .. '-idea'
              local properties = {}
              for _, name in ipairs({ 'config', 'system', 'plugins', 'log' }) do
                local path = runtime .. '/' .. name
                vim.fn.mkdir(path, 'p', 448)
                properties[#properties + 1] = 'idea.' .. name .. '.path=' .. path
              end
              vim.fn.writefile(properties, runtime .. '/idea.properties')
              vim.api.nvim_create_autocmd('VimLeavePre', {
                once = true,
                callback = function()
                  if not busy then
                    vim.fn.delete(runtime, 'rf')
                  end
                end,
              })
            end
            local content = utils.join_at_newline(params.bufnr, params.content)
            local path
            path, cleanup = loop.temp_file(content, params.bufname)
            local env = { IDEA_PROPERTIES = runtime .. '/idea.properties' }
            if args.idea_vm_options then
              env.IDEA_VM_OPTIONS = args.idea_vm_options
            end
            vim.system(
              { opts.command, 'format', '-s', style, path },
              {
                cwd = cwd,
                env = env,
                text = true,
                timeout = opts.timeout,
              },
              vim.schedule_wrap(function(result)
                if result.code == 124 then
                  finish('Formatter timed out after ' .. opts.timeout .. ' ms')
                elseif result.code ~= 0 or result.signal ~= 0 then
                  finish(
                    'Formatter exited with code '
                      .. result.code
                      .. ' (signal '
                      .. result.signal
                      .. ')\n'
                      .. (result.stderr ~= '' and result.stderr or result.stdout or '')
                  )
                elseif result.stderr and result.stderr ~= '' then
                  finish('Formatter wrote to stderr:\n' .. result.stderr)
                else
                  local read_ok, output = pcall(loop.read_file, path)
                  if read_ok then
                    finish(nil, output)
                  else
                    finish(tostring(output))
                  end
                end
              end)
            )
          end)
          if not ok then
            finish(tostring(err))
          end
        end,
      }
    end,
  })
end
