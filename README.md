# Godot-particles-collision (2D)

**what is it** particle collision shader for Godot

*variants:*

**v1** simple SDF collision(no loops), SDF created from Polygons2D once(on start), collision by normals generated form SDF. Video [youtube link](https://youtu.be/hycdANeMXaE). Only for "static map".

**v2** *bad* normals to edges [youtube link](https://youtu.be/lAtyWqqZrnM). Support collision to dynamic maps/objects.(no need sdf)

**v3** will be for Godot4 only, using Vulkan and compute, I do not want make another "bad" physics base on GLES2/3 limitations.
