#!/bin/sh

kubectl label --overwrite nodes master usage=ingress-controller
kubectl label --overwrite nodes pvc-node1 usage=persistence-volume
