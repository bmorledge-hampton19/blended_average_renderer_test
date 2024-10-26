# blended_average_renderer_test
This project was created to better understand Godot shaders, subviewports, and render modes. It is essentially a custom render mode which computes an average of all rgb values at a given position (weighted by alpha values), and then applies a premultiplied alpha value over the top. The idea was to have it behave kind of like mixing a bunch of paints together. (Transparent paints, I guess?)

Here is the related thread that was pivotal in developing this repository: https://forum.godotengine.org/t/blend-multiple-textures-using-shaders/86798
