# aricma skills

Agent skills for aricma's open source software, plus the ones we publish as an
organisation. One folder per skill under `skills/`, each following the
[Agent Skills specification](https://agentskills.io/specification).

## Use a skill

A skill is just a folder: `SKILL.md` and whatever it ships next to it. Copy or
symlink the folder into your agent's skills directory — `~/.agents/skills/<name>`
for Pi, `~/.claude/skills/<name>` for Claude Code. There is nothing to install.

| skill | what it covers |
| ----- | -------------- |

No skills yet — see [TODOs.md](./TODOs.md).

## Add a skill

`skills/<name>/SKILL.md`, with `name` and `description` frontmatter; the folder
name is the skill name. `mask build` checks every skill against the spec.

Every command is in [maskfile.md](./maskfile.md): install `mask`, then
`mask setup` once and `mask ci` as the gate.

## License

MIT — see [LICENSE](./LICENSE).
