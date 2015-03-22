export Editor

Blink.resource(Pkg.dir("DevTools", "deps", "codemirror-5.0", "lib", "codemirror.js"))
Blink.resource(Pkg.dir("DevTools", "deps", "codemirror-5.0", "lib", "codemirror.css"))
Blink.resource(Pkg.dir("DevTools", "deps", "codemirror-5.0", "addon", "selection", "active-line.js"))
Blink.resource(Pkg.dir("DevTools", "deps", "codemirror-5.0", "addon", "display", "rulers.js"))

Blink.resource(Pkg.dir("DevTools", "res", "julia.js"))
Blink.resource(Pkg.dir("DevTools", "res", "editor.css"))
Blink.resource(Pkg.dir("DevTools", "res", "june.css"))

type Editor
  w::Window
end

function Editor(value = "")
  w = Window()
  loadcss!(w, "codemirror.css")
  loadcss!(w, "editor.css")
  loadcss!(w, "june.css")
  loadjs!(w, "codemirror.js")
  loadjs!(w, "active-line.js")
  loadjs!(w, "rulers.js")
  loadjs!(w, "julia.js")
  body!(w, "", fade = false)
  @js_ w cm = CodeMirror(document.body,
                         $(@d(:value => value,
                              :mode=>"julia2",
                              :theme=>"june",
                              :lineNumbers=>true,
                              :styleActiveLine=>true,
                              :rulers=>[80],
                              :showCursorWhenSelecting=>true)))
  return Editor(w)
end
