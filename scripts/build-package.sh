#!/usr/bin/env bash

function log {
	echo "$@" >&2
}

function die {
	log "$@"
	exit 1
}

keep=false
publish=false

while getopts "kph" o; do
  case "$o" in
		k)
			keep=true
			;;
    p)
  		publish=true
      ;;
    h)
	    echo "Usage: $0 [-p] <package name> <version>"
			exit 0
			;;
    *)
	    die "Usage: $0 [-p] <package name> <version>"
      ;;
  esac
done
shift $((OPTIND-1))

pkg="${1:?"Usage: $0 [-p] <package name> <version>"}"
version="${2:?"Usage: $0 [-p] <package name> <version>"}"

function prefix {
	sed -e "s|^|$1|"
}

set -euo pipefail

cd $(dirname "$0")/..

if ! [ -d "packages/$pkg" ]; then
	log "Invalid packgage name: $pkg"
	log "Pick one of the following package names:"
	( cd packages && ls | prefix "- " ) >&2
	exit 1
fi

DOTCONFIG_DIR="$(pwd)"
. <(scripts/build-package/determine-versions.js)

export DOTCONFIG_DIR
export KDL_VERSION

FORCE_COLOR=1
export FORCE_COLOR

pkgdir="$(cd "packages/$pkg" && pwd)"

workdir="$(mktemp -d)"
log "Working directory: $workdir"

log "Loading settings for package $pkg"
source "packages/$pkg/settings"

old_name="$(echo "$pkg" | sed -e "s|__|/|")"
new_name="@dot-config/$pkg"
new_version="${version}-dotconfig.${DOTCONFIG_VERSION}"

pushd "$workdir" > /dev/null 2>&1

if [[ "$version" = "main" ]]; then
	if ! command -v fetch_main >/dev/null 2>&1; then
		die "No fetch_main configured for package $pkg"
	fi

	log "Downloading main version for $pkg"
	fetch_main
else
	if ! command -v fetch_version >/dev/null 2>&1; then
		die "No fetch_version configured for package $pkg"
	fi

	log "Downloading version $version for $pkg"
	fetch_version "$version"
fi

"$DOTCONFIG_DIR/scripts/build-package/update-package-json.js" "$new_name" "packages/$pkg" "$new_version"

for file in "$pkgdir"/??-*
do
	filename="$(basename "$file")"
	case "$filename" in
		*.sh)
			log "Running script $filename"

			"$file" \
				2> >(prefix "    " >&2) \
				| prefix "    " \
				|| die "Script $filename failed, keeping working directory $workdir for debugging"
			;;
		*.patch)
			log "Applying patch $filename"

			patch <"$file" \
				2> >(prefix "    " >&2) \
				| prefix "    " \
				|| die "Patch $filename failed, keeping working directory $workdir for debugging"
			;;
		*)
			die "Unable to handle $file"
			;;
	esac
done

if [ -n "${dist_folder:-}" ]; then
	cd "$dist_folder"
fi

cat <<EOF >README.md
# $new_name

This package contains $old_name version $version with patches so it loads configuration from a \`.config\` folder.

## Usage

Replace

\`\`\`
  "$old_name": "$version"
\`\`\`

with

\`\`\`
  "$old_name": "npm:$new_name@$new_version"
\`\`\`

For more info, see https://github.com/bgotink/dot-config.
EOF

if $publish; then
	if [[ "$version" = main ]] then
		tag=develop
		latest=false
	else
		tag="upstream-$version"
		latest="$("$DOTCONFIG_DIR/scripts/build-package/is-latest-tag.js" "$pkg" "$version")"
	fi

	npm publish --access public --tag "$tag"

	if $latest; then
		npm dist-tag add "${new_name}@${new_version}" latest
	fi
fi

if $keep; then
	log "Kept working directory $workdir as requested"
elif ! $publish; then
	log "Kept working directory $workdir because publish was skipped"
	if [ -n "${dist_folder:-}" ]; then
		log "Output folder: $(pwd)"
	fi
else
	popd >/dev/null 2>&1

	rm -fr "$workdir"
	log "Working directory removed"
fi
