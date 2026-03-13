#!/usr/bin/env bash
set -euo pipefail

CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD:-80}"
SNS_TOPIC_ARN="${SNS_TOPIC_ARN:-}"
AWS_REGION="${AWS_REGION:-us-east-2}"
CLUSTER_NAME="${CLUSTER_NAME:-unknown-cluster}"

FAILURES=()

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

add_failure() {
  FAILURES+=("$1")
  log "ERROR: $1"
}

send_sns_alert() {
  local message="$1"

  if [[ -z "$SNS_TOPIC_ARN" ]]; then
    log "WARN: SNS_TOPIC_ARN not set. Skipping SNS alert."
    return 0
  fi

  aws sns publish \
    --topic-arn "$SNS_TOPIC_ARN" \
    --subject "EKS Cluster Health Check Failed: $CLUSTER_NAME" \
    --message "$message" \
    --region "$AWS_REGION" >/dev/null

  log "SNS alert sent."
}

check_prereqs() {
  command -v kubectl >/dev/null 2>&1 || {
    echo "kubectl is not installed or not in PATH"
    exit 2
  }

  command -v aws >/dev/null 2>&1 || {
    echo "aws CLI is not installed or not in PATH"
    exit 2
  }
}

check_nodes() {
  log "Checking node readiness..."

  local not_ready_nodes
  not_ready_nodes=$(kubectl get nodes --no-headers 2>/dev/null | awk '$2 != "Ready" {print $1 ":" $2}')

  if [[ -n "$not_ready_nodes" ]]; then
    add_failure "Found NotReady or unhealthy nodes: $not_ready_nodes"
  else
    log "All nodes are Ready."
  fi
}

check_pods() {
  log "Checking pod failure states..."

  local bad_pods
  bad_pods=$(kubectl get pods -A --no-headers 2>/dev/null | awk '$4 ~ /CrashLoopBackOff|Error/ {print $1 "/" $2 ":" $4}')

  if [[ -n "$bad_pods" ]]; then
    add_failure "Found failed pods: $bad_pods"
  else
    log "No pods in CrashLoopBackOff or Error state."
  fi
}

check_metrics_server() {
  if ! kubectl top nodes >/dev/null 2>&1; then
    add_failure "Unable to collect node metrics with 'kubectl top nodes'. Ensure metrics-server is installed and healthy."
    return 1
  fi
  return 0
}

check_node_utilization() {
  log "Checking node CPU and memory utilization..."

  check_metrics_server || return 0

  while read -r node cpu_percent mem_percent; do
    cpu_value="${cpu_percent%\%}"
    mem_value="${mem_percent%\%}"

    if [[ "$cpu_value" -gt "$CPU_THRESHOLD" ]]; then
      add_failure "Node $node CPU usage is ${cpu_value}% which exceeds threshold ${CPU_THRESHOLD}%"
    fi

    if [[ "$mem_value" -gt "$MEMORY_THRESHOLD" ]]; then
      add_failure "Node $node memory usage is ${mem_value}% which exceeds threshold ${MEMORY_THRESHOLD}%"
    fi
  done < <(kubectl top nodes --no-headers | awk '{print $1, $3, $5}')

  if [[ "${#FAILURES[@]}" -eq 0 ]]; then
    log "Node CPU and memory utilization are within thresholds."
  fi
}

main() {
  log "Starting pre-deployment cluster health check for cluster: $CLUSTER_NAME"
  log "Configured thresholds: CPU=${CPU_THRESHOLD}% MEMORY=${MEMORY_THRESHOLD}%"

  check_prereqs
  check_nodes
  check_pods
  check_node_utilization

  if [[ "${#FAILURES[@]}" -gt 0 ]]; then
    local failure_message
    failure_message=$(
      printf "Cluster health check failed for %s\n\nThresholds:\n- CPU: %s%%\n- Memory: %s%%\n\nFailures:\n" \
        "$CLUSTER_NAME" "$CPU_THRESHOLD" "$MEMORY_THRESHOLD"
      printf -- "- %s\n" "${FAILURES[@]}"
    )

    log "Cluster health check FAILED."
    echo "$failure_message"
    send_sns_alert "$failure_message"
    exit 1
  fi

  log "Cluster health check PASSED."
}

main "$@"
