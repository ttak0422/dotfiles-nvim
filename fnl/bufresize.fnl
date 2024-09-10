(let [M (require :bufresize)
      register {:keys [] :trigger_events [:BufWinEnter :WinEnter]}
      resize {:keys [] :trigger_events [:VimResized]}]
  (M.setup {: register : resize}))
