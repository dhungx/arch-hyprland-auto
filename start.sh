#!/usr/bin/env bash
# =============================================================================
#  HYPRLAND 2025 MULTI-LANGUAGE LAUNCHER v1.0
#  Chọn ngôn ngữ → Tự động tải & chạy đúng script (en.sh / vi.sh / kr.sh)
#  GitHub: https://github.com/dhungx/arch-hyprland-auto
# =============================================================================

set -euo pipefail

REPO="https://raw.githubusercontent.com/dhungx/arch-hyprland-auto/main"

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
echo -e "\e[1;32m   [+] Đang tải script $NAME ($LANG.sh)...\e[0m"
echo

# Tự động tải đúng script theo ngôn ngữ
curl -fsSL "$REPO/$LANG.sh" -o "/tmp/hyprland-$LANG.sh" || {
    echo -e "\e[1;31m   [-] Lỗi tải script! Kiểm tra mạng hoặc GitHub.\e[0m"
    exit 1
}

chmod +x "/tmp/hyprland-$LANG.sh"

echo -e "\e[1;32m   [OK] Tải thành công! Bắt đầu cài đặt $NAME...\e[0m"
echo -e "\e[1;33m   [!] CẢNH BÁO: TOÀN BỘ DỮ LIỆU TRÊN Ổ ĐĨA SẼ BỊ XÓA!\e[0m"
echo

# Xác nhận lần cuối trước khi chạy
read -rp "   Tiếp tục cài đặt? (y/N): " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "\e[1;33m   Hủy cài đặt.\e[0m"; exit 0; }

echo
echo -e "\e[1;36m   Bắt đầu cài Hyprland 2025 ($NAME)...\e[0m"
echo -e "\e[1;36m   Thả lỏng và chờ 6-10 phút\e[0m"
echo

# CHẠY SCRIPT ĐÚNG NGÔN NGỮ
sudo bash "/tmp/hyprland-$LANG.sh"

echo
echo -e "\e[1;92m   HOÀN TẤT! Tháo USB → gõ: reboot\e[0m"
echo -e "\e[1;38;5;165m   Chào mừng đến với Hyprland 2025 – ĐẸP NHƯ IPAD PRO M2!\e[0m"
