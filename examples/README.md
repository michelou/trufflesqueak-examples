# <span id="top">TruffleSqueak Examples</span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/" rel="external"><img src="../docs/images/balloon.svg" width="120" alt="Sqeak project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="./"><b><code>examples\</code></b></a> contains <a href="https://squeak.org/" rel="external">Squeak</a> code examples coming from various websites and books and tested on a Windows machine.
  </td>
  </tr>
</table>

In this document we present the following [Squeak] code examples:

- [Logarithmic equation](#log)
- [tinyBenchmarks](#tiny_benchmarks)
- [System reporter](#system_reporter)

> **:mag_right:** The [Terse Guide to Squeak][squeak_guide] is included in the Squeak image <sup id="anchor_01"><a href="#footnote_01">1</a></sup> and is accessible from the '**Help**' menu of the Squeak IDE.

## <span id="log">Logarithmic equation</span>

Let's take as first example the [logarithmic equation][wiki_logarithm] *"The logarithm of a product is the sum of the logarithms of the factors"*, i.e. <code>log<sub>b</sub>(x*y) = log<sub>b</sub>(x) + log<sub>b</sub>(y)</code>:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where">where</a> trufflesqueak</b>
C:\opt\graalvm-ce-java11-22.1.0\bin\trufflesqueak.cmd
&nbsp;
<b>&gt; <a href="https://github.com/hpi-swa/trufflesqueak/blob/master/docs/development.md#debugging">trufflesqueak</a> --code "6 log - (2 log + 3 log)"</b>
[trufflesqueak] Running Squeak/Smalltalk on GraalVM CE...
[trufflesqueak] Image loaded in 1390ms.
[trufflesqueak] Preparing image for headless execution...
[trufflesqueak] Evaluating '6 log - (2 log + 3 log)'...
[trufflesqueak] Result: <b>-1.1102230246251565E-16</b>
</pre>

We observe that the result is *not* equal to zero due to limited precision in floating-point operations. By contrast, executing `log(6) - (log(2) + log(3))` in the [ke!san Online Calculator][keisan] returns `0` as an answer.

<!--
<b>&gt; trufflesqueak --code "3 raisedTo: 32" images\TruffleSqueak-20.2.0.image</b>
[trufflesqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 20.3.0 (Graal-compiled)...
[trufflesqueak] Image loaded in 3822ms.
Preparing image for headless execution...
[trufflesqueak] Evaluating '3 raisedTo: 32'...
[trufflesqueak] Result: 1853020188851841
-->

## <span id="tiny_benchmarks">tinyBenchmarks</span>

This micro-benchmark suite is often used to measure and compare the performance of different hardware platforms and Squeak VMs and consists of two benchmarks:
- The first one is bytecode-heavy as it allocates, fills, and reads from a large array.
- The other one is a recursive [Fibonacci][wiki_fibonacci] benchmark and therefore send-heavy

<pre style="font-size:80%;">
<b>&gt; <a href="https://github.com/hpi-swa/trufflesqueak/blob/master/docs/development.md#debugging">trufflesqueak</a> --code "1 tinyBenchmarks"</b>
[trufflesqueak] Running Squeak/Smalltalk on GraalVM CE...
[trufflesqueak] Image loaded in 1544ms.
[trufflesqueak] Preparing image for headless execution...
[trufflesqueak] Evaluating '1 tinyBenchmarks'...
[trufflesqueak] Result: 11,000,000,000 bytecodes/sec; 200,000,000 sends/sec
</pre>

The following command adds compilation tracing; line 1 in the
generated log file `tinyBenchmarks.txt` points to the output directory
containing the corresponding IGV graphs:

<pre style="font-size:80%;">
<b>&gt; <a href="https://github.com/hpi-swa/trufflesqueak/blob/master/docs/development.md#debugging">trufflesqueak</a> --code "1 tinyBenchmarks" \
   --engine.TraceCompilation --vm.Dgraal.Dump=Truffle:1 --log.file=tinyBenchmarks.txt</b>
[...]
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/type">type</a> tinyBenchmarks.txt</b>
Dumping IGV graphs in T:\graal_dumps\2021.01.11.11.46.17.076
[engine] opt done     IdentityDictionary&gt;&gt;scanFor:          |AST  173|Time  610( 523+87  )ms|Tier 2|Inlined   1Y
   0N|IR   802/ 1421|CodeSize   5474|Addr 0x7b20750|Src n/a
[engine] opt done     Magnitude&gt;&gt;min: &lt;split-3927f244&gt;      |AST   26|Time   59(  56+3   )ms|Tier 2|Inlined   0Y
   0N|IR    27/   18|CodeSize    104|Addr 0x79da210|Src n/a
[engine] opt done     SequenceableCollection&gt;&gt;from:to:put:  |AST  220|Time  346( 306+41  )ms|Tier 2|Inlined   1Y
   0N|IR   320/  653|CodeSize   2969|Addr 0x7aaec10|Src n/a
[engine] opt done     Integer&gt;&gt;benchmark                    |AST  253|Time 1575(1523+52  )ms|Tier 2|Inlined   3Y
   0N|IR   643/  931|CodeSize   3735|Addr 0x7d42110|Src n/a
[engine] opt done     Integer&gt;&gt;benchFib                     |AST   88|Time 1640(1548+93  )ms|Tier 2|Inlined   6Y
   8N|IR   661/ 1869|CodeSize   8452|Addr 0x7d3ad10|Src n/a
&nbsp
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> /b graal_dumps\2021.01.11.11.46.17.076</b>
TruffleHotSpotCompilation-2968[IdentityDictionary__scanFor_].bgv
TruffleHotSpotCompilation-3320[Integer__benchmark].bgv
TruffleHotSpotCompilation-3500[SequenceableCollection__from_to_put_].bgv
TruffleHotSpotCompilation-3572[Magnitude__min___split-3927f244_].bgv
TruffleHotSpotCompilation-3611[Integer__benchFib].bgv
</pre>

## <span id="system_reporter">System Reporter</span>

This Squeak code displays the user environment variables including the Java system properties of our [GraalVM] environment:

<pre style="font-size:80%;">
<b>&gt; <a href="https://github.com/hpi-swa/trufflesqueak/blob/master/docs/development.md#debugging">trufflesqueak</a> --code "String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000"</b>
[trufflesqueak] Running TruffleSqueak-22.1.0.image on GraalVM CE (latency mode)...
[trufflesqueak] Image loaded in 3190ms.
[trufflesqueak] Evaluating 'String streamContents: [:s | SystemReporter new reportVM: s] limitedTo: 10000'...
platform sources revision trufflesqueak:c452863571a194b4237947e7063cc11fb7a91e65
built for GraalVM 22.1.0 (Java 11.0.15, windows, amd64)
{trufflesqueak: {commit.committer: Fabio Niephaus <code@fniephaus.com>, commit.committer-ts: 1651559791, commit.rev: c452863571a194b4237947e7063cc11fb7a91e65}}
&nbsp;
== System Properties =================================>
awt.toolkit = sun.awt.windows.WToolkit
chromeinspector.home = C:\opt\graalvm-ce-java11-22.1.0\tools\chromeinspector
coverage.home = C:\opt\graalvm-ce-java11-22.1.0\tools\coverage
dap.home = C:\opt\graalvm-ce-java11-22.1.0\tools\dap
file.encoding = Cp1252
file.separator = \
[...]
java.version = 11.0.15
java.version.date = 2022-04-19
java.vm.compressedOopsMode = Zero based
java.vm.info = mixed mode, sharing
java.vm.name = OpenJDK 64-Bit Server VM
java.vm.specification.name = Java Virtual Machine Specification
java.vm.specification.vendor = Oracle Corporation
java.vm.specification.version = 11
java.vm.vendor = GraalVM Community
java.vm.version = 11.0.15+10-jvmci-22.1-b06
jdk.debug = release
jdk.internal.vm.ci.enabled = true
js.home = C:\opt\graalvm-ce-java11-22.1.0\languages\js
line.separator =
&nbsp;
lsp.home = C:\opt\graalvm-ce-java11-22.1.0\tools\lsp
nfi-libffi.home = C:\opt\graalvm-ce-java11-22.1.0\languages\nfi-libffi
nfi.home = C:\opt\graalvm-ce-java11-22.1.0\languages\nfi
org.graalvm.home = C:\opt\graalvm-ce-java11-22.1.0
[...]
org.graalvm.version = 22.1.0
os.arch = amd64
os.name = Windows 10
os.version = 10.0
path.separator = ;
profiler.home = C:\opt\graalvm-ce-java11-22.1.0\tools\profiler
regex.home = C:\opt\graalvm-ce-java11-22.1.0\languages\regex
smalltalk.home = C:\opt\graalvm-ce-java11-22.1.0\languages\smalltalk
sun.arch.data.model = 64
sun.boot.library.path = C:\opt\graalvm-ce-java11-22.1.0\bin
sun.cpu.endian = little
sun.cpu.isalist = amd64
sun.desktop = windows
sun.io.unicode.encoding = UnicodeLittle
[...]
<= System Properties ===================================
</pre>

## <span id="footnotes">Footnotes</span>

<span id="footnote_01">[1]</span> ***Squeak image*** [↩](#anchor_01)

<dl><dd>
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/trufflesqueak">TruffleSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/May 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[graalvm]: https://www.graalvm.org/
[keisan]: https://keisan.casio.com/calculator
[squeak]: https://squeak.org/
[squeak_guide]: https://wiki.squeak.org/squeak/5699
[wiki_fibonacci]: https://wiki.squeak.org/squeak/1481
[wiki_logarithm]: https://en.wikipedia.org/wiki/Logarithm
