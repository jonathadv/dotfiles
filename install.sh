#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :

set -o errexit
set -o pipefail
set -o nounset


declare -r script_full_path="$(realpath $0)"
declare -r script_dir="$(dirname ${script_full_path})"

install_bash() {
    echo 'Configuring Bash.'
    
    ln -fs "${script_dir}/bash/bashrc" "${HOME}/.bashrc"
}

install_zsh() {
    echo 'Configuring ZSH.'
    
    ln -fs "${script_dir}/zsh/zshrc" "${HOME}/.zshrc"
}

install_base16_shell() {
    echo 'Configuring base16_shell.'
    
    rm -rf "${HOME}/.config/base16-shell"
    git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/base16-shell"
}

install_vim() {
    echo 'Configuring vim.'

    [[ -d "${HOME}/.vim" ]] && rm -rf "${HOME:-/tmp}/.vim"
    ln -fs "${script_dir}/vim" "${HOME}/.vim"
    ln -fs "${script_dir}/vim/vimrc" "${HOME}/.vimrc"
    
    cd "${script_dir}"
    git submodule init
    git submodule update
    
    # Commenting colorscheme to prevent error when opening
    # vim for the firt time. It'll be reverted right below.
    sed -i 's/colorscheme/"""colorscheme/g' "${HOME}/.vimrc"
    
    echo "Opening vim and running: VundleInstall."
    vim -c 'VundleInstall' -c 'quit' -c 'quit'
    
    sed -i 's/"""colorscheme/colorscheme/g' "${HOME}/.vimrc"
}

install() {
    install_base16_shell    
    install_bash
    install_zsh
    install_vim
}

install
