# Phase 51: deterministic defaults for CI gate runner only.
# Local runs can override by exporting RELEASE_TAG and RELEASE_HEAD.
if [ "${CI_GATES_RUNNER:-0}" = "1" ]; then
  if [ -z "${RELEASE_TAG:-}" ]; then
    export RELEASE_TAG="v0.51.0"
  fi
  if [ -z "${RELEASE_HEAD:-}" ]; then
    if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
      export RELEASE_HEAD="HEAD^2"
    else
      export RELEASE_HEAD="HEAD"
    fi
  fi
fi
