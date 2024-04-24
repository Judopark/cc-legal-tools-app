#!/bin/bash
#
# Check if all specified Python versions match Pipfile
#
set -o errtrace
set -o nounset

# https://en.wikipedia.org/wiki/ANSI_escape_code
E0="$(printf    "\e[0m")"   # reset
E91="$(printf   "\e[91m")"  # bright red foreground
E92="$(printf   "\e[92m")"  # bright green foreground
E97="$(printf   "\e[97m")"  # bright white foreground
E100="$(printf  "\e[100m")" # bright black (gray) background
EXIT_STATUS=0


pyvercompare() {
    local _path=${1}
    local _match=${2}
    local _field=${3}
    local _unwanted="\"',["
    # extract Python version
    _ver=$(awk "/${_match}/ {print \$${_field}}" \
        "${_path}")
    # clean-up Python version
    _ver="${_ver//[${_unwanted}]/}"
    # compare Python version
    if [[ "${_path}" == 'Pipfile' ]]
    then
        _status="✅  ${E92}athoritative Python version${E0}"
        PIPFILE_VER=${_ver}
    elif [[ "${_ver}" == "${PIPFILE_VER}" ]] \
        || [[ "${_ver}" == "python${PIPFILE_VER}" ]] \
        || [[ "${_ver}" == "python:${PIPFILE_VER}-slim" ]] \
        || [[ "${_ver}" == "py${PIPFILE_VER//./}" ]]
    then
        _status="✅  ${E92}Python version matches Pipfile${E0}"
    else
        _status="❌  ${E91}Python version does not match Pipfile${E0}"
        EXIT_STATUS=1
    fi
    # print info
    printf "${E97}${E100} %9s${E0} %s\n" 'File:' "${E97}${_path}${E0}"
    printf "${E97}${E100} %9s${E0} %s\n" 'Version:' "${_ver}"
    printf "${E97}${E100} %9s${E0} %s\n" 'Status:' "${_status}"
    echo
}


# Change directory to root directory of cc-legal-tools-app repository
# (grandparent directory of this script)
# shellcheck disable=SC2164
cd "${0%/*}"/../

pyvercompare 'Pipfile' 'python_version =' '3'
pyvercompare '.github/workflows/django-app-coverage.yml' 'python-version:' '2'
pyvercompare '.github/workflows/static-analysis.yml' 'python-version:' '2'
pyvercompare '.pre-commit-config.yaml' 'python: python' '2'
pyvercompare 'Dockerfile' 'FROM python:' '2'
pyvercompare 'pyproject.toml' 'target-version =' '3'

exit ${EXIT_STATUS}
