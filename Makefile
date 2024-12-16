PORTNAME=	lix
DISTVERSION=    2.91.1	
PORTREVISION=	1
CATEGORIES=	sysutils

MAINTAINER=	dave.null@FreeBSD.org
COMMENT=	Purely functional package manager
WWW=		https://lix.systems/

MASTER_SITES=	https://git.lix.systems/lix-project/lix/archive/
DISTNAME=	${DISTVERSION}
WRKSRC=		${WRKDIR}/${PORTNAME}

LICENSE=	LGPL21
LICENSE_FILE=	${WRKSRC}/COPYING

OPTIONS_DEFINE=        DOCS TEST
DOCS_MESON_TRUE=        enable-docs
TESTS_MESON_TRUE=        enable-tests

SUB_FILES=	pkg-message
USE_RC_SUBR=	nix_daemon
USES=		bison compiler:c++17-lang cpe ninja meson localbase libarchive \
		pkgconfig sqlite:3 ssl

BUILD_DEPENDS=	${LOCALBASE}/share/aclocal/ax_cxx_compile_stdcxx.m4:devel/autoconf-archive \
                ${LOCALBASE}/include/rapidcheck.h:devel/rapidcheck \
                ${LOCALBASE}/include/toml.hpp:devel/toml11 \
                ${LOCALBASE}/include/tao/pegtl.hpp:devel/pegtl \
		gsed:textproc/gsed \
		bash:shells/bash \
		docbook-xsl-ns>=0:textproc/docbook-xsl-ns \
		gnustat:sysutils/coreutils \
		grealpath:sysutils/coreutils \
		cargo:devel/rust \
		lsof:sysutils/lsof \
		xmllint:textproc/libxml2 \
		xsltproc:textproc/libxslt \
		jq:textproc/jq \
		nlohmann-json>=3.9:devel/nlohmann-json
LIB_DEPENDS=	libaws-cpp-sdk-core.so:devel/aws-sdk-cpp \
		libaws-crt-cpp.so:devel/aws-crt-cpp \
		libboost_context.so:devel/boost-libs \
		libbrotlienc.so:archivers/brotli \
		libcurl.so:ftp/curl \
		libeditline.so:devel/editline \
		libgc.so:devel/boehm-gc \
		libsodium.so:security/libsodium \
		libcpuid.so:sysutils/libcpuid \
		libgit2.so:devel/libgit2 \
		liblowdown.so:textproc/lowdown
#`TEST_DEPENDS=	dot:graphics/graphviz \
#`		git:devel/git \
#`		gxargs:misc/findutils \
#`		hg:devel/mercurial \
#`		gtest:devel/googletest \
#`		${LOCALBASE}/bin/grep:textproc/gnugrep

USE_LDCONFIG=	yes

CPE_VENDOR=	nix_project
MESON_ARGS=	-Dinternal-api-docs="disabled" 

# grealpath and gnustat are needed for tests.
BINARY_ALIAS=	realpath=grealpath readlink=greadlink stat=gnustat sed=gsed install=ginstall id=gid mkdir=mkdir wc=gwc touch=gtouch tar=gtar grep=${LOCALBASE}/bin/grep

GROUPS=		nixbld

DOCS_BUILD_DEPENDS=	mdbook>=0:textproc/mdbook \
			mdbook-linkcheck>=0:textproc/mdbook-linkcheck

_BASH=		${LOCALBASE}/bin/bash
_STRIP_TARGETS=	bin/nix bin/nix-build bin/nix-channel bin/nix-collect-garbage \
		bin/nix-copy-closure bin/nix-daemon bin/nix-env \
		bin/nix-instantiate bin/nix-prefetch-url bin/nix-store \
		lib/liblixexpr.so lib/liblixmain.so lib/liblixstore.so \
		lib/liblixutil.so lib/liblixcmd.so lib/liblixfetchers.so

#post-patch:
# 	${REINPLACE_CMD} -e 's,=/dummy,=${WRKDIR}/dummy,g' \
# 		${WRKSRC}/doc/manual/local.mk

post-install:
	@${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_SCRIPT} ${FILESDIR}/add-nixbld-users ${STAGEDIR}${DATADIR}

	@${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_SCRIPT} -m 640 ${FILESDIR}/nix.conf.sample ${STAGEDIR}${ETCDIR}

	@${RM} ${STAGEDIR}${PREFIX}/libexec/nix/build-remote
	@${RLN} ${STAGEDIR}${PREFIX}/bin/nix ${STAGEDIR}${PREFIX}/libexec/nix/build-remote

	@cd ${STAGEDIR}${PREFIX} && ${STRIP_CMD} ${_STRIP_TARGETS}

pre-test:
	${MKDIR} /tmp/nix-test

	${REINPLACE_CMD} -e 's| xargs | gxargs |g' ${WRKSRC}/tests/functional/push-to-store.sh
	${REINPLACE_CMD} -e 's| sed | gsed |g' ${WRKSRC}/tests/functional/read-only-store.sh
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/functional/timeout.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/functional/check-reqs.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/functional/nar-access.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/functional/pass-as-file.sh
	${REINPLACE_CMD} -e 's| date | ${LOCALBASE}/bin/gdate |g' ${WRKSRC}/tests/functional/check.nix

	${REINPLACE_CMD} -e 's| wc -l)| /usr/bin/grep -c .)|g' ${WRKSRC}/tests/functional/gc-auto.sh
	${REINPLACE_CMD} -e 's| tar c tarball)| tar -cf - tarball)|' ${WRKSRC}/tests/functional/tarball.sh
	${REINPLACE_CMD} -e 's|^grep |/usr/bin/grep |' ${WRKSRC}/tests/functional/check.sh
	${REINPLACE_CMD} -e 's|^grep |/usr/bin/grep |' ${WRKSRC}/tests/functional/check.sh

	${REINPLACE_CMD} -e "/'restricted\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'repair\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'user-envs\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'remote-store\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'simple\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'nix-profile\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'build-delete\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'read-only-store\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'fmt\.sh/d" ${WRKSRC}/tests/functional/meson.build
	${REINPLACE_CMD} -e "/'flakes\/flake-registry\.sh/d" ${WRKSRC}/tests/functional/meson.build

post-test:
	${RM} -r /tmp/nix-test

.include <bsd.port.mk>
