## Parallelism: prefer agent teams when I want visibility

When I ask for parallel work — "in parallel," "team," "split panes,"
"have one do X while another does Y" — use the agent-teams tools
(TeamCreate, Agent, SendMessage), not Task.

Use Task (subagents) for fire-and-forget background work I won't need
to watch or steer: codebase searches, single-file analyses, quick lookups.

For 1–2 quick tasks, just do them inline in the main session — spawning
agents costs ~10–20k tokens of context rebuild per agent before any work.

