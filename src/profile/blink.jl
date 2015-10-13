using Media, ..BlinkDisplay, ..DevTools, Blink, Lazy

media(ProfileTree, Media.Graphical)
BlinkDisplay.displaysize(::ProfileTree) = (480, 288)
BlinkDisplay.displaytitle(::ProfileTree) = "Profile"

function Media.render(view::WebView, x::ProfileTree; options = @d())
  w = invoke(Media.render, (WebView, Any), view, x)

  handle(w, "click") do data
    path = split(data["file"], ":")
    file = join(path[1:end-1], ":")
    line = parseint(path[end])
    ed = editor(file)
    setcursor(ed, line)
    lines = DevTools.ProfileView.flatlines(x)
    filter!((li, p) -> fullpath(li.file) == file, lines)
    setbars(ed, [d("line"=>li.line, "percent"=>p) for (li, p) in lines])
    barson(ed)
  end

  sleep(1)
  @js_ w begin
    @var bars = document.getElementsByClassName("file-link")
    Array.prototype.forEach.call(
      bars, function(bar)
        Blink.click(bar, e -> Blink.msg("click", d("file"=>bar.getAttribute("data-file"))))
      end)
  end
end
