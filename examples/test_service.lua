--0f16b58085aefa674b524ee1

PPI = require("ppi")
require("tprint")

function Hello()
	print("Hello user, what you want from me?")
end

PPI.Expose("Hello", function() Hello() end)