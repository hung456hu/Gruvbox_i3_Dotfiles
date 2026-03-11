#!/bin/bash

# ============================================================
#   Gruvbox i3 Dotfiles - Auto Install Script
#   https://github.com/hung456hu/Gruvbox_i3_Dotfiles
# ============================================================

set -e

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---------- Helpers ----------
info()    { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[ERR]${NC}  $1"; exit 1; }
step()    { echo -e "\n${BOLD}${YELLOW}━━━ $1 ━━━${NC}"; }

# ---------- Banner ----------
echo -e "${BOLD}${GREEN}"
cat << 'EOF'
  ██████╗ ██████╗ ██╗   ██╗██╗   ██╗██████╗  ██████╗ ██╗  ██╗
 ██╔════╝ ██╔══██╗██║   ██║██║   ██║██╔══██╗██╔═══██╗╚██╗██╔╝
 ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝██║   ██║ ╚███╔╝ 
 ██║   ██║██╔══██╗██║   ██║╚██╗ ██╔╝██╔══██╗██║   ██║ ██╔██╗ 
 ╚██████╔╝██║  ██║╚██████╔╝ ╚████╔╝ ██████╔╝╚██████╔╝██╔╝ ██╗
  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
         i3wm Dotfiles Installer — by hung456hu
EOF
echo -e "${NC}"

# ---------- Kiểm tra chạy với user thường (không phải root) ----------
if [[ "$EUID" -eq 0 ]]; then
    error "Không chạy script này bằng root! Hãy chạy với user thường (có quyền sudo)."
fi

# ---------- Xác định thư mục repo ----------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Thư mục dotfiles: ${DOTFILES_DIR}"

# ============================================================
# BƯỚC 1 — Cài đặt package từ pacman
# ============================================================
step "Bước 1/8 — Cài đặt packages (pacman)"

if [[ -f "${DOTFILES_DIR}/pkglist.txt" ]]; then
    info "Đang cài đặt packages từ pkglist.txt..."
    sudo pacman -S --needed --noconfirm - < "${DOTFILES_DIR}/pkglist.txt" \
        && success "Cài đặt pacman packages thành công!" \
        || warn "Một số package có thể không cài được, tiếp tục..."
else
    warn "Không tìm thấy pkglist.txt, bỏ qua bước này."
fi



# ============================================================
# BƯỚC 2 — Cài đặt yay (AUR helper)
# ============================================================
step "Bước 2/8 — Cài đặt yay (AUR helper)"

if command -v yay &>/dev/null; then
    success "yay đã được cài đặt, bỏ qua."
else
    info "Đang clone và build yay..."
    TMPDIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "${TMPDIR}/yay"
    cd "${TMPDIR}/yay"
    makepkg -si --noconfirm
    cd "${DOTFILES_DIR}"
    rm -rf "${TMPDIR}"
    success "Cài đặt yay thành công!"
fi

# ============================================================
# BƯỚC 3 — Cài đặt package AUR
# ============================================================
step "Bước 3/8 — Cài đặt AUR packages"

if [[ -f "${DOTFILES_DIR}/aurlist.txt" ]]; then
    info "Đang cài đặt AUR packages từ aurlist.txt..."
    yay -S --needed --noconfirm - < "${DOTFILES_DIR}/aurlist.txt" \
        && success "Cài đặt AUR packages thành công!" \
        || warn "Một số AUR package có thể không cài được, tiếp tục..."
else
    warn "Không tìm thấy aurlist.txt, bỏ qua bước này."
fi

# ============================================================
# BƯỚC 4 — Copy dotfiles vào đúng vị trí
# ============================================================
step "Bước 4/8 — Triển khai dotfiles"

# 4a. vconsole.conf → /etc/vconsole.conf (terminus-font cho ly)
if [[ -f "${DOTFILES_DIR}/vconsole.conf" ]]; then
    info "Đang copy vconsole.conf → /etc/vconsole.conf ..."
    sudo cp "${DOTFILES_DIR}/vconsole.conf" /etc/vconsole.conf
    success "Đã copy vconsole.conf"
else
    warn "Không tìm thấy vconsole.conf, bỏ qua."
fi

# 4b. bin/ → /usr/local/bin/
if [[ -d "${DOTFILES_DIR}/bin" ]]; then
    info "Đang copy bin/ → /usr/local/bin/ ..."
    sudo cp -r "${DOTFILES_DIR}/bin/." /usr/local/bin/
    sudo chmod +x /usr/local/bin/*
    success "Đã copy bin/ vào /usr/local/bin/"
else
    warn "Không tìm thấy thư mục bin/, bỏ qua."
fi

# 4c. config/ → ~/.config/
if [[ -d "${DOTFILES_DIR}/config" ]]; then
    info "Đang copy config/ → ~/.config/ ..."
    mkdir -p "${HOME}/.config"
    cp -r "${DOTFILES_DIR}/config/." "${HOME}/.config/"
    success "Đã copy config/ vào ~/.config/"
else
    warn "Không tìm thấy thư mục config/, bỏ qua."
fi

# 4d. 40-touchpad.conf → /etc/X11/xorg.conf.d/
if [[ -f "${DOTFILES_DIR}/40-touchpad.conf" ]]; then
    info "Đang copy 40-touchpad.conf → /etc/X11/xorg.conf.d/ ..."
    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp "${DOTFILES_DIR}/40-touchpad.conf" /etc/X11/xorg.conf.d/40-touchpad.conf
    success "Đã copy 40-touchpad.conf"
else
    warn "Không tìm thấy 40-touchpad.conf, bỏ qua."
fi

# 4e. zshrc → ~/.zshrc
if [[ -f "${DOTFILES_DIR}/zshrc" ]]; then
    info "Đang copy zshrc → ~/.zshrc ..."
    cp "${DOTFILES_DIR}/zshrc" "${HOME}/.zshrc"
    success "Đã copy .zshrc"
else
    warn "Không tìm thấy zshrc, bỏ qua."
fi

# 4f. xprofile → ~/.xprofile
if [[ -f "${DOTFILES_DIR}/xprofile" ]]; then
    info "Đang copy xprofile → ~/.xprofile ..."
    cp "${DOTFILES_DIR}/xprofile" "${HOME}/.xprofile"
    success "Đã copy .xprofile"
else
    warn "Không tìm thấy xprofile, bỏ qua."
fi

# ============================================================
# BƯỚC 5 — Khởi động ly display manager
# ============================================================
step "Bước 5/8 — Kích hoạt ly display manager"

if systemctl list-unit-files | grep -q "ly"; then
    info "Đang enable ly display manager..."
    sudo systemctl enable ly@tty1.service
    success "Đã enable ly@tty1.service"
else
    warn "ly chưa được cài đặt, bỏ qua enable service."
fi

# ============================================================
# BƯỚC 6 — Cài đặt zsh + Oh My Zsh + plugins + theme
# ============================================================
step "Bước 6/8 — Cài đặt zsh, Oh My Zsh, plugins, Powerlevel10k"

# Đặt zsh làm shell mặc định
if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Đang đặt zsh làm default shell..."
    chsh -s "$(which zsh)"
    success "Đã đặt zsh làm default shell (có hiệu lực sau khi đăng nhập lại)"
else
    success "zsh đã là default shell."
fi

# Cài Oh My Zsh nếu chưa có
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    info "Đang cài đặt Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Cài đặt Oh My Zsh thành công!"
else
    success "Oh My Zsh đã được cài đặt, bỏ qua."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# Plugin: zsh-autosuggestions
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
    info "Đang cài zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    success "Cài zsh-autosuggestions thành công!"
else
    success "zsh-autosuggestions đã có, bỏ qua."
fi

# Plugin: zsh-syntax-highlighting
if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
    info "Đang cài zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    success "Cài zsh-syntax-highlighting thành công!"
else
    success "zsh-syntax-highlighting đã có, bỏ qua."
fi

# Theme: Powerlevel10k
if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then
    info "Đang cài Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM}/themes/powerlevel10k"
    success "Cài Powerlevel10k thành công!"
else
    success "Powerlevel10k đã có, bỏ qua."
fi

# Nerd Font
info "Đang cài JetBrains Mono Nerd Font..."
sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd \
    && success "Cài font thành công!" \
    || warn "Không thể cài ttf-jetbrains-mono-nerd."

# ============================================================
# BƯỚC 7 — Copy lại .zshrc sau khi Oh My Zsh cài xong
#          (vì OMZ có thể ghi đè .zshrc)
# ============================================================
step "Bước 7/8 — Áp dụng lại .zshrc dotfile"

if [[ -f "${DOTFILES_DIR}/zshrc" ]]; then
    info "Áp dụng lại zshrc dotfile (ghi đè bản OMZ mặc định)..."
    cp "${DOTFILES_DIR}/zshrc" "${HOME}/.zshrc"
    success "Đã áp dụng .zshrc"
fi

# ============================================================
# BƯỚC 8 — Rebuild initramfs để vconsole có hiệu lực
# ============================================================
step "Bước 8/8 — Rebuild initramfs (áp dụng terminus-font cho ly)"

info "Đang chạy mkinitcpio -P ..."
sudo mkinitcpio -P \
    && success "Rebuild initramfs thành công!" \
    || warn "mkinitcpio gặp lỗi, bạn có thể chạy thủ công: sudo mkinitcpio -P"

# ============================================================
# HOÀN TẤT
# ============================================================
echo -e "\n${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   ✅  Cài đặt hoàn tất thành công!       ║"
echo "  ║                                          ║"
echo "  ║  Hãy reboot để áp dụng toàn bộ thay đổi  ║"
echo "  ║         sudo reboot                      ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
