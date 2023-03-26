#!/bin/sh

specify -Nns rpm/*yaml || exit 1
printf building...
rpmbuild -bb --build-in-place rpm/*.spec > build.log 2>&1
printf "exit: $?\n"
grep ^Wrote build.log
rm -f *.list
