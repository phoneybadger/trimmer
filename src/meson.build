glib_dep = [dependency('glib-2.0')]
gtk_dep = [dependency('gtk+-3.0')]
granite_dep = [dependency('granite')]

executable (meson.project_name(),

            'Main.vala',
            'Application.vala',
            'Window.vala',
            
            dependencies : [glib_dep, gtk_dep, granite_dep]
            )
