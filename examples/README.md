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
C:\opt\graalvm-ce-java8-19.3.0.2\bin\graalsqueak.cmd
&nbsp;
<b>&gt; graalsqueak --code "6 log - (2 log + 3 log)" images\GraalSqueak-1.0.0-rc6.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 19.3.0.2 (Graal-compiled)...
[graalsqueak] Image loaded in 3833ms.
Preparing image for headless execution...
[graalsqueak] Evaluating '6 log - (3 log + 2 log)'...
[graalsqueak] Result: <b>-1.1102230246251565E-16</b>
</pre>

We observe that the result is *not* equal to zero due to limited precision in floating-point operations. By contrast, executing `log(6) - (log(2) + log(3))` in the [ke!san Online Calculator][keisan] returns `0` as an answer.

<!--
<b>&gt; graalsqueak --code "3 raisedTo: 32" images\GraalSqueak-1.0.0-rc6.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 19.3.0.2 (Graal-compiled)...
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
<b>&gt; graalsqueak --code "1 tinyBenchmarks" images\GraalSqueak-1.0.0-rc6.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 19.3.0.2 (Graal-compiled)...
[graalsqueak] Image loaded in 3358ms.
Preparing image for headless execution...
[graalsqueak] Evaluating '1 tinyBenchmarks'...
[graalsqueak] Result: 10,000,000,000 bytecodes/sec; 150,000,000 sends/sec
</pre>

## <span id="system_reporter">System Reporter</span>

This Squeak code displays the user environment variables including the Java system properties of our [GraalVM] environment:

<pre style="font-size:80%;">
<b>&gt; graalsqueak --code "String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000" GraalSqueak-1.0.0-rc6.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 19.3.0.2 (Graal-compiled)...
[graalsqueak] Image loaded in 3031ms.
Preparing image for headless execution...
[graalsqueak] Evaluating 'String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000'...
platform sources revision ilt on Nov 12 2019 22:08:49 CET
OpenJDK 64-Bit GraalVM CE 19.3.0.2 (build 25.232-b07-jvmci-19.3-b06; mixed mode)
GRAAL_VERSION=19.3.0.2
GRAAL_HOME=C:\opt\graalvm-ce-java8-19.3.0.2
&nbsp;
== System Properties =================================>
R.home = C:\opt\graalvm-ce-java8-19.3.0.2\jre\languages\R
awt.toolkit = sun.awt.windows.WToolkit
chromeinspector.home = C:\opt\graalvm-ce-java8-19.3.0.2\jre\tools\chromeinspector
file.encoding = Cp1252
file.encoding.pkg = sun.io
file.separator = \
graalvm.home = C:\opt\graalvm-ce-java8-19.3.0.2
graalvm.version = 19.3.0.2
[...]
sun.boot.library.path = C:\opt\graalvm-ce-java8-19.3.0.2\jre\bin
sun.cpu.endian = little
sun.cpu.isalist = amd64
sun.desktop = windows
sun.io.unicode.encoding = UnicodeLittle
sun.java.command = de.hpi.swa.graal.squeak.launcher.GraalSqueakLauncher --polyglot --code String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000 GraalSqueak-1.0.0-rc6.image
sun.java.launcher = SUN_STANDARD
sun.jnu.encoding = Cp1252
sun.management.compiler = HotSpot 64-Bit Tiered Compilers
sun.os.patch.level =
sun.stderr.encoding = cp850
sun.stdout.encoding = cp850
user.country = CH
user.dir = K:\examples
user.home = %USERPROFILE%
user.language = fr
user.name = %USERNAME%
user.script =
user.timezone = Europe/Berlin
user.variant =
<= System Properties ===================================
</pre>


## <span id="footnotes">Footnotes</span>

<a name="footnote_01">[1]</a> ***Squeak image*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/January 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[graalvm]: https://www.graalvm.org/
[keisan]: https://keisan.casio.com/calculator
[squeak]: https://squeak.org/
[squeak_guide]: https://wiki.squeak.org/squeak/5699
[wiki_fibonacci]: http://wiki.squeak.org/squeak/1481
[wiki_logarithm]: https://en.wikipedia.org/wiki/Logarithm
