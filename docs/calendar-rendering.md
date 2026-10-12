# Calendar rendering

`Calendar#to_svg` returns a standalone SVG with a title, description, legible day cells, and an optional holiday label. `Calendar#to_html` returns a document with print CSS. Both escape user-facing text and offer `:editorial`, `:business`, `:academic`, and `:ink_saver` themes. Paper dimensions accept Letter or A4 in portrait or landscape orientation.

The yearly renderer lays out 12 month grids on one page. PDF and raster exports are not included; print HTML through a browser or convert SVG with an application chosen by the caller.
