(let [M (require :go-impl)
      opts {:icons {:interface {:text " " :hl :GoImplInterfaceIcon}
                    :go {:text " " :hl :GoImplGoBlue}}
            :prompt {:receiver "󰆼  ▸ "
                     :interface "  ▸ "
                     :generic "󰘻  {name} ▸ "}}]
  (M.setup opts))
