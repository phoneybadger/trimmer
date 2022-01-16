# trimmer
A video trimming utility designed for elementary OS.

**trimmer is still a work in progress**

![Welcome screen screenshot](data/screenshot-welcome.png)
![Trimming screen screenshot](data/screenshot-trim.png)

# Building, testing and installation
You'll need the following dependencies
- valac
- meson
- libgtk3-dev
- libgranite-dev
- libclutter-gst-3.0-dev
- libclutter-gtk-1.0-dev
- libgstreamer-1.0-dev

Run `meson` to configure the build environment and then use `ninja` to build
```
meson build
cd build
ninja
```
To install use `ninja install`, then execute with `com.github.adithyankv.trimmer`
```
sudo ninja install
com.github.adithyankv.trimmer
```
# Credits
- Directly inspired by Ivan Molodetskikh's [Video Trimmer](https://gitlab.gnome.org/YaLTeR/video-trimmer) for GNOME.
- Video used in screenshots is Blender open movie [Sprite fright](https://studio.blender.org/films/sprite-fright/)
