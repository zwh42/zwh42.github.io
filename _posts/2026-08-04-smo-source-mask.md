---
layout: post
read_time: true
show_date: true
title: "SMO：把光源和掩模放进同一道优化题"
date: 2026-08-04 22:05:14 +0800
tags: [光刻, SMO, 光源优化, 掩模优化]
author: 端点星日志
description: "从部分相干成像、联合目标函数到量产流程，梳理光源—掩模协同优化的原理、二十余年演进、EUV/高NA现状与下一步。"
source_url: "https://mp.weixin.qq.com/s/_m3ihHOoJE-iK788s7s66w"
toc: true
---

如果把传统 OPC 比作“在一张固定光源下修掩模”，那么光源—掩模协同优化（Source Mask Optimization，SMO）做的事情更激进：**照明从哪些角度来、每个角度有多少能量，以及掩模怎样把这些光分配到不同衍射级次，被放进同一道优化题。**

这并不是简单地把两个独立优化串起来。光源改变后，同一块掩模的衍射级次会以不同方式进入物镜；掩模改变后，原来“最优”的光源也可能不再最优。二者互相定义对方的最优解。

截至 2026 年，SMO 已从 2001 年公开论文里的小区域概念验证，发展为 DUV 和 EUV 计算光刻工具链中的成熟能力，并进入高数值孔径 EUV（High-NA EUV）的工艺开发。它的工程形态却与教科书式的“全芯片像素级同时优化”不同：通常先在一组能代表整层风险的关键图形上求出可制造光源，再固定光源进行全芯片 OPC 或 ILT，最后用更严谨的模型和晶圆数据验证。

本文先讲清这种方法为什么有效，再回答三个更现实的问题：它怎样算、二十多年里解决了哪些落地障碍，以及在 High-NA EUV、随机缺陷和 AI 加速的背景下会往哪里走。

## 先说结论：SMO 优化的是“共同工艺窗口”

光刻分辨率常用 Rayleigh 关系作第一层估计：[1][2]

CD=k1λNA,DOF=k2λNA2

波长 λ 和数值孔径 NA 由平台决定后，继续缩小 CD 就意味着压低 k1。代价是图像对焦点、剂量、掩模误差、像差和工艺波动更敏感。

离轴照明、相移掩模、亚分辨率辅助图形（SRAF）和 OPC 都是在有限光学带宽里重新安排信息。传统流程常把它们分开调：先选一套环形、二极或四极照明，再在固定光源下做 OPC。SMO 的核心判断是：**既然照明角谱决定哪些掩模空间频率能进入光瞳，掩模又决定能量落在哪些空间频率上，二者就应该一起分配带宽。**

因此，SMO 的目标通常不是只让标称焦点、标称剂量下的轮廓更像 target，而是让多种图形在一组工艺条件下同时满足规格，也就是扩大共同工艺窗口。目标会同时考虑：

- 
- 标称条件下的边缘放置误差（EPE）和 CD；
- 
- 离焦、剂量变化下的轮廓或工艺变化带（PV Band）；
- 
- 图像对数斜率、曝光裕量和景深；
- 
- 掩模误差增强因子（MEEF）、SRAF 不可打印性；
- 
- 光源可实现性、掩模最小线宽/间距、写入与检测能力；
- 
- EUV 场景下的三维掩模效应、随机 CDU 和缺陷率。
-

这也解释了为什么“图形误差最低”的解未必是工程上最好的解：它可能只在一个焦点上很好，或者需要无法制造的碎片化掩模和无法在扫描机上实现的理想光源。

## 物理直觉：光源在选择“哪组衍射级次参与干涉”

把掩模图形记为 m(r)，其频谱为 ^m(f)。在 Köhler 照明和部分相干成像近似下，可以把扩展光源离散成许多彼此不相干的源点。对位于光瞳坐标 q 的一个源点，相干像场可写成：

Aq(r)=F−1 ⁣{P(f+q)^m(f)}

其中 P 是包含孔径、像差、偏振等信息的光瞳函数。不同源点之间按强度相加：

I(r)=∫ΩsJ(q)∣Aq(r)∣2dq

J(q) 就是待优化的光源强度分布。这个式子给出了最直接的物理图像：移动或增强某个源点，相当于移动光瞳相对于掩模频谱的采样位置，从而改变哪些衍射级次被收集、它们怎样干涉。

以一维密集线为例，若只有零级光进入物镜，像面几乎没有线条调制；至少需要零级与 ±1 级中的合适组合发生干涉。离轴照明可以把原本落在光瞳外的一阶衍射移入光瞳。但同一个源点对另一种节距、二维拐角或线端未必有利。这就是“最佳光源依赖图形”的根源，也是整层只有一个全局光源时最难协调的矛盾。

掩模优化则从另一侧改变频谱：主图形偏置、serif、hammerhead 和 SRAF 都会重新分配衍射级次的振幅与相位。SMO 的协同来自两种自由度的互补：光源决定如何采样频谱，掩模决定提供什么频谱。

## 从 Hopkins 到卷积核：为什么这道题算得动

对部分相干系统，Hopkins 形式把照明与投影系统压缩进传输交叉系数（Transmission Cross Coefficient，TCC）：[1][2]

TCC(f1,f2)=∫J(q)P(f1+q)P∗(f2+q)dq

空中像为：

I(r)=∬TCC(f1,f2)^m(f1)^m∗(f2)ei2π(f1−f2)⋅rdf1df2

直接计算四维 TCC 很贵。生产级计算通常对它做特征分解，只保留占主导的相干系统，也就是常说的 SOCS：

I(r)≈K∑k=1λk∣hk⊗m∣2

这样，一次成像被化为少量卷积和 FFT。光源变化会改变 TCC 及其核；掩模变化会改变卷积输入。算法需要在准确度、核数量和反复重分解的代价之间取舍。

另一条路线是直接使用前面的 Abbe 源点求和。它对逐个光源像素求梯度更自然，也容易加入源点相关的偏振和三维掩模响应，但源点很多时计算量会迅速增加。2024 年提出的双层 SMO 工作就采用加速 Abbe 成像，把“给定掩模求最优光源”显式放进下层问题。[18]

生产软件并不会只押注一种公式。薄掩模、快速三维掩模模型、Abbe、Hopkins/SOCS、矢量成像和严谨电磁求解会按阶段组合：探索与迭代使用足够快的模型，签核阶段再用更严谨的模型检查近似是否失效。

## 把物理写成优化问题

设光源像素为 s，掩模变量为 m，工艺条件为 θ。θ 可以包含焦点、剂量、像差、掩模 CD 误差、光源模糊和膜堆栈变化。前向模型给出空中像或胶内像：

Ip=H(s,m;θp)

为了让轮廓可微，研究算法常用 sigmoid 近似阈值胶模型：

Zp(r)=11+exp⁡[−a(Ip(r)−Ith)]

其中 Ith 是阈值，a 控制边缘陡峭程度。真实生产模型可以更复杂，但联合优化的一般形式相近：

min⁡s,m∑p∈PwpL ⁣(Zp,T)+λmRm(m)+λsRs(s)

约束至少包括：

sj≥0,∑jsj=1,mi∈{0,1} 或允许的复透过率集合

L 可以是像素误差、EPE、CD、PV Band、NILS 或它们的组合；Rm 抑制小于掩模规则的孤岛、狭缝和过高曲率；Rs 则限制光源粗糙度、对称性、透过率和照明硬件不能实现的结构。

几个常见指标值得单独写清：

**NILS** 衡量阈值边缘处的归一化图像斜率。对名义线宽 CD，常写为：

NILS=CD∣∂ln⁡I∂x∣I=Ith=CDIth∣∂I∂x∣I=Ith

边缘越陡，剂量或随机波动转化为位置误差的幅度通常越小。但 NILS 不是万能代理。针对 EUV 接触孔的实验研究发现，在其特定数据集中，随机 CDU 与 NILS 的相关性最好，而缺孔与桥连缺陷分别更受最大、最小强度预测；NILS 与最大强度又高度相关。[16] 因此，不能只凭一个指标替代实际缺陷模型。

**MEEF** 衡量掩模 CD 误差被投影到晶圆后的放大。若掩模缩小倍率为 R，可写成：

MEEF=ΔCDwaferΔCDmask/R

High-NA EUV 是各向异性的 4×/8× 缩小，方向不同，R 也不同。MEEF 高的 SMO 解可能在理想掩模上表现很好，却对实际掩模误差极其脆弱。

**PV Band** 是不同焦点、剂量或其他工艺角下轮廓包络之间的带宽或面积。它比标称轮廓误差更接近“量产会漂多少”，但其数值依赖采样的工艺角和聚合定义，跨论文比较时必须先看定义。

## 为什么算法没有唯一标准答案

这道题同时包含连续光强、二值或多级掩模、阈值非线性和制造规则，是高维、非凸且通常非唯一的逆问题。许多不同的光源—掩模组合可以打印出相近轮廓。因此，所谓“最优”总是相对于目标函数、模型、初值和约束而言。

常见求解路线可以分成四类：

1. 
2. **交替优化**：固定掩模做 Source Optimization（SO），再固定光源做 Mask Optimization（MO），循环数次。实现稳健，容易接入已有 OPC/ILT 引擎。2011 年的梯度框架展示了这种路线。[11]
3. 
4. **同时或联合梯度更新**：一次计算源与掩模的灵敏度，沿组合方向更新。2009 年的像素化方法是代表性公开工作，并把拓扑约束纳入可制造性控制。[6]
5. 
6. **启发式/全局搜索**：遗传算法、粒子群、CMA-ES 等更容易跨越局部极小值，但变量数大时计算昂贵。2021 年厚掩模 EUV SMO 将快速厚掩模模型与粒子群结合，再用严谨电磁模型复核。[15]
7. 
8. **层级、低维或代理方法**：用参数化光源、稀疏基、关键图形筛选、双层优化或机器学习初值缩小搜索空间。它们的价值主要是把更好的物理模型和更多工艺角带进可接受的周转时间，而不是取消最终验证。
9.

还有一个容易混淆的术语问题：论文标题里的 simultaneous、joint、co-optimization，不一定代表每一步都严格同时更新两个变量。有的流程是交替优化，有的是先求连续灰度掩模和像素化光源，再把结果投影到可制造源与二值掩模；也有的只在局部 clip 上联合，随后转入固定光源的全芯片 OPC。评价方法时，应看变量、更新顺序和最终交付物，而不是只看 SMO 这个名字。

## 从理想解到量产解：真正的 SMO 流程

生产流程中，光源和掩模存在一个根本不对称：**光源通常是整层、整张 reticle 甚至一组产品共享的全局自由度，掩模却有数百万到数十亿个局部自由度。** 一个冷门但极端困难的图形，可能把全局光源拉向对其他图形不利的方向。

因此，典型工程流程更接近下面八步：

1. 
2. **定义目标与工艺角**：明确优化停在空中像、胶轮廓还是刻蚀后轮廓，给出焦点、剂量、掩模误差和缺陷率权重。
3. 
4. **建立候选图形集**：从标准单元、存储阵列、逻辑随机图形和历史热点中提取 clips，覆盖方向、节距、二维线端与局部密度。
5. 
6. **做关键图形筛选**：去掉衍射响应高度重复的 clips，同时保留真正约束共同窗口的 active patterns。全芯片 SMO 论文的一个核心贡献，就是用模式筛选把全层覆盖转化为有限训练集。[7][10]
7. 
8. **联合探索源与掩模**：先允许较自由的像素化源、灰度或曲线掩模，观察系统真正需要的衍射级次、SRAF 位置和图形偏置。
9. 
10. **施加硬件与掩模约束**：把理想源投影为 DOE、微镜阵列或 EUV FlexPupil 能实现的分布；把掩模转换为满足 MRC、写入、检测和缺陷控制的形状。
11. 
12. **冻结全局光源**：在可用 scanner 上确认 pupil fidelity、能量效率、对称性、模糊和跨机匹配。
13. 
14. **完成全芯片 OPC/ILT**：在固定源下对各局部图形做高容量掩模优化，并进行全芯片 LRC/验证。
15. 
16. **用严谨模型与晶圆闭环**：检查三维掩模、胶、随机性和刻蚀；通过 AIMS、CD-SEM、轮廓与缺陷数据校准，再决定是否回到前面重选图形或改权重。
17.

这个流程解释了一个表面矛盾：产业资料会同时说“SMO 联合优化光源和掩模”与“最终在固定光源下做全芯片 OPC”。两句话都成立，只是处在不同阶段。公开的现行 Proteus SMO 资料也明确说明，SMO 先为关键图形或 cells 找��光源和掩模解，再借助生产验证过的 ILT/OPC recipe 转入全芯片掩模综合。[21]

## 二十多年发展史：四次跨越

### 1980s–1990s：各自优化的前史

离轴照明、相移掩模、OPC 和逆向掩模设计分别发展；部分相干成像和快速卷积模型成为计算基础。[1][2] 业界已经认识到光源和掩模都是可设计变量，但计算方法与照明硬件仍各自为战。

### 2001–2005：SMO 概念形成

IBM 团队 2001 年在 SPIE 报告、2002 年期刊化的工作明确联合求解最佳掩模与光源；小区域仿真中报告相对传统 RET 的 2–6 倍工艺窗口。[3] 2005 年，Socha 等提出频域 simultaneous SMO。[4]

这一步证明，“共同设计”能找到远离经验规则的解，并把共同工艺窗口而非单点图像作为优化目标。

### 2008–2011：自由形状走向量产流程

Hsu 等把像素化自由光源、灰度掩模、EPE 和 scanner 约束串成流程。[5] Ma 与 Arce 展示像素级同时优化。[6] 2009 年的研究开始面向 22 nm 的大量 clips。[7] 2010 年，自由形状照明在 22 nm SRAM 上完成 DOE 与可编程照明的晶圆比较。[8] 随后出现 from theory to practice 与 full-chip 流程。[9][10]

可编程照明、关键图形筛选、高容量模型和可制造掩模共同让 SMO 从小 clip 走向整层工艺开发。

### 2014–至今：EUV、三维与多目标

2014 年公开的 EUV SMO 已显式考虑反射式三维掩模、斜入射、非远心性和 FlexPupil。[13] 此后，随机性、厚掩模、High-NA 各向异性、曲线掩模与更多工艺目标进入联合优化。[14–20]

优化对象由此从理想空中像扩展到真实扫描机、三维掩模、缺陷率、吞吐量和完整图形转移。

两条历史线索尤其重要。

第一，**算法进展和照明硬件进展缺一不可。** 2009 年前后，自由形状光源不再只靠漫长的定制 DOE 周期，可编程微镜照明使计算结果能够快速落到 scanner。ASML 在 2010 年公开介绍 FlexRay 与 Tachyon SMO 时，已经把前者描述为数千个可调微镜组成的可编程照明器，把后者定位为同步分析光源与掩模的计算工具。[12]

第二，**全芯片并不等于暴力优化全芯片所有像素。** 2009–2011 年的公开工作反复处理同一问题：怎样从海量图形中找出真正改变最优光源的少数约束图形，怎样在固定源下把联合解转成生产级全芯片修正。这仍是今天 SMO 周转时间与可迁移性的关键。

## 2026 年的现状：成熟能力，新的物理边界

### 193 nm 浸没式：方法成熟，价值集中在整层权衡

在 193i 中，自由形状照明、源约束、SRAF、OPC/ILT 与全芯片验证已经形成完整工具链。公开产品资料仍把 SMO 列为先进节点和 EUV 的生产级 mask synthesis 能力；ASML 也继续把 OPC 与 SMO 列为计算光刻的核心组成。[21][22]

但“成熟”不代表每一层都值得做最激进的 SMO。收益取决于层的节距谱、方向性、二维图形比例、是否多重图形化，以及现有标准照明是否已经接近最优。实际应用更像一个经济性判断：为共同窗口多争取的余量，是否抵得过光源开发、模型校准、跨机匹配和更复杂掩模的成本。

### 0.33 NA EUV：光源不再能与三维掩模分开

EUV 是反射式掩模，约 6° 斜入射带来吸收体阴影、方向相关相位、H/V 差异、最佳焦面偏移和非远心图形位移。薄掩模模型下的最优源，加入真实 mask 3D（M3D）后可能不再最优。

2014 年的 EUV SMO 工作已经把 NXE:33x0 的可调 FlexPupil、快速 M3D 模型和 mask defocus 纳入同一流程，用于缓解 H/V bias、Bossung tilt、pattern shift 与 flare 敏感性。[13] 2021 年的厚掩模 SMO 研究则再次说明：快速降阶模型适合进入迭代，但最后仍需严谨电磁模拟验证。[15]

EUV 还把目标从“平均轮廓正确”推向“随机尾部可接受”。光子数、二次电子、光刻胶化学和掩模粗糙度共同造成 LCDU、缺孔和桥连。2015 年已有工作把经验随机 EPE 模型放入 EUV SMO，联合考虑 pupil、mask、dose 与 target CD。[14] 今天更现实的问题不是把随机性压成一个 NILS 权重，而是怎样让优化指标与 after-development、after-etch 缺陷数据真正相关。[16]

### High-NA EUV：SMO 正在变成更大的协同优化

0.55 NA 提高分辨率，同时带来更小景深、中央遮拦、4×/8× anamorphic 成像、半场曝光与 stitching，以及更严苛的 mask 3D 和掩模规则问题。2024 年 imec 的随机逻辑金属研究已经把 absorber、mask tone、SRAF、MRC 与 EXE:5000 条件一起评估；其设置中，方向不同的设计尺度对应不同的 4×/8×掩模放大。[17]

到 2026 年，imec 公布的 High-NA 工作已经不只说 source 与 mask，而是把低折射率相移掩模、胶、刻蚀和 source-mask optimization 放在同一条图形化链上，以实现线端控制与 LCDU 目标。[23] 这代表趋势的实质：SMO 的边界正在向 source-mask-material-resist-etch co-optimization 扩展。

需要克制看待“现状”这个词。公开厂商页面能证明相关能力存在并面向 DUV/EUV、高 NA 与全芯片流程，但不能证明所有先进层都采用相同 recipe，也不能公开客户实际工艺窗口、缺陷率或运行成本。论文里的改善比例也只对其模型、图形集和基线成立。

## 未来五条趋势

### 1. 从交替优化走向可微分、双层和层级优化

传统交替 SO/MO 容易实现，却可能在两个变量之间反复追逐。双层优化把“在当前掩模下，光源已经达到局部最优”写成上层掩模问题的约束，并通过 hypergradient 传递光源响应。2024 年 BiSMO 论文报告了相对其基线的误差和运行时间改善，说明这种数学重构值得继续探索。[18]

真正的产业挑战不是把一个小 benchmark 算得更快，而是把厚掩模、多个工艺角、硬件约束和成千上万 clips 放进同一可微框架，同时保持数值稳定与可解释性。

### 2. AI 更像“领航员”，不是签核模型

最有希望的用法包括：预测初始光源、筛选 active patterns、构建快速 M3D/胶代理模型、调节多目标权重，以及识别优化后仍需严谨验证的区域。

2025 年 SourceNet 用 CNN 为参数化 SMO 预测 seed source，在其数据和实现上报告 87.5% 的速度提升。[20] 这个结果支持“学习一个好初值”有价值，却不能推出神经网络可替代物理优化。跨层、跨 NA、跨 absorber 或跨 scanner 时，数据分布会变化；最终光源还必须满足能量守恒、pupil fidelity、MRC 和晶圆结果。更可信的路线会是 physics-in-the-loop：AI 提案，物理模型优化，严谨模型与硅数据签核。

### 3. 目标函数从 EPE/NILS 转向缺陷率、产能和成本

EUV 曝光剂量既影响随机缺陷，又直接影响 scanner throughput。更高 NILS、最大/最小强度、DOF、dose、mask bias 和 resist/etch 条件之间不是单调关系。未来 SMO 需要优化概率尾部，例如在给定剂量与 throughput 预算下最小化缺孔、桥连和局部 EPE，而不是只最小化平均像素误差。

这要求三类新证据进入闭环：大规模缺陷计量、可校准的随机模型，以及从 ADI 到 AEI 的图形传播。没有这些数据，复杂目标函数只是把未知误差藏进更多权重。

### 4. 曲线掩模和多束写入释放新的掩模自由度

早期 SMO 经常先得到灰度或像素化理想掩模，再“清理”为 Manhattan 几何，清理过程会损失工艺窗口。多束 mask writer 的写入时间对形状复杂度不再像传统 VSB 那样敏感，曲线 OPC/ILT 因而更可行。

这会让 mask 一侧的解空间更接近 SMO 的连续最优解，但不会取消制造约束：曲率、最小空间、剂量调制、mask process correction、检测与修复仍然存在。未来的约束会从“能不能写曲线”转向“什么曲线在完整 mask process 后最稳健”。

### 5. SMO 将融入 DTCO，而不是停在光刻模块

一个全局光源无法同时拯救任意设计规则。反过来，如果允许轻微调整 track pitch、tip-to-tip、cell architecture、cut mask 分解或 patterning scheme，常能获得比继续雕刻光源像素更大的余量。

因此，未来流程会更早地把 SMO 用于 technology pathfinding：比较单次曝光与多重图形化，选择 absorber 与 mask tone，评估设计规则，决定哪些图形交给 source、mask、etch 或 design 解决。此时 SMO 不再只是 tapeout 前的 RET，而是 DTCO 中评估“这套设计—工艺组合是否有可制造解”的求解器。

## 给从业者的六个判断问题

遇到一份 SMO 结果，不妨先问：

1. 
2. **优化的是哪些图形？**clip 集是否覆盖真实产品的节距、方向、二维线端和历史热点，还是只有规则的 line/space？
3. 
4. **优化的是哪个工艺输出？**空中像、固定阈值轮廓、三维胶形还是刻蚀后轮廓？
5. 
6. **工艺角是否足够？**标称条件好看不等于共同窗口更大；焦点、剂量、MEEF、像差和随机性怎样采样？
7. 
8. **光源能否在设备上实现？**pupil fidelity、能量效率、模糊、对称、跨场和跨机匹配是否进入约束？
9. 
10. **掩模是否真的可制造？**MRC 通过只是底线，还要看写入时间、MPC 后形状、检测、修复和缺陷敏感性。
11. 
12. **最终用什么签核？**快速模型生成的最优解，是否经过 M3D/胶/刻蚀严谨模型以及独立晶圆数据验证？
13.

如果这六个问题答不清，漂亮的自由形状 pupil 和 mask 图更可能是“优化器的作品”，还不是“产线的解”。

## 结语

SMO 最值得记住的，不是某一种梯度算法，也不是某张像素化光源图，而是一种工程方法：**当两个子系统通过同一物理带宽强耦合时，分别优化往往会过早锁死自由度。**

过去二十多年，SMO 的进步可以概括为四次落地：从概念上的共同设计，到像素化自由源；从自由源到可编程照明；从小区域仿真到关键图形驱动的全芯片流程；再从理想 DUV 空中像扩展到 EUV 三维掩模、随机缺陷和 High-NA 完整图形化链。

下一阶段也不会是“AI 自动给出万能光源”。更可能的现实是：更强的可微物理模型负责梯度，机器学习负责初值与降阶，曲线掩模和可编程照明提供自由度，计量与硅数据约束真实性，DTCO 决定哪些问题根本不该只由光刻来解。

SMO 的终点从来不是一张最优光源图，而是一个在设备、掩模、工艺、设计和成本约束下仍然可制造的共同窗口。

## 参考文献

[1] C. A. Mack, *Fundamental Principles of Optical Lithography: The Science of Microfabrication*, Wiley, 2007. DOI: 10.1002/9780470723876

[2] A. K. K. Wong, *Optical Imaging in Projection Microlithography*, SPIE Press, 2005. DOI: 10.1117/3.612961

[3] A. E. Rosenbluth et al., “Optimum mask and source patterns to print a given shape,” *J. Microlith., Microfab., Microsyst.* 1(1), 2002. DOI: 10.1117/1.1448500

[4] R. Socha, X. Shi, and D. LeHoty, “Simultaneous source mask optimization (SMO),” *Proc. SPIE* 5853, 180–193, 2005. DOI: 10.1117/12.617431

[5] S. Hsu et al., “An innovative source-mask co-optimization (SMO) method for extending low k1 imaging,” *Proc. SPIE* 7140, 714010, 2008. DOI: 10.1117/12.806657

[6] X. Ma and G. R. Arce, “Pixel-based simultaneous source and mask optimization for resolution enhancement in optical lithography,” *Optics Express* 17(7), 5783–5793, 2009. DOI: 10.1364/OE.17.005783

[7] A. E. Rosenbluth et al., “Intensive optimization of masks and sources for 22 nm lithography,” *Proc. SPIE* 7274, 727409, 2009. DOI: 10.1117/12.814844

[8] J. Bekaert et al., “Freeform illumination sources: an experimental study of source-mask optimization for 22 nm SRAM cells,” *Proc. SPIE* 7640, 764009, 2010. DOI: 10.1117/12.846918

[9] T. Dam et al., “Source-mask optimization (SMO): from theory to practice,” *Proc. SPIE* 7640, 764028, 2010. DOI: 10.1117/12.848257

[10] M.-C. Tsai et al., “Full-chip source and mask optimization,” *Proc. SPIE* 7973, 79730A, 2011. DOI: 10.1117/12.881633

[11] Y. Peng, J. Zhang, Y. Wang, and Z. Yu, “Gradient-based source and mask optimization in optical lithography,” *IEEE Trans. Image Process.* 20(10), 2856–2864, 2011. DOI: 10.1109/TIP.2011.2131668

[12] ASML, “Chipmakers adopt ASML's holistic lithography to continue Moore's Law,” 2010. 原始页面

[13] X. Liu et al., “EUV source-mask optimization for 7 nm node and beyond,” *Proc. SPIE* 9048, 90480Q, 2014. DOI: 10.1117/12.2047584

[14] S. Hsu et al., “EUV resolution enhancement techniques (RETs) for k1 0.4 and below,” *Proc. SPIE* 9422, 94221I, 2015. DOI: 10.1117/12.2086074

[15] Z. Zhang, S. Li, X. Wang, W. Cheng, and Y. Qi, “Source mask optimization for extreme-ultraviolet lithography based on thick mask model and social learning particle swarm optimization algorithm,” *Optics Express* 29(4), 5448–5465, 2021. DOI: 10.1364/OE.418242

[16] J.-H. Franke et al., “Elucidating the role of imaging metrics for variability and after etch defectivity,” *J. Micro/Nanopattern. Mater. Metrol.* 21(2), 023201, 2022. DOI: 10.1117/1.JMM.21.2.023201

[17] S. Hwang, W. Gillijns, S. De Gendt, and R.-H. Kim, “Source mask optimization study for high-NA EUV lithography to achieve single patterning on random logic metal,” *Proc. SPIE* 12954, 129540X, 2024. DOI: 10.1117/12.3010869

[18] G. Chen, H. He, P. Xu, H. Geng, and B. Yu, “Efficient bilevel source mask optimization,” *Proc. 61st ACM/IEEE Design Automation Conference*, Article 142, 2024. DOI: 10.1145/3649329.3656252

[19] Z. Zhang et al., “High-fidelity source mask optimization for suppressing line-end shortening,” *Applied Optics* 63(2), 327–337, 2024. DOI: 10.1364/AO.506473

[20] R. Joglekar, P. Kumar, R. Botta, and N. R. Mohapatra, “SourceNet: CNN-based source prediction for parametric source mask optimization,” *J. Micro/Nanopattern. Mater. Metrol.* 24(4), 043202, 2025. DOI: 10.1117/1.JMM.24.4.043202

[21] Synopsys, “Proteus Solutions: Full-Chip Mask Synthesis,” 访问于 2026-08-04. 产品页面

[22] ASML, “Computational lithography,” 访问于 2026-08-04. 技术页面

[23] imec, “The case for High NA EUV: unlocking the next era of chip manufacturing,” 访问于 2026-08-04. 技术综述
