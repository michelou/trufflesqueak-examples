# <span id="top">GraalVM Updater on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">GraalSqueak</a> is a Squeak/Smalltalk implementation for the <a href="https://www.graalvm.org/">GraalVM</a>.<br/>
  This document presents <b><code>gu.bat</code></b>, a batch file we wrote as a <i>substitute</i> for Oracle's <a href="https://www.graalvm.org/docs/reference-manual/install-components/">GraalVM Updater</a> on a Windows machine.
  </td>
  </tr>
</table>

This document is part of a series of topics related to [GraalSqueak](https://github.com/hpi-swa/graalsqueak) on Windows:

- [Installing GraalSqueak on Windows](README.md)
- Using **`gu.bat`** on Windows [**&#9660;**](#bottom)
- [Building GraalSqueak on Windows](BUILD.md)

## <span id="section_01">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Git 2.23](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.23.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/#19201))

For instance our development environment looks as follows (*October 2019*) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
C:\opt\graalvm-ce-19.2.1\                             <i>(362 MB)</i>
C:\opt\Git-2.23.0\                                    <i>(271 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).

We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).

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

## GU overview

We wrote the batch command [**`gu.bat`**](bin/gu.bat) as a <i>substitute</i> for Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/) on a Windows machine <sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>.

In short [**`gu.bat`**](bin/gu.bat):
- implements a subset of the commands featured by Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/).
- relies *only* on variable **`GRAAL_HOME`** (location of the [GraalVM](https://www.graalvm.org/) installation directory).
- contains ~600 lines of batch code including a few lines of PowerShell code.

Command **`gu -h`** (or **`gu --help`**) prints the following help message:
<pre style="font-size:80%;">
<b>&gt;where gu</b>
K:\bin\gu.bat
&nbsp;
<b>&gt; gu -h</b>
Usage: gu command { options } { params }
  Commands:
    available [-lv] &lt;expr&gt;         list components in the component catalog
    info [-cL] &lt;param&gt;             print component information (from file, URL or catalog)
    install [-0cfiLnorv] &lt;param&gt;   install specified component (ID or local archive)
    list [-clv] &lt;expr&gt;             list installed components
    rebuild-images                 rebuild native images
    remove [-0fxv] &lt;id&gt;            remove component (ID)
    update [-x][&lt;ver&gt;][&lt;param&gt;]    upgrade to the recent GraalVM version
  Options:
    -A, --auto-yes                 say YES or ACCEPT to a question
    -c, --catalog                  treat parameters as component IDs from catalog. This is the default.
    -d, --debug                    show commands executed by this scriptD
    -f, --force                    disable (un-)installation checks
    -h, --help                     print this help message or a command specific help message
    -L, --local-file               treat parameters as local filenames
    -n, --no-progress              do not display download progress
    -o, --overwrite                silently overwrite already existing component
    -r, --replace                  replace component if already installed
    -u, --url                      treat parameters as URLs
    -v, --verbose                  display progress messages</pre>

> **:mag_right:** The definition of the above commands and options is based on the following documentation:
> - [Oracle GraalVM EE 19 Guide](https://docs.oracle.com/en/graalvm/enterprise/19/guide/) : [GraalVM Updater](https://docs.oracle.com/en/graalvm/enterprise/19/guide/reference/graalvm-updater.html).
> - [GraalVM Reference Manual](https://www.graalvm.org/docs/reference-manual/) : [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/).

Oracle's [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/install-components/) features seven commands and supports both long and short options (*"switches"*).

> **:mag_right:** Command [**`gu.bat install -h`**](bin/gu.bat) displays the help message for command **`install`** (same for the other **`gu`** commands).
> <pre style="font-size:80%;">
> <b>&gt; gu install -h</b>
>    Usage: gu install [-0cfiLnorv] &lt;param&gt;
>      Options:
>        -0                ???
>        -c, --catalog     treat parameters as component IDs from catalog (default)
>        -f, --force       disable installation checks
>        -i                ???
>        -L, --local-file  treat parameters as local filenames of packaged components
>        -n, --no-progress do not display download progress
>        -o, --overwrite   silently overwrite previously installed component
>        -r, --replace     ???
>        -v, --verbose     enable verbose output</pre>

In the next section we present usage examples of commands currently implemented in [**`gu.bat`**](bin/gu.bat).

## GU commands

#### `gu.bat available`

Command [**`gu.bat available`**](bin/gu.bat) with not argument prints components available from the GraalVM Catalog <sup id="anchor_03"><a href="#footnote_03">[3]</a></sup> which fit in our environment. For instance we would get the following output with a GraalVM 19.2.1 installation on a Unix machine:

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

Command [**`gu.bat available python r`**](bin/gu.bat) with arguments **`python`** and **`r`** prints the corresponding components available from the GraalVM Catalog:

<pre style="font-size:80%;">
<b>&gt; gu available python r</b>
Downloading: Component catalog
Component.19.2.1_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.19.2.1_linux_amd64.org.graalvm.r-Bundle-Name=FastR
</pre>

#### `gu.bat install`

Command [**`gu.bat install`**](bin/gu.bat) can install [GraalVM](https://www.graalvm.org/) components in three different ways, namely:
<ul>
<li>from a catalog <i>(default, option </i><b><code>-c</code></b><i>)</i></li>
<li>from a local component archive <i>(option </i><b><code>-L</code></b><i>)</i></li>
<li>from a remote component archive <i>(option </i><b><code>-u</code></b><i>)</i></li>
</ul>

*Installation from a **catalog***:

Command [**`gu.bat -v install python`**](bin/gu.bat) adds the [GraalPython](https://github.com/graalvm/graalpython) component to the [GraalVM](https://www.graalvm.org/) installation directory

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
   Do you really want to add the component into directory c:\opt\graalvm-ce-19.2.1? y
   Install GraalVM component into directory c:\opt\graalvm-ce-19.2.1
   </pre>

> **:mag_right:** In the above output path **`%TEMP%\graal-updater`** is the working directory used by command **`gu.bat`**:
> <pre style="font-size:80%;">
> dir /a-d %TEMP%\graal-updater | findstr /r /c:"^[^ ]"
> 23.10.2019  14:51           133 318 graal-updater-component-catalog.properties
> 23.10.2019  09:43        65 156 656 python-installable-svm-linux-amd64-19.2.1.jar
> </pre>

*Installation from a **local** component archive:*

Command [**`gu.bat install -L graalsqueak-component.jar`**](bin/gu.bat) adds the GraalSqueak component to the [GraalVM](https://www.graalvm.org/) installation directory.

<pre style="font-size:80%;">
<b>&gt; echo %GRAAL_HOME%</b>
C:\opt\graalvm-ce-19.2.1
&nbsp;
<b>&gt; curl -sL https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar -o graalsqueak-component.jar</b>
&nbsp;
<b>&gt; gu install -L graalsqueak-component.jar</b>
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalsqueak.cmd
Component ready for installation into directory C:\opt\graalvm-ce-19.2.1
Do you really want to add the component to directory C:\opt\graalvm-ce-19.2.1? y
Install GraalVM component into directory C:\opt\graalvm-ce-19.2.1
</pre>

*Installation from a **remote** component archive:*

<pre style="font-size:80%;">
<b>&gt; gu install -uv https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar
Download component https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc4/graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar</b>
Install remote component graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar
Extract GraalVM component into directory %TEMP%\graal-updater\tmp
Create file %TEMP%\graal-updater\tmp\bin\graalsqueak.cmd
Create file %TEMP%\graal-updater\tmp\jre\bin\graalsqueak.cmd
Component ready to be installed in C:\opt\graalvm-ce-19.2.1
Do you really want to add the component into directory C:\opt\graalvm-ce-19.2.1? y
Install GraalVM component into directory C:\opt\graalvm-ce-19.2.1
</pre>

#### `gu.bat list`

Command [**`gu.bat list`**](bin/gu.bat) displays components from the catalog which are eligible to be added to a [GraalVM](https://www.graalvm.org/) installation directory. For instance, we would get the following output on a Unix machine where **`GRAAL_HOME`** specify the path of a GraalVM 19.2.1 installation:
<pre style="font-size:80%;">
<b>&gt; grep "^(OS|GRAAL)" $GRAAL_HOME\release</b>
OS_NAME=linux
OS_ARCH=amd64
GRAAL_VERSION=19.2.1
&nbsp;
<b>&gt; gu list</b>
Downloading: Component catalog
Component.19.2.1_linux_amd64.org.graalvm.llvm_toolchain-Bundle-Name=LLVM.org toolchain
Component.19.2.1_linux_amd64.org.graalvm.native_image-Bundle-Name=Native Image
Component.19.2.1_linux_amd64.org.graalvm.python-Bundle-Name=Graal.Python
Component.19.2.1_linux_amd64.org.graalvm.r-Bundle-Name=FastR
Component.19.2.1_linux_amd64.org.graalvm.ruby-Bundle-Name=TruffleRuby
</pre>


## Footnotes

<a name="footnote_01">[1]</a> ***Downloads*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://github.com/hpi-swa/graalsqueak/releases/">graalsqueak-component-1.0.0-rc4-for-GraalVM-19.2.1.jar</a>  <i>(  5 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>                     <i>(171 MB)</i>
</pre>

<a name="footnote_02">[2]</a> ***GraalVM Updater*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
Command <a href="https://www.graalvm.org/docs/reference-manual/install-components/"><b><code>gu</code></b></a> is not yet supported on Windows, so we currently run our own (stripped down) command <a href="bin/gu.bat"><b><code>bin\gu.bat</code></b></a> to add the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> component (e.g. archive file <b><code>graalsqueak-component.jar</code></b>) to our <a href="https://www.graalvm.org/">GraalVM</a> installation directory (e.g. <b><code>c:\opt\graalvm-ce-19.2.1\</code></b>).
</p>

<a name="footnote_03">[32]</a> ***GraalVM Catalog*** [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
At the time of writing the GraalVM Catalog contains <i>no</i> component for the Windows platform.<br/>
Components currently available are:
</p>
<table style="margin:0 0 1em 20px;">
<tr><th>ID</th><th>Version(s)</th><th>Platform(s)</th></tr>
<tr><td><code>llvm_toolchain</code></td><td>19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>native_image</code></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>python</code></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>r</code></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
<tr><td><code>ruby</code></td><td>19.0, 19.1, 19.2</td><td><b><code>linux_amd64</code></b>, <b><code>macos_amd64</code></b></td></tr>
</table>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/October 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
