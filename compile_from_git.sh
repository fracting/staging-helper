if [ ! -f config.sh ]; then
    cp config.sh.example config.sh
fi
source ./config.sh

echo "Copying wine-git code from"$WINEGIT
if [ -d "code" ]; then
    cd code
    git reset --hard origin/master
    git clean -dxf
    git pull origin master
else
    git clone $WINEGIT code
    cd code
fi

# Hack for old autoconf
export AUTOCONF_VERSION=`autoconf --version|head -n 1|cut -d " " -f 4`
if [ $AUTOCONF_VERSION \< 2.69 ]; then
    patch -p1 < ../centos_hack.diff
    echo "Applying wine-staging patches from"$STAGING to $(pwd)
fi

$STAGING/patches/patchinstall.sh DESTDIR="$(pwd)" --all --force-autoconf
./configure --with-xattr --prefix=$PREFIX CC="ccache gcc" CFLAGS="-g -O0 -m32"
make -j4
#make install
