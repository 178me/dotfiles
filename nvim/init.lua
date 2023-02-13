local patterns = {
	"^basic",
	"^keymap",
	"^utils",
	"^snippet/",
}
local function reload()
	for name, _ in pairs(package.loaded) do
		for _, pattern in pairs(patterns) do
			if name:match(pattern) then
				package.loaded[name] = nil
			end
		end
	end
end
reload()
-- nvim变量配置
require("basic")
-- 插件加载
require("plugins")
-- 代码块
require("snippet")
-- 资源
require("source")
-- 快捷键
require("keymap")
