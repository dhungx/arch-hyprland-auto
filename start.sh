#!/usr/bin/env bash
# =============================================================================
#  HYPRLAND 2025 MULTI-LANGUAGE LAUNCHER v2.0 ENHANCED
#  Chọn ngôn ngữ → Tự động tải & chạy đúng script (en.sh / vi.sh / kr.sh)
#  GitHub: https://github.com/dhungx/arch-hyprland-auto
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

REPO="https://raw.githubusercontent.com/dhungx/arch-hyprland-auto/main"
TIMEOUT=30
MAX_RETRIES=3
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === MULTILINGUA MESSAGES ===
declare -A MSG_LANG_SELECT=(
    [vi]="Chọn ngôn ngữ"
    [en]="Select language"
    [kr]="언어 선택"
)

declare -A MSG_DOWNLOADING=(
    [vi]="Đang tải script"
    [en]="Downloading script"
    [kr]="스크립트 다운로드 중"
)

declare -A MSG_DOWNLOAD_SUCCESS=(
    [vi]="Tải script thành công!"
    [en]="Script downloaded successfully!"
    [kr]="스크립트 다운로드 완료!"
)

declare -A MSG_DOWNLOAD_INCOMPLETE=(
    [vi]="Script tải không đầy đủ hoặc hỏng, thử lại..."
    [en]="Script incomplete or corrupted, retrying..."
    [kr]="스크립트가 불완전하거나 손상되었습니다. 다시 시도 중..."
)

declare -A MSG_TIMEOUT_ERROR=(
    [vi]="Timeout hoặc lỗi mạng khi tải"
    [en]="Timeout or network error while downloading"
    [kr]="다운로드 중 시간 초과 또는 네트워크 오류"
)

declare -A MSG_NO_INTERNET=(
    [vi]="Không có kết nối Internet"
    [en]="No Internet connection"
    [kr]="인터넷 연결 없음"
)

declare -A MSG_NEED_CONNECTION=(
    [vi]="Cần Internet hoặc script cục bộ"
    [en]="Need Internet or local script"
    [kr]="인터넷 또는 로컬 스크립트 필요"
)

declare -A MSG_USING_LOCAL=(
    [vi]="Sẽ sử dụng script cục bộ..."
    [en]="Using local script..."
    [kr]="로컬 스크립트 사용 중..."
)

declare -A MSG_USING_FALLBACK=(
    [vi]="Không thể tải từ mạng, sử dụng script cục bộ..."
    [en]="Cannot download, using local script..."
    [kr]="다운로드할 수 없음, 로컬 스크립트 사용 중..."
)

declare -A MSG_DOWNLOAD_FAILED=(
    [vi]="Lỗi tải script sau"
    [en]="Script download failed after"
    [kr]="스크립트 다운로드 실패 후"
)

declare -A MSG_RETRIES=(
    [vi]="lần thử! Kiểm tra mạng hoặc GitHub."
    [en]="retries! Check network or GitHub."
    [kr]="번 시도! 네트워크 또는 GitHub를 확인하세요."
)

declare -A MSG_LOAD_SUCCESS=(
    [vi]="Tải thành công! Bắt đầu cài đặt"
    [en]="Loaded successfully! Starting installation"
    [kr]="로드 완료! 설치 시작"
)

declare -A MSG_WARNING=(
    [vi]="CẢNH BÁO: TOÀN BỘ DỮ LIỆU TRÊN Ổ ĐĨA SẼ BỊ XÓA!"
    [en]="WARNING: ALL DATA ON DISK WILL BE DELETED!"
    [kr]="경고: 디스크의 모든 데이터가 삭제됩니다!"
)

declare -A MSG_CONFIRM=(
    [vi]="Tiếp tục cài đặt? (y/N): "
    [en]="Continue installation? (y/N): "
    [kr]="설치를 계속하시겠습니까? (y/N): "
)

declare -A MSG_CANCELLED=(
    [vi]="Hủy cài đặt."
    [en]="Installation cancelled."
    [kr]="설치 취소됨."
)

declare -A MSG_STARTING=(
    [vi]="Bắt đầu cài Hyprland 2025"
    [en]="Starting Hyprland 2025 installation"
    [kr]="Hyprland 2025 설치 시작"
)

declare -A MSG_WAIT=(
    [vi]="Thả lỏng và chờ 6-10 phút"
    [en]="Relax and wait 6-10 minutes"
    [kr]="편안하게 앉아 6-10분을 기다리세요"
)

declare -A MSG_COMPLETE=(
    [vi]="HOÀN TẤT! Tháo USB → gõ: reboot"
    [en]="COMPLETE! Remove USB → type: reboot"
    [kr]="완료! USB 제거 → 입력: reboot"
)

declare -A MSG_WELCOME=(
    [vi]="Chào mừng đến với Hyprland 2025 – ĐẸP NHƯ IPAD PRO M2!"
    [en]="Welcome to Hyprland 2025 – BEAUTIFUL AS IPAD PRO M2!"
    [kr]="Hyprland 2025에 오신 것을 환영합니다 – IPAD PRO M2처럼 아름답습니다!"
)

# === LOGGING FUNCTIONS ===
log()    { echo -e "\e[1;32m[+] $(date '+%H:%M:%S') $*\e[0m"; }
warn()   { echo -e "\e[1;33m[!] $(date '+%H:%M:%S') $*\e[0m"; }
err()    { echo -e "\e[1;31m[-] $(date '+%H:%M:%S') $*\e[0m" >&2; }
success(){ echo -e "\e[1;92m[OK] $(date '+%H:%M:%S') $*\e[0m"; }

# === CLEANUP HANDLER ===
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        err "Script encountered an error (exit code: $exit_code)"
        rm -f /tmp/hyprland-*.sh 2>/dev/null || true
    fi
    exit $exit_code
}
trap cleanup EXIT

# === CHECK INTERNET CONNECTION ===
check_internet() {
    for server in 1.1.1.1 8.8.8.8 8.8.4.4; do
        if ping -q -c 2 "$server" &>/dev/null; then
            return 0
        fi
    done
    return 1
}

clear
echo -e "\e[1;38;5;165m"
cat << "EOF"
   
████████╗██╗░░░██╗███╗░░██╗░█████╗░
╚══██╔══╝╚██╗░██╔╝████╗░██║██╔══██╗
░░░██║░░░░╚████╔╝░██╔██╗██║██║░░██║
░░░██║░░░░░╚██╔╝░░██║╚████║██║░░██║
░░░██║░░░░░░██║░░░██║░╚███║╚█████╔╝
░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚══╝░╚════╝░                                                                                                        
           MULTI-LANGUAGE INSTALLER
EOF
echo -e "\e[0m"

echo -e "\e[1;36m   Chọn ngôn ngữ / 언어 선택 / Select language:\e[0m"
echo -e "   \e[1;33m[1]\e[0m English (en.sh)"
echo -e "   \e[1;33m[2]\e[0m Tiếng Việt (vi.sh)"
echo -e "   \e[1;33m[3]\e[0m 한국어 (kr.sh)"
echo

while true; do
    read -rp "   Nhập lựa chọn (1-3) / 입력 (1-3): " choice
    case $choice in
        1)
            LANG="en"
            NAME="English"
            break
            ;;
        2)
            LANG="vi"
            NAME="Tiếng Việt"
            break
            ;;
        3)
            LANG="kr"
            NAME="한국어"
            break
            ;;
        *)
            echo -e "\e[1;31m   [!] Vui lòng chọn 1, 2 hoặc 3! / 1~3만 입력하세요!\e[0m"
            ;;
    esac
done

echo
echo -e "\e[1;32m   [+] ${MSG_DOWNLOADING[$LANG]} $NAME ($LANG.sh)...\e[0m"
echo

# Tự động tải đúng script theo ngôn ngữ với retry logic
download_script() {
    local attempt=1
    while [[ $attempt -le $MAX_RETRIES ]]; do
        log "Tải script (lần $attempt/$MAX_RETRIES)..."
        
        if timeout $TIMEOUT curl -fsSL "$REPO/$LANG.sh" -o "/tmp/hyprland-$LANG.sh" 2>/dev/null; then
            # Validate script was downloaded correctly
            if [[ -f "/tmp/hyprland-$LANG.sh" ]] && [[ -s "/tmp/hyprland-$LANG.sh" ]] && grep -q "#!/usr/bin/env bash" "/tmp/hyprland-$LANG.sh"; then
                success "${MSG_DOWNLOAD_SUCCESS[$LANG]}"
                return 0
            else
                warn "${MSG_DOWNLOAD_INCOMPLETE[$LANG]}"
                rm -f "/tmp/hyprland-$LANG.sh"
            fi
        else
            warn "${MSG_TIMEOUT_ERROR[$LANG]}"
        fi
        
        ((attempt++))
        if [[ $attempt -le $MAX_RETRIES ]]; then
            sleep 2
        fi
    done
    
    # Try fallback: load from local if available
    if [[ -f "$SCRIPT_DIR/$LANG.sh" ]]; then
        warn "${MSG_USING_FALLBACK[$LANG]}"
        cp "$SCRIPT_DIR/$LANG.sh" "/tmp/hyprland-$LANG.sh"
        return 0
    fi
    
    return 1
}

if ! check_internet; then
    warn "${MSG_NO_INTERNET[$LANG]}"
    if [[ ! -f "$SCRIPT_DIR/$LANG.sh" ]]; then
        err "${MSG_NEED_CONNECTION[$LANG]}"
        exit 1
    fi
    log "${MSG_USING_LOCAL[$LANG]}"
fi

if ! download_script; then
    err "${MSG_DOWNLOAD_FAILED[$LANG]} $MAX_RETRIES ${MSG_RETRIES[$LANG]}"
    exit 1
fi

chmod +x "/tmp/hyprland-$LANG.sh"

echo -e "\e[1;32m   [OK] ${MSG_LOAD_SUCCESS[$LANG]}...\e[0m"
echo -e "\e[1;33m   [!] ${MSG_WARNING[$LANG]}\e[0m"
echo

# Xác nhận lần cuối trước khi chạy
read -rp "   ${MSG_CONFIRM[$LANG]}" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "\e[1;33m   ${MSG_CANCELLED[$LANG]}\e[0m"; exit 0; }

echo
echo -e "\e[1;36m   ${MSG_STARTING[$LANG]} ($NAME)...\e[0m"
echo -e "\e[1;36m   ${MSG_WAIT[$LANG]}\e[0m"
echo

# CHẠY SCRIPT ĐÚNG NGÔN NGỮ
sudo bash "/tmp/hyprland-$LANG.sh"

echo
echo -e "\e[1;92m   ${MSG_COMPLETE[$LANG]}\e[0m"
echo -e "\e[1;38;5;165m   ${MSG_WELCOME[$LANG]}\e[0m"
