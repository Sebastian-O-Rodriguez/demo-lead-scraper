#!/bin/bash
# Parallel agent dispatcher with dependency-aware wave execution
# Usage: ./scripts/dispatch.sh <sprint-name>
#
# Reads current-sprint.md, parses tasks and dependencies, dispatches agents
# in dependency-ordered waves with result validation and automatic replanning.

set -euo pipefail

###############################################################################
# Configuration
###############################################################################

SPRINT="${1:?Usage: dispatch.sh <sprint-name>}"
SPRINT_FILE=".gorp/plans/current-sprint.md"
JOURNAL_DIR=".gorp/journal"
DATE=$(date +%Y-%m-%d)
DISPATCH_LOG="$JOURNAL_DIR/dispatch-${SPRINT}-${DATE}.log"
VALID_AGENTS="architect backend frontend qa robo"

# Counters for final summary
COUNT_DONE=0
COUNT_FAILED=0
COUNT_BLOCKED=0
COUNT_SKIPPED=0

###############################################################################
# Logging
###############################################################################

log() {
  local level="$1"; shift
  local msg="$*"
  local ts
  ts=$(date +"%Y-%m-%dT%H:%M:%S%z")
  echo "[$ts] [$level] $msg" | tee -a "$DISPATCH_LOG"
}

log_task() {
  local task_id="$1" agent="$2" status="$3"
  shift 3
  local extra="${*:-}"
  local ts
  ts=$(date +"%Y-%m-%dT%H:%M:%S%z")
  local line="[$ts] task=$task_id agent=$agent status=$status"
  if [ -n "$extra" ]; then
    line="$line $extra"
  fi
  echo "$line" | tee -a "$DISPATCH_LOG"
}

###############################################################################
# Sprint file helpers
###############################################################################

check_sprint_approval() {
  local status_line
  status_line=$(grep -iE '^\s*Status\s*:' "$SPRINT_FILE" | head -1 || true)

  if [ -z "$status_line" ]; then
    log "WARN" "No Status line found in sprint file; proceeding anyway"
    return 0
  fi

  if echo "$status_line" | grep -iqE '(approved|in\s*progress)'; then
    log "INFO" "Sprint status accepted: $status_line"
    return 0
  fi

  if echo "$status_line" | grep -iqE 'planning'; then
    log "ERROR" "Sprint is still in Planning. Approve the sprint before dispatching."
    echo ""
    echo "ERROR: Sprint status is 'Planning'. Update the Status line in"
    echo "       $SPRINT_FILE to 'Approved' or 'In Progress' first."
    exit 1
  fi

  log "WARN" "Unrecognised sprint status: $status_line — proceeding"
  return 0
}

###############################################################################
# Task parsing
###############################################################################

TASK_IDS=()
TASK_AGENTS=()
TASK_TITLES=()
TASK_CRITERIA=()
TASK_STATUSES=()

parse_tasks() {
  while IFS='|' read -r _ id agent task status criteria _; do
    id=$(echo "$id" | xargs)
    agent=$(echo "$agent" | xargs | tr '[:upper:]' '[:lower:]')
    task=$(echo "$task" | xargs)
    status=$(echo "$status" | xargs | tr '[:upper:]' '[:lower:]')
    criteria=$(echo "$criteria" | xargs)

    if [ -z "$id" ] || [ -z "$agent" ] || [ -z "$task" ]; then
      continue
    fi

    if [ "$status" != "pending" ]; then
      continue
    fi

    TASK_IDS+=("$id")
    TASK_AGENTS+=("$agent")
    TASK_TITLES+=("$task")
    TASK_CRITERIA+=("$criteria")
    TASK_STATUSES+=("pending")
  done < <(grep -E '^\|.*\bpending\b' "$SPRINT_FILE" || true)
}

task_index_by_id() {
  local search_id="$1"
  local i
  for i in "${!TASK_IDS[@]}"; do
    if [ "${TASK_IDS[$i]}" = "$search_id" ]; then
      echo "$i"
      return 0
    fi
  done
  return 1
}

###############################################################################
# Dependency parsing
###############################################################################

DEPS_RAW=()

parse_dependencies() {
  local in_deps=0
  while IFS= read -r line; do
    if echo "$line" | grep -qiE '^##\s+Dependencies'; then
      in_deps=1
      continue
    fi
    if [ "$in_deps" -eq 1 ] && echo "$line" | grep -qE '^##'; then
      break
    fi
    if [ "$in_deps" -eq 0 ]; then
      continue
    fi
    if echo "$line" | grep -qiE '^\s*-\s+\S+\s+depends\s+on'; then
      local target deps_str
      target=$(echo "$line" | sed -E 's/^\s*-\s+(\S+)\s+depends\s+on\s+/\1/i')
      deps_str=$(echo "$target" | sed -E 's/[,+]/ /g; s/\band\b/ /gi')
      target=$(echo "$deps_str" | awk '{print $1}')
      deps_str=$(echo "$deps_str" | cut -d' ' -f2-)
      DEPS_RAW+=("$target $deps_str")
    fi
  done < "$SPRINT_FILE"
}

get_deps_for() {
  local task_id="$1"
  local entry
  for entry in "${DEPS_RAW[@]+"${DEPS_RAW[@]}"}"; do
    local t
    t=$(echo "$entry" | awk '{print $1}')
    if [ "$t" = "$task_id" ]; then
      echo "$entry" | cut -d' ' -f2-
      return
    fi
  done
}

###############################################################################
# Wave builder
###############################################################################

build_waves() {
  local remaining=()
  local i
  for i in "${!TASK_IDS[@]}"; do
    remaining+=("$i")
  done

  local resolved=()
  local wave=0

  while [ "${#remaining[@]}" -gt 0 ]; do
    local wave_tasks=()
    local still_remaining=()

    for i in "${remaining[@]}"; do
      local tid="${TASK_IDS[$i]}"
      local deps
      deps=$(get_deps_for "$tid")

      local all_met=1
      if [ -n "$deps" ]; then
        for dep in $deps; do
          local found=0
          for r in "${resolved[@]+"${resolved[@]}"}"; do
            if [ "$r" = "$dep" ]; then
              found=1
              break
            fi
          done
          if [ "$found" -eq 0 ]; then
            all_met=0
            break
          fi
        done
      fi

      if [ "$all_met" -eq 1 ]; then
        wave_tasks+=("$i")
      else
        still_remaining+=("$i")
      fi
    done

    if [ "${#wave_tasks[@]}" -eq 0 ]; then
      for i in "${still_remaining[@]}"; do
        echo "unresolvable $i"
      done
      break
    fi

    for i in "${wave_tasks[@]}"; do
      echo "$wave $i"
      resolved+=("${TASK_IDS[$i]}")
    done

    remaining=("${still_remaining[@]+"${still_remaining[@]}"}")
    wave=$((wave + 1))
  done
}

###############################################################################
# Sprint file updater
###############################################################################

update_task_status_in_file() {
  local task_id="$1"
  local new_status="$2"
  sed -i.bak -E \
    "/^\|[[:space:]]*${task_id}[[:space:]]*\|/s/\|[[:space:]]*(pending|in.progress)[[:space:]]*\|/| ${new_status} |/" \
    "$SPRINT_FILE"
  rm -f "${SPRINT_FILE}.bak"
}

###############################################################################
# Mark downstream dependents as skipped
###############################################################################

skip_dependents_of() {
  local failed_id="$1"
  local i
  for i in "${!TASK_IDS[@]}"; do
    local tid="${TASK_IDS[$i]}"
    local deps
    deps=$(get_deps_for "$tid")
    if [ -z "$deps" ]; then
      continue
    fi
    for dep in $deps; do
      if [ "$dep" = "$failed_id" ]; then
        if [ "${TASK_STATUSES[$i]}" = "pending" ]; then
          TASK_STATUSES[$i]="skipped"
          COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
          log_task "$tid" "${TASK_AGENTS[$i]}" "skipped" "reason=upstream_${failed_id}_failed"
          update_task_status_in_file "$tid" "skipped"
          skip_dependents_of "$tid"
        fi
        break
      fi
    done
  done
}

###############################################################################
# Dispatch a single task
###############################################################################

dispatch_task() {
  local idx="$1"
  local task_id="${TASK_IDS[$idx]}"
  local agent="${TASK_AGENTS[$idx]}"
  local task_title="${TASK_TITLES[$idx]}"
  local criteria="${TASK_CRITERIA[$idx]}"

  if ! echo "$VALID_AGENTS" | grep -qw "$agent"; then
    log_task "$task_id" "$agent" "skipped" "reason=unknown_agent"
    TASK_STATUSES[$idx]="skipped"
    COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
    update_task_status_in_file "$task_id" "skipped"
    return 0
  fi

  local prompt
  prompt="## Task
ID: $task_id
Title: $task_title
Agent: $agent
Sprint: $SPRINT

## Acceptance Criteria
$criteria

## Rules
- Read CLAUDE.md first for product context
- Read .gorp/plans/current-sprint.md for full sprint context
- Only modify files within your task scope
- Write journal entry to .gorp/journal/${agent}-${DATE}.md when done
- Conventional commits: type(scope): description"

  local output_file="$JOURNAL_DIR/${agent}-${task_id}-dispatch.json"
  local start_ts
  start_ts=$(date +%s)

  log_task "$task_id" "$agent" "dispatching" "title=\"$task_title\""

  GORP_AGENT="$agent" GORP_SCOPE="$task_id" \
    claude -p "$prompt" \
      --agent "$agent" \
      --output-format json \
      > "$output_file" 2>&1
  local exit_code=$?

  local end_ts
  end_ts=$(date +%s)
  local duration=$(( end_ts - start_ts ))

  local final_status="done"

  if [ "$exit_code" -ne 0 ]; then
    log_task "$task_id" "$agent" "failed" "exit_code=$exit_code duration=${duration}s"
    final_status="failed"
  fi

  local journal_file="$JOURNAL_DIR/${agent}-${DATE}.md"
  if [ "$final_status" = "done" ] && [ ! -f "$journal_file" ]; then
    log_task "$task_id" "$agent" "failed" "reason=no_journal_file duration=${duration}s"
    final_status="failed"
  fi

  if [ "$final_status" = "done" ] && [ -f "$journal_file" ]; then
    local journal_status
    journal_status=$(grep -iE '^\s*Status\s*:' "$journal_file" | tail -1 | sed -E 's/^\s*Status\s*:\s*//' | xargs | tr '[:upper:]' '[:lower:]' || true)
    if [ -n "$journal_status" ]; then
      case "$journal_status" in
        done|complete|completed)
          final_status="done"
          ;;
        blocked*)
          final_status="blocked"
          ;;
        failed|error)
          final_status="failed"
          ;;
        *)
          log "WARN" "Unrecognised journal status '$journal_status' for task $task_id — treating as done"
          ;;
      esac
    fi
  fi

  if [ "$final_status" = "done" ]; then
    log_task "$task_id" "$agent" "done" "duration=${duration}s"
  fi

  TASK_STATUSES[$idx]="$final_status"
  update_task_status_in_file "$task_id" "$final_status"

  echo "$final_status" > "$JOURNAL_DIR/.result-${task_id}"

  if [ "$final_status" = "failed" ] || [ "$final_status" = "blocked" ]; then
    skip_dependents_of "$task_id"
  fi
}

###############################################################################
# Replan step
###############################################################################

run_replan() {
  log "INFO" "=== Replan Step ==="

  local summary="## Dispatch Summary for Sprint: $SPRINT\nDate: $DATE\n\n"
  summary+="| ID | Agent | Task | Result |\n"
  summary+="|-----|-------|------|--------|\n"

  local i
  for i in "${!TASK_IDS[@]}"; do
    summary+="| ${TASK_IDS[$i]} | ${TASK_AGENTS[$i]} | ${TASK_TITLES[$i]} | ${TASK_STATUSES[$i]} |\n"
  done

  local replan_prompt
  replan_prompt="## Replan Required

The following sprint dispatch had failures or blocked tasks.

$(echo -e "$summary")

## Instructions
- Analyse the failures and blocks above
- Update .gorp/plans/current-sprint.md with revised tasks if needed
- Write your analysis to .gorp/journal/robo-${DATE}.md
- Keep the sprint goals intact; adjust approach, not scope"

  log "INFO" "Dispatching Robo for replan"

  GORP_AGENT="robo" GORP_SCOPE="replan" \
    claude -p "$replan_prompt" \
      --agent "robo" \
      --output-format json \
      > "$JOURNAL_DIR/robo-replan-dispatch.json" 2>&1 || true

  log "INFO" "Replan dispatch complete"
}

###############################################################################
# Main
###############################################################################

main() {
  if [ ! -f "$SPRINT_FILE" ]; then
    echo "Error: $SPRINT_FILE not found"
    exit 1
  fi

  mkdir -p "$JOURNAL_DIR"

  echo "# Dispatch Log: $SPRINT ($DATE)" > "$DISPATCH_LOG"
  echo "" >> "$DISPATCH_LOG"

  log "INFO" "=== Dispatching Sprint: $SPRINT ==="

  check_sprint_approval

  parse_tasks

  if [ "${#TASK_IDS[@]}" -eq 0 ]; then
    log "WARN" "No pending tasks found in $SPRINT_FILE"
    echo "No pending tasks to dispatch."
    exit 0
  fi

  log "INFO" "Found ${#TASK_IDS[@]} pending task(s)"

  parse_dependencies

  local wave_data
  wave_data=$(build_waves)

  local max_wave=0
  while IFS=' ' read -r w idx; do
    if [ "$w" = "unresolvable" ]; then
      continue
    fi
    if [ "$w" -gt "$max_wave" ]; then
      max_wave="$w"
    fi
  done <<< "$wave_data"

  while IFS=' ' read -r w idx; do
    if [ "$w" = "unresolvable" ]; then
      local tid="${TASK_IDS[$idx]}"
      TASK_STATUSES[$idx]="skipped"
      COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
      log_task "$tid" "${TASK_AGENTS[$idx]}" "skipped" "reason=unresolvable_dependencies"
      update_task_status_in_file "$tid" "skipped"
    fi
  done <<< "$wave_data"

  local wave_num=0
  while [ "$wave_num" -le "$max_wave" ]; do
    log "INFO" "--- Wave $wave_num ---"

    local pids=()
    local pid_task_map=()

    while IFS=' ' read -r w idx; do
      if [ "$w" = "unresolvable" ]; then
        continue
      fi
      if [ "$w" -ne "$wave_num" ]; then
        continue
      fi

      local tid="${TASK_IDS[$idx]}"

      if [ "${TASK_STATUSES[$idx]}" = "skipped" ]; then
        continue
      fi

      dispatch_task "$idx" &
      local pid=$!
      pids+=("$pid")
      pid_task_map+=("$pid:$idx")

      log "INFO" "  PID $pid -> ${TASK_IDS[$idx]} (${TASK_AGENTS[$idx]})"
    done <<< "$wave_data"

    if [ "${#pids[@]}" -gt 0 ]; then
      for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
      done
    fi

    for entry in "${pid_task_map[@]+"${pid_task_map[@]}"}"; do
      local idx="${entry#*:}"
      local tid="${TASK_IDS[$idx]}"
      local result_file="$JOURNAL_DIR/.result-${tid}"
      if [ -f "$result_file" ]; then
        local result
        result=$(cat "$result_file")
        TASK_STATUSES[$idx]="$result"
        rm -f "$result_file"
        case "$result" in
          done)     COUNT_DONE=$((COUNT_DONE + 1)) ;;
          failed)   COUNT_FAILED=$((COUNT_FAILED + 1)) ;;
          blocked)  COUNT_BLOCKED=$((COUNT_BLOCKED + 1)) ;;
          skipped)  COUNT_SKIPPED=$((COUNT_SKIPPED + 1)) ;;
        esac
      fi
    done

    for entry in "${pid_task_map[@]+"${pid_task_map[@]}"}"; do
      local idx="${entry#*:}"
      local st="${TASK_STATUSES[$idx]}"
      if [ "$st" = "failed" ] || [ "$st" = "blocked" ]; then
        skip_dependents_of "${TASK_IDS[$idx]}"
      fi
    done

    log "INFO" "Wave $wave_num complete"
    wave_num=$((wave_num + 1))
  done

  log "INFO" "=== Dispatch Complete ==="
  log "INFO" "Results: done=$COUNT_DONE failed=$COUNT_FAILED blocked=$COUNT_BLOCKED skipped=$COUNT_SKIPPED"

  echo ""
  echo "=== Sprint Dispatch Summary ==="
  echo "  Done:    $COUNT_DONE"
  echo "  Failed:  $COUNT_FAILED"
  echo "  Blocked: $COUNT_BLOCKED"
  echo "  Skipped: $COUNT_SKIPPED"
  echo ""
  echo "Log: $DISPATCH_LOG"
  echo ""

  if [ "$COUNT_FAILED" -gt 0 ] || [ "$COUNT_BLOCKED" -gt 0 ]; then
    log "INFO" "Failures or blocks detected — triggering replan"
    run_replan
  fi

  if [ "$COUNT_FAILED" -gt 0 ]; then
    exit 1
  fi

  echo "=== All agents complete ==="
}

main
