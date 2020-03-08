# <span id="top">GraalSqueak Examples</span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="./"><b><code>examples\</code></b></a> contains <a href="https://squeak.org/">Squeak</a> code examples coming from various websites and books and tested on a Windows machine.
  </td>
  </tr>
</table>

In this document we present the following [Squeak] code examples:

- [Logarithmic equation](#log)
- [tinyBenchmarks](#tiny_benchmarks)
- [System reporter](#system_reporter)

> **:mag_right:** The [Terse Guide to Squeak][squeak_guide] is included in the Squeak image <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup> and is accessible from the '**Help**' menu of the Squeak IDE.

## <span id="log">Logarithmic equation</span>

Let's take as first example the [logarithmic equation][wiki_logarithm] *"The logarithm of a product is the sum of the logarithms of the factors"*, i.e. <code>log<sub>b</sub>(x*y) = log<sub>b</sub>(x) + log<sub>b</sub>(y)</code>:

<pre style="font-size:80%;">
<b>&gt; where graalsqueak</b>
C:\opt\graalvm-ce-java8-20.0.0\bin\graalsqueak.cmd
&nbsp;
<b>&gt; graalsqueak --code "6 log - (2 log + 3 log)" images\GraalSqueak-1.0.0-rc7.image</b>
[graalsqueak] Running Squeak/Smalltalk on GraalVM CE...
[graalsqueak] Image loaded in 1390ms.
[graalsqueak] Preparing image for headless execution...
[graalsqueak] Evaluating '6 log - (2 log + 3 log)'...
[graalsqueak] Result: <b>-1.1102230246251565E-16</b>
</pre>

We observe that the result is *not* equal to zero due to limited precision in floating-point operations. By contrast, executing `log(6) - (log(2) + log(3))` in the [ke!san Online Calculator][keisan] returns `0` as an answer.

<!--
<b>&gt; graalsqueak --code "3 raisedTo: 32" images\GraalSqueak-1.0.0-rc7.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 20.0.0 (Graal-compiled)...
[graalsqueak] Image loaded in 3822ms.
Preparing image for headless execution...
[graalsqueak] Evaluating '3 raisedTo: 32'...
[graalsqueak] Result: 1853020188851841
-->

## <span id="tiny_benchmarks">tinyBenchmarks</span>

This micro-benchmark suite is often used to measure and compare the performance of different hardware platforms and Squeak VMs and consists of two benchmarks:
- The first one is bytecode-heavy as it allocates, fills, and reads from a large array.
- The other one is a recursive [Fibonacci][wiki_fibonacci] benchmark and therefore send-heavy

<pre style="font-size:80%;">
<b>&gt; graalsqueak --code "1 tinyBenchmarks" images\GraalSqueak-1.0.0-rc7.image</b>
[graalsqueak] Running Squeak/Smalltalk on GraalVM CE...
[graalsqueak] Image loaded in 1204ms.
[graalsqueak] Preparing image for headless execution...
[graalsqueak] Evaluating '1 tinyBenchmarks'...
[graalsqueak] Result: 27,000,000 bytecodes/sec; 150,000,000 sends/sec
</pre>

## <span id="system_reporter">System Reporter</span>

This Squeak code displays the user environment variables including the Java system properties of our [GraalVM] environment:

<pre style="font-size:80%;">
<b>&gt; graalsqueak --code "String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000" images\GraalSqueak-1.0.0-rc7.image</b>
[graalsqueak] Running Squeak/Smalltalk on GraalVM CE...
[graalsqueak] Image loaded in 1321ms.
[graalsqueak] Preparing image for headless execution...
[graalsqueak] Evaluating 'String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000'...
platform sources revision ilt on Mar 08 2020 11:51:16 CET
OpenJDK 64-Bit Server VM GraalVM CE 20.0.0 (25.242-b06-jvmci-20.0-b02; mixed mode)
&nbsp;
== System Properties =================================>
agentscript.home = c:\opt\graalvm-ce-java8-20.0.0\jre\tools\agentscript
awt.toolkit = sun.awt.windows.WToolkit
chromeinspector.home = c:\opt\graalvm-ce-java8-20.0.0\jre\tools\chromeinspector
coverage.home = c:\opt\graalvm-ce-java8-20.0.0\jre\tools\coverage
file.encoding = Cp1252
file.encoding.pkg = sun.io
file.separator = \
[...]
java.version = 1.8.0_242
java.vm.info = mixed mode
java.vm.name = OpenJDK 64-Bit Server VM GraalVM CE 20.0.0
java.vm.specification.name = Java Virtual Machine Specification
java.vm.specification.vendor = Oracle Corporation
java.vm.specification.version = 1.8
java.vm.vendor = Oracle Corporation
java.vm.version = 25.242-b06-jvmci-20.0-b02
js.home = c:\opt\graalvm-ce-java8-20.0.0\jre\languages\js
jvmci.Compiler = graal
line.separator =

lsp.home = c:\opt\graalvm-ce-java8-20.0.0\jre\tools\lsp
nfi.home = c:\opt\graalvm-ce-java8-20.0.0\jre\languages\nfi
org.graalvm.home = c:\opt\graalvm-ce-java8-20.0.0
org.graalvm.launcher.shell = true
org.graalvm.version = 20.0.0
os.arch = amd64
os.name = Windows 10
os.version = 10.0
path.separator = ;
profiler.home = c:\opt\graalvm-ce-java8-20.0.0\jre\tools\profiler
regex.home = c:\opt\graalvm-ce-java8-20.0.0\jre\languages\regex
smalltalk.home = c:\opt\graalvm-ce-java8-20.0.0\jre\languages\smalltalk
sun.arch.data.model = 64
[...]
sun.boot.library.path = C:\opt\graalvm-ce-java8-20.0.0\jre\bin
sun.cpu.endian = little
sun.cpu.isalist = amd64
sun.desktop = windows
sun.io.unicode.encoding = UnicodeLittle
sun.java.command = de.hpi.swa.graal.squeak.launcher.GraalSqueakLauncher --polyglot --code String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000 GraalSqueak-1.0.0-rc7.image
[...]
<= System Properties ===================================
</pre>


## <span id="footnotes">Footnotes</span>

<a name="footnote_01">[1]</a> ***Squeak image*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</p>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/March 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[graalvm]: https://www.graalvm.org/
[keisan]: https://keisan.casio.com/calculator
[squeak]: https://squeak.org/
[squeak_guide]: https://wiki.squeak.org/squeak/5699
[wiki_fibonacci]: https://wiki.squeak.org/squeak/1481
[wiki_logarithm]: https://en.wikipedia.org/wiki/Logarithm
