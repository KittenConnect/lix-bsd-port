--- src/libutil/fmt.hh.orig	2024-05-25 16:20:59.069080000 +0200
+++ src/libutil/fmt.hh	2024-05-25 16:21:15.901329000 +0200
@@ -6,7 +6,7 @@
 #include <optional>
 #include <boost/format.hpp>
 // Darwin stdenv does not define _GNU_SOURCE but does have _Unwind_Backtrace.
-#ifdef __APPLE__
+#if defined __APPLE__ || defined __FreeBSD__
 #define BOOST_STACKTRACE_GNU_SOURCE_NOT_REQUIRED
 #endif
 #include <boost/stacktrace.hpp>
