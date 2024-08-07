#!/bin/sh

specify -Nns rpm/*yaml || exit 1
printf linting...
find qml/ -type f -name "*.qml" -exec qmllint {} +
find python/ -type f -name "*.py" -exec python3 -m py_compile {} \;
# Clean up modifications from patching
git submodule foreach "git reset --quiet --hard"
git submodule foreach "git clean --quiet --force *"
printf building...
rpmbuild -bb --build-in-place -D "_sourcedir $PWD/rpm" rpm/*.spec > build.log 2>&1
ex=$?
if [ $ex -eq 0 ]; then
  awk '/^Wrote/ {print "To install do either:\npkcon install-local " $2 "\nxdg-open " $2}' build.log
  make -s distclean
  # Clean up modifications from patching
  git submodule foreach "git reset --quiet --hard"
  git submodule foreach "git clean --quiet --force *"
fi
printf "exit: $ex\n"
