<p align="center">
  <img src="https://github.com/macaroni-os/macaroni-site/blob/master/site/static/images/logo.png">
</p>

# PAGeant

**P**ascal **A**nice **G**eant is a GUI for the Macaroni PMS.

The Anice is the new name of the Macaroni PMS.

## Compilation on Macaroni Phoenix

At the moment the packages `fpc` and `lazarus` are available only
on Phoenix release.

To compile locally the GUI just setup correctly the compiler GCC and
the binutils:

```shell

$> anise i elt-patches patch autoconf-archive gcc-config
  diffutils binutils binutils-libs which make portage lazarus fpc
...

$> gcc-config 1 && source /etc/profile

$> eselect gcc set 1 && macaronictl env-update

$> # Under the repository directory execute:
$> make build
```

By default the build using the `lazbuild` path of the `lazarus`
package. If you want to use a local compiled version you need to override
the `LAZBUILD_OPTS` variable:

```shell
$> LAZBUILD_OPTS="--lazarusdir=/usr/local/lazarus-main/lazbuild --build-mode=Release" make build
```

At the end of the compilation will be generated the binary `pageant`
that could be executed with:

```shell
$> ./pageant
```

