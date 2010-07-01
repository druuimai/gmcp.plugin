PPI = require("ppi")
require("tprint")

function Hello()
  print("Hello user, what you want from me?")
end

PPI.Expose("Hello", Hello)