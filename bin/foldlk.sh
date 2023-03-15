


srcdir=$1

if test -z "${srcdir}"
then
  printf "usage: %s [srcdir]\n", $0
  exit
fi


find  ${srcdir}  -name "*.h" | xargs -I'{}' -n1 -P8 sh -c '/data/home/dongluo/srcutils/bin/foldlk.py /boot/config-3.10.107-1-tlinux2_kvm_guest-0049 {}'
find  ${srcdir}  -name "*.c" | xargs -I'{}' -n1 -P8 sh -c '/data/home/dongluo/srcutils/bin/foldlk.py /boot/config-3.10.107-1-tlinux2_kvm_guest-0049 {}'
find  ${srcdir}  -name "*.S" | xargs -I'{}' -n1 -P8 sh -c '/data/home/dongluo/srcutils/bin/foldlk.py /boot/config-3.10.107-1-tlinux2_kvm_guest-0049 {}'

