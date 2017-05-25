<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!-- vim: set sts=2 ai expandtab: -->

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX  (XeTeX focused)
    ############################################################################ -->

  <xsl:param name="xetex.font">
    <!-- Set Western font: XeTeX default seems Latin Modern (LM) Family of Fonts -->
      <!-- Depends: lmodern, tipa -->

    <!-- Nimbus: Original Adobe PostScript looks-alike -->
      <!-- Origin:  URW++  -->
      <!-- Depends: gsfonts -->
      <!-- Note:    missing some odd codes, mono is thin -->
    <!--
    <xsl:text>\setmainfont{Nimbus Roman No9 L}&#10;</xsl:text>
    <xsl:text>\setsansfont{Nimbus Sans L}&#10;</xsl:text>
    <xsl:text>\setmonofont{Nimbus Mono L}&#10;</xsl:text>
    -->

    <!-- DejaVu: Extended coverage Bitstream Vera Fonts -->
      <!-- Origin:  GNOME, https://dejavu-fonts.github.io/  -->
      <!-- Depends: fonts-dejavu -->
      <!-- Note:    mainly for computer screens, too big and spaced -->
    <!--
    <xsl:text>\setmainfont{DejaVu Serif}&#10;</xsl:text>
    <xsl:text>\setsansfont{DejaVu Sans}&#10;</xsl:text>
    <xsl:text>\setmonofont{DejaVu Sans Mono}&#10;</xsl:text>
    -->

    <!-- Liberation: Extended coverage MS (monotype) fonts looks-alike -->
      <!-- Origin:  Red Hat, https://pagure.io/liberation-fonts -->
      <!-- Depends: fonts-liberation2  -->
      <!-- License: SIL -->
      <!-- Note:    Best looking -->
    <xsl:text>\setmainfont{Liberation Serif}&#10;</xsl:text>
    <xsl:text>\setsansfont{Liberation Sans}&#10;</xsl:text>
    <xsl:text>\setmonofont{Liberation Mono}&#10;</xsl:text>

    <!-- GNU FreeFont: Extended coverage Adobe PostScript looks-alike -->
      <!-- Origin:  GNU, https://www.gnu.org/software/freefont -->
      <!-- Depends: fonts-freefont-otf  -->
      <!-- License: GPL3+ font_exception -->
      <!-- Note:    Best looking -->
    <!--
    <xsl:text>\setmainfont{FreeSerif}&#10;</xsl:text>
    <xsl:text>\setsansfont{FreeSans}&#10;</xsl:text>
    <xsl:text>\setmonofont{FreeMono}&#10;</xsl:text>
    -->

    <!-- Only non-latin chars seem to use \setCJK*font settings -->
    <xsl:text>\usepackage{xeCJK}&#10;</xsl:text>
    <xsl:choose>
      <xsl:when test="$lingua = 'zh-cn'">
	<!-- zh_CN centric: main=Serif CJK Arphic+文泉-->
          <!-- Depends: fonts-arphic-gbsn00lp -->
          <!-- Depends: fonts-wqy-zenhei -->
        <!--
        <xsl:text>\setCJKmainfont{AR PL SungtiL GB}&#10;</xsl:text>
        <xsl:text>\setCJKsansfont{WenQuanYi Zen Hei}&#10;</xsl:text>
        <xsl:text>\setCJKmonofont{WenQuanYi Zen Hei Mono}&#10;</xsl:text>
        -->
	<!-- zh_CN centric: main=Sans CJK, Google Droid derivative--> 
          <!-- Depends: fonts-wqy-microhei -->
	<xsl:text>\setCJKmainfont{WenQuanYi Micro Hei}&#10;</xsl:text>
	<xsl:text>\setCJKsansfont{WenQuanYi Micro Hei}&#10;</xsl:text>
	<xsl:text>\setCJKmonofont{WenQuanYi Micro Hei Mono}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$lingua = 'zh-tw'">
        <!-- zh_TW centric:  main=Serif CJK Arphic+文泉 -->
          <!-- Depends: fonts-arphic-bsmi00lp -->
          <!-- Depends: fonts-wqy-zenhei -->
        <!--
        <xsl:text>\setCJKmainfont{AR PL Mingti2L Big5}&#10;</xsl:text>
        <xsl:text>\setCJKsansfont{WenQuanYi Zen Hei}&#10;</xsl:text>
        <xsl:text>\setCJKmonofont{WenQuanYi Zen Hei Mono}&#10;</xsl:text>
        -->
	<!-- zh_TW centric: main=Sans CJK, Google Droid derivative--> 
          <!-- Depends: fonts-wqy-microhei -->
	<xsl:text>\setCJKmainfont{WenQuanYi Micro Hei}&#10;</xsl:text>
	<xsl:text>\setCJKsansfont{WenQuanYi Micro Hei}&#10;</xsl:text>
	<xsl:text>\setCJKmonofont{WenQuanYi Micro Hei Mono}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$lingua = 'ko'">
        <!-- ko centric:  -->
          <!-- Depends: fonts-unfonts-core -->
        <xsl:text>\setCJKmainfont{UnBatang}&#10;</xsl:text>
        <xsl:text>\setCJKsansfont{UnDotum}&#10;</xsl:text>
        <xsl:text>\setCJKmonofont{UnDotum}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- This includes English etc. (English original text has my name in Japanese -->
        <!-- ja centric: Older IPA, main=serif --> 
          <!-- Depends: fonts-ipafont -->
        <!--
        <xsl:text>\setCJKmainfont{IPAPMincho}&#10;</xsl:text>
        <xsl:text>\setCJKsansfont{IPAPGothic}&#10;</xsl:text>
        <xsl:text>\setCJKmonofont{IPAGothic}&#10;</xsl:text>
        -->
        <!-- ja centric: Newer IPA, main=serif --> 
          <!-- Depends: fonts-ipaexfont -->
        <!--
        <xsl:text>\setCJKmainfont{IPAexMincho}&#10;</xsl:text>
        <xsl:text>\setCJKsansfont{IPAexGothic}&#10;</xsl:text>
        <xsl:text>\setCJKmonofont{IPAexGothic}&#10;</xsl:text>
        -->
        <!-- ja centric:  main=sans -->
          <!-- Depends: fonts-vlgothic -->
	<xsl:text>\setCJKmainfont{VL PGothic}&#10;</xsl:text>
	<xsl:text>\setCJKsansfont{VL PGothic}&#10;</xsl:text>
	<xsl:text>\setCJKmonofont{VL Gothic}&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

</xsl:stylesheet>

<!--
= Asian font basics =

NOTE: This is slightly outdated

== Sanserif ==
  simplified Chinese: 黑体 hēi tǐ
    ttf-wqy-zenhei (zh_CN centric)
      WenQuanYi Zen Hei,文泉驛正黑,文泉驿正黑
      WenQuanYi Zen Hei Sharp,文泉驛點陣正黑,文泉驿点阵正黑
      WenQuanYi Zen Hei Mono,文泉驛等寬正黑,文泉驿等宽正黑
  traditional Chinese: 黑體 hēi tǐ 
  Japanese: ゴシック kaku goshikku, gothic
    otf-ipafont-gothic (ja centric)
      IPAGothic,IPAゴシック
      IPAPGothic,IPA Pゴシック

== Serif ==
中国大陆一般称：宋体；台湾香港一般称：明體
  simplified Chinese: 宋体/(明体), Sòngtǐ
    ttf-arphic-gbsn00lp (zh_CN centric)
      AR PL SungtiL GB
  traditional Chinese: (宋體)/明體, Sòngtǐ
    ttf-arphic-bsmi00lp (zh_TW centric)
      AR PL Mingti2L Big5
      (Missing some character in output...)
    ttf-arphic-uming    (zh_TW centric)
      AR PL UMing
       = "AR PL Mingti2L Big5" and "AR PL SungtiL GB" + extra in Taiwan-style
       (BUild failure happened thus not used)
  Japanese: 明朝体, Minchōtai
    otf-ipafont-mincho (ja centric)
      IPAMincho,IPA明朝:style=Regular
      IPAPMincho,IPA P明朝:style=Regular
  Korean: Hangul: 명조체; Hanja: 明朝體; Revised Romanization: Myeongjoche

== Script () ==
  simplified Chinese: 楷书; kǎishū
    ttf-arphic-gkai00mp (zh_CN centric)
      AR PL KaitiM GB
  traditional Chinese: 楷書; kǎishū
    ttf-arphic-bkai00mp (zh_TW centric)
      AR PL KaitiM Big5
    ttf-arphic-ukai     (zh_TW centric)
      AR PL UKai
       = AR PL KaitiM Big5" + "AR PL KaitiM GB" + extra in Taiwan-style
  Japanese: 楷書, kaisho (教科書体)

Korean:
ttf-baekmuk 1st most popular    which contains 4 font families.
                                latex-cjk-xcjk suggest this
      /usr/share/fonts/truetype/baekmuk/dotum.ttf
      /usr/share/fonts/truetype/baekmuk/hline.ttf
      /usr/share/fonts/truetype/baekmuk/gulim.ttf
      /usr/share/fonts/truetype/baekmuk/batang.ttf
      Baekmuk Batang,백묵 바탕:style=Regular       ... serif
      Baekmuk Dotum,백묵 돋움:style=Regular        ... san-serif  medium (print?)
      Baekmuk Gulim,백묵 굴림:style=Regular        ... san-serif  thin   (screen?)
      Baekmuk Headline,백묵 헤드라인:style=Regular ... bold san-serif    (best screen small)
ttf-unfonts-core    2nd popular and increasing
                    made from the HLaTeX's PostScript fonts
                    UnBatang, UnDotum, Ungraphic, Unpilgi, and UnGungseo
      UnBatang  ... serif
      UnDotum   ... san-serif
      UnGungseo ... Kai/kaisho
                    latex-cjk-xcjk uses UnBatang as example
ttf-alee    3rd most popular    many fonts by alee
ttf-nanum                       Myeongjo and Gothic Korean font families/screen font
ttf-nanum-coding                Korean fixed width font family

encoding names:
  * GB2312, GBK or GB18030: Simplified Chinese
  * Big5:                   Traditional Chinese
-->

