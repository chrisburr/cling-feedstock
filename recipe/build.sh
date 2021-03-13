#!/bin/bash
set -x

mkdir build
cd build

# Cling needs some minor patches to the LLVM sources
sed -i "s@LLVM_LINK_LLVM_DYLIB yes@LLVM_LINK_LLVM_DYLIB no@g" "${PREFIX}/lib/cmake/llvm/LLVMConfig.cmake"
cd "${PREFIX}"
patch -p1 < "${RECIPE_DIR}/llvm-patches/0001-Fix-the-compilation.patch"
patch -p1 < "${RECIPE_DIR}/llvm-patches/0002-Make-datamember-protected.patch"
cd -

cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_CXX_STD=c++17 \
  ..

make -j${CPU_COUNT}
make install

# patch -d $PREFIX -R -p1 -i $RECIPE_DIR/llvm-headers.patch
