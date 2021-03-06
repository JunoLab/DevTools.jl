export Editor, editor, setbars, barson, barsoff, setcursor

type Editor
  file
  w::Window
end

filetitle(e) = e.file == nothing ? "Julia" : basename(e.file)

Blink.msg(e::Editor, args...) = Blink.msg(e.w, args...)
Blink.handlers(e::Editor) = Blink.handlers(e.w)

# I know, I know, this code is a mess.

function loadeditor(p::Page; value = "", ver = "5.0.0")
  for f in ["codemirror.min.js"
            "codemirror.min.css"
            "addon/display/rulers.min.js"
            "addon/selection/active-line.min.js"
            "addon/search/searchcursor.min.js"
            "keymap/sublime.min.js"]
    load!(p, "https://cdnjs.cloudflare.com/ajax/libs/codemirror/$ver/$f")
  end

  for f in ["julia.js", "editor.css", "june.css", "bars.js", "bars.css"]
    load!(p, Pkg.dir("DevTools", "res", f))
  end

  @js_ p CodeMirror.keyMap.blink = d("fallthrough"=>"sublime")

  body!(p, "", fade = false)
  @js_ p cm = CodeMirror(document.body,
                         $(d(:value => value,
                             :mode=>"julia2",
                             :theme=>"june",
                             :keyMap=>"blink",
                             :lineNumbers=>true,
                             :styleActiveLine=>true,
                             :rulers=>[80],
                             :showCursorWhenSelecting=>true)))
  @js_ p Bars.hook(cm)
  handle_eval(p)
end

function Editor(value = ""; file = nothing)
  w = Window(d(:title=>file == nothing ? "Julia" : basename(file)))
  loadeditor(w.content, value = value)
  ed = Editor(file, w)
  handle_dirty(ed)
  handle_save(ed)
  return ed
end

editor(f) = Editor(read(f, String), file = f)

setbars(e, ls) = @js_ e Bars.set(cm, $ls)
barson(e) = @js_ e Bars.on(cm)
barsoff(e) = @js_ e Bars.off(cm)

function centrecursor(ed)
  @js_ ed begin
    @var l = cm.getCursor().line
    @var y = cm.charCoords(d("line"=>l, "ch"=>0), "local").top
    @var height = cm.getScrollerElement().offsetHeight
    cm.scrollTo(0, y - height/2 + 55)
  end
end

function setcursor(ed, line, ch = 0)
  @js_ ed cm.setCursor($(line-1), $ch)
  centrecursor(ed)
end

norm(key::AbstractString) = replace(key, r"\bc\b"i, Sys.is_apple() ? "Cmd" : "Ctrl")

function keymap(ed, key, res)
  @js_ ed begin
    @var map = CodeMirror.keyMap.blink
    map[$(norm(key))] = $res
#     CodeMirror.normalizeKeyMap(map)
  end
end

function handle_dirty(e::Editor)
  @js_ e cm.on("changes", () -> Blink.msg("change", d("clean"=>cm.isClean())))

  handle(e, "change") do data
    t = filetitle(e)
    data["clean"] || (t *= "*")
    title(e.w, t)
  end
end

function handle_save(ed::Editor)
  keymap(ed, "C-S", :(cm -> Blink.msg("save", d("code"=>cm.getValue()))))

  handle(ed, "save") do data
    if ed.file != nothing && isfile(ed.file)
      @js_ ed cm.markClean()
      title(ed.w, filetitle(ed))
      open(io -> write(io, data["code"]), ed.file, "w")
    end
  end
end

function handle_eval(ed)
  keymap(ed, "Shift-Enter", :(cm -> Blink.msg("eval", d("code"=>cm.getSelection()))))

  handle(ed, "eval") do data
    try
      result = eval(Main, parse(data["code"]))
      @js_ ed console.log($(sprint(show, result)))
    catch e
      @js_ ed console.log($(sprint(showerror, e, catch_backtrace())))
    end
  end
end
