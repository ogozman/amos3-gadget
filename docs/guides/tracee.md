---
title: 'The "tracee" gadget'
weight: 10
---

Tracee traces various events that are happening in the pods and show them on the screen.
Here we deploy a small demo pod "mypod":

```
$ kubectl run --restart=Never -ti --image=busybox mypod -- sh -c 'while /bin/true ; do whoami ; sleep 3 ; done'
```

Using the opensnoop gadget, we can see which processes open what files.
We can simply filter for the pod "mypod" and omit specifying the node,
thus snooping on all nodes for pod "mypod":

```
$ kubectl gadget tracee --podname mypod
NODE TIME(s)        UID    COMM             PID     TID     RET              EVENT                ARGS
[ 0] 56575.637516   0      sleep            14      14      0                sched_process_exit   
[ 0] 56575.637988   0      sh               1       1       15               clone                flags: CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID, stack: 0x0, parent_tid: 0x0, child_tid: 0x4D6209, tls: 5343200
[ 0] 56575.638282   0      sh               15      15      0                execve               pathname: /bin/true, argv: [/bin/true]
[ 0] 56575.638433   0      sh               15      15      0                security_bprm_check  pathname: /bin/true, dev: 239, inode: 818205
[ 0] 56575.639022   0      true             15      15      0                sched_process_exit   
[ 0] 56575.639388   0      sh               1       1       16               clone                flags: CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID, stack: 0x0, parent_tid: 0x0, child_tid: 0x4D6209, tls: 5343200
[ 0] 56575.639679   0      sh               16      16      0                execve               pathname: /bin/whoami, argv: [whoami]
```

As you can see in order to execute whoami operation and also go to idle for three seconds, various events have to triggered by the kernel.
We can leave tracee by hitting Ctrl-C.

Finally, we need to clean up our pod:

```
$ kubectl delete pod mypod
```
