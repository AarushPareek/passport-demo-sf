#!/usr/bin/env bash
set -euo pipefail

# Local Agentia quality gates (macOS / Linux). Agentia runs this from the repo root during
# `agentia cicd work test` and before `agentia cicd work submit`. Exit non-zero to stop.

# >>> agent-passport (managed by `agentia passport setup`; edit with setup, not by hand) >>>
# Agent Passport: the agent must hold a current, granted stamp before this story moves on.
echo "## Agent Passport: verifying the agent"
agentia passport verify --env Passport-Dev --agent CustomerServiceAgent --travel-to Passport-QA || exit $?
# <<< agent-passport <<<
