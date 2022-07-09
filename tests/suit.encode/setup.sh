declare MEDIADIR="${TEST_MOCKDIR}/media"

declare MOCKSRC_FILE="${MEDIADIR}/mess/vid1.txt"
declare MOCKSRC_DIR="${MEDIADIR}/mess"
declare MOCKSRC_FILENAME="$(basename "${MOCKSRC_FILE}")"
declare MOCKDEST_FILE="${MEDIADIR}/vencoded.txt"

declare -A ENC_OPTS=()
