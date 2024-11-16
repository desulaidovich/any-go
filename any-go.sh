#!/usr/bin/env bash

usage() {
cat << EOF
Использование: $0 [ОПЦИЯ]...

ОПЦИИ:
-i,  --install   [ВЕРСИЯ]  Версия go для установки.
-u,  --uninstall [ВЕРСИЯ]  Удалить загруженную версию go.
-s,  --select    [ВЕРСИЯ]  Выбрать загруженную версию go.
EOF
}

uninstall_golang() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ОШИБКА: вы не указали версию."
        exit 1
    fi

    local go_local=/usr/local/any-go/go$version
    if [[ -d $go_local ]]; then
        sudo rm -rf $go_local
        echo "УДАЛЕН: $go_local"
    elif [[ ! -d $go_local ]]; then
        echo "Каталог $go_local не существует"
    fi

    local go_home=$HOME/.any-go/go$version
    if [[ -d $go_home ]]; then
        rm -rf $go_home
        echo "УДАЛЕН: $go_home"
    elif [[ ! -d $go_home ]]; then
        echo "Каталог $go_home не существует"
    fi
}

install_golang() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ОШИБКА: вы не указали версию."
        exit 1
    fi

    local go_archive_name="go$version.linux-amd64.tar.gz"
    local go_downdload_link="https://go.dev/dl/$go_archive_name"

    echo "Начинаем загрузку golang-$version с $go_downdload_link"
    curl -L $go_downdload_link -o $go_archive_name -s

    sudo mkdir -p /usr/local/any-go/go$version
    sudo tar -C /usr/local/any-go/go$version -xzf $go_archive_name --strip-components 1
    echo "ДОБАВЛЕН: /usr/local/any-go/go$version"

    rm $go_archive_name

    mkdir -p $HOME/.any-go/go$version
    echo "ДОБАВЛЕН: $HOME/.any-go/go$version"
}

select_golang() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ОШИБКА: вы не указали версию."
        exit 1
    fi

    local go_root=/usr/local/any-go/go$version
    if [[ ! -d $go_root ]]; then
        echo "ОШИБКА: go$version не найден в $go_root"
        exit 1
    fi

    local go_path=$HOME/.any-go/go$version
    if [[ ! -d $go_path ]]; then
        echo "ОШИБКА: go$version не найден в $go_path"
        exit 1
    fi

    cat <<- EOF > $HOME/.any_go_current
export GOROOT=/usr/local/any-go/go$version
export GOPATH=$HOME/.any-go/go$version
export GOBIN=$HOME/.any-go/go$version/bin
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -i|--install)
        go_v="$2"
        install_golang "$go_v"
        shift 2
        ;;
    -u|--uninstall)
        go_v="$2"
        uninstall_golang "$go_v"
        shift 2
        ;;
    -s|--select)
        go_v="$2"
        select_golang "$go_v"
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
      echo "ОШИБКА: Неизвестная опция '${1:-}'."
      echo "Введи '$0 --help' для помощи."
      exit 1
      ;;
  esac
done