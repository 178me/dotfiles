local M = {}

function M:complete(_, callback)
	callback({
		{ label = "package" },
	})
end

return M
