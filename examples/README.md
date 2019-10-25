# <span id="top">GraalSqueak Examples</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://squeak.org/"><img src="https://squeak.org/static/img/balloon.svg" width="120" alt="LLVM"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="./"><b><code>examples\</code></b></a> contains <a href="https://squeak.org/">Squeak</a> examples coming from various websites and books and tested on a Windows machine.
  </td>
  </tr>
</table>

In this document we present the following [Squeak](https://squeak.org/) examples:

- [Logarithmic equation](#log)
- 222
- 333

> **:mag_right:** The [Terse Guide to Squeak](https://wiki.squeak.org/squeak/5699) is included in the Squeak image <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup> and is accessible from the '**Help**' menu of the Squeak IDE.

# <span id="log">Logarithmic equation</span>

Let's take as first example the [logarithmic equation](https://en.wikipedia.org/wiki/Logarithm) *"The logarithm of a product is the sum of the logarithms of the factors"*, i.e. <code>log<sub>b</sub>(x*y) = log<sub>b</sub>(x) + log<sub>b</sub>(y)</code>:

<pre style="font-size:80%;">
<b>&gt; where graalsqueak</b>
C:\opt\graalvm-ce-19.2.1\bin\graalsqueak.cmd
&nbsp;
<b>&gt; graalsqueak --code "6 log - (2 log + 3 log)" images\GraalSqueak-1.0.0-rc4.image</b>
[graalsqueak] Running Squeak/Smalltalk on OpenJDK 64-Bit GraalVM CE 19.2.1 (Graal-compiled)...
[graalsqueak] Image loaded in 3833ms.
Preparing image for headless execution...
[graalsqueak] Evaluating '6 log - (3 log + 2 log)'...
[graalsqueak] Result: <b>-1.1102230246251565E-16</b>
</pre>

We observe that the result is *not* equal to zero due to limited precision in floating-point operations. By contrast, executing `log(6) - (log(2) + log(3))` in the [ke!san Online Calculator](https://keisan.casio.com/calculator) returns `0` as an answer.

# <b><code id="222">222</code></b>

xxxx

<pre style="font-size:80%;">
xxx
</pre>

# <b><code id="333">333</code></b>

xxxx

<pre style="font-size:80%;">
xxx
</pre>


## Footnotes

<a name="footnote_01">[1]</a> ***Squeak image*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
A Squeak image is required to run/test the <a href="https://github.com/hpi-swa/graalsqueak">GraalSqueak</a> installable component. Concretely we can either install the full <a href="https://squeak.org/downloads/">Squeak distribution</a> (32 MB) or we can just download the <a href="https://squeak.org/downloads/">Squeak image</a> (18 MB).
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/October 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
