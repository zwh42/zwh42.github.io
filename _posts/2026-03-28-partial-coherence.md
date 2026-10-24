---
layout: post
read_time: true
show_date: true
title: "部分相干与照明形状：从衍射级次到源掩膜优化"
date: 2026-03-28 22:41:13 +0800
tags: [光刻, 部分相干, 照明, SMO]
author: 端点星日志
description: "从互相干性与 Abbe 源点求和出发，推导离轴照明的频谱移位、双光束成像、Hopkins TCC 与 SMO 的约束及局限。"
source_url: "https://mp.weixin.qq.com/s/mhlnUuVk1ZF27v8BnTiK2Q"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

*2026-10-25 修订 · [计算光刻阅读路线](/lithography/)*

同样的波长、数值孔径和掩膜，换一种照明形状，晶圆上的空中像就可能明显变化。某种照明能改善竖直密集线，却让横线或孤立孔变差。原因并不是“光更亮了”，而是**入射方向决定了掩膜衍射级次相对投影瞳的位置，也决定了哪些场分量能够形成有用干涉**。

理解这一点，需要把两个概念分开：不同源点之间如何进行统计叠加，以及单个源点内部的衍射级次如何干涉。把它们统称为“干涉强弱”，容易在照明、相干性和对比度之间建立错误对应。

## 1. 部分相干不是把干涉开关调到一半

相干性描述两个位置的电场是否具有稳定的统计相关关系。对准单色场，在同一时刻的互强度可以写成

$$
J(\mathbf r_1,\mathbf r_2)
=\langle E(\mathbf r_1)E^*(\mathbf r_2)\rangle,
$$

归一化后得到复相干度

$$
\mu(\mathbf r_1,\mathbf r_2)
=\frac{J(\mathbf r_1,\mathbf r_2)}
{\sqrt{I(\mathbf r_1)I(\mathbf r_2)}}.
$$

$\lvert\mu\rvert=1$ 对应完全相关；$\mu=0$ 表示这两个位置的交叉项在平均后消失。相干度依赖位置对，通常不是整个掩膜上一个统一的标量。Hopkins 的部分相干成像理论，正是用统计相关量把物、照明和光学系统连接起来。[1](#ref-1)

光源的时间相干性与空间相干性也不同。窄带光可以有较长的时间相干长度，但经过扩展源和照明光学之后，掩膜上不同位置的空间相关性仍然有限。因此，不能仅从“光刻用激光”推断掩膜上是完全空间相干照明。

## 2. σ 是源尺寸参数，不是普遍的相干度

对于常规居中圆形照明，常用

$$
\sigma=\frac{NA_{\rm ill}}{NA_{\rm proj}}.
$$

以下 $\lambda$ 均取真空波长，空间频率以每单位长度的周期数计。分子与分母必须换算到同一物方或像方，不能把掩膜侧的照明 NA 与晶圆侧的投影 NA 不经倍率换算直接相除。用统一的像方频率坐标，令投影瞳半径 $f_c=NA/\lambda$，则圆源半径是 $\sigma f_c$。[2](#ref-2)

当圆源收缩到中心点，$\sigma\to0$，接近单方向的空间相干照明；当源扩展，某些掩膜位置对的相关性降低。但是 **$\sigma=1$ 并不对任意物体严格等价于完全非相干成像**。它只说明源的角度半径与投影孔径的半径相等。完全非相干是物面互强度趋于局域化的理想极限，不能单凭一个有限源半径定义。[2](#ref-2)

对于环形源，还需要 $\sigma_{\rm in}$ 与 $\sigma_{\rm out}$；对于偶极或自由形状源，需要极点位置、方向、大小和权重。具有同一外半径的源，可能产生完全不同的成像结果。

## 3. Abbe 方法：每个源点相干，源点之间加强度

在 Köhler 照明的常用模型下，把扩展源离散成互不相干的源点。每个源点在掩膜上提供一个入射方向；先计算这个方向照明下的相干像，再将强度按源权重相加。[3](#ref-3)

设 $m(\mathbf r)$ 是折算到晶圆侧的薄掩膜复透过率，$\widetilde m$ 是其频谱，$\mathbf s$ 是入射方向对应的空间频率，$P$ 是包含振幅、离焦与像差的复瞳。忽略对强度没有影响的整体相位，可写成

$$
E_{\mathbf s}(\mathbf r)=
\int\widetilde m(\mathbf f)P(\mathbf f+\mathbf s)
 e^{i2\pi\mathbf f\cdot\mathbf r}\,d\mathbf f,
$$

$$
I(\mathbf r)=\int S(\mathbf s)
|E_{\mathbf s}(\mathbf r)|^2\,d\mathbf s,
\qquad S(\mathbf s)\geq0.
$$

单个源点产生的零级、一级等衍射场之间有交叉项，因此能够干涉；不同源点之间按这里的统计假设没有交叉项。因此，一般不能把最后一式改成 $\lvert\int \sqrt S E_{\mathbf s}\,d\mathbf s\rvert^2$。

部分相干并不是某个源点的衍射级次“只干涉一部分”。它来自对许多不同照明条件下的相干强度图进行平均；这些图中的条纹位置、对比度和频率组合可能不同，平均之后便出现不同的边缘响应。

## 4. 离轴照明为什么能收集更高的掩膜频率

对一维周期 $p$ 的线栅，衍射级次位于

$$
f_n=s+\frac np.
$$

级次进入投影瞳的条件是 $\lvert f_n\rvert\leq f_c$。正入射 $s=0$ 时，零级位于瞳中心；若 $1/p>f_c$，两个一级都在瞳外，只有零级不能构成线栅强度调制。

现在把光源移动到负方向。零级和正一级会同时向负方向平移，其中正一级可能进入瞳内。**照明改变了频谱相对瞳的位置，并没有把镜头孔径变大。** Mack 的离轴照明教学文正是从这个级次几何解释其收益与方向性。[4](#ref-4)

对于半径 $\sigma f_c$ 的居中圆源，可能被某个源点移入瞳的掩膜频率支撑并集，可延伸到

$$
f_{\rm mask,support}=(1+\sigma)\frac{NA}{\lambda}.
$$

这是支撑几何关系，而不是所有图形共有的单一强度传递函数。支撑内的频率可能只有极少光源权重能够接收，也可能找不到足够强的另一级与它干涉。部分相干下从某类边缘响应测出的“表观 OTF”，也不一定能够代表其他物体；Shakeri 等的研究专门讨论了这一限制。[6](#ref-6)

## 5. 一个数值例子：双光束为什么改善密集线

取 $\lambda=193\,\mathrm{nm}$、$NA=1.35$、目标周期 $p=80\,\mathrm{nm}$。所有尺寸仍以晶圆侧定义。这是用于复算的理想例子，不是某种量产配方。

瞳半径 $f_c\approx0.00699\,\mathrm{nm}^{-1}$，线栅基频为 $1/p=0.0125\,\mathrm{nm}^{-1}$。正入射时一级落在瞳外。若选择

$$
s=-\frac{1}{2p},\qquad \frac{s}{f_c}\approx-0.894,
$$

零级与正一级就分别位于 $-0.894f_c$ 和 $+0.894f_c$，均落在瞳内。两束场的形式为

$$
E(x)=b_0+b_1e^{i2\pi x/p},
$$

$$
I(x)=|b_0|^2+|b_1|^2+
2\operatorname{Re}\left(b_0b_1^*e^{-i2\pi x/p}\right).
$$

强度因此具有周期 $p$ 的调制。理想双光束对比度为

$$
C=\frac{2|b_0b_1|}{|b_0|^2+|b_1|^2}.
$$

两个振幅相等时才能达到 1；“收到两个级次”并不保证满对比度。若为 50% 占空比的理想二值振幅线栅，零级振幅为 $1/2$，一级大小为 $1/\pi$，且两级瞳透过率相同，则该式给出约 $0.906$。掩膜相位、三维效应、偏振和有限源大小都会改变这个理想结果。

把两个级次布置在相同瞳半径还有另一层意义：在近轴离焦相位只依赖半径平方的模型中，它们获得相同离焦相位，条纹对比度可以较稳定。这解释了某些双光束配置的焦深优势，不能把它外推为对任意图形、任意像差都不敏感。[4](#ref-4)

## 6. 环形、偶极和四极分别在选择什么

![常规、环形和多极照明的示意图](/assets/images/references/illumination-shapes.png)

*图：EUV illumination shapes。作者 Guiding light，2017；来源为 [Wikimedia Commons 文件页](https://commons.wikimedia.org/wiki/File:EUV_illumination_shapes.png)，采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可；此处未修改。图示用于比较照明形状，不表示本文数值例子的具体源设置。*

常规圆源在中心附近分配光能；环形源去掉中心部分，使较大入射角获得更高相对权重；偶极源把能量集中在两个相对方向；四极源同时给两组方向提供支持。这些变化会改变参与干涉的级次组合，不能简单排成一个从差到好的序列。

对沿 $y$ 方向延伸的竖直线，主要周期变化在 $x$ 方向，所以有用的离轴位移应沿 $x$ 方向。将这种偶极照明旋转 90°，对同一线栅的作用就不同。四极源常被用于同时兼顾正交方向的图形，但它不自动成为接触孔或所有二维结构的最佳照明。[4](#ref-4)

此外，对目标方向无用的源点仍可能送来零级背景，降低合成图像的调制度。有限极点面积意味着其中每个角度的级次位置略有不同；它既关系到传输光量和实际可实现性，也会改变最佳焦点与离焦表现。只用理想点源的结果来评价真实扩展源，通常不够。

## 7. Hopkins TCC：把照明提前积分

把 Abbe 式的模平方展开并交换积分次序，可以定义传递交叉系数：

$$
TCC(\mathbf f,\mathbf g)=\int S(\mathbf s)
P(\mathbf f+\mathbf s)P^*(\mathbf g+\mathbf s)\,d\mathbf s.
$$

于是

$$
I(\mathbf r)=\iint\widetilde m(\mathbf f)\widetilde m^*(\mathbf g)
TCC(\mathbf f,\mathbf g)
 e^{i2\pi(\mathbf f-\mathbf g)\cdot\mathbf r}
\,d\mathbf f\,d\mathbf g.
$$

这是部分相干成像的 Hopkins 表述。[1](#ref-1)[3](#ref-3) 两个频率 $\mathbf f,\mathbf g$ 对应一对参与干涉的掩膜分量，强度调制位于它们的差频。它不是普通的单频率 OTF：一般不能写成 $\widetilde I=H\widetilde m$。

如果光源、NA、离焦和像差固定，TCC 的系统部分可以预计算，随后对许多不同掩膜重复使用。将离散 TCC 做特征分解，还可以得到多个相干模式的加权强度和，从而降低重复计算成本；截断模式数则引入近似误差，需要按目标精度检验。[3](#ref-3)

上述公式仍是标量薄掩膜模型。若掩膜的衍射响应强烈依赖入射角和偏振，不能只用一个固定的二维 $m$ 表示全部源点。高 NA 和 EUV 问题需要检验矢量场、三维掩膜及角度依赖模型的影响。[7](#ref-7)

## 8. 从选择源形状到源掩膜优化

既然 $S$ 决定哪些频率配对获得权重，而 $m$ 决定这些频率的振幅和相位，就有理由联合优化二者。一个示意问题是

$$
\min_{m\in\mathcal M,\,S\in\mathcal S}
\sum_{q\in\mathcal Q}w_q
L\!\left(\mathcal F(m,S;q),C_{\rm tar}\right)
+\alpha R_m(m)+\beta R_S(S).
$$

$\mathcal Q$ 覆盖剂量、离焦和代表性图形；$\mathcal M$ 约束掩膜尺寸及可写性，$\mathcal S$ 约束源的支撑、非负性、极点尺寸和设备可实现性。固定总强度 $\int S=1$ 有助于公平比较光学形状，但真实优化还要考虑可输送功率与曝光吞吐，不能把任意尖锐的数学点源当作无成本资源。

Rosenbluth 等的 2001 年论文已经说明，源可调整会释放新的掩膜自由度，并展示了局部二维图形上的联合优化。[5](#ref-5) 此后可用的目标函数和表示方式更多，但核心困难仍然存在：固定掩膜时，源点强度叠加对 $S$ 是线性的；把胶轮廓、阈值、多个工艺条件和掩膜变量一同加入后，整个问题通常仍是非凸的，交替优化不能保证找到全局最优。

## 9. 从源形状理解掩膜上的空间相关性

在准单色、理想 Köhler 照明及忽略缓慢包络变化的条件下，掩膜面上两个位置之间的互强度，可以从源方向的叠加得到。设两点间隔为 $\Delta\mathbf r$，单个方向引入相位差 $2\pi\mathbf s\cdot\Delta\mathbf r$，对互不相干的源方向取平均，就有

$$
\mu(\Delta\mathbf r)=
\frac{\int S(\mathbf s)e^{i2\pi\mathbf s\cdot\Delta\mathbf r}\,d\mathbf s}
{\int S(\mathbf s)\,d\mathbf s}.
$$

这里用与源频率一致的坐标尺度，表达的是上述理想模型下的空间相关性。它说明源分布与相干性之间是傅里叶关系，而不是“光源越大，每一处的干涉都同比减弱”。源的形状会产生具有方向性的相关结构。[1](#ref-1)[2](#ref-2)

例如在一维示意中，中心点源给出 $\mu=1$；两个位于 $\pm s_0$ 的等强点源给出

$$
\mu(\Delta x)=\cos(2\pi s_0\Delta x).
$$

相关性随点间隔发生振荡，某些间隔的模甚至重新达到 1。这并不违反“两个源点互不相干”的假设：源点之间的统计独立，与掩膜面上两个位置接受同一批源点之后形成的相关性，是不同层次的问题。

这个例子也进一步解释了为什么单独报告 $\sigma$ 不够。圆源、环源和偶极源即使外半径一样，也具有不同的傅里叶变换，因此对不同间距的掩膜位置建立不同相关性。用一个圆源的结论直接替代另一个源形状，可能遗漏决定性的方向与间隔信息。

## 10. SMO 的一个实际难点：局部收益与全局共同条件

在固定掩膜的情况下，记第 $j$ 个源点产生的强度图为 $I_j$，源权重为 $a_j$，则

$$
I=\sum_j a_jI_j,\qquad a_j\geq0.
$$

如果目标仅是一个直接依赖光强的线性量，调整源权重的结构相对简单。但轮廓来自阈值或材料模型，某个源点增加后可能让一侧边缘接近目标、另一侧越界；多个图形同时参与时，收益还可能冲突。采用平均损失，会倾向于帮助数量更多的图形，而未必守住少数最难结构的边界。

因此，可以把关键图形设置为硬约束，或让目标函数更关注最差工艺点。代价是可行集合缩小、优化更困难，甚至需要承认某些布局在共同条件下没有足够窗口。此时应改变布局、掩膜方案或工艺分解，而不是无限追求更奇特的光源。

掩膜变化还会反过来改变各个 $I_j$。固定源做一次 OPC，再固定掩膜改一次源，是合理的交替思路；但前一步修正后，后一步所面对的频谱已经变化，结果可能依赖初始条件。对不同起点进行比较、保留制造约束并在未优化过的图形上验证，比只报告一次局部收敛的最小误差更能说明方法是否可用。[5](#ref-5)

实际全层设计还存在空间尺度差异：掩膜可以在许多局部位置采用不同修正，而曝光照明通常需要服务于更大区域的一组图形。每个局部块各自最优的源，不一定能组合成一个共同可用的源。由此可见，SMO 的挑战不仅是多一个变量，还在于这些变量具有不同的作用范围和共享约束。

## 11. 怎样评价一种照明确实更好

评价必须回到一组明确任务：哪些间距、方向、孤立或密集结构需要共同打印？是否在相同剂量与功率约定下比较？名义 EPE 降低时，局部 NILS 和离焦表现有没有恶化？辅助图形是否误打印？多个图形的可用窗口是否还有交集？

源优化并不是增加镜头的物理孔径，而是在既定孔径内，更有目的地分配入射方向。部分相干理论则提供了计算这种分配如何影响干涉与强度的语言。它们的价值，最终要由目标图形的轮廓、工艺窗口及制造约束共同确认。

## 参考文献

<span id="ref-1"></span>**[1]** Hopkins, H. H. “On the diffraction theory of optical images.” *Proceedings of the Royal Society of London. Series A*, 217(1130), 408–432, 1953. [DOI: 10.1098/rspa.1953.0071](https://doi.org/10.1098/rspa.1953.0071)。访问日期：2026-10-25。

<span id="ref-2"></span>**[2]** Kirchauer, H. *Photolithography Simulation*. Doctoral dissertation, TU Wien, 1998，§2.3.3 “Partial Coherence and Advanced Apertures”。[大学原文](https://iue.tuwien.ac.at/phd/kirchauer/node21.html)。访问日期：2026-10-25。

<span id="ref-3"></span>**[3]** Kirchauer, H. *Photolithography Simulation*. Doctoral dissertation, TU Wien, 1998，§4.3.1–4.3.2。[Abbe’s Method](https://www.iue.tuwien.ac.at/phd/kirchauer/node61.html)；[Hopkins’ Method](https://www.iue.tuwien.ac.at/phd/kirchauer/node62.html)。访问日期：2026-10-25。

<span id="ref-4"></span>**[4]** Mack, C. A. “Off-Axis Illumination.” *The Lithography Expert / Microlithography World*, August 2003, Tutor 42. [作者公开 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR42%20%28Aug%2003%29.pdf)。访问日期：2026-10-25。

<span id="ref-5"></span>**[5]** Rosenbluth, A. E.; Bukofsky, S. J.; Hibbs, M. S.; Lai, K.; Molless, A. F.; Singh, R. N.; Wong, A. K. K. “Optimum mask and source patterns to print a given shape.” *Proceedings of SPIE*, 4346, 486–502, 2001. [DOI: 10.1117/12.435748](https://doi.org/10.1117/12.435748)；[作者机构书目与摘要](https://hub.hku.hk/handle/10722/54040)。访问日期：2026-10-25。

<span id="ref-6"></span>**[6]** Shakeri, S. M.; van Vliet, L. J.; Stallinga, S. “Impact of partial coherence on the apparent optical transfer function derived from the response to amplitude edges.” *Applied Optics*, 56(12), 3518–3530, 2017. [DOI: 10.1364/AO.56.003518](https://doi.org/10.1364/AO.56.003518)。访问日期：2026-10-25。

<span id="ref-7"></span>**[7]** Mack, C. A. *Fundamental Principles of Optical Lithography: The Science of Microfabrication*. Wiley, 2007，第 2–3 章。[DOI: 10.1002/9780470723876](https://doi.org/10.1002/9780470723876)。访问日期：2026-10-25。
