# Reproduction for Bazel Remote Excution using Symlinks

This repository illustrates a bug using the Bazel Remote Execution System.

## Issue

The issue is that our build is relying that symlinked files are _actual_ symlinks.
It turns out that using Remote Execution a file that is symlinked via https://bazel.build/rules/lib/actions#declare_symlink
is not an actual symlink, but the file itself.

Apparently there is a Bazel flag (https://bazel.build/reference/command-line-reference#flag--incompatible_remote_symlinks)
which is enabled by default that should ensure exactly this.
Following this flag we find https://github.com/bazelbuild/bazel/issues/6631, which describes the needed feature is already
implemented by Bazel.

The used Remote Execution Setup was BuildBarn. Trying to reproduce the issue on another setup made it clear, that the issue
also exists in other remote execution systems. A first analysis on BuildBarn side was done within https://github.com/buildbarn/bb-remote-execution/issues/104, it turned out that the issue most certainly resides within Bazel, since the remote files are never declared as symlink.

## How to reproduce the issue

We have two targets with the same inputs:

```
bazel build //:foo
```

and

```
bazel build --remote_executor=<your remote execution instance> //:bar
```

Checking the output of these files, one can see that in one case `test.txt` is a symlink
and in the other, it is not (but directly the original file).


For example on a local exection:

```
cat bazel-bin/foo 
.:
total 4
drwxr-xr-x 3 foo bar 4096 Jun 21 19:37 bazel-out

./bazel-out:
total 4
drwxr-xr-x 3 foo bar 4096 Jun 21 19:37 k8-fastbuild

./bazel-out/k8-fastbuild:
total 4
drwxr-xr-x 2 foo bar 4096 Jun 21 19:37 bin

./bazel-out/k8-fastbuild/bin:
total 4
-rw-r--r-- 1 foo bar   0 Jun 21 19:37 foo
lrwxrwxrwx 1 foo bar 120 Jun 21 19:37 test.txt -> /home/foo/.cache/bazel/_bazel_foo/f1074c083961816371a3269ddb70634a/execroot/__main__/bazel-out/k8-fastbuild/bin/test.txt
```



```
cat bazel-bin/bar 
.:
total 4
drwxr-xr-x 3 root root 4096 Jun 21 13:54 bazel-out

./bazel-out:
total 4
drwxr-xr-x 3 root root 4096 Jun 21 13:54 k8-fastbuild

./bazel-out/k8-fastbuild:
total 4
drwxr-xr-x 2 root root 4096 Jun 21 13:54 bin

./bazel-out/k8-fastbuild/bin:
total 0
-rw-r--r--    1 root root 0 Jun 21 13:54 bar
-r-xr-xr-x 5818 root root 0 Jan  1  2000 test.txt
```
