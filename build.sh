#!/bin/bash
echo "Cloning dependencies"
git clone https://github.com/najahiiii/AnyKernel3.git -b ginkgo-ten --depth=1 AnyKernel
mkdir .signer && curl -sLo .signer/zipsigner-3.0.jar https://raw.githubusercontent.com/najahiiii/Noob-Script/noob/bin/zipsigner-3.0.jar
echo "Done"
CHECKPOINT="$(git log --pretty=format:'%h : %s' -1)"
KERNEL_DIR=$(pwd)
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
SHA=$(echo "$CIRCLE_SHA1" | cut -c 1-8)
START3=$(date +"%s")
export ARCH=arm64
export KBUILD_BUILD_USER=s133py
export KBUILD_BUILD_HOST=Kali
export PATH="/mnt/kernels/Violet/msm-4.14/clang-llvm/bin:${PATH}"
export CCV=$(clang --version | head -n 1 | perl -pe 's/\(git.*?\)//gs' | sed -e 's/  */ /g')
export LLDV=$(ld.lld --version | head -n1 | perl -pe 's/\(git.*?\)//gs' | sed 's/(compatible with [^)]*)//' | sed 's/[[:space:]]*$//')
git config --global user.email "thiviyan@gmail.com"
git config --global user.name "Thiviyan"

# Compile plox
function compile() {
    make -s -C "$(pwd)" -j"$(nproc)" O=out vendor/nethunter_defconfig
    make -C "$(pwd)" O=out -j$(nproc) \
                    CC=clang \
                    AR=llvm-ar \
                    NM=llvm-nm \
                    OBJCOPY=llvm-objcopy \
                    OBJDUMP=llvm-objdump \
                    STRIP=llvm-strip \
                    CROSS_COMPILE=aarch64-linux-gnu- \
                    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
        if ! [ -a "$IMAGE" ]; then
            finerr
            exit 1
        fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel/
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9q unsigned.zip * -x LICENSE README.md *placeholder
    mv unsigned.zip ../.signer/
    cd ..
}
# Signer
function signer() {
    cd .signer || exit 1
    TANGGAL3=$(date +'%H%M-%d%m%y')
    if [ "$is_test" = true ]; then
        java -jar zipsigner-3.0.jar \
        unsigned.zip Team420_NH-Ginkgo-Willow-A9-Alpha-"rc${CIRCLE_BUILD_NUM}-${TANGGAL3}-${SHA}".zip
        rm unsigned.zip
    else
        java -jar zipsigner-3.0.jar \
        unsigned.zip Team420_NH-Ginkgo-Willow-A9-"${TANGGAL3}-${SHA}".zip
        rm unsigned.zip
    fi
    cd ..
}
compile
zipping
signer
END3=$(date +"%s")
DIFF3=$(($END3 - $START3))

