--!strict
-- Declaration of every remote. The server creates them (Net.Setup); clients fetch them (Net.Get).
-- Direction and payload are documented in docs/gamedev/tech-design.md § contrato de remotes.

export type RemoteKind = "RemoteEvent" | "RemoteFunction" | "UnreliableRemoteEvent"

local Remotes: { [string]: RemoteKind } = {
	-- client -> server, replies (ok, reasonOrPayload). Payload: { action: string, ... }
	RequestAction = "RemoteFunction",
	-- server -> client. Payload: { kind: string, text: string }
	Notify = "RemoteEvent",
}

return Remotes
