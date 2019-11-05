# <span id="top">Using <code>gu.bat</code> on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;"><a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> is a Squeak/Smalltalk implementation for the <a href="https://www.graalvm.org/">GraalVM</a>.<br/>
  This document presents <b><code>gu.bat</code></b>, a batch file we wrote as a <i>substitute</i> for Oracle's <a href="https://www.graalvm.org/docs/reference-manual/install-components/">GraalVM Updater</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- [Installing GraalSqueak on Windows](README.md)
- Using **`gu.bat`** on Windows [**&#9660;**](#bottom)
- [Building GraalSqueak on Windows](BUILD.md)

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Git 2.24](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.24.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))

For instance our development environment looks as follows (*November 2019*) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\   <i>(362 MB)</i>
C:\opt\Git-2.24.0\          <i>(271 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

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

- file [**`bin\gu.bat`**](bin/gu.bat) is the batch script for installing the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component on a Windows machine.
- directory [**`docs\`**](docs/) contains several [GraalSqueak](https://github.com/hpi-swa/graalsqueak) related papers/articles.
- directory [**`examples\`**](examples/) contains [Squeak](https://squeak.org/) code examples (see [**`examples\README.md`**](examples/README.md)).
- file [**`BUILD.md`**](BUILD.md) is the Markdown document presenting the generation of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.
- file [**`GU.md`**](GU.md) is the Markdown document for this page.
- file [**`README.md`**](README.md) is the Markdown document presenting the installation of the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`K:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst K: %USERPROFILE%\workspace\graalsqueak-examples</b>
> </pre>

In the next section we give a brief overview of batch file **`gu.bat`**.

## <span id="overview">**`gu.bat`** overview</span>

We wrote batch command [**`gu.bat`**](bin/gu.bat) as a <i>substitute</i> for Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/) on a Windows machine <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>.

In short [**`gu.bat`**](bin/gu.bat):
- implements a *subset* of the commands featured by Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/).
- works properly given *one* the following two requirements is met:
    - the environment variable **`GRAAL_HOME`**  is defined or
    - **`gu.bat`** is located in directory **`<graalvm-dir>\bin\`**.
- contains ~850 lines of batch code including a few lines of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/) code.

Command **`gu -h`** (or **`gu --help`**) prints the following help message:
<pre style="font-size:80%;">
<b>&gt;where gu</b>
K:\bin\gu.bat
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
    -h, --help                       Print this help message or a command specific help message.
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
> - [Oracle GraalVM EE 19 Guide](https://docs.oracle.com/en/graalvm/enterprise/19/guide/) : [GraalVM Updater](https://docs.oracle.com/en/graalvm/enterprise/19/guide/reference/graalvm-updater.html).
> - [GraalVM Reference Manual](https://www.graalvm.org/docs/reference-manual/) : [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/).

Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/) features seven commands and supports both long and short options (*"switches"*).

In the next section we present usage examples of commands currently implemented in [**`gu.bat`**](bin/gu.bat).

## <span id="commands">**`gu.bat`** commands</span>

#### <span id="gu_available">`gu.bat available`</span>

Command [**`gu.bat available`**](bin/gu.bat) with not argument displays components available from the GraalVM Catalog <sup id="anchor_04a"><a href="#footnote_04">[4]</a></sup> which fit in our environment. For instance we get the following output with a GraalVM 19.2.1 installation on a Unix machine:

<pre style="font-size:80%;">
<b>&gt; gu available</b>
Downloading: Component catalog
Component.19.2.1_linux_amd64.org.graalvm.llvm_toolchain-Bundle-Name=LLVM.org toolchain
Component.19.2.1_linux_amd64.org.graalvm.native_image-Bundle-Name=Native Image
Component.19.2.1_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.19.2.1_linux_amd64.org.graalvm.r-Bundle-Name=FastR
Component.19.2.1_linux_amd64.org.graalvm.ruby-Bundle-Name=TruffleRuby
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
Component.19.2.1_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.19.2.1_linux_amd64.org.graalvm.r-Bundle-Name=FastR
</pre>

Command [**`gu.bat available -l python r`**](bin/gu.bat) with option **`-l`** instead displays their URL addresses:

<pre style="font-size:80%;">
<b>&gt; gu available -l python r</b>
Downloading: Component catalog
https://github.com/graalvm/graalpython/releases/download/vm-19.2.1/python-installable-svm-linux-amd64-19.2.1.jar
https://github.com/oracle/fastr/releases/download/vm-19.2.1/r-installable-linux-amd64-19.2.1.jar
</pre>

#### <span id="gu_info">`gu.bat info`</span>

Command [**`gu.bat info`**](bin/gu.bat) prints component information from file, URL or catalog.

<pre style="font-size:80%;">
<b>&gt; gu info -h</b>
Usage: gu info [-clLprstuv] {&lt;param&gt;}
Print component information from file, URL or catalog.
  Options:
    -c, --catalog     treat parameters as component IDs from catalog. This is the default
    -L, --local-file  treat parameters as local filenames of packaged components
    -u, --url         treat parameters as URLs
    -v, --verbose     enable verbose output
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
   GRAALVM_VERSION=19.2.1</pre>

#### <span id="gu_install">`gu.bat install`</span>

Command [**`gu.bat install`**](bin/gu.bat) installs [GraalVM](https://www.graalvm.org/) installable components from three different sources, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive <i>(option </i><b><code>-u</code></b><i>)</i></li>
</ul>

> **:mag_right:** Options **`-c`**, **`-L`** and **`-u`** are mutual exclusive:
> <pre style="font-size:80%;">
> <b>&gt; gu install -cL python</b>
> Error: --catalog, --local-file and --url options are mutual exclusive
> </pre>

<pre style="font-size:80%;">
<b>&gt; gu install -h</b>
Usage: gu install [-0cfiLnorv] {&lt;param&gt;}
Install specified components from file, URL or catalog.
&nbsp;
  Options:
    -0, --dry-run        Dry run. Do not change any files.
    -c, --catalog        Treat parameters as component IDs from catalog (default).
    -f, --force          Disable installation checks
    -i, --fail-existing  Fail if the to be installed component already exists.
    -L, --local-file     Treat parameters as local filenames of packaged components.
    -n, --no-progress    Do not display download progress.
    -o, --overwrite      Silently overwrite previously installed component.
    -r, --replace        Replace different files.
    -u, --url            Treat parameters as URLs.
    -v, --verbose        Enable verbose output.
</pre>

*Installation from a **catalog***

Command [**`gu.bat -v install python`**](bin/gu.bat) adds the [GraalPython](https://github.com/graalvm/graalpython) component to our [GraalVM](https://www.graalvm.org/) environment:

<pre style="font-size:80%;">
<b>&gt; gu install -v python</b>
Downloading: Component catalog graal-updater-component-catalog.properties
Processing component archive: Component python
Downloading: Component python-installable-svm-linux-amd64-19.2.1.jar
Install remote component python-installable-svm-linux-amd64-19.2.1.jar
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalpython.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalpython.cmd
Component ready to be installed in c:\opt\graalvm-ce-19.2.1
Do you really want to add the component into directory c:\opt\graalvm-ce-19.2.1 (y/*)? y
Install GraalVM component into directory c:\opt\graalvm-ce-19.2.1
</pre>

> **:mag_right:** In the above output path **`%TEMP%\graal-updater`** is the working directory used by command **`gu.bat`**:
> <pre style="font-size:80%;">
> <b>&gt; dir /a-d %TEMP%\graal-updater | findstr /r /c:"^[^ ]"</b>
> 23.10.2019  14:51           133 318 graal-updater-component-catalog.properties
> 23.10.2019  09:43        65 156 656 python-installable-svm-linux-amd64-19.2.1.jar
> </pre>

*Installation from a **local** component archive*

Command [**`gu.bat install -L graalsqueak-component.jar`**](bin/gu.bat) adds the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component to our [GraalVM](https://www.graalvm.org/) environment.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-19.2.1
&nbsp;
<b>&gt; curl -sL -o graalsqueak-component.jar https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc5/graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</b>
&nbsp;
<b>&gt; gu install -L graalsqueak-component.jar</b>
Install local component graalsqueak-component.jar
Do you really want to add the component into directory C:\opt\graalvm-ce-19.2.1 (y/*)? y
</pre>

Adding option **`-A`** skips user confirmation before proceeding with the installation:

<pre style="font-size:80%;">
<b>&gt; gu install -AL graalsqueak-component.jar</b>
Install local component graalsqueak-component.jar
</pre>

*Installation from a **remote** component archive*

Command [**`gu.bat install -uv`**](bin/gu.bat)` `[**`https://../graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar`**](https://github.com/hpi-swa/graalsqueak/releases/) adds the [GraalSqueak](https://github.com/hpi-swa/graalsqueak) component to our [GraalVM](https://www.graalvm.org/) environment.

<pre style="font-size:80%;">
<b>&gt; gu install -uv https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc5/graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar
Download component https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc5/graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</b>
Install remote component graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalsqueak.cmd
Component ready to be installed in C:\opt\graalvm-ce-19.2.1
Do you really want to add the component into directory C:\opt\graalvm-ce-19.2.1 (y/*)? y
Install GraalVM component into directory C:\opt\graalvm-ce-19.2.1
</pre>

#### <span id="gu_list">`gu.bat list`</span>

Command [**`gu.bat list`**](bin/gu.bat) prints the components installed in our [GraalVM](https://www.graalvm.org/) environment:

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-19.2.1
&nbsp;
<b>&gt; gu list</b>
component graalpython
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="graalpython:712a86dcc68db59113297a4d95ff640b75a0dc4f"
   GRAALVM_VERSION=19.2.1
component fastr
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="fastr:3aa5dacd30b8d0862e91a5d19bf3b59d94365500"
   GRAALVM_VERSION=19.2.1
component truffleruby
   OS_NAME=linux
   OS_ARCH=amd64
   SOURCE="truffleruby:3b698b1a4bf9b168891f1f795858eb550c258bc7"
   GRAALVM_VERSION=19.2.1
component graalsqueak
   OS_NAME=windows
   OS_ARCH=amd64
   SOURCE="graalsqueak:b414a22e8e70e97674232fc30c15aac7a3853929"
   GRAALVM_VERSION=19.2.1
</pre>

Command [**`gu.bat list -c`**](bin/gu.bat) is equivalent to [**`gu.bat available`**](#gu_available); it displays components available from the GraalVM Catalog <sup id="anchor_04b"><a href="#footnote_04">[4]</a></sup> which fit in our environment.

#### <span id="gu_rebuild">`gu.bat rebuild-images`</span>

We have no further plans to implement command [**`gu.bat rebuild-images`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu rebuild-images</b>
Command rebuild-images not yet implemented
(current GraalVM version: 19.2.1)
</pre>

#### <span id="gu_remove">`gu.bat remove`</span>

We have no further plans to implement command [**`gu.bat remove`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu remove</b>
Command remove not yet implemented
(current GraalVM version: 19.2.1)
</pre>

#### <span id="gu_update">`gu.bat update`</span>

We have no further plans to implement command [**`gu.bat update`**](bin/gu.bat).

<pre style="font-size:80%;">
<b>&gt; gu update</b>
Command update not yet implemented
(current GraalVM version: 19.2.1)
</pre>

## <span id="license">License</span>

**`gu.bat`** is released under the [MIT License](LICENSE).

## <span id="footnotes">Footnotes</span>

<a name="footnote_01">[1]</a> ***Downloads*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/graalsqueak/releases/">graalsqueak-component-1.0.0-rc5-for-GraalVM-19.2.1.jar</a>  <i>(  5 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>                     <i>(171 MB)</i>
</pre>

<a name="footnote_02">[2]</a> ***GraalVM Updater*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Microsoft Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> component (e.g. archive file <b><code>graalsqueak-component.jar</code></b>) to our <a href="https://www.graalvm.org/">GraalVM</a> environment (e.g. <b><code>c:\opt\graalvm-ce-19.2.1\</code></b>).
</p>

<a name="footnote_03">[3]</a> ***Preinstalled components*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
Component <a href="https://github.com/graalvm/graaljs">GraalJS</a> is preinstalled in the <a href="https://www.graalvm.org/">GraalVM</a> environment. It is a <a href="https://github.com/tc39/ecma262">ECMAScript 2019</a> compliant Javascript implementation built on <a href="https://www.graalvm.org/">GraalVM</a> (with <a href="https://www.graalvm.org/docs/reference-manual/polyglot/">Polyglot language interoperability</a> support).
</p>

<pre style="margin:0 0 1em 20px;font-size:80%;">
<b>&gt; where /r c:\opt\graalvm-ce-19.2.1 js.cmd</b>
c:\opt\graalvm-ce-19.2.1\bin\js.cmd
c:\opt\graalvm-ce-19.2.1\jre\bin\js.cmd
c:\opt\graalvm-ce-19.2.1\jre\languages\js\bin\js.cmd
&nbsp;
<b>&gt; js --version</b>
GraalVM JavaScript (GraalVM CE JVM 19.2.1)
</pre>

<a name="footnote_04">[4]</a> ***GraalVM Catalog*** [↩](#anchor_04a)

<p style="margin:0 0 1em 20px;">
At the time of writing the GraalVM Catalog contains <i>no</i> component for the Windows platform.<br/>
Components currently available are:
</p>
<table style="margin:0 0 1em 20px;">
<tr><th>ID</th><th>Version(s)</th><th>Supported platform(s)</th></tr>
<tr><td><code>llvm_toolchain</code></td><td>19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>native_image</code></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><a href="https://github.com/graalvm/graalpython"><code>python</code></a></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><a href="https://github.com/oracle/fastr"><code>r</code></a></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><a href="https://github.com/oracle/truffleruby"><code>ruby</code></a</td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
</table>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
