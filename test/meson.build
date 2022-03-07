test_deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite'),
    dependency('gee-0.8')
]

timestamp_test = 'timestamp-test'
timestamp_test_sources = [
    'TestTimestamp.vala',
    meson.source_root() + '/src/Timestamp.vala'
]
timestamp_test_exe = executable(
    timestamp_test,
    timestamp_test_sources,
    dependencies: test_deps
)
test(timestamp_test, timestamp_test_exe)

filename_test = 'filename-parsing-test'
filename_test_sources = [
    'TestFilenameParser.vala',
    meson.source_root() + '/src/Utils/Utils.vala',
    meson.source_root() + '/src/Timestamp.vala'
]
filename_test_exe = executable(
    filename_test,
    filename_test_sources,
    dependencies: test_deps
)
test(filename_test, filename_test_exe)
