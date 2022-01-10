glib_dep = [dependency('glib-2.0')]
gtk_dep = [dependency('gtk+-3.0')]
granite_dep = [dependency('granite')]
gst_deps = [dependency('clutter-gst-3.0'), dependency('clutter-gtk-1.0')]

executable (meson.project_name(),

            'Main.vala',
            'Application.vala',
            'Widgets/Window.vala',
            'Widgets/WelcomeView.vala',
            'Widgets/TrimView.vala',
            'Widgets/VideoPlayer.vala',
            'Widgets/HeaderBar.vala',
            'Widgets/TimeStampEntry.vala',
            'Widgets/Timeline.vala',
            'Controllers/TrimController.vala',
            
            dependencies : [glib_dep, gtk_dep, granite_dep, gst_deps]
            )
