# aricma skills Actions

This mask file documents the actions you can run in this repo. Install
[`mask`](https://github.com/jacobdeichert/mask) once, then `mask setup` to get
the pinned tools into `./tmp/bin`.

## Targets

- OS/arch: linux/amd64, linux/arm64, darwin/arm64
- Unix shell: sh
- Windows: not a target for the repo commands — the skills themselves are plain
  Markdown and are portable.

Deviations from the standard command set:

- No `preview`: there is nothing to run, the repo ships text.
- `test` runs the checker's own self-test against fixtures, not a consumer suite.

## setup

> Install the tools pinned in mise.toml into ./tmp/bin.

```sh
export PATH="$MASKFILE_DIR/tmp/bin:$PATH"
command -v mise >/dev/null || {
	printf 'mise not found on PATH. Install it, then re-run mask setup.\n' >&2
	exit 1
}
cd "$MASKFILE_DIR"
mise install
# A plain link rather than `mise reshim`: a shim dir here would also expose every
# tool mise installed globally, shadowing binaries this repo never pinned.
mkdir -p "$MASKFILE_DIR/tmp/bin"
ln -sf "$(mise which dprint)" "$MASKFILE_DIR/tmp/bin/dprint"
```

## format

> Check that every Markdown file is formatted with dprint. Pass --fix to rewrite.

**OPTIONS**

- fix
  - flags: -f --fix
  - desc: Rewrite files instead of only checking them

```sh
export PATH="$MASKFILE_DIR/tmp/bin:$PATH"
cd "$MASKFILE_DIR"
if [ "${fix:-}" = "true" ]; then
	dprint fmt
else
	dprint check
fi
```

## build

> Check every skill against the Agent Skills specification.

```sh
sh "$MASKFILE_DIR/scripts/check-skills.sh" "$MASKFILE_DIR"
```

## test

> Self-test the skill checker against good and broken fixtures.

```sh
sh "$MASKFILE_DIR/scripts/check-skills.sh" --self-test
```

## ci

> Run format, build, and test as the local quality gate. Pass --fix to rewrite formatting.

**OPTIONS**

- fix
  - flags: -f --fix
  - desc: Auto-fix formatting instead of only checking it

```sh
set --
[ "${fix:-}" = "true" ] && set -- --fix
$MASK format "$@" && $MASK build && $MASK test
```
