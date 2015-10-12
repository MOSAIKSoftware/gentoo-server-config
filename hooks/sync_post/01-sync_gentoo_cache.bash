#!/bin/bash

source "${PALUDIS_EBUILD_DIR}/echo_functions.bash"
source "/etc/paludis/hooks/set_portdir.bash"

if [[ ${TARGET} == gentoo ]] ; then
	# Number of jobs for egencache, default is number or processors.
	egencache_jobnum="$(nproc)"

	ebegin "Fetching pre-generated metadata cache for gentoo repository"
	rsync -aq rsync://rsync.gentoo.org/gentoo-portage/metadata/md5-cache/ "${PORTDIR}"/metadata/md5-cache/
	eend $?

	ebegin "Updating metadata cache for repository ${TARGET}"
	egencache --jobs=${egencache_jobnum} --repo=${TARGET} --update --update-use-local-desc
	eend $?
fi
