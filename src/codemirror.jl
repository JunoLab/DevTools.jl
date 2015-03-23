export Editor, editor

type Editor
  w::Window
end

Blink.msg(e::Editor, args...) = Blink.msg(e.w, args...)
Blink.handlers(e::Editor) = Blink.handlers(e.w)

function Editor(value = ""; title = "Julia")
  w = Window(@d(:title=>title))
  for f in (["lib", "codemirror.js"],
            ["lib", "codemirror.css"],
            ["addon", "display", "rulers.js"],
            ["addon", "selection", "active-line.js"],
            ["keymap", "sublime.js"])
    Blink.load!(w, Pkg.dir("DevTools", "deps", "codemirror-5.0", f...))
  end

  for f in ["julia.js", "editor.css", "june.css", "bars.js", "bars.css"]
    Blink.load!(w, Pkg.dir("DevTools", "res", f))
  end

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
  @js_ w Bars.hook(cm)
  return Editor(w)
end

editor(f) = Editor(readall(f), title = basename(f))

setbars(e::Editor, ls) = @js_ e.w Bars.set(cm, $ls)
barson(e::Editor) = @js_ e.w Bars.on(cm)
barsoff(e::Editor) = @js_ e.w Bars.off(cm)
