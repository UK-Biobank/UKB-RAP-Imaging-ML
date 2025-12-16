#!/usr/bin/env bash
set -euxo pipefail

if [[ "${1-}" == "bash" && "${2-}" == "-c" && -n "${3-}" ]]; then
  eval "set -- ${3}"
fi


# Default paths for SAK
OUT_DIR=${OUT_DIR:-/tmp}
WORK_DIR=${WORK_DIR:-/work/run}
PANDORA_ROOT=${PANDORA_ROOT:-/work/PANDORA}

mkdir -p "$WORK_DIR" "$PANDORA_ROOT" "$OUT_DIR"
cd "$WORK_DIR"

# Symlink to inputs
ln -sf /tmp/* . 

# Args
CSV=""
SUBJECT_COL=""
VAR_COLS=""
PI=""
PM=""
CONTRAST="" 
GLOBALS_TAR=""
MODALITY_TAR=""
SUBJECT_IDS_FILE=""
NAME=""
CONFOUNDS=""

# Output flags (T on by default, others off)
OUT_T=1
OUT_P=0
OUT_F=0
OUT_PF=0

usage() {
  cat >&2 <<EOF
Usage: $0 \\
  --csv file.csv \\
  --subject-col 1 \\
  --var-cols 2[,3,...] \\
  --pi warpfield_jacobian \\
  --pm voxel|ICA1K|ICA10K \\
  --subject-ids subjectIDs_union.sample \\
  --globals-tar globals.tar \\
  --modality-tar warpfield_jacobian.tar \\
  --contrast "1 0 1"  # or multiple e.g. "1 0 0; 0 0 1" \\
  --confounds all|small \\
  --name <label> \\
  [--out /out] \\
  [--no-out-t]  #disable T stats (default is on) \\
  [--out-p] #output P values (in -log10(P) form) for T stats \\
  [--out-f] #output F stats \\
  [--out-pf] #output P values for F stats \\

Notes:
- Number of contrast coefficients in each row must equal the number of variables in --var-cols
- Multiple contrasts are separated by ';' and written as separate rows in design.con.
- By default, T-stat maps are written (unless --no-out-t). P/F/PF maps are off unless specified.
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv) CSV="$2"; shift 2;;
    --subject-col) SUBJECT_COL="$2"; shift 2;;
    --var-cols) VAR_COLS="$2"; shift 2;;
    --pi) PI="$2"; shift 2;;
    --pm) PM="$2"; shift 2;;
    --contrast) CONTRAST="$2"; shift 2;;
    --globals-tar) GLOBALS_TAR="$2"; shift 2;;
    --modality-tar) MODALITY_TAR="$2"; shift 2;;
    --subject-ids) SUBJECT_IDS_FILE="$2"; shift 2;;
    --confounds) CONFOUNDS="$2"; shift 2;;
    --name) NAME="$2"; shift 2;;
    --out) OUT_DIR="$2"; shift 2;;

    # Output controls
    --out-t) OUT_T=1; shift 1;;
    --no-out-t) OUT_T=0; shift 1;;
    --out-p) OUT_P=1; shift 1;;
    --out-f) OUT_F=1; shift 1;;
    --out-pf) OUT_PF=1; shift 1;;

    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

# Check required arguments
if [[ -z "$CSV" || -z "$SUBJECT_COL" || -z "$VAR_COLS" ]]; then
  echo "Error: --csv, --subject-col and --var-cols are required" >&2; usage; exit 2
fi
if [[ -z "$PI" ]]; then
  echo "Error: --pi (PANDORA submodality, e.g. warpfield_jacobian) is required" >&2; usage; exit 2
fi
if [[ -z "$PM" ]]; then
  echo "Error: --pm is required, e.g., voxel | ICA1K | ICA10K" >&2; usage; exit 2
fi
if [[ -z "$MODALITY_TAR" ]]; then
  echo "Error: --modality-tar is required and should point to the modality .tar" >&2; usage; exit 2
fi
if [[ -z "$GLOBALS_TAR" ]]; then
  echo "Error: --globals-tar is required and should point to globals.tar" >&2; usage; exit 2
fi
if [[ -z "$SUBJECT_IDS_FILE" ]]; then
  echo "Error: --subject-ids is required and should point to subjectIDs_union.sample" >&2; usage; exit 2
fi
if [[ -z "$CONTRAST" ]]; then
  echo "Error: --contrast is required and must match the number of variables in --var-cols" >&2; usage; exit 2
fi
if [[ -z "$CONFOUNDS" ]]; then
  echo "Error: --confounds is required (e.g., all | small)" >&2; usage; exit 2
fi
if [[ -z "$NAME" ]]; then
  echo "Error: --name is required (label used in output file name)" >&2; usage; exit 2
fi

# Validate that --var-cols contains at least one column
IFS=',' read -r -a var_cols_arr <<< "$VAR_COLS"
n_vars=${#var_cols_arr[@]}
if [[ "$n_vars" -le 0 ]]; then
  echo "Error: --var-cols must specify at least one column" >&2
  exit 2
fi

# Prepare PANDORA tree
echo "Extracting globals: $GLOBALS_TAR"
tar -C "$PANDORA_ROOT" -xvf "$GLOBALS_TAR"
echo "Extracting modality tar: $MODALITY_TAR"
tar -C "$PANDORA_ROOT" -xvf "$MODALITY_TAR"

if [[ ! -e "$PANDORA_ROOT/$PI" ]]; then
  echo "Error: Expected modality path '$PANDORA_ROOT/$PI' not found after extracting '$MODALITY_TAR'. Check that the tar’s top-level folder matches '$PI' under '$PANDORA_ROOT'." >&2
  exit 2
fi

mkdir -p "$PANDORA_ROOT/globals"
cp "$SUBJECT_IDS_FILE" "$PANDORA_ROOT/globals/subjectIDs_union.sample"
if [[ ! -f "$PANDORA_ROOT/globals/subjectIDs_union.sample" ]]; then
  echo "Error: Missing $PANDORA_ROOT/globals/subjectIDs_union.sample. Provide it via --subject-ids." >&2
  exit 2
fi

# Build design files
TMP_JOIN="$WORK_DIR/tmp_vars.txt"

awk -F, -v sc="$SUBJECT_COL" -v vc="$VAR_COLS" '
BEGIN {
  n = split(vc, idx, ",");
}
NR>1 {
  if ($(sc) == "") next;
  ok = 1;
  for (i = 1; i <= n; i++) {
    if ($(idx[i]) == "") { ok = 0; break; }
  }
  if (!ok) next;
  printf "%s", $(sc);
  for (i = 1; i <= n; i++) { printf " %s", $(idx[i]); }
  printf "\n";
}' "$CSV" > "$TMP_JOIN"

awk '{print $1}' "$TMP_JOIN" > subjects.txt
awk '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?" ":"\n");}' "$TMP_JOIN" > design.mat

# Build design.con (allowing multiple contrasts where each row is separated by ';')
: > design.con  
IFS=';' read -r -a contrast_rows <<< "$CONTRAST"

valid_rows=0
for row in "${contrast_rows[@]}"; do
  # remove whitespaces
  row_trimmed="$(echo "$row" | xargs || true)"
  [[ -z "$row_trimmed" ]] && continue

  # split row on whitespace into coefficients
  read -r -a coeffs <<< "$row_trimmed"

  # Check each row matches the number of variables
  if [[ ${#coeffs[@]} -ne "$n_vars" ]]; then
    echo "Error: contrast row '$row_trimmed' has ${#coeffs[@]} coefficients; expected $n_vars (from --var-cols)." >&2
    exit 2
  fi

  echo "$row_trimmed" >> design.con
  valid_rows=$((valid_rows + 1))
done

if [[ "$valid_rows" -eq 0 ]]; then
  echo "Error: no valid contrast rows found in --contrast." >&2
  exit 2
fi

# load FSL environment
if [[ -f "$FSLDIR/etc/fslconf/fsl.sh" ]]; then
  source "$FSLDIR/etc/fslconf/fsl.sh"
fi

# Run fsl_glm
OUT_PREFIX="${PI}_${PM}_${NAME}_confounds_${CONFOUNDS}"

glm_cmd=(fsl_glm
  -i "$PANDORA_ROOT/${PI}"
  -d design.mat
  -c design.con
  --pandora_subs=subjects.txt
  --demean
  --pandora_njobs=-1
  --pandora_mode="${PM}"
  --pandora_confs="${CONFOUNDS}"
)

# Add selected output options to fsl_glm command 
if [[ "$OUT_T" -eq 1 ]]; then
  glm_cmd+=(--out_t="${OUT_PREFIX}_T")
fi
if [[ "$OUT_P" -eq 1 ]]; then
  glm_cmd+=(--out_p="${OUT_PREFIX}_P")
fi
if [[ "$OUT_F" -eq 1 ]]; then
  glm_cmd+=(--out_f="${OUT_PREFIX}_F")
fi
if [[ "$OUT_PF" -eq 1 ]]; then
  glm_cmd+=(--out_pf="${OUT_PREFIX}_PF")
fi

echo "Running: ${glm_cmd[*]}"
"${glm_cmd[@]}"

# Copy outputs to OUT_DIR
shopt -s nullglob
for f in "${OUT_PREFIX}"*; do
  cp "$f" "$OUT_DIR/" || true
done
cp subjects.txt "$OUT_DIR/" 
cp design.mat "$OUT_DIR/" 
cp design.con "$OUT_DIR/" 

echo "Completed. Outputs in $OUT_DIR"