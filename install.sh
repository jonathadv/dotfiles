#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :

set -o errexit
set -o pipefail
set -o nounset


declare -r script_dir="$( cd "$(dirname "$0")" ; pwd -P )"
echo ${script_dir}

do_backup() {
    local full_filename="${1}"
    local dir_name="$(dirname ${full_filename})"
    local new_file="$(basename ${full_filename})_$(date +%Y_%m_%d_%s).bkp"
    
    if [[ ! -e "${full_filename}" ]]; then
        echo "File ${full_filename} not found. No backup do be done."
        return
    fi
    
    echo "Backuping ${full_filename} as ${dir_name}/${new_file}"
    cp -vR "${full_filename}" "${dir_name}/${new_file}"
}

install_bash() {    
    do_backup "${HOME}/.bashrc"
    echo 'Configuring Bash.'
    
    ln -fs "${script_dir}/bash/bashrc" "${HOME}/.bashrc"
}

install_zsh() {
    do_backup "${HOME}/.zshrc"
    echo 'Configuring ZSH.'
    
    ln -fs "${script_dir}/zsh/zshrc" "${HOME}/.zshrc"
}

install_base16_shell() {
    echo 'Configuring base16_shell.'
    
    rm -rf "${HOME}/.config/base16-shell"
    git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/base16-shell"
}

install_vim() {
    do_backup "${HOME}/.vimrc"
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
    local sourceable_home_dir="${HOME}/.sourceable"
    local sourceable_file="${sourceable_home_dir}/sourceable"
    local oh_my_zsh_dir="${HOME}/.oh-my-zsh"
    local files
    
    do_backup "${HOME}/.sourceable"
    
    cd "${sourceable_dir}"
    
    echo "Looking for files to source..." 
    files=$(ls 2> /dev/null) || true
    files="${files/README.MD/}"
    
    if [[ -n "${files}" ]]; then
        mkdir -p "${oh_my_zsh_dir}"
        mkdir -p "${sourceable_home_dir}"

        echo "source ${sourceable_file}" > "${oh_my_zsh_dir}/oh-my-zsh.sh"

        echo '# Sourced files' >  "${sourceable_file}"
 
        for f in ${files}; do 
            echo "Sourcing file '${f}' in ${sourceable_file}"
            mv -v "${sourceable_dir}/${f}" "${sourceable_home_dir}"
            echo "source ${sourceable_home_dir}/${f}" >> "${sourceable_file}"
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
