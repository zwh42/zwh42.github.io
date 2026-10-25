---
layout: post
read_time: true
show_date: true
title: "空中像与边缘敏感度：阈值模型、NILS 和工艺窗口"
date: 2026-03-22 16:56:16 +0800
tags: [光刻, Aerial Image, 光学成像, NILS]
author: 端点星日志
description: "明确空中像与胶内像的区别，用阈值等值线推导边缘位移和 NILS，再连接剂量、离焦、胶化学及随机缺陷。"
source_url: "https://mp.weixin.qq.com/s/k_oYqt0IgiSPEMeqkGAlLg"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

空中像（aerial image）描述投影光学系统在指定像面形成的连续强度分布。它是掩模衍射与材料响应之间的光学接口，光刻胶还需要经过膜内传播、曝光反应、烘烤和显影，才能形成可量测的材料轮廓。[[1]](#ref-1)

在阈值近似下，胶边缘对应强度等值线。对等值线作局部扰动分析，可以把剂量和光学误差映射为边缘位移，并得到归一化图像对数斜率（NILS）与尺寸稳定性的关系。该关系适用于局部非零斜率和连续存在的边缘；胶的三维状态、图形拓扑变化与随机缺陷需要更完整的模型。

## 空中像的定义与归一化

在选定的像面上，空中像是横向坐标的连续函数 $I(x,y)$。扫描不同焦面时，应写成 $I(x,y;z)$。这里的 $z$ 表示离焦位置，不要与随后胶膜内部的深度坐标混淆。

在均匀介质、适当归一化的标量模型中，单一相干照明可写为

$$
I(x,y;z)\propto|E(x,y;z)|^2.
$$

扩展照明则需要对互不相干的源点分别计算强度，再加权求和：

$$
I(\mathbf r;z)=\int S(\mathbf s)
|E_{\mathbf s}(\mathbf r;z)|^2d\mathbf s.
$$

$\mathbf r=(x,y)$ 是像面横向坐标，$\mathbf s$ 标记照明方向，$S(\mathbf s)\ge0$ 为源的强度权重，$E_{\mathbf s}$ 是该源点照明下的复电场。两式中的常数可以吸收到光强归一化里，但归一化约定必须一致。某些软件以无掩膜开口的强度为 1，另一些按入射功率或源权重归一化。比较不同照明的峰值时，如果总功率约定不同，数值并没有直接可比性。高 NA（数值孔径）矢量模型还需要正确处理各分量、偏振与能流，不能不加条件地把一个标量 $E$ 当作全部电磁场。[[1]](#ref-1)[[2]](#ref-2)

空中像通常指尚未加入完整胶膜光学响应的理想像面分布。光进入实际胶层之后，还会吸收，并在胶、抗反射层和基底之间反射、干涉。胶内像需要描述随深度变化的场与吸收能量；它可能具有驻波，也可能受膜厚和基底反射率影响。在胶表面看到的二维空中像，并不能单独决定整层胶的三维曝光状态。[[1]](#ref-1)

<figure class="technical-figure" id="fig-1">
  <div class="figure-image"><a href="/assets/images/wechat/back-to-basics-fitting-01.png" target="_blank" rel="noopener" aria-label="教材中的双光束干涉强度峰谷，在新标签页查看大图"><img src="/assets/images/wechat/back-to-basics-fitting-01.png" alt="教材中的双光束干涉强度峰谷" width="1016" height="560" loading="lazy" decoding="async"></a></div>
  <figcaption markdown="span">图：干涉产生连续的强度峰谷。来源：Konijnenberg、Adam、Urbach，开放教材 [BSc Optics，第 2 版（2024）](https://doi.org/10.59490/tb.91)，图 5.8，书页 125（[原始 PDF 第 130 页](https://books.open.tudelft.nl/home/catalog/download/174/319/559?inline=1#page=130)），采用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可。本图从教材页面裁切，未改图内内容；这里用于解释光场叠加产生强度分布的原理。</figcaption>
</figure>

## 强度分布与曝光剂量

曝光剂量是单位面积接收的时间积分能量，常用 $\mathrm{mJ/cm^2}$。在照明形状、焦点位置和光学状态固定、曝光线性缩放的近似下，可以把局部曝光量写成

$$
Q(x,y)=D\,I(x,y),
$$

其中 $D$ 是全局剂量，$I$ 是按约定归一化的空间分布。这个分离假设很有用：改剂量只是整体乘一个系数，改焦点位置则通常会改变空间分布本身。

但实际扫描曝光、时间变化、膜内漂白和材料非线性，可能使完整过程比这个乘法更复杂。因此，把剂量变化说成“阈值变化”，只是在固定归一化图像中的一种等价表示；物理上改变的首先是送到材料中的曝光能量。

## 阈值模型与胶图形极性

假设有一个有效曝光阈值 $Q_c$，定义高曝光区域的指示函数：

$$
B(x,y)=
\begin{cases}
1,&D\,I(x,y)\geq Q_c,\\
0,&D\,I(x,y)<Q_c.
\end{cases}
$$

其阈值边界满足

$$
I(x,y)=T,\qquad T=Q_c/D.
$$

这是一条等值线，而不是光学系统直接画出的几何边。在正性胶中，高曝光区域通常更易被显影去除；负性胶的保留与去除关系不同。因此，$B=1$ 在这里仅表示“超过有效阈值”，不能不说明胶的极性就称为“留下来的材料”。

阈值模型忽略了深度、反应输运、显影时间及轮廓演化，不能取代胶模型。它的用途是把光学分布和边缘位置之间的关系先讲清楚，并为快速筛查提供一个可以校准的近似。[[1]](#ref-1)

## 边缘位置的一阶扰动

沿一条切线，在目标边缘 $x_e$ 上有

$$
D I(x_e)=Q_c.
$$

现在允许剂量、阈值和图像形状发生小变化，取对数并微分：

$$
\delta\ln D+\delta\ln I\big|_{x_e}
+\left.\frac{\partial\ln I}{\partial x}\right|_{x_e}\delta x_e
=\delta\ln Q_c.
$$

因此

$$
\delta x_e=
\frac{\delta\ln Q_c-\delta\ln D-
\delta\ln I|_{x_e}}
{\partial_x\ln I|_{x_e}}.
$$

这里 $\delta\ln I\rvert_{x_e}$ 表示在原位置处、由焦点位置或其他光学参数造成的图像变化，不包括边缘移动本身。这个公式由本文在阈值模型内直接推得，适用于变化较小、局部斜率非零、边界交点持续存在的情况。

若只变剂量，分子简化为 $-\delta D/D$。局部斜率越小，同样的剂量误差对应越大的边缘位移；若斜率接近零，线性近似也会失效，等值线可能突然消失或改变连接关系。这正是临界打印条件会表现得很不稳定的原因。

对一条左右边界为 $x_L,x_R$ 的特征，

$$
CD=x_R-x_L,\qquad \delta CD=\delta x_R-\delta x_L.
$$

两侧边缘不能不加判断地当作一个边缘处理。它们的斜率符号相反，位移可能让 CD（关键尺寸）的变化相加，也可能同时向一个方向移动而主要造成位置偏移。

## NILS 与剂量敏感度

在预期边缘处定义图像对数斜率，并用名义特征宽度 $w$ 归一化：

$$
NILS=w\left|\frac{\partial\ln I}{\partial x}\right|_{x_e}
=\frac{w}{I(x_e)}
\left|\frac{\partial I}{\partial x}\right|_{x_e}.
$$

本文取绝对值表示稳定性的大小；在记录有向边缘的算法中，也可以保留符号。导数单位是长度的倒数，乘以 $w$ 后 NILS 无量纲。Mack 的原始教学文章特别强调，应在预期胶边缘位置评价，而不是随意寻找曲线上最大的斜率。[[3]](#ref-3)

对左右对称、两侧 NILS 相等、$w=CD$ 的特征，纯剂量小扰动给出

$$
\frac{|\delta CD|}{CD}
\approx\frac{2}{NILS}\left|\frac{\delta D}{D}\right|.
$$

系数 2 来自两个边缘。这个结果解释了 NILS 与曝光裕量的关系，但不应脱离假设使用：真实胶的有限对比度、酸扩散和显影过程，会让从空中像预测的裕量与实际结果不同。[[4]](#ref-4)[[5]](#ref-5)

全局 Michelson 对比度

$$
C=\frac{I_{\max}-I_{\min}}{I_{\max}+I_{\min}}
$$

只依赖全局极值。两幅图像即使具有相同峰谷，也可能在阈值附近具有不同斜率。NILS 在预期边缘位置评价局部响应，与边缘位移直接相关；完整良率分析仍需包含材料响应及随机失效。

## 周期图像的解析算例

考虑本文构造的理想周期图像：

$$
I(x)=I_0\left[1+C\cos\frac{2\pi x}{p}\right],
\qquad 0<C<1.
$$

选阈值 $T=I_0$，亮区边缘在 $x=\pm p/4$，名义宽度 $w=p/2$。代入定义得

$$
NILS=\frac p2\frac{2\pi C}{p}=\pi C.
$$

令 $p=80\,\mathrm{nm}$，所以 $w=40\,\mathrm{nm}$。当 $C=0.8$ 时，NILS 约为 2.51；当 $C=0.3$ 时，约为 0.94。若剂量增加 3%，一阶模型预测高曝光区宽度分别变化约 $0.96\,\mathrm{nm}$ 和 $2.55\,\mathrm{nm}$。两张图在名义剂量下都可以有正确 CD，但对同样的扰动，后者明显更敏感。

上述数值是给定周期模型下的解析结果，用于量化调制度、局部斜率与等值线扰动之间的关系。较大剂量变化应通过重新求解交点处理，一阶近似的精度需要单独检验。

## 二维轮廓的法向响应

复杂版图上的边缘没有统一的 $x$ 方向。此时应沿轮廓的局部法线 $\mathbf n$ 使用

$$
\partial_n I=\nabla I\cdot\mathbf n.
$$

若以 $F(\mathbf r)=DI(\mathbf r)-Q_c$ 定义边界，一阶法向位移满足

$$
\delta r_n\approx-\frac{\delta F}{|\nabla F|}.
$$

这把线端缩短、拐角移动和二维 EPE（边缘放置误差）统一成了等值线扰动问题。但鞍点、极值点附近的 $\lvert\nabla F\rvert$ 很小，局部法线可能不稳定；当两个亮区刚好连起来，变化涉及拓扑，单个边缘位移公式便不足够。桥连和缺孔需要额外检查，而不能被平均 EPE 掩盖。

图像网格也会影响结果。如果像素间距太粗，阈值交点和导数可能主要反映插值误差。工程上应针对关键轮廓做网格与插值收敛检查，而不是看到更多小数位就认为结果更准确。

## 焦点—剂量工艺窗口

离焦可能改变峰谷、局部斜率和最佳阈值交点。它通常并不是简单的整图缩放；因此只在最佳焦面比较 NILS 或 CD，容易漏掉重要风险。

更完整的做法是扫描剂量与焦点位置，得到焦点—剂量矩阵 FEM。固定剂量画 CD 对焦点位置的曲线，就是常见的 Bossung 表示；在二维平面上画出所有满足规格的点，则得到该特征的工艺窗口。规格还可以包含胶厚损失、侧壁角和图形完整性。[[6]](#ref-6)

产品需要多种结构共同合格，所以应取不同图形窗口的交集。对某个密集线优化得很好的照明，如果让孤立线或接触孔的窗口消失，并不能算整体成功。这也解释了 OPC（光学邻近效应修正）与源优化为什么要覆盖多个代表性图形和多个工艺条件。

## 材料响应与附加状态变量

把有效阈值 $Q_c$ 当成常数，等价于把材料响应的许多细节压缩成一个参数。对固定胶配方和窄工艺范围，这可能足以支持快速比较；但若目标是预测烘烤温度、胶厚或显影时间改变后的结果，就需要恢复相应的材料状态。

以化学放大胶为例，吸收光子后生成的反应物分布属于曝光潜像；后曝光烘烤中，反应物迁移、淬灭并催化保护基团变化；显影速率再取决于材料转换程度。即使局部曝光量相同，若邻域提供的反应物输运不同，最终显影行为也可能不同。一个只读取该点光强的固定阈值模型就无法表达这种非局域性。[[1]](#ref-1)[[5]](#ref-5)

深度方向的问题也不能通过多画几条横向切线解决。如果胶顶部充分曝光而底部不足，可能出现底部残胶；顶部与底部轮廓差异很大时，俯视 CD 相同也不表示侧壁角相同。刻蚀关心的是胶剖面能否作为稳定掩膜，因此二维空中像的合格条件与最终转移条件之间，需要明确的材料模型或实验校准。

“有效阈值随工艺改变”可以概括一些现象，却不应变成万能解释。若为了拟合每种图形都设置独立阈值，模型便失去了跨图形预测的能力。更有价值的检验是：用同一套参数，是否能够预测未参与校准的尺寸、间距、方向和离焦条件。

## 空中像的比较条件

比较空中像应固定几何、照明归一化、像面位置和名义剂量。按各自峰值归一化与按开场强度归一化会产生不同的峰值—阈值关系；分别拉伸纵轴适合展示曲线形状，曝光能力比较则需要相同的物理尺度。

固定阈值比较用于评价同一工艺条件下的目标偏差；分别调剂量至相同标称 CD 后比较，则用于评价尺寸校正后的鲁棒性。两种比较的剂量条件不同，应分别报告，避免将剂量校正与光学设计的收益混合。

边缘位置需要注明切线、法线方向和目标宽度，NILS 还需要对应到具体边缘与工艺点。接触孔的径向斜率具有方位依赖，线端与长直边中部也可能具有不同敏感度，局部最大 NILS 不代表整条轮廓的稳定性。

模型误差与计量误差需要分别记录。俯视 SEM 边缘依赖电子成像、轮廓提取和参考高度，未必对应阈值模型的理想边界。若模型输出胶底部轮廓而量测更接近顶部或信号等值线，应先统一观测对象，再判断需要校正的掩模误差。[[1]](#ref-1)

如果结果包含示意图，还应区分教材原理图、本文解析例子和严格仿真输出。干涉峰谷可以说明图像形成的机制，却不能直接读出某个生产层的胶边缘或曝光裕量；用于工程决策的数值必须保留相应的材料、设备与求解条件。

可复现的空中像比较应保存生成条件、归一化、轮廓提取方法和材料模型范围，并分别注明解析近似、仿真和晶圆数据的证据来源。

## 光学指标的适用范围

空中像用于分析辅助图形、照明与离焦对主边缘的影响，提供可与胶响应连接的强度分布和局部斜率。它是光学模型与材料模型之间的接口。

但空中像既不直接给出化学潜像，也不直接给出显影后的三维胶轮廓。相同的平均空中像，在不同胶材料、胶厚、烘烤和显影条件下可以产生不同结果。EUV 情况下，局部吸收和化学物种的随机性还会造成粗糙度及稀有缺陷；确定性的 $I(x,y)$ 和 NILS 本身不包含这些分布尾部。[[1]](#ref-1)[[7]](#ref-7)

空中像给出光学系统提供给材料的空间强度信息。稳定轮廓的形成还依赖胶内传播、化学反应、显影及后续图形转移。失效分析需要根据目标平面和敏感度，将观测偏差归入相应的光学或工艺环节。

## 参考文献

<span id="ref-1"></span>**[1]** Mack, C. A. *Fundamental Principles of Optical Lithography: The Science of Microfabrication*. Wiley, 2007，尤其第 2–7 章。[DOI: 10.1002/9780470723876](https://doi.org/10.1002/9780470723876)。访问日期：2026-10-25。

<span id="ref-2"></span>**[2]** Kirchauer, H. *Photolithography Simulation*. TU Wien, 1998，§4.1.5 “Vector-Valued Extension”、§4.3.1 “Abbe’s Method”。[矢量模型](https://www.iue.tuwien.ac.at/phd/kirchauer/node54.html)；[扩展源强度求和](https://www.iue.tuwien.ac.at/phd/kirchauer/node61.html)。访问日期：2026-10-25。

<span id="ref-3"></span>**[3]** Mack, C. A. “Using the Normalized Image Log-Slope.” *The Lithography Expert*, Winter 2001, Tutor 32. [作者公开 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR32%20%28Winter%2001%29.pdf)。访问日期：2026-10-25。

<span id="ref-4"></span>**[4]** Mack, C. A. “Using the Normalized Image Log-Slope, part 2.” *The Lithography Expert*, Spring 2001, Tutor 33. [作者公开 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR33%20%28Spring%2001%29.pdf)。访问日期：2026-10-25。

<span id="ref-5"></span>**[5]** Mack, C. A. “Using the Normalized Image Log-Slope, part 3.” *The Lithography Expert*, Summer 2001, Tutor 34. [作者公开 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR34%20%28Summer%2001%29.pdf)。访问日期：2026-10-25。

<span id="ref-6"></span>**[6]** Kirchauer, H. *Photolithography Simulation*. TU Wien, 1998，§3.2.1 “Focus Effects and Process Window”。[大学原文](https://www.iue.tuwien.ac.at/phd/kirchauer/node41.html)。访问日期：2026-10-25。

<span id="ref-7"></span>**[7]** Mack, C. A. “Metrics for stochastic scaling in EUV lithography.” *Proceedings of SPIE*, 11147, 111470A, 2019. [DOI: 10.1117/12.2538985](https://doi.org/10.1117/12.2538985)；[作者公开稿](https://lithoguru.com/scientist/litho_papers/2019_Metrics%20for%20stochastic%20scaling%20in%20EUV.pdf)。访问日期：2026-10-25。
