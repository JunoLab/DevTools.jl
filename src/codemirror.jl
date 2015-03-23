export Editor, editor, setbars, barson, barsoff, setcursor

type Editor
  file
  w::Window
end

Blink.msg(e::Editor, args...) = Blink.msg(e.w, args...)
Blink.handlers(e::Editor) = Blink.handlers(e.w)

function handle_dirty(e::Editor)
  @js_ e cm.on("changes", () -> Blink.msg("change", ["clean"=>cm.isClean()]))

  handle(e, "change") do data
    t = e.file == nothing ? "Julia" : basename(e.file)
    data["clean"] || (t *= "*")
    title(e.w, t)
  end
end

function Editor(value = ""; file = nothing)
  w = Window(@d(:title=>file == nothing ? "Julia" : basename(file)))
  ed = Editor(file, w)
  for f in (["lib", "codemirror.js"],
            ["lib", "codemirror.css"],
            ["addon", "display", "rulers.js"],
            ["addon", "selection", "active-line.js"],
            ["addon", "search", "searchcursor.js"],
            ["addon", "dialog", "dialog.css"],
            ["addon", "dialog", "dialog.js"],
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
  handle_dirty(ed)
  return ed
end

editor(f) = Editor(readall(f), file = f)

setbars(e::Editor, ls) = @js_ e Bars.set(cm, $ls)
barson(e::Editor) = @js_ e Bars.on(cm)
barsoff(e::Editor) = @js_ e Bars.off(cm)

function centrecursor(ed::Editor)
  @js_ ed begin
    @var l = cm.getCursor().line
    @var y = cm.charCoords(["line"=>l, "ch"=>0], "local").top
    @var height = cm.getScrollerElement().offsetHeight
    cm.scrollTo(0, y - height/2 + 55)
  end
end

function setcursor(ed::Editor, line, ch = 0)
  @js_ ed cm.setCursor($(line-1), $ch)
  centrecursor(ed)
end
