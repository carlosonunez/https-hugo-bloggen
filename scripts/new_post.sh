#!/usr/bin/env bash
# This script looks horrible. I wrote it super quickly between tasks.
# My bad!
DEFAULT_ENVIRONMENT_FILE=$PWD/.env
ENVIRONMENT_FILE="${ENVIRONMENT_FILE:-$DEFAULT_ENVIRONMENT_FILE}"
export $(egrep -Ev '^#' "$ENVIRONMENT_FILE" | xargs -0)

REPO_NAME='https-hugo-bloggen'
is_running_inside_of_bloggen() {
  grep -Eiq  -- "$REPO_NAME" < <(git remote -v)
}

usage() {
  cat <<-EOF
$(basename "$0") TITLE [TAGS] [CATEGORIES]
Creates new posts.

OPTIONS

  TITLE         The title of your post.
  TAGS          A comma-separated list of tags to apply to your post.
  CATEGORIES    A comma-separated list of categories to apply to your post.
  OVERWRITE     Overwrite an existing post, if it exists.

ENVIRONMENT VARIABLES

  IS_DRAFT    Mark this post as a draft so that it doesn't get published. (default: false)
  POST_DIR    Override the directory the post lands in. (default: "./content/")
EOF
}
if is_running_inside_of_bloggen
then
  >&2 echo "ERROR: Run this from your blog's root directory instead."
  exit 1
fi

if grep -Eiq -- '-h|--help' <<< "$*"
then
  usage
  exit 0
fi

title="${1:-$(read -rp "Enter the title for your new post: " temp; echo "$temp")}"
if test -z "$title"
then
  usage
  >&2 echo "ERROR: Please provide a title."
  exit 1
fi
title_single=$(tr '[:upper:]' '[:lower:]' <<< "$title" | sed -E 's/[ ]/-/g')
tags="${2:-$(read -rp "Enter a comma-separated list of tags, or press ENTER to skip: " temp; echo "$temp")}"
categories="${3:-$(read -rp "Enter a comma-separated list of categories, or press ENTER to skip: " temp; echo "$temp")}"
post_fp="./content"
test -n "$POST_DIR" && post_fp="$(sed -E 's;\/$;;' <<< "${POST_DIR}")"
if ! test -d "$post_fp"
then
  >&2 echo "INFO: Creating post directory: $post_fp"
  mkdir -p "$post_fp"
fi
post_fp="${post_fp}/${title_single}.md"
if test -f "$post_fp" && test -z "$OVERWRITE"
then
  >&2 echo "ERROR: Post already exists: $post_fp"
  exit 1
fi
today="$(date --iso-8601=seconds)"
draft=false
test -n "$IS_DRAFT" && draft=true
front_matter=$(cat <<-EOF
---
title: $title
date: $today
draft: $draft
EOF
)
test -n "$categories" && front_matter="$front_matter\ncategories: $categories"
test -n "$tags" && front_matter="$front_matter\ntags: $tags"
front_matter="${front_matter}\n---"
>&2 echo "INFO: Creating '${title_single}' at ${post_fp}"
echo -e "$front_matter" > "$post_fp"
