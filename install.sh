#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :

set -o errexit
set -o pipefail
set -o nounset


declare -r script_dir="$( cd "$(dirname "$0")" ; pwd -P )"
echo ${script_dir}

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
    echo 'Configuring VIM.'

    [[ -d "${HOME}/.vim" ]] && rm -rf "${HOME:-/tmp}/.vim"
    ln -fs "${script_dir}/vim" "${HOME}/.vim"
    ln -fs "${script_dir}/vim/vimrc" "${HOME}/.vimrc"
    
    cd "${script_dir}"
    git submodule init
    git submodule update
    
    # Commenting colorscheme to prevent error when opening
    # VIM for the firt time. It'll be reverted right below.
    sed -i 's/colorscheme/"""colorscheme/g' "${HOME}/.vimrc"
    
    echo "Opening VIM and running: VundleInstall."
    vim -c 'VundleInstall' -c 'quit' -c 'quit'
    
    sed -i 's/"""colorscheme/colorscheme/g' "${HOME}/.vimrc"
}

add_custom_sources() { 
    local sourceable_dir="${script_dir}/sourceable"
    local sourceable_file="${HOME}/.sourceable"
    local oh_my_zsh_dir="${HOME}/.oh-my-zsh"
    local files
    
    cd "${sourceable_dir}"
    
    echo "Looking for files to source..."    
    files=$(ls 2> /dev/null) || true
    files="${files/README.MD/}"
    
    if [[ -n "${files}" ]]; then
        mkdir -p "${oh_my_zsh_dir}"
        echo "source ${HOME}/.sourceable" >> "${oh_my_zsh_dir}/oh-my-zsh.sh"

        echo '# Sourced files' >>  "${sourceable_file}"
 
        for f in ${files}; do 
            echo "Sourcing file '${f}' in ${sourceable_file}"
            echo "source ${sourceable_dir}/${f}" >> "${sourceable_file}"
        done
    else
        echo 'No files to source.'
    fi
}

install() {
    install_base16_shell
    install_bash
    install_zsh
    install_vim
    add_custom_sources
}

install
