PORTNAME=	lix
DISTVERSION=	2.90-beta.1
PORTREVISION=	2
CATEGORIES=	sysutils

MAINTAINER=	null@FreeBSD.org
COMMENT=	Purely functional package manager
WWW=		https://lix.systems/

MASTER_SITES=	https://git.lix.systems/lix-project/lix/archive/
DISTNAME=	${DISTVERSION}
WRKSRC=		${WRKDIR}/${PORTNAME}

LICENSE=	LGPL21
LICENSE_FILE=	${WRKSRC}/COPYING

#USES=		bison gmake
USES=		autoreconf bison compiler:c++17-lang cpe ninja meson localbase libarchive \
		pkgconfig sqlite:3 ssl

SUB_FILES=	pkg-message

#CARGO_CRATES=   autocfg-1.1.0 \
#                cbitset-0.2.0 \
#                dissimilar-1.0.7 \
#                expect-test-1.4.1 \
#                num-traits-0.2.18 \
#                once_cell-1.19.0 \
#                proc-macro2-1.0.79 \
#                quote-1.0.35 \
#                rnix-0.8.1 \
#                rowan-0.9.1 \
#                rustc-hash-1.1.0 \
#                serde-1.0.197 \
#                serde_derive-1.0.197 \
#                smol_str-0.1.24 \
#                syn-2.0.53 \
#                text_unit-0.1.10 \
#                thin-dst-1.1.0 \
#                unicode-ident-1.0.12

#CARGO_CARGOTOML= ${WRKSRC}/lix-doc/Cargo.toml
#CARGO_CARGOLOCK= ${WRKSRC}/lix-doc/Cargo.lock

MESON_ARGS=	-Dinternal-api-docs="disabled" \
		-Denable-docs=false \
		-Denable-tests=false

#	-DBOOST_STACKTRACE_GNU_SOURCE_NOT_REQUIRED=1

BINARY_ALIAS=	install=ginstall

BUILD_DEPENDS=	${LOCALBASE}/share/aclocal/ax_cxx_compile_stdcxx.m4:devel/autoconf-archive \
		${LOCALBASE}/include/rapidcheck.h:devel/rapidcheck \
		${LOCALBASE}/include/toml.hpp:devel/toml11 \
		gsed:textproc/gsed \
		bash:shells/bash \
		docbook-xsl-ns>=0:textproc/docbook-xsl-ns \
		gnustat:sysutils/coreutils \
		grealpath:sysutils/coreutils \
		ginstall:sysutils/coreutils \
		xmllint:textproc/libxml2 \
		xsltproc:textproc/libxslt \
		jq:textproc/jq \
		lsof:sysutils/lsof \
		nlohmann-json>=3.9:devel/nlohmann-json \
#		doxygen:devel/doxygen
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

_BASH=		${LOCALBASE}/bin/bash

#pre-cmd=	

_STRIP_TARGETS=	bin/nix bin/nix-build bin/nix-channel bin/nix-collect-garbage \
		bin/nix-copy-closure bin/nix-daemon bin/nix-env \
		bin/nix-instantiate bin/nix-prefetch-url bin/nix-store \
		lib/libnixexpr.so lib/libnixmain.so lib/libnixstore.so \
		lib/libnixutil.so lib/libnixcmd.so lib/libnixfetchers.so


post-install:
	@${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_SCRIPT} ${FILESDIR}/add-nixbld-users ${STAGEDIR}${DATADIR}

	#@${RM} ${STAGEDIR}${PREFIX}/libexec/nix/build-remote
	#@${RLN} ${STAGEDIR}${PREFIX}/bin/nix ${STAGEDIR}${PREFIX}/libexec/nix/build-remote

	#@cd ${STAGEDIR}${PREFIX} && ${STRIP_CMD} ${_STRIP_TARGETS}
.include <bsd.port.mk>
