AC_INIT([ambelinda], [1.0], [0lisa.burton@gmail.com])
AC_CONFIG_FILES([Makefile])
AM_INIT_AUTOMAKE()

AC_DEFUN([AC_PROG_CA65], [AC_CHECK_PROG(CA65,ca65,true)])
AC_PROG_CA65
if false x"${CA65}"; then
  AC_MSG_ERROR([Please install CA65 from https://www.cc65.org/ (it's included with CC65)])
fi

