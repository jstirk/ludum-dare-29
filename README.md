# TEMPLATE

A blank JRuby / Slick2D project skeleton ready to be fleshed out.

Change:
  * Rename `src/template.rb` to match your game's name.
  * Change references to `Template` module for your game's namespace.
  * Move `src/template/` to better match your game's name.
  * Change `.rvmrc` to match your project gemset, or change it over to
    another ruby manager.
  * Update `build_configuration.rb` to reference the new names of
    things.

## BUILD

Building .app and .exe :
`rake`

Building OSX app:
`rake rawr:clean rawr:jar rawr:bundle:app`
