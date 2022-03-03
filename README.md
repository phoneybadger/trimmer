<div align="center">
  <div align="center">
    <img src="data/icons/64.svg" width="64">
  </div>
  <h1 align="center">Trimmer</h1>
  <div align="center">A video trimming utility for elementary OS. </div>
</div>

## Usage

Quickly trim videos using start and end timestamps. Trimmer doesn't re-encode any videos so the process should be very fast.

## Screenshots

![Welcome screen screenshot](data/screenshot-welcome.png)
![Trimming screen screenshot](data/screenshot-trim.png)

## Building, testing and installation

### Flatpak
Flatpak is the recommended method of installation. Download or clone the repo,
```
git clone https://github.com/phoneybadger/trimmer.git
cd trimmer
```
then run
```
flatpak-builder build com.github.phoneybadger.trimmer.yml --user --install --force-clean
```
the program should now be installed and can be launched using
```
flatpak run com.github.phoneybadger.trimmer
```

### Build from source
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
To install use `ninja install`, then execute with `com.github.phoneybadger.trimmer`
```
sudo ninja install
com.github.phoneybadger.trimmer
```

## Contributing
Contributions are always welcome. Please do raise an issue if you come across
a bug and please feel free to send in pull requests with features or bug fixes. 
For making code contributions you can perhaps look at the `TODO` comments within
the code and pick up one of those or go through the github issues.

The code generally follows the [elementary code style guidelines](https://docs.elementary.io/develop/writing-apps/code-style)

### Translations
Generate `.pot` translation template file using `po/LINGUAS` and `po/POTFILES`.
```
ninja com.github.phoneybadger.trimmer-pot
```
then use the template file to generate/update `.po` files for each of the 
languages listed in `LINGUAS`
```
ninja com.github.phoneybadger.trimmer-update-po
```

## Credits
- Directly inspired by Ivan Molodetskikh's [Video Trimmer](https://gitlab.gnome.org/YaLTeR/video-trimmer) for GNOME.
- Video used in screenshots is Blender open movie [Sprite fright](https://studio.blender.org/films/sprite-fright/).
- [Resizer](https://github.com/peteruithoven/resizer) and [Videos](https://github.com/elementary/videos) for code reference.
- Article on [Vala reactive programming](https://dev.to/igordsm/vala-reactive-programming-2pf4) by Igor Montagner.
