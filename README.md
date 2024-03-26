# Compiler Mini Matlab
#### Author: [Ng Zheng Jue](https://github.com/xinjue37), [Heng Chia Ying](https://github.com/xinying100), [Lim Yi Jing](https://github.com/yijing0612), [Ong Ming Jie](https://github.com/ethanong98), [Ng Rui Qi](https://github.com/Ruiqi2002), [Tan Hong Guan](https://github.com/tanhg1116)

&emsp;&emsp; Compilers are essential software tools that bridge the gap between high-level programming languages and the low-level machine code executed by computers. They play a crucial role in translating human-readable code into efficient and executable instructions. Given the assignment of developing a compiler, our team has developed a compiler that can perform the same functions as a Matlab software. We have implemented some of the exact same functions from Matlab. Through developing this software, we hope to be able to create a software that is like Matlab and add even more functions into it, being able to easily customize it.

## Wrong format of operation:
|No|Wrong|Output|Correct|
|:-:|:--|:-:|:--|
|1|sin30|Undeclared Identifier !|sin(30)|
|2|tranpose([1 2 3])|The identifier is not a function|transpose([1 2 3])|
|3|mod([1 2; 3 4])|The arguments number are too few, 1. Use 2 arguments.|mod([1 2; 3 4], 3)|

## Operation Involved
&emsp;|-> Let <b> a </b> be constant.<br>
&emsp;|-> Let <b> b </b> be vector.<br>
&emsp;|-> Let <b> c </b> be matrix.<br>
&emsp;|-> Let <b> d </b> be either constant, vector or matrix.

#### <br><b>i ) Arithmetic -- 1 argument </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|+|Addition|d+d|
|2|-|Subtraction|d-d|
|3|*|Multiplication|d*d|
|4|/|Division|d/d|
|5|^|Power|d^d|

#### <br><b>ii ) Modulo -- 2 arguments </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|mod()|Remainder after division|mod(d,n)|

#### <br><b>iii ) Trigonometry -- 1 arguments </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|sin()|Sine in radians|sin(d)|
|2|cos()|Cosine in radians|cos(d)|
|3|tan()|Tangent in radians|tan(d)|
|4|asin()|Inverse sine in radians|asin(d)|
|5|acos()|Inverse cosine in radians|acos(d)|
|6|atan()|Inverse tangent in radians|atan(d)|

#### <br><b>iv ) Rounding -- 1 argument </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|round()|Round to nearest integer|round(d)|
|2|ceil()|Round to nearest integer greater or equal to|ceil(d)|
|3|floor()|Round to nearest integer smaller or equal to|floor(d)|

#### <br><b>v ) Exponents & Logarithms -- 1 argument </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|exp()|Exponential|exp(d)|
|2|log()|Natural logarithm|log(d)|
|3|log10()|Logarithm base 10|log10(d)|
|4|sqrt()|Square root|sqrt(d)|

#### <br><b>vi ) Size & Shapes -- 1 argument </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|length()|Length of largest array dimensions|length(b)<br>length(c)|
|2|size()|Array size|size(b)<br>size(c)|
|3|ndims()|Number of dimensions|ndims(b)<br>ndims(c)|
|4|numel()|Number of elements|numel(b)<br>numel(c)|

#### <br><b>vii ) Transpose, Create & Combine Arrays -- 1,2 arguments </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|transpose()|Transpose vector or matrix|transpose(b)<br>transpose(c)|
|2|horzat()|Concatenate arrays horizontally|horzat(b,b)<br>horzat(c,c)|
|3|verzat()|Concatenate arrays vertically|verzat(b,b)<br>verzat(c,c)|
|4|zeros()|Create arrays of all zeros|zeros(a,a)|
|5|ones()|Create arrays of all ones|ones(a,a)|

#### <br><b>viii ) Reshape -- 3 arguments </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|reshape()|Reshape arrays|reshape(b,a,a)<br>reshape(c,a,a)|

#### <br><b>ix ) Generate Space Vector -- 3 arguments </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|linspace()|Generate a3 number of points in [a1,a2] lineraly|linspace(a1,a2,a3)|
|2|logspace()|Generate a3 number of points in [a1,a2] logarithmically|logspace(a1,a2,a3)|

#### <br><b>x ) Command, Datetime & Calendar -- 0 argument </b>
|No|Function|Explanation|Example|
|:-:|:--|:--|:--|
|1|clc|Clear command window|-|
|2|ans|Most recent answer|-|
|3|datetime|Current date and time|-|
|4|calendar|Current month|-|

