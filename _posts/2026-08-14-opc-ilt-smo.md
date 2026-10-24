---
layout: post
read_time: true
show_date: true
title: "OPC、ILT、SMO，到底分别在优化什么"
date: 2026-08-14 00:29:50 +0800
tags: [光刻, OPC, ILT, SMO]
author: 端点星日志
description: "OPC 定义掩模修正任务，ILT 扩大掩模的反演搜索空间，SMO 再把照明加入变量。到了 curvilinear mask、AI 求解和 High-NA EUV 时代，真正可靠的分界仍是变量、约束与交付物。"
source_url: "https://mp.weixin.qq.com/s/GjLR8b9IgiOAFF2APP8-Fg"
toc: true
---

把 OPC、ILT 和 SMO 放在一行，人们很容易先问谁比谁先进，再把三者排成一条升级路线。公开论文和生产流程都撑不起这种排法。

如果只看研究概念进入公开文献的时间，今天被综述纳入 ILT 脉络的 inverse mask design 的确出现得更早。Liu 和 Zakhor 在 1992 年已经用 Hopkins model、branch-and-bound 与 simulated annealing 系统设计 pre-distorted mask。[3][13] Rosenbluth 等人联合优化 mask 与 source 的会议论文发表于 2001 年，相关期刊论文发表于 2002 年。[5]

这两个年份只能说明相关问题进入公开文献的时间不同。它们推不出工程采用顺序，也推不出“做完 ILT 才能进入 SMO”。2001 年的论文同时讨论了 fixed-source mask optimization、fixed-mask source optimization 和 mask-source joint optimization。[5] 今天的流程也常在 SMO 确定 source 以后，再用 full-chip OPC 或 ILT 完成掩模修正。[11]

model-based OPC 可以生成 curvilinear mask，ILT 也能输出 Manhattan mask。AI 又让 edge-based、pixel-based 和 field-based solver 互相借用技术。把 1990 年代以来的论文、Erdmann 和 Mack 的经典教材、2025 年的 AI-ILT 综述，以及 ASML、Synopsys 当前的技术资料放在一起看，一条更稳定的主线会浮出来。

OPC 说的是掩模修正任务。ILT 说的是怎样把掩模当成逆问题来求。SMO 增加了照明光源这组变量。三者可能使用相近的成像模型，也可能盯着同一组 EPE、CD 和 process window 指标，真正不同的是优化器手里有哪些自由度。

## 先把目标、变量和约束拆开

设晶圆上希望得到的图形为 T，掩模为 M，照明光源为 S，焦点、剂量、像差、胶和刻蚀条件合在 θ 里。前向光刻模型可以简写成

W=F(M,S;θ)

W 是模型预测的晶圆图形。优化器让它接近目标，同时照顾工艺波动和制造限制。一个常见的抽象形式是

J=∑p∈PwpL(Wp,T)+RM(M)+RS(S)

L 可以衡量 EPE、CD、轮廓差异或 PV Band。RM 约束掩模的最小线宽、间距、曲率和复杂度。RS 约束光源能量、平滑度、对称性和照明硬件能力。

经典教材反复提醒，nominal focus 和 nominal dose 下的一张漂亮轮廓远远不够。真正有用的解，需要在 common process window 里照顾一组图形。[1][2] 所以，OPC、ILT 和 SMO 的优化目标可以高度相似。更值得追问的是优化变量、搜索空间和约束在哪里生效。

| 名称 | 主要优化变量 | 常见工程交付物 |
| --- | --- | --- |
| OPC | 掩模边缘、bias、角部与辅助图形 | 已选光源下的 full-chip 修正掩模 |
| ILT | 掩模函数、边界或拓扑 | 更大搜索空间里求得的掩模解 |
| SMO | 光源分布与掩模 | 可实现的全局光源及配套掩模方案 |

ASML 现在用更宽的“计算光刻”来概括扫描机、掩模与工艺的共同优化。[12] OPC、ILT 和 SMO 可以理解成这套大系统中的三个常用工作层级。名称会随论文和产品变化，变量、约束与最终交付物更经得起追问。

## OPC 沿着掩模做修正

OPC 的全名是 Optical Proximity Correction。早期 rule-based OPC 很直观。线端容易缩短，就给线端增加 bias 或 hammerhead。角部容易圆化，就加入 serif。dense pattern 与 isolated pattern 成像不同，就按局部环境使用不同规则。

进入 model-based OPC 以后，forward simulation 成为循环的一部分。版图边缘被切成许多片段，模型计算 wafer contour，求解器根据 EPE、CD 或其他误差移动边缘，再次仿真。SRAF 也可���加入流程，用来改变衍射谱和 process window。

这里容易留下一个过时印象，仿佛 OPC 永远只会推拉直线边缘。2025 年的 ILT 综述把 model-based OPC 继续分为 edge-based 和 pixel-based 路线，并回顾了 pixel-based 方法如何逐步走向 ILT。[8] Synopsys 当前的 Proteus 资料也明确写到，生产 OPC 同时支持 Manhattan 和 curvilinear 版图。[11]

因此，OPC 直接优化的是掩模修正（mask correction），评判结果却落在 wafer 上。掩模与 design target 长得更像，不会自动获得更高分。只要通过 lithography model 以后 wafer contour 更接近目标，并且在工艺波动下保持稳定，serif、hammerhead、SRAF 和 curvilinear edge 都有工程价值。

现代 OPC 模型还可能包含 resist、etch 和 mask 3D effect。“Optical”保留了技术沿革，今天的交付物仍是一张经过计算修正、能够进入制造流程的掩模版图。

## ILT 把掩模写成逆问题

ILT 的全名是 Inverse Lithography Technology。Pang 在 2021 年的综述里，把它概括为已知掩模到晶圆的前向变换（mask-to-wafer forward transform）以后，反求一张具有 pattern fidelity 或 process window 优势的掩模。[3]

在常见设定中，光源已经固定，ILT 求的是 M。

JILT=J(M∣S,θ)

Poonawala 和 Milanfar 把 mask design 写成 inverse imaging problem，后续工作又发展出 pixel-based、continuous function、level-set、frequency-domain 和 field-based 等多种表示。[1][4] 主图形、角部与辅助图形可以在同一 cost function 里演化，搜索也有机会离初始版图更远。

这几句话里有三个限定很重要。

ILT 不等于 pixel-based method。level-set 优化的是 implicit boundary，field-based solver 和 parameterized method 也能完成反演。ILT 不等于 curvilinear mask。制造规则要求 Manhattan 化时，它可以输出直角图形。ILT 也不保证 global optimum。这个 inverse problem 多解且 non-convex，mask rule、计算预算与初值共同限定了最后能找到的解。[1][3]

OPC 与 ILT 的边界也没有一条行业统一的细线。站在任务层面，两者都在做 mask correction。站在 solver 层面，ILT 通常给掩模更连续、更高维或更少受初始边界限制的 search space。当前商业工具甚至同时提供 curvilinear OPC、Manhattan ILT 和 curvilinear ILT。[11]

所以，看到一个复杂 curvilinear shape 不能立刻断言它来自 ILT，看到 Manhattan output 也不能排除 ILT。更可靠的问题是掩模怎样表示，哪些自由度被联合求解，制造约束何时进入迭代。

## SMO 再把照明放进变量表

SMO 的全名是 Source Mask Optimization。它的基本形式变成

JSMO=J(S,M∣θ)

这里的光源不是简单的曝光亮度。S 描述照明光瞳里的角度分布，决定哪些入射波矢参与成像。掩模决定衍射谱，投影物镜收集其中一部分。光源变化以后，同一张掩模的衍射级次会以另一种方式进入物镜。掩模变化以后，原来合适的光源也可能失去优势。

Rosenbluth 等人在 2001 年的会议论文中公开联合寻找 mask 与 source，2002 年又以期刊论文形式发表相关工作。[5] 后续 pixel-based SMO 把两者写入同一套优化框架，并加入拓扑与制造约束。[6]

SMO 有一个天然的不对称。光源通常服务整层版图或一组曝光任务，是数量较少的全局自由度。掩模修正随位置变化，是数量巨大的局部自由度。给一类困难图形单独求出的漂亮光源，可能会损害其他方向、节距和二维图形。

实际流程常从 representative pattern 或 hotspot 开始，联合探索 source 与 mask，再把 source 收敛到 scanner 能够实现的形状。光源冻结以后，full-chip mask 仍交给 OPC 或 ILT。公开的 full-chip SMO 工作和当前生产工具都采用了这类分层思路。[7][11]

High-NA EUV 又让这项工作多了几层现实约束。2024 年 imec 的一项 0.55 NA 研究，在同一个 test cell 里比较 dark-field、bright-field、不同 absorber、带或不带 SRAF 等组合，同时纳入 4×/8× anamorphic magnification、mask writing rule、resist blur 和 process window。[10]

严格按缩写，SMO 的变量仍是 source 和 mask。到了 High-NA 研究中，source、pattern tone、absorber、SRAF、mask 3D effect 和 resist model 往往要放在同一轮方案比较里。今天谈 SMO，已经很难只看一张 freeform source 图。

## AI 改了求解方式，没有增加第四类变量

近几年又出现 GAN-OPC、神经网络 ILT、可微光刻和 DiffOPC 等名字。它们确实改变了计算成本与搜索方式，也容易制造一个新误会，仿佛 AI 成了 OPC、ILT、SMO 之后的第四级。

2025 年的 AI-ILT 综述梳理了机器学习在 initial mask generation、SRAF insertion、surrogate lithography model、gradient estimation 和 end-to-end prediction 中的用法。[8] 2024 年提出的 DiffOPC 则把 edge-based OPC 写进 differentiable framework，让传统 edge control point 也能利用 automatic differentiation。[9]

这些方法改变的是模型、solver 和 initialization。最终被移动的自由度仍然可以是 mask，也可以是 source 与 mask。AI 输出还要接受物理模型、mask rule、process corner 和 full-chip verification。它让旧路线互相渗透，变量表却没有凭空多出一栏。

这个视角也解释了当前文献里的命名差异。同一种神经网络，若只预测局部 edge displacement，通常会被写进 OPC flow。若输出高自由度 mask field，作者更可能称它为 ILT。若连 source distribution 也参加训练或优化，问题才进入 SMO 的范围。

## 同一条线端，三种方法怎样动手

拿一个容易发生 line-end shortening 的线端作示意，区别会清楚很多。

OPC 会根据当前晶圆轮廓移动线端附近的边缘控制点，必要时加入 hammerhead 或 SRAF。光源已经选定，主要使用掩模上的局部自由度。

ILT 仍使用这套 source，却把更完整的局部 mask 送入 cost function。line end、corner 和 assist feature 可以一起演化，最后可能得到 curvilinear shape，也可能得到满足 Manhattan rule 的复杂形状。它扩大的是 mask solution 的 search space。

SMO 会把这个线端与其他方向、节距和二维图形放在同一组样本里。优化器既能改掩模，也能改变照明角谱。它需要找到整层图形能够共享的光源，无法给每个线端配一套专属照明。

三条路径最后都可能用 EPE、CD、NILS、PV Band 和 MEEF 评价结果。指标并没有替它们划出边界，变量与自由度才有这个作用。

## 看到新名词时，先问五个问题

先看 solver 动了什么，只有 mask，还是 source 与 mask 一起变化。再看 mask 怎样表示，edge segment、pixel、continuous field、level-set 和 curve control point，会带来不同的 search space。

接着看 forward model 算到 aerial image、resist contour 还是 post-etch contour，cost function 覆盖哪些 process corner，制造约束又怎样进入流程。约束在迭代中生效、在输出后清理，或者只能依赖 mask writer capability，结果会有明显差别。nominal condition 下的漂亮轮廓，也代替不了 common process window。

这五个问题答完，很多等号会自然消失。OPC 不再等于 rule-based correction，ILT 不再等于 curvilinear mask，SMO 也不再等于一张 freeform source 图。到了 AI 与 High-NA EUV 时代，缩写仍有用，变量、约束与交付物更接近工程真相。

## 参考文献与延伸阅读

[1] Andreas Erdmann, *Optical and EUV Lithography, A Modeling Perspective*, SPIE Press, 2021. 图书页面

[2] Chris A. Mack, *Fundamental Principles of Optical Lithography, The Science of Microfabrication*, Wiley, 2007. 图书页面

[3] L. Pang, “Inverse lithography technology, 30 years from concept to practical, full-chip reality,” *Journal of Micro/Nanopatterning, Materials, and Metrology* 20(3), 030901, 2021. 论文页面

[4] A. Poonawala and P. Milanfar, “Mask design for optical microlithography, an inverse imaging problem,” *IEEE Transactions on Image Processing* 16(3), 774-788, 2007.

[5] A. E. Rosenbluth et al., “Optimum mask and source patterns to print a given shape,” *Proceedings of SPIE* 4346, 486-502, 2001，相关期刊论文发表于 2002 年。会议论文 期刊论文

[6] X. Ma and G. R. Arce, “Pixel-based simultaneous source and mask optimization for resolution enhancement in optical lithography,” *Optics Express* 17(7), 5783-5793, 2009. 论文页面

[7] M. C. Tsai et al., “Full-chip source and mask optimization,” *Proceedings of SPIE* 7973, 79730A, 2011. 论文页面

[8] Y. Yang et al., “Advancements and challenges in inverse lithography technology, a review of artificial intelligence-based approaches,” *Light, Science & Applications* 14, 214, 2025. 论文页面

[9] R. Chen et al., “DiffOPC, Differentiable edge-based optical proximity correction,” *Proceedings of ICCAD*, 2024. 论文页面

[10] S. Hwang et al., “Source mask optimization for High-NA EUV lithography,” *Proceedings of SPIE* 12955, 2024. 论文页面

[11] Synopsys, *Proteus Optical Proximity Correction*, 2024. 技术资料

[12] ASML, *Computational lithography*. 技术页面

[13] Y. Liu and A. Zakhor, “Binary and phase shifting mask design for optical lithography,” *IEEE Transactions on Semiconductor Manufacturing* 5(2), 138-152, 1992. 论文页面
