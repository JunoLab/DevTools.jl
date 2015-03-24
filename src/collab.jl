using Blink, Mux

function collab(p)
  loadeditor(p, ver = "4.3.0")
  load!(p, "https://cdn.firebase.com/js/client/2.0.2/firebase.js")
  load!(p, "http://www.firepad.io/examples/firepad.js")
  @js_ p begin
    @var firebase = @new Firebase("crackling-heat-4207.firebaseio.com")
    @var firepad = Firepad.fromCodeMirror(firebase, cm)
  end
end

@app demo =
  (Mux.defaults,
   Blink.resroute,
   page("/juno", Blink.app(collab)),
   Mux.notfound())

@app demow =
  (Mux.wdefaults,
   Blink.ws_handler)

rundemo() = serve(demo, demow, 8080)
