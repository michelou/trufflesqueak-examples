# <span id="top">Using <code>gu.bat</code> on Microsoft Windows</span> <span style="font-size:80%;font-style:italic;">(deprecated)</span>  <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="Squeak logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;"><a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> is a Squeak/Smalltalk implementation for the <a href="https://www.graalvm.org/">GraalVM</a>.<br/>
  This document presents <b><code>gu.bat</code></b>, a batch file we wrote as a <i>substitute</i> for Oracle's <a href="https://www.graalvm.org/docs/reference-manual/install-components/">GraalVM Updater</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [TruffleSqueak][trufflesqueak] on Windows:

- [Installing TruffleSqueak on Windows](README.md)
- Using **`gu.bat`** on Windows [**&#9660;**](#bottom)
- [Building TruffleSqueak on Windows](BUILD.md)

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Git 2.27][git_downloads] ([*release notes*][git_relnotes])
- [GraalVM Community Edition 20.0 LTS][graalvm_downloads] ([*release notes*][graalvm_relnotes])

For instance our development environment looks as follows (*July 2020*) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
C:\opt\Git-2.27.0\                <i>(278 MB)</i>
C:\opt\graalvm-ce-java8-20.1.0\   <i>(360 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**][linux_opt] directory on Unix).

## <span id="structure">Directory structure</span>

This project is organized as follows:
<pre style="font-size:80%;">
bin\gu.bat
docs\
examples\README.md
BUILD.md
GU.md
README.md
setenv.bat
</pre>

where

- file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for *installing* the [TruffleSqueak] component on a Windows machine.
- directory [**`docs\`**](docs/) contains several [TruffleSqueak] related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak] code examples (see [**`examples\README.md`**](examples/README.md)).
- file [**`BUILD.md`**](BUILD.md) is the Markdown document presenting the generation of the [TruffleSqueak] component.
- file [**`GU.md`**](GU.md) is the Markdown document for this page.
- file [**`README.md`**](README.md) is the Markdown document presenting the installation of the [TruffleSqueak] component.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`Q:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst Q: %USERPROFILE%\workspace\trufflesqueak-examples</b>
> </pre>

In the next section we give a brief overview of batch file **`gu.bat`**.

## <span id="overview">**`gu.bat`** overview</span>

We wrote batch command [**`gu.bat`**](bin/gu.bat) as a <i>substitute</i> for Oracle's [GraalVM Updater][gu_refman] on a Windows machine <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>.

 > **&#9755;** Starting with version 20.0 command `gu.cmd` is part of the [GraalVM] distribution; Windows users can should use `gu.cmd` instead `gu.bat`.

In short [**`gu.bat`**](bin/gu.bat):
- implements a *subset* of the commands featured by Oracle's [GraalVM Updater][gu_refman].
- works properly given *one* the following two requirements is met:
    - the environment variable **`GRAAL_HOME`**  is defined or
    - **`gu.bat`** is located in directory **`<graalvm-dir>\bin\`**.
- contains ~850 lines of batch code including a few lines of [PowerShell] code.

Command **`gu -h`** (or **`gu --help`**) prints the following help message:
<pre style="font-size:80%;">
<b>&gt;where gu</b>
Q:\bin\gu.bat
&nbsp;
<b>&gt; gu -h</b>
Usage: gu command {&lt;option&gt;} {&lt;param&gt;}
&nbsp;
  Commands:
    available [-l] &lt;expr&gt;            List components in the component catalog.
    info [-cL] &lt;param&gt;               Print component information (from file, URL or catalog).
    install [-0AcfiLnoru] {&lt;param&gt;}  Install specified components (from file, URL or catalog).
    list [-cl] &lt;expr&gt;                List installed components.
    rebuild-images                   Rebuild native images.
    remove [-0fx] &lt;id&gt;               Remove component (ID).
    update [-x][&lt;ver&gt;][&lt;param&gt;]      Upgrade to the recent GraalVM version.
&nbsp;
  Options supported by all commands:
    -d, --debug                      Show commands executed by this script.
    -h, --help                       Display this help message or a command specific help message.
    -v, --verbose                    Display progress messages.
&nbsp;
  Options:
    -0, --dry-run                    Dry run. Do not change any files.
    -A, --auto-yes                   Say YES or ACCEPT to a question.
    -c, --catalog                    Treat parameters as component IDs from catalog. This is the default.
    -f, --force                      Disable (un-)installation checks.
    -i, --fail-existing              Fail if the to be installed component already exists.
    -L, --local-file                 Treat parameters as local filenames.
    -l, --list-files                 List files.
    -n, --no-progress                Do not display download progress.
    -o, --overwrite                  Silently overwrite already existing component.
    -p, --paths                      Display full paths in lists.
    -r, --replace                    Replace different files.
    -u, --url                        Treat parameters as URLs.
    -x, --ignore                     Do not terminate uninstall on failed file deletions.</pre>

> **:mag_right:** The definition of the above commands and options is based on the following documentation:
> - [Oracle GraalVM EE 19 Guide](graalvm_ee_refman) : [GraalVM Updater][gu_ee_refman].
> - [GraalVM Reference Manual](graalvm_refman) : [GraalVM Updater][gu_refman].

Oracle's [GraalVM Updater][gu_refman] features seven commands and supports both long and short options (*"switches"*).

In the next section we present usage examples of commands currently implemented in [**`gu.bat`**](bin/gu.bat).

## <span id="commands">**`gu.bat`** commands</span>

#### <span id="gu_available">`gu.bat available`</span>

Command [**`gu.bat available`**](bin/gu.bat) with not argument displays components available from the GraalVM Catalog <sup id="anchor_04a"><a href="#footnote_04">[4]</a></sup> which fit in our environment. For instance we get the following output with a GraalVM 20.1.0 installation on a Unix machine:

<pre style="font-size:80%;">
<b>&gt; gu available</b>
Downloading: Component catalog
Component.20.1.0_linux_amd64.org.graalvm.llvm_toolchain-Bundle-Name=LLVM.org toolchain
Component.20.1.0_linux_amd64.org.graalvm.native_image-Bundle-Name=Native Image
Component.20.1.0_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.20.1.0_linux_amd64.org.graalvm.r-Bundle-Name=FastR
Component.20.1.0_linux_amd64.org.graalvm.ruby-Bundle-Name=TruffleRuby
</pre>

> **:mag_right:** The address of the GraalVM Catalog is stored in file **`%GRAAL_HOME%\release`** :
> <pre style="font-size:80%;">
> <b>&gt; type %GRAAL_HOME%\release | findstr /b component_catalog</b>
> component_catalog=https://www.graalvm.org/component-catalog/graal-updater-component-catalog.properties
> </pre>

Command [**`gu.bat available python r`**](bin/gu.bat) with arguments **`python`** and **`r`** displays components available from the GraalVM Catalog which fit our environment:

<pre style="font-size:80%;">
<b>&gt; gu available python r</b>
Downloading: Component catalog
Component.20.1.0_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.20.1.0_linux_amd64.org.graalvm.r-Bundle-Name=FastR
</pre>

Command [**`gu.bat available -l python r`**](bin/gu.bat) with option **`-l`** instead displays their URL addresses:

<pre style="font-size:80%;">
<b>&gt; gu available -l python r</b>
Downloading: Component catalog
https://github.com/graalvm/graalpython/releases/download/vm-20.1.0/python-installable-svm-java8-linux-amd64-20.1.0.jar
https://github.com/oracle/fastr/releases/download/vm-20.1.0/r-installable-java8-linux-amd64-20.1.0.jar
</pre>

#### <span id="gu_info">`gu.bat info`</span>

Command [**`gu.bat info`**](bin/gu.bat) prints component information from file, URL or catalog.

<pre style="font-size:80%;">
<b>&gt; gu info -h</b>
Usage: gu info [-cdhlLprstuv] {&lt;param&gt;}
Print component information from file, URL or catalog.
&nbsp;
  Options:
    -c, --catalog     Treat parameters as component IDs from catalog. This is the default.
    -d, --debug       Show commands executed by this script.
    -h, --help        Display this help message.
    -L, --local-file  Treat parameters as local filenames of packaged components.
    -u, --url         Treat parameters as URLs.
    -v, --verbose     Enable verbose output.
</pre>

Command [**`gu.bat info -L ruby`**](bin/gu.bat) displays component information for the installed component **`ruby`**:

<pre style="font-size:80%;">
<b>&gt; gu info -L ruby</b>
Component: ruby
   characterMimeType.0=application/x-ruby
   className=org.truffleruby.RubyLanguage
   defaultMimeType=application/x-ruby
   dependentLanguage.0=llvm
   fileTypeDetector0=org.truffleruby.RubyFileTypeDetector
   implementationName=TruffleRuby
   interactive=true
   internal=false
   name=Ruby
   version=2.6.2
   OS_NAME=linux
   OS_ARCH=amd64
   GRAALVM_VERSION=20.1.0</pre>

#### <span id="gu_install">`gu.bat install`</span>

Command [**`gu.bat install`**](bin/gu.bat) installs [GraalVM] installable components from three different sources, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive <i>(option </i><b><code>-u</code></b><i>)</i></li>
</ul>

> **:mag_right:** Options **`-c`**, **`-L`** and **`-u`** are mutual exclusive:
> <pre style="font-size:80%;">
> <b>&gt; gu install -cL python</b>
> Error: --catalog(-c), --local-file(-L) and --url(-u) options are mutual exclusive
> </pre>

<pre style="font-size:80%;">
<b>&gt; gu install -h</b>
Usage: gu install [-0cdfhiLnorv] {&lt;param&gt;}
Install specified components from file, URL or catalog.
&nbsp;
  Options:
    -0, --dry-run        Dry run. Do not change any files.
    -c, --catalog        Treat parameters as component IDs from catalog (default).
    -d, --debug          Show commands executed by this script.
    -f, --force          Disable installation checks.
    -h, --help           Display this help message.
    -i, --fail-existing  Fail if the to be installed component already exists.
    -L, --local-file     Treat parameters as local filenames of packaged components.
    -n, --no-progress    Do not display download progress.
    -o, --overwrite      Silently overwrite previously installed component.
    -r, --replace        Replace different files.
    -u, --url            Treat parameters as URLs.
    -v, --verbose        Enable verbose output.
</pre>

*Installation from a **catalog***

Command [**`gu.bat -v install python`**](bin/gu.bat) adds the [GraalPython] component to our [GraalVM] environment:

<pre style="font-size:80%;">
<b>&gt; gu install -v python</b>
Downloading: Component catalog graal-updater-component-catalog.properties
Processing component archive: Component python
Downloading: Component python-installable-svm-linux-amd64-20.1.0.jar
Install remote component python-installable-svm-linux-amd64-20.1.0.jar
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalpython.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalpython.cmd
Component ready to be installed in c:\opt\graalvm-ce-java8-20.1.0
Do you really want to add the component into directory c:\opt\graalvm-ce-java8-20.1.0 (y/*)? y
Install GraalVM component into directory c:\opt\graalvm-ce-java8-20.1.0
</pre>

> **:mag_right:** In the above output path **`%TEMP%\graal-updater`** is the working directory used by command **`gu.bat`**:
> <pre style="font-size:80%;">
> <b>&gt; dir /a-d %TEMP%\graal-updater | findstr /r /c:"^[^ ]"</b>
> 23.10.2019  14:51           133 318 graal-updater-component-catalog.properties
> 23.10.2019  09:43        65 156 656 python-installable-svm-linux-amd64-20.1.0.jar
> </pre>

*Installation from a **local** component archive*

Command [**`gu.bat install -L trufflesqueak-component.jar`**](bin/gu.bat) adds the [TruffleSqueak] component to our [GraalVM] environment.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-java8-20.1.0
&nbsp;
<b>&gt; curl -sL -o trufflesqueak-component.jar https://github.com/hpi-swa/trufflesqueak/releases/download/20.1.0/trufflesqueak-installable-java8-windows-amd64-20.1.0.jar</b>
&nbsp;
<b>&gt; gu install -L trufflesqueak-component.jar</b>
Install local component trufflesqueak-component.jar
Do you really want to add the component into directory C:\opt\graalvm-ce-java8-20.1.0 (y/*)? y
</pre>

Adding option **`-A`** skips user confirmation before proceeding with the installation:

<pre style="font-size:80%;">
<b>&gt; gu install -AL trufflesqueak-component.jar</b>
Install local component trufflesqueak-component.jar
</pre>

*Installation from a **remote** component archive*

Command [**`gu.bat install -uv`**](bin/gu.bat)` `[**`https://../trufflesqueak-component-1.0.0-rc9-for-GraalVM-20.2.1.jar`**](trufflesqueak_downloads) adds the [TruffleSqueak] component to our [GraalVM] environment.

<pre style="font-size:80%;">
<b>&gt; gu install -u trufflesqueak-installable-java8-windows-amd64-20.1.0.jar</b>
Install remote component trufflesqueak-installable-java8-windows-amd64-20.1.0.jar
Do you really want to add the component into directory C:\opt\graalvm-ce-java8-20.1.0 (y/*)? y
Install GraalVM component into directory C:\opt\graalvm-ce-java8-20.1.0
</pre>

#### <span id="gu_list">`gu.bat list`</span>

Command [**`gu.bat list`**](bin/gu.bat) prints the components installed in our [GraalVM] environment:

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-java8-20.1.0
&nbsp;
<b>&gt; gu list</b>
component graalpython
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="graalpython:712a86dcc68db59113297a4d95ff640b75a0dc4f"
   GRAALVM_VERSION=20.1.0
component fastr
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="fastr:3aa5dacd30b8d0862e91a5d19bf3b59d94365500"
   GRAALVM_VERSION=20.1.0
component truffleruby
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="truffleruby:3b698b1a4bf9b168891f1f795858eb550c258bc7"
   GRAALVM_VERSION=20.1.0
component trufflesqueak
   OS_NAME=windows
   OS_ARCH=amd64
   SOURCE="trufflesqueak:b414a22e8e70e97674232fc30c15aac7a3853929"
   GRAALVM_VERSION=20.1.0
</pre>

Command [**`gu.bat list -c`**](bin/gu.bat) is equivalent to [**`gu.bat available`**](#gu_available); it displays components available from the GraalVM Catalog <sup id="anchor_04b"><a href="#footnote_04">[4]</a></sup> which fit in our environment.

#### <span id="gu_rebuild">`gu.bat rebuild-images`</span>

We have no further plans to implement command [**`gu.bat rebuild-images`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu rebuild-images</b>
Command rebuild-images not yet implemented
(current GraalVM version: 20.1.0)
</pre>

#### <span id="gu_remove">`gu.bat remove`</span>

Command **`gu remove`** removes the installed component specified by its component ID.

<pre style="font-size:80%;">
<b>&gt; gu remove -h</b>
Usage: gu remove [-0dfhxv] &lt;param&gt;
Remove component (ID).

  Options:
    -0, --dry-run     Dry run. Do not change any files.
    -d, --debug       Show commands executed by this script.
    -f, --force       Disable uninstallation checks (eg. non-matching versions).
    -h, --help        Display this help message.
    -x, --ignore      Do not terminate uninstall on failed file deletions.
    -v, --verbose     Enable verbose output.
</pre>

We have no further plans to implement command [**`gu.bat remove`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu remove</b>
Command remove not yet implemented
(current GraalVM version: 20.1.0)
</pre>

#### <span id="gu_update">`gu.bat update`</span>

Command **`gu update`** upgrades our environment to the specified GraalVM version.

<pre style="font-size:80%;">
<b>&gt; gu update -h</b>
Usage: gu update [-dhvx] [&lt;ver&gt;] [&lt;param&gt;]
Upgrade to the recent GraalVM version.

  Options:
    -d, --debug       Show commands executed by this script.
    -h, --help        Display this help message.
    -v, --verbose     Enable verbose output.
    -x, --ignore      Do not terminate uninstall on failed file deletions.
</pre>

We have no further plans to implement command [**`gu.bat update`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu update</b>
Command update not yet implemented
(current GraalVM version: 20.1.0)
</pre>

## <span id="license">License</span>

**`gu.bat`** is released under the [MIT License](LICENSE).

## <span id="footnotes">Footnotes</span>

<a name="footnote_01">[1]</a> ***Downloads*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/trufflesqueak/releases/">trufflesqueak-installable-java8-windows-amd64-1.0.0-rc9-for-GraalVM-20.1.0.jar</a>  <i>(126 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-20.1.0.zip</a>             <i>(154 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.27.0-64-bit.7z.exe</a>                <i>( 41 MB)</i>
<a href="https://squeak.org/downloads/">Squeak5.3-19431-64bit-202003021730-Windows.zip</a>  <i>( 33 MB)</i>
</pre>

<a name="footnote_02">[2]</a> ***GraalVM Updater*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Microsoft Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> component (e.g. archive file <b><code>trufflesqueak-component.jar</code></b>) to our <a href="https://www.graalvm.org/">GraalVM</a> environment (e.g. <b><code>c:\opt\graalvm-ce-java8-20.1.0\</code></b>).
</p>

<a name="footnote_03">[3]</a> ***Preinstalled components*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Component <a href="https://github.com/graalvm/graaljs">GraalJS</a> is preinstalled in the <a href="https://www.graalvm.org/">GraalVM</a> environment. It is a <a href="https://github.com/tc39/ecma262">ECMAScript 2019</a> compliant Javascript implementation built on <a href="https://www.graalvm.org/">GraalVM</a> (with <a href="https://www.graalvm.org/docs/reference-manual/polyglot/">Polyglot language interoperability</a> support).
</p>

<pre style="margin:0 0 1em 20px;font-size:80%;">
<b>&gt; where /r c:\opt\graalvm-ce-java8-20.1.0 js.cmd</b>
c:\opt\graalvm-ce-java8-20.1.0\bin\js.cmd
c:\opt\graalvm-ce-java8-20.1.0\jre\bin\js.cmd
c:\opt\graalvm-ce-java8-20.1.0\jre\languages\js\bin\js.cmd
&nbsp;
<b>&gt; js --version</b>
GraalVM JavaScript (GraalVM CE JVM 20.1.0)
</pre>

<a name="footnote_04">[4]</a> ***GraalVM Catalog*** [↩](#anchor_04a)

<p style="margin:0 0 1em 20px;">
At the time of writing the GraalVM Catalog contains <i>no</i> component for the Windows platform.<br/>
Components currently available are:
</p>
<table style="margin:0 0 1em 20px;">
<tr><th>ID</th><th>Version(s)</th><th>Supported platform(s)</th></tr>
<tr><td><code>llvm_toolchain</code></td><td>19.2, <a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>native_image</code></td><td>19.0, 19.1, 19.2, <a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b>, <b><code>windows</b></code> <i>(20.0+)</i></td></tr>
<tr><td><a href="https://github.com/graalvm/graalpython"><code>python</code></a></td><td>19.0, 19.1, 19.2, <a href="https://github.com/graalvm/graalpython/releases/tag/vm-19.3.1">19.3</a>, <a href="https://github.com/graalvm/graalpython/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><a href="https://github.com/oracle/fastr"><code>r</code></a></td><td>19.0, 19.1, 19.2, <a href="https://github.com/oracle/fastr/releases/tag/vm-19.3.1">19.3</a>, <a href="https://github.com/oracle/fastr/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><a href="https://github.com/oracle/truffleruby"><code>ruby</code></a</td><td>19.0, 19.1, 19.2, <a href="https://github.com/oracle/truffleruby/releases/tag/vm-19.3.1">19.3</a>, <a href="https://github.com/oracle/truffleruby/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><b><code>wasm</code></b></td><td><a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-20.1.0">20.0</a></td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
</table>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/July 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- hrefs -->

[git_downloads]: https://git-scm.com/download/win
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.27.0.txt
[graalpython]: https://github.com/graalvm/graalpython
[graalvm]: https://www.graalvm.org/
[graalvm_downloads]: https://github.com/graalvm/graalvm-ce-builds/releases
[graalvm_ee_refman]: https://docs.oracle.com/en/graalvm/enterprise/20/guide/
[graalvm_refman]: https://www.graalvm.org/docs/reference-manual/
[graalvm_relnotes]: https://www.graalvm.org/docs/release-notes/20_1/
[gu_ee_refman]: https://docs.oracle.com/en/graalvm/enterprise/20/guide/reference/graalvm-updater.html
[gu_refman]: https://www.graalvm.org/docs/reference-manual/install-components/
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[powershell]: https://docs.microsoft.com/en-us/powershell/scripting/
[squeak]: https://squeak.org/
[trufflesqueak]: https://github.com/hpi-swa/trufflesqueak
[trufflesqueak_downloads]: https://github.com/hpi-swa/trufflesqueak/releases/
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
