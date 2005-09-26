# this code is written in Unicode/UTF-8 character-set
# including Japanese letters.

use strict;
use warnings;

use Test::More tests => 13;

BEGIN {
    use_ok( 'Text::ETSV' )
};

########################################################################
# function etsv_encode(%param) and etsv_decode($row)

my %param = (
    name    => 'Masanori HATA'           ,
    mail    => 'lovewing@dream.big.or.jp',
    sex     => 'male'                    ,
    birth   => '2005-09-26'              ,
    nation  => 'Japan'                   ,
    pref    => 'Saitama'                 ,
    city    => 'Kawaguchi'               ,
    tel     => '+81-48-2XX-XXXX'         ,
    fax     => '+81-48-2XX-XXXX'         ,
    job     => 'student'                 ,
    role    => 'president'               ,
    hobby   => 'exaggeration'            ,
);

$param{'message'} = <<'EOF';
Enhanced TSV とは、TSV (Tab Separated Values) を拡張enhanceした表データのフォーマットという意味で名付けてみました。

巷には、表計算ソフトの表データの標準的なフォーマットとして、CSV (Comma Separated Values) によるものの方が目立ちますが、TSV そのものは、原理的に単にデータ項目の区切り文字delimiterとして“,”（comma）の代わりに [Tab] を用いるというだけの違いに過ぎません。ですから両者の置換は技術的に極めて容易ですから、表計算ソフトでは、CSV 以外にも TSV での表データの入出力に対応している場合が普通です。

CSV にしても TSV にしても、あまりにも原始的なフォーマットのため、これらの拡張方法に関しても、特にこれといった標準的規格defacto standardは存在しないようです。CSV では、“,”を区切り文字として用いているため、それをデータ内容として用いるために、さらに各データ項目を“"”（double quote）で囲むというようなやり方で拡張しているのが普通です。ところが、さらに区切り文字の“,”をデータ内容として使うために、“"”を新たな区切り文字として使ってしまうため、今度はデータ内容に“"”を使いたい場合に、“"”を 2 回重ねて“""”という形で示すなどというような、あまりスマートではないやり方となっています。

僕は個人的に、[Tab] を用いた方が、データファイルを人間が直接テキストファイルとして眺めた場合に直観的で美しいという点で CSV よりも好きでした。そもそも [Tab] という ASCII 文字は、“,”のような人間の自然言語の表記に使うための文字ではなく、コンピュータが理解するための制御文字であり、本来的に表tableの項目column移動ボタンのために使われていたものです。人間が読むための文章の字下げindent整形用よりもむしろ、表データの区切りにこそ使うために存在する文字だと言えます。人間側が、データ内容として“,”を使いたいような場面は多いと思いますが、一方、[Tab] を使いたいような場面は少ないでしょうから、合理的な発想だと言えるはずです。

etsv-escape

原理的には、TSV そのものは CSV の区切り文字の“,”の代わりに [Tab] を用いただけということになりますから、[Tab] 自体をデータ内容として使いたい場合には、CSV の場合と同じく、拡張的な方法によって工夫する必要が生じます。そこで、TSV をフォーマット的に拡張するに当たって、CSV が従来行ってきたような拡張方法（要するに、“"”で囲むやり方）とは、ちょっと違った、より賢い（と僕が主観的に判断した）やり方で対処したいと思いました。

そのやり方は、Web の uri-escape の方法を応用するものです。uri-escape では、区切り文字等に使用する予約文字を %HH のスタイルの、ASCII コード番号に変換するやり方でエスケープして対処しています。% は、それがエスケープされた文字の始まりであることを示すトークン文字であり、HH は 00 ～ FF の 2 桁の十六進数を示しています。予約文字と、エスケープでトークン文字として使用する % 自身をエスケープの対象として考えればいいということになります。

uri-escape においては、対象とする予約文字がそれなりに多いのですが、TSV について考えるとき、わずかな予約文字だけを頭に入れればいいことになります。まずエスケープでトークン文字として使用する % 自身、そしてデータの行ごとの区切りを示す改行文字、最後に各データ行内のデータ項目の区切りを示す [Tab] ということになります。

改行文字は、歴史的な理由から、プラットフォームによって Unix: [LF]; Macintosh: [CR]; Windows: [CR][LF] という風にバリエーションがありますから、ともかく [CR] と [LF] の両方をそれぞれエスケープの対象とする必要があるということになります。

さらに、後述するもう一つの拡張要素である属性名の実現のために、= もエスケープの対象とします。

以上をまとめると、etsv-escape の対象となる文字は、[CR], [LF], [Tab], =, % の 5 文字であり、それぞれの文字は、ASCII コード番号に従って %0D, %0A, %09, %3D, %25 へと変換されます。

属性名

もうひとつの Web から借りてきたアイデアとして、各データ項目を name=value のペアとして表すというやり方です。従来の表データでは、データ項目の並んでいる列の位置で、各項目の種類を決定するやり方が一般的です。しかし、このやり方がスマートでないと思うのは、各項目の種類を示すのに、わざわざ「ヘッダ」のような部分を作って表データファイルの先頭に書いたりするので、ファイルの読み込み方法をヘッダ部分とデータ内容部分とで分ける必要があるという、不整合性を孕む点です。

また、物理的に項目の位置だけで、そのデータの属性を決定してしまうので、とうてい論理的なやり方だとは言えません。このため、データの項目数を一列増やそうとしただけで、かなり低レベル（劣っているという意味ではなく、ハードディスクのローレベル・フォーマットのような用語をイメージして下さい）な、ファイルの読み込みルーチンを直接書き換えるような作業を必要とされることになります。

そこで、各項目を name=value のペアとして表現すれば、そのデータが自分がどの属性のデータであるか、「データが自分自身で知っている」という、正しくオブジェクト志向的な扱いを簡単に実現できるので、合理的かつ今風のやり方だと言えると思います。もちろん、name= をすべてのデータ項目に埋め込むことになりますから、多少の容量的なオーバーヘッドは生じますが、それよりもプレ・オブジェクト志向的なパラダイムからの脱却によって享受できる利益の方がはるかに大きいはずです。

さらに、人間が手動で直接データファイルを修正するような場合も、属性との対応が明確で便利です。

具体的な使い方としては、name, value それぞれを etsv-escape して、= でつなげて name=value の形にし、各データ項目をさらに [Tab] で区切ってつなげたものが、データエントリー 1 行となります（これを etsv-encode と呼びます）。各データ項目の属性は各データ項目自身が知っているわけですから、データ項目の並び方の順番は全く気にする必要はありません（もちろん、人間がデータファイルを見たときの見た目の美しさのこだわりとして、気にしても構いません）。データエントリーの 1 行目と 2 行目で並び方が食い違っていたとしても構わないわけです。例えば、下のような形になります：

name1=value1[tab]name2=value2[tab]name3=value3[tab]...[改行]
name1=value1[tab]name2=value2[tab]name3=value3[tab]...[改行]
(...)

Perl で扱う場合には、ハッシュデータとして、すなわちハッシュの（name を）「キー」と（value を）「値」として入力すれば、簡単に利用できるので便利です。

その他

拡張子を特に使うとしたら、「.tsv」でいいでしょう。実質はテキストファイルですので、「.txt」でも構わないと思います。
EOF

my $got = etsv_encode(%param);

my %param2 = etsv_decode($got);

is($param2{'name'}, $param{'name'},
    'etsv_encode() then etsv_decode() part1');
is($param2{'sex'}, $param{'sex'},
    'etsv_encode() then etsv_decode() part2');
is($param2{'birth'}, $param{'birth'},
    'etsv_encode() then etsv_decode() part3');
is($param2{'nation'}, $param{'nation'},
    'etsv_encode() then etsv_decode() part4');
is($param2{'pref'}, $param{'pref'},
    'etsv_encode() then etsv_decode() part5');
is($param2{'city'}, $param{'city'},
    'etsv_encode() then etsv_decode() part6');
is($param2{'tel'}, $param{'tel'},
    'etsv_encode() then etsv_decode() part7');
is($param2{'fax'}, $param{'fax'},
    'etsv_encode() then etsv_decode() part8');
is($param2{'job'}, $param{'job'},
    'etsv_encode() then etsv_decode() part9');
is($param2{'role'}, $param{'role'},
    'etsv_encode() then etsv_decode() part10');
is($param2{'hobby'}, $param{'hobby'},
    'etsv_encode() then etsv_decode() part11');
is($param2{'message'}, $param{'message'},
    'etsv_encode() then etsv_decode() part12');
