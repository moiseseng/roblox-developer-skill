--!strict
-- Player-facing text. One table per language; Config.SourceLanguage picks the default.
-- Keep gameplay code free of literal UI strings so copy can be reviewed and localized in one place.

local Config = require(script.Parent.Config)

export type Key =
	"coins"
	| "upgrade"
	| "upgrade_level"
	| "loading"
	| "err_poor"
	| "err_max_level"
	| "err_rate"
	| "err_no_data"
	| "err_load"
	| "err_generic"

local TABLES: { [string]: { [Key]: string } } = {
	es = {
		coins = "{amount} monedas",
		upgrade = "Mejorar",
		upgrade_level = "Mejorar (nivel {level}) · {cost}",
		loading = "Cargando…",
		err_poor = "No tienes suficientes monedas",
		err_max_level = "Nivel máximo",
		err_rate = "Demasiado rápido",
		err_no_data = "Cargando datos…",
		err_load = "No pudimos cargar tus datos. Vuelve a intentarlo en un momento.",
		err_generic = "No se pudo",
	},
	en = {
		coins = "{amount} coins",
		upgrade = "Upgrade",
		upgrade_level = "Upgrade (level {level}) · {cost}",
		loading = "Loading…",
		err_poor = "Not enough coins",
		err_max_level = "Max level",
		err_rate = "Too fast",
		err_no_data = "Loading data…",
		err_load = "We could not load your data. Please try again in a moment.",
		err_generic = "Something went wrong",
	},
}

local Strings = {}

-- True when the key exists in any table; use before get() with a dynamic key.
function Strings.has(key: string): boolean
	local table_ = TABLES[Config.SourceLanguage] or TABLES.en
	return table_[key :: Key] ~= nil or TABLES.en[key :: Key] ~= nil
end

-- Strings.get("coins", { amount = "1.2K" }) -> "1.2K monedas"
function Strings.get(key: Key, vars: { [string]: any }?): string
	local table_ = TABLES[Config.SourceLanguage] or TABLES.en
	local text = table_[key] or TABLES.en[key] or key
	if vars then
		text = string.gsub(text, "{(%w+)}", function(name)
			local value = vars[name]
			return if value ~= nil then tostring(value) else "{" .. name .. "}"
		end)
	end
	return text
end

return Strings
