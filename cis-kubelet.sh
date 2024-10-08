#!/bin/bash
#cis-kubelet.sh

total_fail=$(kube-bench run --targets node  --version 1.15 --check 2.1.10,2.1.11 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed Kubelet while testing for 2.1.10, 2.1.11"
                exit 1;
        else
                echo "CIS Benchmark Passed Kubelet for 2.1.10, 2.1.11"
fi;