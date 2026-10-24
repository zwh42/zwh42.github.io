---
layout: post
read_time: true
show_date: true
title: "OPC、ILT 与 SMO 的变量、约束及求解范围"
date: 2026-08-14 00:29:50 +0800
tags: [光刻, OPC, ILT, SMO]
author: 端点星日志
description: "以统一前向模型比较 OPC、ILT 和 SMO 的变量、参数化、目标函数、制造约束及验证范围。"
source_url: "https://mp.weixin.qq.com/s/GjLR8b9IgiOAFF2APP8-Fg"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

*2026-10-25 修订 · [计算光刻阅读路线](/lithography/)*

OPC、ILT 和 SMO 从不同角度描述计算光刻中的优化任务。OPC 指向邻近效应补偿，ILT 将掩模综合表述为逆成像问题，SMO 将照明分布纳入联合设计变量。三者可以共享前向模型、损失函数和求导方法，也可以在同一制造流程中组合使用。

分类的依据应包括实际更新的变量、可行几何集合和最终交付物。曲线输出、梯度算法或 GPU 实现均不足以单独确定方法类别。本文以统一的鲁棒优化形式比较三者，并讨论指标、制造约束及全芯片验证对结果解释的影响。

## 统一前向模型与变量集合

设目标晶圆图形为 $T$，掩模为 $M$，照明光源为 $S$，焦点、剂量、像差、材料与工艺条件统称 $\theta$。前向模型是

$$
W=F(M,S;\theta).
$$

$W$ 可以表示空中像、显影后轮廓或刻蚀后轮廓。刻蚀后轮廓更接近最终电路要求，也增加了材料建模和校准成本。各输出平面需要对应的验证数据，空中像误差仅反映图形转移链中的光学部分。[[1]](https://doi.org/10.1002/9780470723876)

一个统一的鲁棒优化形式可以写成

$$
\min_{M\in\mathcal M,S\in\mathcal S}
\sum_{c=1}^{C}\alpha_c
\sum_{p\in\mathcal P}w_p
L\!\left(F(M_c,S;\theta_p),T_c\right)
+\lambda R_M(M)+\mu R_S(S).
$$

$c$ 标记代表图形或局部区域，$p$ 标记工艺角。$R_M$ 控制掩模复杂度，$R_S$ 控制光源形状、能量和硬件可实现性。固定 $S=S_0$，就得到掩模优化；允许 $S$ 也变化，才是源—掩模协同设计。

| 维度 | 常规模型 OPC | 常见 ILT | SMO |
| --- | --- | --- | --- |
| 主要变量 | 边缘偏移、bias、角部与 SRAF 参数 | 掩模场、隐式边界、曲线或拓扑变量 | 光源参数，以及一种掩模表示 |
| 光源 | 通常固定 | 通常固定，也可嵌入联合流程 | 明确参与优化 |
| 初始几何依赖 | 常围绕原边缘修正 | 通常允许更大形状变化 | 取决于掩模求解器 |
| 主要工程交付物 | 修正后的掩模版图 | 可制造的反演掩模 | 可实现的全局光源及配套修正流程 |
| 共同验收 | 晶圆误差、工艺窗口、规则、制造与验证 | 同左 | 同左，并增加光源硬件检查 |

表中列出的是典型实现；具体算法的类别还取决于实际更新的参数与允许的几何变化。

## 规则式与模型式 OPC

规则式 OPC 根据线宽、间距和邻近环境施加 bias、hammerhead、serif 等几何修正。模型式 OPC 则把正向仿真放进迭代：在评估点比较晶圆轮廓与目标，更新掩模边缘，再次仿真。

假设边缘控制变量为 $\mathbf u$，EPE 向量为 $\mathbf e(\mathbf u)$。小幅更新时，可近似为

$$
\mathbf e(\mathbf u+\Delta\mathbf u)
\approx\mathbf e(\mathbf u)+J\Delta\mathbf u.
$$

灵敏度矩阵 $J$ 反映边缘之间的耦合。一个片段向外移动，不只影响与它正对的那一点，还可能改变旁边的线端与角部。因此，OPC 并非每条边各自修到零误差那么简单。

![未经校正与经过 OPC 的图形对照](/assets/images/references/optical-proximity-correction.png)
*图 1：通过改变输入掩模补偿输出图形，是 OPC 的基本任务；图示本身不区分边缘法与 ILT 求解器。来源：[Wikimedia Commons，Optical proximity correction.png](https://commons.wikimedia.org/wiki/File:Optical_proximity_correction.png)，LithoGuy，2010，公共领域（Public domain），未修改。*

OPC 的一个工程优势是，变量可以集中在当前误差附近，保留版图结构与层级，也便于控制修正幅度。对于大部分已经能打印的图形，这种表示可能比给整个区域分配像素变量更经济。局限在于，如果只移动既有边界，就很难主动改变拓扑或远处的辅助图形布局；系统往往再配合 SRAF 插入、重新分段或局部更自由的求解。

Synopsys 的公开文档同时列出 Manhattan 与 curvilinear 模型 OPC，以及 field-based ILT，说明几何输出与求解器类别之间并无一一对应关系。[[2]](https://www.synopsys.com/content/dam/synopsys/silicon/datasheets/proteus-ds.pdf) 文档说明工具提供的能力，实际部署范围和性能仍需对应应用数据。

## ILT 的掩模搜索空间

ILT 从目标出发，寻找使前向成像接近目标的掩模：

$$
M^*=\arg\min_{M\in\mathcal M}
J(M\mid S_0,\theta).
$$

这个问题与模型 OPC 的任务有重合，区别通常在搜索空间与求解方式。全场像素允许更多区域参与变化，水平集允许边界合并、分裂，曲线参数化则能在较少变量下表达平滑边缘。主特征与 SRAF 可以在同一目标中竞争光学资源，而不必完全依赖预设辅助图形模板。

像素化逆掩模设计在 1992 年 Liu 与 Zakhor 的二值/相移掩模论文中已有系统讨论；2007 年 Poonawala 与 Milanfar 又以逆成像、连续松弛与正则化组织了这一问题。[[3]](https://doi.org/10.1109/66.136275) [[4]](https://doi.org/10.1109/TIP.2006.891332) 这条研究史不支持“ILT 到 2020 年才首次引入反向设计”的说法。

### 非凸性与连续松弛

掩模振幅经过光学传递后取模平方，再经过胶的非线性响应；二值性和制造规则还带来离散约束。目标通常非凸，不同初值可能收敛到不同结果。增加变量，理论上扩大了可选集合，却也增加了局部极值、病态方向和模型过拟合的机会。

连续求解常将 $m_i\in\{0,1\}$ 松弛到 $[0,1]$，并加入二值化和复杂度惩罚。灰度场阈值化会改变频谱和轮廓，因此最终可制造几何必须重新成像，评估二值化及后续处理造成的误差。

ILT 允许搜索更自由的掩模解，是否输出曲线取决于可行集合与参数化。要求 Manhattan 几何时，反演可以输出直角图形；采用曲线边缘参数的模型 OPC 也可以输出弯曲轮廓。

## SMO 的照明角谱变量

SMO 求解

$$
(M^*,S^*)=\arg\min_{M\in\mathcal M,S\in\mathcal S}
J(M,S).
$$

这里 $S$ 描述照明光瞳中的角度与能量分布。曝光剂量是总量，源分布决定来自哪些方向的光参与成像；二者不能混为一个变量。

在薄掩模、部分相干成像近似下，可以写成离散源点求和：

$$
I(\mathbf r)=\sum_j s_j
\left|\mathcal F^{-1}
\left\{P(\mathbf f+\mathbf q_j)\widehat M(\mathbf f)\right\}\right|^2,
\quad s_j\ge0.
$$

不同源点互不相干，所以按强度相加；同一个源点激发的衍射级次仍会相干干涉。掩模决定频谱 $\widehat M$，光源位置 $\mathbf q_j$ 改变物镜对频谱的采样。一个变量改变以后，另一个变量原来的最佳选择就可能不再合适。

Rosenbluth 等人在 2001 年会议、2002 年期刊扩展工作中联合研究光源与掩模。原论文的小场周期图形条件需要保留，不能将其改善比例推广到任意版图。[[5]](https://doi.org/10.1117/1.1448500) Ma 与 Arce 2009 年的工作则给出了像素化同时优化与约束处理的代表性框架。[[6]](https://doi.org/10.1364/OE.17.005783)

### 共享光源与局部掩模

同一曝光任务通常共享光源，局部掩模却能各自修改。一种有利于水平密集线的源，可能损害垂直线、孤立线或二维线端。优化目标必须覆盖代表图形集合，而非给每个图形分别寻找一套无法同时使用的专属光源。

这会产生一种常见的工程流程：先用有限的关键图形联合探索源与掩模，把理想源收敛为扫描机可实现的分布；再冻结光源，用高容量 OPC 或 ILT 修正全芯片。最终全芯片阶段不再移动光源，并不否定前面的 SMO，它只是将全局决策与大量局部修正分层处理。公开 full-chip SMO 工作正是围绕这种规模与覆盖问题展开。[[7]](https://doi.org/10.1117/12.881633)

### 交替与联合更新策略

SMO 可以交替 SO（源优化）与 MO（掩模优化），也可以同时计算两个变量的梯度，或把一个变量的近似最优响应嵌入另一个变量的优化。名称里的 joint、simultaneous 或 co-optimization，不能代替对更新顺序的检查。

固定掩模时，空中像对非相干源点权重是线性的；但胶阈值、工艺窗口和硬件约束会使源优化目标更复杂。固定光源时，掩模问题仍然非凸。将两个子问题交替求解，一般不会自动获得全局最优，也可能出现一个子问题的改善损害另一个方向的情形。

## EPE、NILS、MEEF 与工艺变化带

EPE 衡量晶圆边缘相对目标边缘的位置差。不同论文对采样点、符号、允许限和失败计数的定义可能不同，不能只看一个平均数。一个线端回缩很严重，但长直边采样点很多，平均值仍可能很好看。

CD 衡量线宽或孔尺寸，EPE 则更直接反映边缘位置；两者也不互相替代。两条边一起平移时，CD 可以不变，而定位已经错了。反过来，中心位置正确，线宽仍可能超差。

NILS 是边缘处的归一化图像对数斜率：

$$
\mathrm{NILS}=CD\left|\frac{\partial\ln I}{\partial x}\right|.
$$

在简单阈值模型中，斜率更陡通常意味着剂量扰动造成的边缘移动更小。然而 NILS 是局部成像代理，不能单独证明 EUV 缺孔、桥连和刻蚀后缺陷都降低。每一个代理指标，都应与真实失效模式建立联系。

MEEF 衡量掩模误差在晶圆上的放大。若掩模缩小倍率为 $R$，可写成

$$
\mathrm{MEEF}=\frac{\Delta CD_{\mathrm{wafer}}}
{\Delta CD_{\mathrm{mask}}/R}.
$$

该定义要求尺寸和方向一致；各向异性成像时还要分别说明方向倍率。PV Band 则观察多工艺角轮廓的变化包络，它的宽度/面积定义与采样集合需要明确，不能把不同论文的数值直接横比。

EPE、NILS、MEEF 和 PV Band 分别描述边缘定位、局部光强斜率、掩模误差传递及工艺变化下的轮廓响应。它们可以进入 OPC、ILT 或 SMO 的目标函数，但度量选择与优化变量属于不同的分类维度。

## 线端校正的方案比较

设某金属线端在标称条件下回缩，同时在离焦时与邻线出现桥连风险。首先保持模型和光源一致，比较三种求解范围。

OPC 路线可以移动线端与邻近边缘，加入 hammerhead 或 SRAF，再以 EPE、CD 和规则检查筛选更新。如果已有表示能够容纳有效修正，采用更多变量未必有显著收益。

ILT 路线允许更完整的局部场参与优化。线端与辅助形状可以联合演化，出现远离原始边界的新岛、窄颈或曲线。它可能找到边缘小步修正难以到达的解，也可能生成需要清理的不可制造结构。公平比较必须在最终制造几何上重新仿真。

SMO 路线进一步改变照明，但应把这个线端和其他节距、方向、二维图形放在同一集合里。对线端最有利的光源，不一定是整层最好的。若只有这个 clip 进入目标，得到的是局部探索结果，还不是可直接部署的全局光源。

假设初步结果是：方案 A 标称 EPE 最小，但离焦桥连；方案 B 标称误差略大，却在所有采样角合格；方案 C 模型窗口最大，但源需要设备无法实现的细碎强度分布。工程选择通常更接近 B。这个假设例子说明，最终判断来自目标和约束，而不是名称的“先进程度”。

## 制造约束的实施阶段

可以先放开约束寻找理想解，再输出清理；也可以每一步都施加规则；还可以先在松约束下探索，再逐步收紧。三种方式都可能有用，但其误差路径不同。

事后清理容易移除光学上有用的小辅助岛，改变窄缝和局部相位关系。若不重新优化，原有窗口就可能丢失。强制每步硬投影则可能让梯度方向被频繁打断，导致停滞或局部振荡。延续方法试图逐渐从理想场过渡到可行几何，但需要设计惩罚权重和切换条件。

此外，数字掩模 MRC 只是第一道门。掩模工艺校正、写入量化、吸收体轮廓与检测能力仍会改变最终可行性。一个曲线能否写出来，与能否在合理时间内写出、测准、检出缺陷和修复，是不同的问题。

这种约束也解释了为什么像素越多不一定越好。若真实制造只能稳定控制某一尺度，把网格继续细化到远小于该尺度，可能主要增加模型噪声与输出复杂度，而不是可兑现的自由度。

## 学习方法与可微求解

如果网络只预测边缘位移，它服务的是一组掩模参数；如果预测高自由度掩模场，它服务的是更宽的逆掩模搜索；如果连源也参与联合优化，问题才增加了 SMO 的变量。网络结构本身并不产生第四级工艺自由度。

DiffOPC 对分段边缘表示传播梯度，实现可微边缘优化。[[8]](https://arxiv.org/abs/2408.08969) 这表明梯度计算方法可以独立于掩模参数化选择。

自动微分给出既定前向模型的导数，其物理适用性仍由模型决定。若缺少关键三维掩模或胶效应，精确导数也只能优化这一近似模型。学习初值、代理仿真和生产签核因此需要分别评价。

比较 AI 方法时，还应分开训练时间、局部推理时间和完整修正/验证时间。新层是否需要重训，训练集是否覆盖真实热点，最终是否回到独立物理模型，这些条件往往比网络名称更决定工程可用性。

## EUV 与 High-NA 的附加自由度

EUV 掩模是反射式三维结构，斜入射、吸收体和多层膜使方向相关效应更强。High-NA 又带来各向异性成像与更严苛的窗口要求。单纯使用薄掩模、标量模型得到的源—掩模组合，可能在更完整模型中失去优势。

2024 年 imec 的 High-NA 随机逻辑金属研究，把光源、掩模 tone、吸收体、SRAF 和制造规则纳入方案评估。[[9]](https://doi.org/10.1117/12.3010869) 这项工作能证明相关协同问题正在被具体研究，不能推出所有 High-NA 工艺都采用同一组最优参数。

严格按缩写，SMO 仍指 source 和 mask 的优化。当 absorber、resist、etch 或设计规则也可改变，研究已经接近更大的协同设计。用统一变量表描述它，比强行把所有新进展装进三个缩写更清楚。

## 问题定义与结果的比较条件

结果比较需要首先统一输出平面与模型校准条件。空中像、显影后及刻蚀后目标对应不同的预测任务，可控变量还可能包括掩模边缘、场、拓扑、全局光源、剂量或材料。变量范围与设备及制造约束共同决定可行集合。

鲁棒性由图形与工艺角的覆盖、独立验证和失效定义约束。平均损失、最坏误差和共同窗口反映不同性质，应在同一比较中明确各自的采样和阈值。

运行时间比较还需要固定容差和硬件，并明确是否包含二值化、MRC、全芯片数据准备与验证。局部推理与完整掩模流程采用不同的计时边界。

在分层流程中，SMO 用于选择共享照明与掩模策略，固定光源后的 OPC 或 ILT 承担大容量掩模修正，独立模型及晶圆数据验证最终预测。对这类组合方案，应分别归属各阶段的误差改善与计算成本。

## 参考文献

以下在线资料统一访问于 **2026-10-25**。文中目标函数与示例为统一符号后的教学性归纳。

1. C. A. Mack. *Fundamental Principles of Optical Lithography: The Science of Microfabrication*. Wiley, 2007. DOI: [10.1002/9780470723876](https://doi.org/10.1002/9780470723876).
2. Synopsys. *Proteus Solutions: Full-Chip Mask Synthesis*. 官方技术文档, 2024. [PDF](https://www.synopsys.com/content/dam/synopsys/silicon/datasheets/proteus-ds.pdf).
3. Y. Liu, A. Zakhor. “Binary and Phase Shifting Mask Design for Optical Lithography.” *IEEE Transactions on Semiconductor Manufacturing*, 5(2): 138–152, 1992. DOI: [10.1109/66.136275](https://doi.org/10.1109/66.136275).
4. A. Poonawala, P. Milanfar. “Mask Design for Optical Microlithography—An Inverse Imaging Problem.” *IEEE Transactions on Image Processing*, 16(3): 774–788, 2007. DOI: [10.1109/TIP.2006.891332](https://doi.org/10.1109/TIP.2006.891332).
5. A. E. Rosenbluth, S. Bukofsky, C. Fonseca, et al. “Optimum Mask and Source Patterns to Print a Given Shape.” *Journal of Microlithography, Microfabrication, and Microsystems*, 1(1): 13–30, 2002. DOI: [10.1117/1.1448500](https://doi.org/10.1117/1.1448500). 初步会议版：SPIE 4346, 2001。
6. X. Ma, G. R. Arce. “Pixel-based Simultaneous Source and Mask Optimization for Resolution Enhancement in Optical Lithography.” *Optics Express*, 17(7): 5783–5793, 2009. DOI: [10.1364/OE.17.005783](https://doi.org/10.1364/OE.17.005783).
7. M.-C. Tsai et al. “Full-chip Source and Mask Optimization.” *Proceedings of SPIE*, 7973: 79730A, 2011. DOI: [10.1117/12.881633](https://doi.org/10.1117/12.881633).
8. G. Chen, H. Yang, H. Ren, B. Yu, D. Z. Pan. “Differentiable Edge-based OPC.” *ICCAD*, 2024. [作者预印本 arXiv:2408.08969](https://arxiv.org/abs/2408.08969).
9. S. Hwang, W. Gillijns, S. De Gendt, R.-H. Kim. “Source Mask Optimization (SMO) Study for High-NA EUV Lithography to Achieve Single Patterning on Random Logic Metal.” *Proceedings of SPIE*, 12954: 129540X, 2024. DOI: [10.1117/12.3010869](https://doi.org/10.1117/12.3010869). [imec 官方书目](https://imec-publications.be/entities/publication/f98b3cc7-e696-483b-a979-8a8c86a14a0a).
