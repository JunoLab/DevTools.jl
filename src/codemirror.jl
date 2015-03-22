export Editor

type Editor
  w::Window
end

function Editor(value = "")
  w = Window()
  for f in (["lib", "codemirror.js"],
            ["lib", "codemirror.css"],
            ["addon", "display", "rulers.js"],
            ["addon", "selection", "active-line.js"],
            ["keymap", "sublime.js"])
    Blink.load!(w, Pkg.dir("DevTools", "deps", "codemirror-5.0", f...))
  end

  for f in ["julia.js", "editor.css", "june.css"]
    Blink.load!(w, Pkg.dir("DevTools", "res", f))
  end

  sleep(0.1)

  body!(w, "", fade = false)
  @js_ w cm = CodeMirror(document.body,
                         $(@d(:value => value,
                              :mode=>"julia2",
                              :theme=>"june",
                              :keyMap=>"sublime",
                              :lineNumbers=>true,
                              :styleActiveLine=>true,
                              :rulers=>[80],
                              :showCursorWhenSelecting=>true)))
  return Editor(w)
end
