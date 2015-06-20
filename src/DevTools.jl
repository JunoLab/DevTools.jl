module DevTools

using Blink, Media, Lazy

export BlinkDisplay, pin, top, docs, profiler

include("display/BlinkDisplay.jl")
using .BlinkDisplay
include("profile/profile.jl")
include("codemirror.jl")
include("collab.jl")

profiler() = ProfileView.fetch()

end # module
