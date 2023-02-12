plasmid <- parse_plasmid("petm20.gb")

p <- render_plasmap(plasmid,
                    rotation = 45,
                    plasmid_name = "pETM20-avi-dsnPPR10-C2",
                    zoom_y = 3)

p+ggplot2::scale_fill_brewer(palette = 4, type = "div", aesthetics = "fill")

ggplot2::ggsave( "oi.png", dpi = 500, width = 8, height = 8)
