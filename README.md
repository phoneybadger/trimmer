# trimmer
A video trimming utility designed for elementary OS.

**trimmer is still a work in progress**

![Welcome screen screenshot](data/screenshot-welcome.png)
![Trimming screen screenshot](data/screenshot-trim.png)

## Building, testing and installation
You'll need the following dependencies
- valac
- meson
- libgtk3-dev
- libgranite-dev
- libclutter-gst-3.0-dev
- libclutter-gtk-1.0-dev
- libgstreamer-1.0-dev
- ffmpeg

Run `meson` to configure the build environment and then use `ninja` to build
```
meson build --prefix=/usr
cd build
ninja
```
To install use `ninja install`, then execute with `com.github.adithyankv.trimmer`
```
sudo ninja install
com.github.adithyankv.trimmer
```

## Contributing
Contributions are always welcome. Please do raise an issue if you come across
a bug and please feel free to send in pull requests with features or bug fixes. 
For making code contributions you can perhaps look at the `TODO` comments within
the code and pick up one of those or go through the github issues.

The code generally follows the [elementary code style guidelines](https://docs.elementary.io/develop/writing-apps/code-style)

## Credits
- Directly inspired by Ivan Molodetskikh's [Video Trimmer](https://gitlab.gnome.org/YaLTeR/video-trimmer) for GNOME.
- Video used in screenshots is Blender open movie [Sprite fright](https://studio.blender.org/films/sprite-fright/)
- [Resizer](https://github.com/peteruithoven/resizer) and [Videos](https://github.com/elementary/videos) for code reference.
