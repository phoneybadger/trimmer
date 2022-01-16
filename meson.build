project('trimmer', 'c', 'vala')

subdir('src')
subdir('data')

glib_dep = [dependency('glib-2.0')]
gtk_dep = [dependency('gtk+-3.0')]
granite_dep = [dependency('granite')]
gst_deps = [dependency('clutter-gst-3.0'),
            dependency('clutter-gtk-1.0')]

executable (
  meson.project_name(),
  sources,
  dependencies : [glib_dep, gtk_dep, granite_dep, gst_deps]
)

meson.add_install_script('meson/post_install.py')
