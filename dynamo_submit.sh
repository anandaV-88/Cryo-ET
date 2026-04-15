#!/bin/bash
# DYNAMO_SUBMIT - Submit Dynamo project to Curnagl GPUs
#
# Usage: dynamo_submit.sh project_name [--test]
# Tries gpu-h100 (reserved) first, falls back to gpu or gpu-l40 if full.

set -e

# ============================================================
# CONFIGURATION
# ============================================================
MATLAB_PATH="/dcsrsoft/spack/external/Mathworks/MATLAB/R2024b/bin/matlab"
DYNAMO_PATH="/work/TRAINING/UNIL/FBM/pnavarr1/navarro_teaching/Dynamo_v.1.1.555/dynamo_activate.m"
RUNTIME_LIBS="/dcsrsoft/spack/external/Mathworks/Runtime/R2023b/runtime/glnxa64:/dcsrsoft/spack/external/Mathworks/Runtime/R2023b/bin/glnxa64:/dcsrsoft/spack/external/Mathworks/Runtime/R2023b/sys/os/glnxa64:/dcsrsoft/spack/external/Mathworks/Runtime/R2023b/sys/opengl/lib/glnxa64"

TIME="6:00:00"
GPUS=1

# ============================================================
# PARSE ARGS
# ============================================================
PROJECT=""
TEST_MODE=false

for arg in "$@"; do
    if [ "$arg" = "--test" ]; then
        TEST_MODE=true
    else
        PROJECT="$arg"
    fi
done

if [ -z "$PROJECT" ]; then
    echo ""
    echo "=== DYNAMO_SUBMIT ==="
    echo ""
    echo "  Usage:  dynamo_submit.sh project_name [--test]"
    echo "  Tries gpu-h100 (reserved) first, then gpu, then gpu-l40."
    echo "  --test: submit without reservation/account"
    echo ""
    exit 0
fi

# ============================================================
# RESOLVE PROJECT PATH
# ============================================================
if [[ "$PROJECT" == /* ]]; then
    PROJECT_DIR="$PROJECT"
else
    PROJECT_DIR="$(pwd)/${PROJECT}"
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PROJECT="$(basename "$PROJECT_DIR")"
HPC_DIR="$(dirname "$PROJECT_DIR")"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project directory not found: ${PROJECT_DIR}"
    exit 1
fi

VP_FILE="${PROJECT_DIR}/settings/virtual_project.mat"
if [ ! -f "$VP_FILE" ]; then
    echo "ERROR: Virtual project not found: ${VP_FILE}"
    exit 1
fi

# ============================================================
# CHECK GPU AVAILABILITY AND PICK PARTITION
# ============================================================
get_free_gpus() {
    local partition=$1
    local total=$(scontrol show partition "$partition" 2>/dev/null | grep -oP 'gres/gpu=\K[0-9]+' | head -1)
    if [ -z "$total" ]; then
        echo 0
        return
    fi
    local used=$(squeue -p "$partition" --noheader -o "%b" 2>/dev/null | grep -oP '[0-9]+' | paste -sd+ | bc 2>/dev/null)
    used=${used:-0}
    echo $((total - used))
}

echo "Checking GPU availability..."

H100_FREE=$(get_free_gpus gpu-h100)
GPU_FREE=$(get_free_gpus gpu)
L40_FREE=$(get_free_gpus gpu-l40)

echo "  gpu-h100: ${H100_FREE} free | gpu: ${GPU_FREE} free | gpu-l40: ${L40_FREE} free"

if [ "$H100_FREE" -gt 0 ]; then
    PARTITION="gpu-h100"
    CPUS=16
    MEM="178G"
    ACCOUNT_LINES="#SBATCH --account=pnavarr1_navarro_teaching
#SBATCH --reservation=navarro"
    if [ "$TEST_MODE" = true ]; then
        ACCOUNT_LINES=""
    fi
elif [ "$GPU_FREE" -gt 0 ]; then
    PARTITION="gpu"
    CPUS=24
    MEM="196G"
    ACCOUNT_LINES=""
    echo "  → gpu-h100 full, using gpu (A100) partition"
elif [ "$L40_FREE" -gt 0 ]; then
    PARTITION="gpu-l40"
    CPUS=8
    MEM="48G"
    ACCOUNT_LINES=""
    echo "  → gpu-h100 and gpu full, using gpu-l40 partition"
else
    echo "ERROR: No free GPUs on any partition!"
    echo "  Try again later or check: squeue -p gpu-h100,gpu,gpu-l40"
    exit 1
fi

echo "  → Selected: ${PARTITION} (${CPUS} CPUs, ${MEM} RAM)"

# ============================================================
# FIX PATHS + UPDATE SETTINGS VIA MATLAB
# ============================================================
echo "Fixing paths and updating settings..."

MATLAB_CMD="vp=load('${VP_FILE}'); card=vp.card; f=fieldnames(card); for i=1:length(f), v=card.(f{i}); if ischar(v), v=regexprep(v,'^[A-Za-z]:','/work'); v=strrep(v,char(92),'/'); v=regexprep(v,'^/users/[^/]+/work/','/work/'); card.(f{i})=v; end; end; card.matlab_workers_average=${CPUS}; card.gpu_identifier_set=0; card.destination='matlab_gpu'; card.systemUsingProcessorTables=0; save('${VP_FILE}','card'); disp('Virtual project updated.'); exit;"

$MATLAB_PATH -nodisplay -nosplash -r "$MATLAB_CMD"

# ============================================================
# GENERATE SBATCH
# ============================================================
TIMESTAMP=$(date +%m%d_%H%M%S)
SBATCH_FILE="${HPC_DIR}/dynamo_${PROJECT}_${TIMESTAMP}.sbatch"

cat > "$SBATCH_FILE" << EOF
#!/bin/bash
#SBATCH --job-name=${PROJECT}
#SBATCH --time=${TIME}
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=${MEM}
#SBATCH --gres=gpu:${GPUS}
#SBATCH --partition=${PARTITION}
${ACCOUNT_LINES}
#SBATCH --output=${HPC_DIR}/slurm-%j.out
#SBATCH --error=${HPC_DIR}/slurm-%j.err

MATLAB_PATH="${MATLAB_PATH}"
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${RUNTIME_LIBS}

cd ${HPC_DIR}

cat > ${PROJECT}_run.m << 'RUNEOF'
run ${DYNAMO_PATH}
dynamo_execute_project ${PROJECT}
exit
RUNEOF

\$MATLAB_PATH -nodisplay -nosplash -r ${PROJECT}_run
EOF

# ============================================================
# SUBMIT
# ============================================================
echo ""
echo "Project:   ${PROJECT_DIR}"
echo "Settings:  ${TIME}, ${GPUS} GPU (${PARTITION}), ${CPUS} CPUs, ${MEM} RAM"
echo "Submitting..."

RESULT=$(sbatch "$SBATCH_FILE")

if echo "$RESULT" | grep -q "Submitted batch job"; then
    JOB_ID=$(echo "$RESULT" | grep -o '[0-9]*')
    echo "Job submitted! ID: ${JOB_ID}"
    echo "  Check:   squeue -u $(whoami)"
    echo "  Cancel:  scancel ${JOB_ID}"
else
    echo "Submission failed: ${RESULT}"
    exit 1
fi
