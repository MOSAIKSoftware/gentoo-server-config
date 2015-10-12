#!/bin/bash
#
# Paludis hook script to apply patch (w/o modifying corresponding ebuild file).
#
# Copyright (c), 2010-2012 by Alex Turbov <i.zaufi@gmail.com>
#
# Version: @PH_VERSION@
#

source ${PALUDIS_EBUILD_DIR}/echo_functions.bash

declare -r CONFIG_FILE="/etc/paludis/hooks/configs/auto_patch.conf"
PATCH_DIR="/var/db/paludis/autopatches"
# Configuration override
[[ -f ${CONFIG_FILE} ]] && source ${CONFIG_FILE}

PATCH_DIR_FULL="${PATCH_DIR}/${HOOK}/${CATEGORY}/${PF}"

_ap_rememberfile="${T}/.autopatch_was_here_${PALUDIS_PID}"

issue_a_warning()
{
    local -r tobe="$1"
    ewarn "WARNING: ${CATEGORY}/${PF} package $tobe installed with additional patches applied by auto-patch hook."
    ewarn "WARNING: Before filing a bug, remove all patches, reinstall, and try again..."
}

try_to_apply_patches()
{
    if [[ -n ${PALUDIS_HOOK_DEBUG} ]]; then
        einfo "Check ${PATCH_DIR_FULL}"
    fi
    if [[ -d ${PATCH_DIR_FULL} ]] ; then
        cd "${S}" || die "Failed to cd into ${S}!"
        for i in "${PATCH_DIR_FULL}"/*.patch ; do
            if declare -f epatch >/dev/null ; then
                epatch ${i}
            else
                # sane default if no epatch is there
                einfo "Applying ${i} ..."
                patch -p1 -i "${i}" || die "Failed to apply ${i}!"
            fi
            touch "${_ap_rememberfile}" || die "Failed to touch ${_ap_rememberfile}!"
        done
        if [[ -e ${_ap_rememberfile} ]]; then
            issue_a_warning "will be"
        else
            einfo "No patches in for this package."
        fi
    fi
}

case "${HOOK}" in
    # ATTENTION This script must be symlinked to the following hook dirs:
    ebuild_compile_post         | \
    ebuild_compile_pre          | \
    ebuild_configure_post       | \
    ebuild_configure_pre        | \
    ebuild_install_pre          | \
    ebuild_unpack_post          )
        try_to_apply_patches
        ;;
    install_all_post)
        if [[ -e ${_ap_rememberfile} ]] ; then
            issue_a_warning "was"
        fi
        ;;
esac
