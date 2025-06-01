(local impl (require :go-impl))

(local icons {:interface {:text " " :hl :GoImplInterfaceIcon}
              :go {:text " " :hl :GoImplGoBlue}})

(local prompt {:receiver "󰆼  "
               :interface "  "
               :generic "󰘻  {name} "})

(impl.setup {:picker :snacks : icons : prompt})
