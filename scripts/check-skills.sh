#!/bin/sh
# Checks every folder under skills/ against the Agent Skills specification:
# https://agentskills.io/specification
#
#   check-skills.sh [--self-test] [root]
#
set -eu

usage() {
	printf 'usage: %s [--self-test] [root]\n' "$0"
}

# Prints "name=<value>" and "description=<value>" from the SKILL.md frontmatter.
# Folded and literal blocks are joined into one line so length is measurable.
frontmatter() {
	awk '
		NR == 1 { next }
		$0 == "---" { exit }
		{
			if ($0 ~ /^[A-Za-z][A-Za-z0-9_-]*:/) {
				key = $0; sub(/:.*/, "", key)
				val = $0; sub(/^[^:]*:[ \t]*/, "", val)
				sub(/^[>|][+-]?[0-9]*$/, "", val)
				cur = key; v[key] = val
			} else if (cur != "" && $0 ~ /^[ \t]+[^ \t]/) {
				line = $0; sub(/^[ \t]+/, "", line)
				v[cur] = v[cur] " " line
			}
		}
		END { for (k in v) printf "%s=%s\n", k, v[k] }
	' "$1"
}

check_skill() {
	dir=$1
	name=$(basename "$dir")
	file="$dir/SKILL.md"
	bad=0
	say() {
		printf '%s: %s\n' "$name" "$1" >&2
		bad=1
	}

	if [ ! -f "$file" ]; then
		say "missing SKILL.md"
		return 1
	fi
	if [ "$(head -n 1 "$file")" != "---" ]; then
		say "SKILL.md must start with a --- frontmatter block"
		return 1
	fi

	meta=$(frontmatter "$file")
	declared=$(printf '%s\n' "$meta" | sed -n 's/^name=//p')
	desc=$(printf '%s\n' "$meta" | sed -n 's/^description=//p')

	case "$name" in
	*[!a-z0-9-]*) say "folder name must be lowercase letters, digits, and inner dashes" ;;
	esac
	[ ${#name} -le 64 ] || say "folder name is ${#name} characters, the limit is 64"
	[ -n "$declared" ] || say "frontmatter is missing a name"
	[ -z "$declared" ] || [ "$declared" = "$name" ] ||
		say "frontmatter name '$declared' does not match the folder name"
	[ -n "$desc" ] || say "frontmatter is missing a description"
	[ ${#desc} -le 1024 ] || say "description is ${#desc} characters, the limit is 1024"

	return $bad
}

check_root() {
	skills="$1/skills"
	[ -d "$skills" ] || {
		printf 'missing skills directory: %s\n' "$skills" >&2
		return 1
	}
	bad=0
	for dir in "$skills"/*; do
		[ -d "$dir" ] || continue
		check_skill "$dir" || bad=1
	done
	return $bad
}

self_test() {
	tmp=$(mktemp -d) || exit 1
	trap 'rm -rf "$tmp"' EXIT

	mkdir -p "$tmp/ok/skills/good-skill"
	printf -- '---\nname: good-skill\ndescription: >-\n  A folded\n  description.\n---\n\n# good-skill\n' \
		>"$tmp/ok/skills/good-skill/SKILL.md"

	mkdir -p "$tmp/renamed/skills/wrong-name"
	printf -- '---\nname: something-else\ndescription: Fine.\n---\n' \
		>"$tmp/renamed/skills/wrong-name/SKILL.md"

	mkdir -p "$tmp/empty/skills/no-frontmatter"
	printf '# no-frontmatter\n' >"$tmp/empty/skills/no-frontmatter/SKILL.md"

	expect() {
		want=$1
		shift
		if "$@" >/dev/null 2>&1; then got=0; else got=1; fi
		[ "$got" -eq "$want" ] || {
			printf 'self-test failed: expected exit %s from: %s\n' "$want" "$*" >&2
			return 1
		}
	}

	expect 0 "$0" "$tmp/ok"
	expect 1 "$0" "$tmp/renamed"
	expect 1 "$0" "$tmp/empty"
	printf 'self-test ok\n'
}

self_test_only=0
root=.
for arg in "$@"; do
	case "$arg" in
	--self-test) self_test_only=1 ;;
	-h | --help) usage; exit 0 ;;
	*) root=$arg ;;
	esac
done

if [ "$self_test_only" -eq 1 ]; then
	self_test
	exit
fi

check_root "$root"
