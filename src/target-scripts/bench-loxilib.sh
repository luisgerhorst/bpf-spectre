#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
bash -n "$(command -v "$0")"
set -x

dst=$1
burst_len=$2

mkdir -p $dst/values

./bench-runtime-begin.sh $@

DOCKER="sudo docker "

# Kill processes from previous runs that did not properly terminate.
cleanup() {
	set +e
	$DOCKER stop loxilb
	$DOCKER rm loxilb

	sudo ip netns delete dummy
	sudo ip netns delete loxilb
	sudo ip netns delete ep1
	sudo ip netns delete ep2
	sudo ip netns delete ep3
	sudo ip netns delete h1
	set -e
}
cleanup

#
# Loxilib setup
#
. ./common.sh
$DOCKER run -u root --cap-add SYS_ADMIN --privileged -v /dev/log:/dev/log -i $loxilib_url loxilib --version
$DOCKER pull $loxilib_url
$DOCKER run -u root --cap-add SYS_ADMIN --restart unless-stopped --privileged -dit -v /dev/log:/dev/log --name loxilb $loxilib_url
#
HADD="sudo ip netns add "
LBHCMD="sudo ip netns exec loxilb "
HCMD="sudo ip netns exec "
#
id=$($DOCKER ps -f name=loxilb | cut  -d " "  -f 1 | grep -iv  "CONTAINER")
echo $id
pid=$($DOCKER inspect -f '{{.State.Pid}}' $id)
if [ ! -f /var/run/netns/loxilb ]; then
	sudo ip netns add dummy || true # create netns directory

	# TODO: use sudo ip netns attach loxilb $pid instead?
	sudo touch /var/run/netns/loxilb
	sudo mount -o bind /proc/$pid/ns/net /var/run/netns/loxilb
fi
#
$HADD ep1
$HADD ep2
$HADD ep3
$HADD h1
#
# Configure load-balancer end-point ep1
sudo ip -n loxilb link add ellb1ep1 type veth peer name eep1llb1 netns ep1
sudo ip -n loxilb link set ellb1ep1 mtu 9000 up
sudo ip -n ep1 link set eep1llb1 mtu 7000 up
$LBHCMD ip addr add 31.31.31.254/24 dev ellb1ep1
$HCMD ep1 ifconfig eep1llb1 31.31.31.1/24 up
$HCMD ep1 ip route add default via 31.31.31.254
$HCMD ep1 ifconfig lo up
#
# Configure load-balancer end-point ep2
sudo ip -n loxilb link add ellb1ep2 type veth peer name eep2llb1 netns ep2
sudo ip -n loxilb link set ellb1ep2 mtu 9000 up
sudo ip -n ep2 link set eep2llb1 mtu 7000 up
$LBHCMD ip addr add 32.32.32.254/24 dev ellb1ep2
$HCMD ep2 ifconfig eep2llb1 32.32.32.1/24 up
$HCMD ep2 ip route add default via 32.32.32.254
$HCMD ep2 ifconfig lo up
#
# Configure load-balancer end-point ep3
sudo ip -n loxilb link add ellb1ep3 type veth peer name eep3llb1 netns ep3
sudo ip -n loxilb link set ellb1ep3 mtu 9000 up
sudo ip -n ep3 link set eep3llb1 mtu 7000 up
$LBHCMD ip addr add 17.17.17.254/24 dev ellb1ep3
$HCMD ep3 ifconfig eep3llb1 17.17.17.1/24 up
$HCMD ep3 ip route add default via 17.17.17.254
$HCMD ep3 ifconfig lo up
#
# Configure load-balancer end-point h1
sudo ip -n loxilb link add ellb1h1 type veth peer name eh1llb1 netns h1
sudo ip -n loxilb link set ellb1h1 mtu 9000 up
sudo ip -n h1 link set eh1llb1 mtu 7000 up
$LBHCMD ip addr add 100.100.100.254/24 dev ellb1h1
$HCMD h1 ifconfig eh1llb1 100.100.100.1/24 up
$HCMD h1 ip route add default via 100.100.100.254
$HCMD h1 ifconfig lo up


sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sleep 1
for burst_pos in $(seq 0 $(expr ${burst_len} - 1))
do
	set +e
	true # TODO
	exitcode=$?
	set -e

	if [ $exitcode != 0 ]
	then
		break
	fi
done

./bench-runtime-end.sh $@

cleanup

echo -n $exitcode > ${dst}/values/workload_exitcode
