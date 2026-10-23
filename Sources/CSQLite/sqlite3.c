// waxjaw: compile the vendored SQLite amalgamation (public domain) as the
// CSQLite module. sys/param.h and the amalgamation both define MIN/MAX,
// which clang reports 77 times as -Wambiguous-macro. The definitions are
// equivalent, so the warning is silenced for this translation unit only.
#pragma clang diagnostic ignored "-Wambiguous-macro"
#include "sqlite3-amalgamation.c"
