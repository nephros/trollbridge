#!/bin/sh

specify -Nns rpm/*yaml || exit 1
printf linting...
qmllint qml/*.qml
python3 -m py_compile python/*.py
git submodule foreach "git reset --hard"
printf building...
rpmbuild -bb --build-in-place rpm/*.spec > build.log 2>&1
printf "exit: $?\n"
grep ^Wrote build.log
rm -f *.list
