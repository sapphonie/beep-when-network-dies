#!/bin/bash
# sappho.io

RED=$(      tput setaf 1)
GREEN=$(    tput setaf 2)
# YELLOW=$(   tput setaf 3)
BLUE=$(     tput setaf 4)
# PURPLE=$(   tput setaf 5)
DEFAULT=$(  tput sgr0   )


# time between each request
sleeptime="0.1"
# time between each beep
beepwait="0.1"


# tty our beep gets written to
tty="/dev/tty42"
# actual beep command that gets run with eval. this needs root btw
beep="printf '\a' &> ${tty}"

# time before we consider our ping / curl a failure
timeout="5"

# list of "always up" ipv4 addrs
ip4s=("1.1.1.1")                         # cloudflare
ip4s+=("8.8.8.8")                        # google
ip4s+=("4.2.2.1")                        # level3

ip6s=("2606:4700:4700::1111")            # cloudflare
ip6s+=("2001:4860:4860::8888")           # google
ip6s+=("2620:119:35::35")                # openvpn

# all these domains do 4/6
domains=("cloudflare.com")
domains+=("google.com")
domains+=("fastly.com")
domains+=("ec2-reachability.amazonaws.com")
domains+=("azure.microsoft.com")
domains+=("facebook.com")
# domains+=("www.msftconnecttest.com")
# domains+=("ip6.me")
# domains+=("icanhazip.com")


do_target ()
{

    echo "${command} -${proto} ${target}"

    if (eval "${command}" -${proto} "${target}") &> /dev/null; then
        echo "${BLUE}${target}${DEFAULT} is ${GREEN}good${DEFAULT}";
    else
        echo "${BLUE}${target}${DEFAULT} is ${RED}BAD${DEFAULT}";
        eval "${beep}"; sleep ${beepwait}; eval "${beep}"; sleep ${beepwait}; eval "${beep}";
        exit 1;
    fi

    sleep ${sleeptime}

}

pingips()
{
    command="ping -w ${timeout} -c 1"

    if [[ ${proto} == "6" ]]; then
        for target in "${ip6s[@]}"; do
            do_target
        done
    else
        for target in "${ip4s[@]}"; do
            do_target
        done
    fi;
}

proto="4"
pingips

proto="6"
pingips



pingdomains()
{
    command="ping -w ${timeout} -c 1"

    for target in "${domains[@]}"; do
        do_target
    done

}

proto="4"
pingdomains
proto="6"
pingdomains


curldomains()
{
    command="curl -s -m ${timeout}"

    for target in "${domains[@]}"; do
        do_target
    done
}

proto="4"
curldomains
proto="6"
curldomains



# eval ${beep};

echo "${GREEN}Success!${DEFAULT}"
