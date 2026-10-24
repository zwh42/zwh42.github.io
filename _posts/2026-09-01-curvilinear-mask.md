---
layout: post
read_time: true
show_date: true
title: "曲线掩模走到哪一步了"
date: 2026-09-01 21:08:00 +0800
tags: [光刻, 曲线掩模, ILT, 计算光刻]
author: 端点星日志
description: "从 ILT、多束写入到原生曲线 OPC、MRC 与掩模工艺校正，梳理曲线掩模四十年演进和仍未闭合的软件链。"
source_url: "https://mp.weixin.qq.com/s/uozNDwe3Sw_TvHhscfZ_kw"
toc: true
---

一条曲线从 OPC 软件走到晶圆上，至少会换四次身份。

在求解器里，它可能是一张连续灰度场的零等值线，也可能由 Bézier 或 B 样条控制点定义。写进 OASIS 文件时，它常被采样成密集的折线多边形。到了多束电子束写入机里，它又变成像素剂量图。掩模显影和刻蚀以后，设备得到的是一条带着圆化、局部偏差和线边粗糙度的物理轮廓。最后，EUV 扫描器看到的还是一个会产生三维电磁散射的结构。

这几条曲线看起来相近，对软件链却未必等价。一次采样、一次平滑、一次几何清理，都可能拿走一点本来留给晶圆 EPE 的误差预算。

曲线掩模近几年重新升温，原因也在这里。ILT 算法、多束掩模写入、GPU 计算和曲线 Mask Process Correction（MPC，掩模工艺校正）分别打通了链条上的一段。进入量产讨论以后，问题从“能不能画出曲线”转向“这条曲线能否稳定地穿过整条数据和制造流程”。

## 曲线并非 ILT 的同义词

Curvilinear mask 常被直接写成 ILT mask，两者其实不能画等号。

ILT 是一种求解方式。它从目标晶圆图形出发，通过正向光刻模型反复计算，寻找能让晶圆轮廓最接近目标的掩模。曲线则是一种几何表示。ILT 可以在输出端被 Manhattan 化，传统 edge-based OPC 也可以把水平和垂直边扩展成曲线控制点，得到平滑轮廓。

这一区分很重要。它把算法能力和制造能力分开了。论文里出现一张自由形状 mask，只能说明优化器找到过这样的解。若要说一项曲线掩模技术已经落地，还要继续问文件能否承载、MRC 能否检查、MPC 能否补偿、writer 能否按时写完、计量和检查能否给出可复现的验收结果。

## 四十多年走过三段路

曲线掩模的数学源头可以追到 inverse mask design，而它的制造史要晚得多。

1981 年，Bahaa Saleh 和 Soheil Sayegh 用迭代的像素翻转寻找优化原始掩模。这篇论文通常被视作 ILT 的早期起点。原论文记录

1990 年代，Yong Liu 和 Avideh Zakhor 系统讨论 binary 和 phase-shifting mask 的逆向设计。进入 2000 年代以后，level-set、连续像素优化和梯度方法逐渐成熟。Level-set 的价值很直接。边界可以自然地移动、分裂和合并，求解器不用预先规定每一个 serif 和 SRAF 应该长在哪里。2005 至 2006 年，首批 ILT 产品论文、65 nm tape-out 和 full-chip 讨论集中出现。Pang 2021 年的 ILT 历史综述

这时的主要障碍有三个。全芯片求解太慢，分块会留下 stitching 问题，VSB 掩模写入机又要把曲线打碎成大量矩形或梯形 shot。数学上很漂亮的 mask，到了写入端可能贵得无法接受。制造规则往往还在优化之后才介入，几何清理又会损失一部分工艺窗口。

2010 年前后，业界已经用 VSB 试写 wavy metal 和曲线 assist feature，但 shot count 仍是硬约束。多束掩模写入随后改写了这个约束。

IMS 在 2011 年完成了一台 262,144 束的 proof-of-concept 工具。2012 年公开的论文给出了 20 nm beam、`82 μm × 82 μm` 阵列场和第一批写入结果，并把生产工具排到 2016 年。IMS 2012 年 POC 论文 IMS 的公司历史如今记录了 2014 年 commercial alpha 和 2016 年起的 production deliveries。IMS 公司历史

多束写入把数十万束固定小 beam 并行开关，写入时间对图形复杂度的敏感性显著下降。NuFlare 当前列出的 MBM-2000 和 MBM-2000PLUS 面向 3 nm 与 3 nm+ design rule，页面同时强调设备要处理 terabyte 级数据。NuFlare 当前产品页 这组事实很能说明问题。曲线造成的负担没有消失，它从 VSB shot 数转移到了 rasterization、剂量计算、数据通路和校准。

第三段路发生在 2019 年以后。GPU 和专用全芯片架构把 curvilinear ILT 的公开演示推进到一至两天量级。OPC、ILT、MRC、MPC 和 fracture 也开始围绕原生曲线改造。2022 年，Micron 在 DRAM 和 NAND 的公开演示中讨论 DUV 与 EUV 曲线 mask，并给出一个 DRAM array 例子，作者报告曲线方案相对矩形方案约有 10% 的 wafer CD uniformity 改善。同一份材料也明确写出，full-curvilinear tapeout 所需基础设施仍要继续推进。Micron 2022 年演示文稿

到 2025 年，Micron、NuFlare 和 D2S 又公开了全版图在线线性校正结果。材料最后采用的措辞是 Micron 已开始把 PLDC-MPC 纳入生产 qualification。四类测试结构里，PLDC 在三类上表现更好，dark pillar 仍有一种离线 MPC 更优。Micron 2025 年演示文稿

这是一条比“已经量产”更有价值的进展。它给出了 qualification 的位置，也保留了尚未被一种方法统一解决的图形差异。

## 今天走到哪一层

截至 2026 年 8 月，公开资料支持下面这幅图景。

| 环节 | 已公开进展 | 仍需闭合的问题 |
| --- | --- | --- |
| 曲线 OPC 与 ILT | 商业工具已公开支持 native curvilinear 和 full-chip flow，论文也给出整芯片优化框架 | runtime、模型精度、stitching、MRC 入环和多工艺角收敛 |
| 数据交换 | PWL OASIS 可交付，SEMI P49 定义实验性 spline multigon | 原生格式尚处过渡期，旧 reader 不兼容，跨工具公差仍会累积 |
| 掩模写入 | IMS 和 NuFlare 都有商用多束 writer，VSB 也有 writer-aware co-optimization 路线 | rasterization、实时剂量计算、resist 和校准仍限制数据通路 |
| MPC 与 MRC | CLMPC、曲线 MRC、PLDC 和 integrated pipeline 均有论文或联合验证 | 不同结构的最优方案不统一，规则定义、模型和全版图 TAT 仍在演进 |
| 计量和检查 | contour metrology、sEPE、large field of view 和 deep check 已成为专门研究方向 | 等效 CD、缺陷判定、轮廓抽取不确定度和 HVM 吞吐量仍缺统一答案 |
| High-NA EUV | 曲线 OPC 与 mask data preparation 已有公开研究，计算平台也把它列为目标场景 | 严格三维模型、部分相干照明、anamorphic 各向异性和 signoff 成本很高 |

因此，曲线 mask 已经越过“只有 clip 仿真”的阶段，也越过“电子束能否画出来”的阶段。它正在进入按图形、按层和按制造流程逐段 qualification 的时期。把它写成先进节点的通用默认值，公开证据还不够。

## OPC 的变量变了

传统 model-based OPC 很习惯一条由水平和垂直 segment 组成的边。fragmentation 决定控制边的粒度，优化器沿法向移动 edge，最后再做 MRC 和验证。

曲线 OPC 可以继续沿用边移动的思路，但变量已经从 segment 位移变成曲线控制点、切向角、弧长和局部曲率。若采用 B 样条，一段轮廓可以写成

C(u)=∑iNi,p(u)Pi

这里的 Pi 是控制点，Ni,p 是 p 次样条基函数。少量控制点就能表达长而平滑的边界，也能把相邻曲段的连续性放进数学定义。

代价随后落到几个新问题上。控制点放得太稀，局部 lithography hotspot 跟不上。放得太密，优化变量和文件尺寸又会膨胀。控制点移动还可能引起 self-intersection、窄颈或拓扑变化。曲线被转回 PWL 后，同一条理论轮廓会因为采样步长不同，得到不同的曲率、最小间距和 MRC 结果。

近年的研究路线很有代表性。有人把二维边界映射成 tangent-angle 和 arc-length 函数，有人只在敏感区域动态插入控制点，也有人直接在 Bézier 或 B-spline 上做 OPC 和 MPC。共同目标都是减少无效自由度，同时保留 mask target 的几何语义。

这些方向已经进入密集发表期。2025 年的 TAAL 方法把二维边界压成切向角和弧长函数，论文发表于 Optics Express。同年还有用 MLP 预测端点、GCN 调整中间控制点的 ML-guided curve correction，论文发表于 IEEE Transactions on Semiconductor Manufacturing。2026 年的 demand-driven 方法继续把控制点集中到误差敏感区，论文发表于 Optics Express。曲线 OPC 的研究焦点已经从能否移动曲线，走到怎样用更少变量取得可签核的精度。

## 目标函数也不能只看 wafer EPE

一个面向实际流程的曲线 mask 优化，可以抽象成下面的形式。

J(M)=∑c∈CwcD ⁣(W(F(M;θc)),T)+λRcurve(M)+μRMRC(M)+νRwrite(M)

F 是光学、Mask3D 和 resist 的正向模型，W 给出晶圆轮廓，T 是目标图形，C 覆盖不同 focus、dose 和工艺条件。后三项分别惩罚不稳定曲率、违反掩模规则的形状和过高的写入代价。

公式本身不难，难的是这些项何时进入求解。

如果 ILT 先把 wafer error 压到最低，最后再用独立 cleanup 切掉小 SRAF、磨平尖点，得到的已经是另一个 mask。OPC 或 ILT 必须重新验证，有时还要重新优化。曲线 MRC 因而越来越早地进入主循环，或者作为每轮更新后的 projection step。

早期曲线 MRC 提出过 minimum manufacturable circle。一个给定半径的圆能沿图形内部和外部平滑滚过，才说明局部宽度、间距和曲率有制造余量。后来又加入 run-length 条件，避免两条曲线只在一个孤立点靠得很近就被误报。这类规则比传统 corner-to-corner 距离更接近连续边界的物理含义。

全芯片场景还多一层工程矛盾。把曲线离散得更细，检查更接近几何真值，数据和运行时间随之增加。直接在 Bézier 上做 native check，能减少 PWL 转换误差，但 boolean、offset、distance 和 violation marker 都要有稳定的曲线算法，已有的 Manhattan 几何内核不能原封不动搬过来。

这类问题已经形成独立的论文序列。2020 年的工作系统讨论了 curvilinear mask shapes 的 MRC，2023 年的 JMM 论文则把 cubic Bézier 的控制点移动、规则约束和 OPC 流程放在一起处理。Curvilinear mask handling in OPC flow

## 数据格式成了精度问题

很多软件团队把格式看成 I/O 问题。对曲线 mask 来说，格式会改变结果。

SEMI P39 OASIS 用 piecewise-linear polygon 保存曲线。轮廓公差越紧，vertex 越多，OPC、MRC、MDP 和 writer 之间每过一次接口，都可能重新采样一次。重复的拟合与反拟合会改变局部曲率，也会让两个工具对同一处 violation 得出不同结论。

SEMI P49-0823 为 P39 定义了实验性的 curvilinear multigon 扩展，允许用 spline control point 传递曲线。SEMI Standards Store 的 P49 条目写得很清楚。它希望减少 ILT 文件尺寸，并让工具间传递 spline figure 时不再插值或丢失信息。它也明确说明，P49 文件与现有 P39 reader 不兼容。SEMI Standards Store 的 P49 条目

截至本文写作时，SEMI Standards Store 仍把 P49-0823 标为 Preliminary 和 Current，条目里却保留了原定 2025 年撤下的通知。这个细节比一句“已经有标准”更接近实际状态。原生曲线格式已经进入行业协作，标准化和互操作仍在过渡。

这也解释了为什么一些 EDA 厂商开始强调 integrated pipeline 或 direct writer handoff。OPC、MRC、MPC 和 fracture 若能在同一进程内共享曲线对象，便可少写几次巨型中间文件，也少做几次几何离散。Synopsys 当前的 Proteus 页面已经公开列出 native curvilinear、full-chip ILT、LRC，以及把 fracture 并入 mask synthesis 的 DMW 流程。Synopsys Proteus 产品页

## MPC 面对的是第二个逆问题

MPC 的英文全称是 Mask Process Correction，通常译作掩模工艺校正。OPC 补偿的是掩模图形经过光刻后在晶圆上的成像误差。MPC 补偿的是电子束写入、resist、显影和刻蚀给物理掩模带来的误差。

OPC 工程师关心 mask 怎样在 wafer 上成像。mask shop 还要解决另一个方向相似、对象不同的逆问题。

> wafer target → OPC 或 ILT → ideal mask target
> 
> ideal mask target → MPC 与 writer correction → physical mask contour
> 
> physical mask contour → scanner → wafer contour

电子束邻近效应、resist、显影和刻蚀会让 mask target 发生局部 bias 和圆化。传统 MPC 常沿 Manhattan edge 做位移。曲线轮廓需要按曲率自适应 fragmentation，或者直接移动 Bézier 控制点。高曲率区需要更密的约束，低曲率长边又不值得浪费同样数量的采样点。

多束 writer 还提供了另一个自由度。它可以在像素域调 dose，用剂量而非大幅改形来移动物理边界。PLDC 把这一步放进 writer rasterization data path，省掉离线 MPC 文件往返。2025 年的 Micron 联合材料显示，这条路线已经开始 production qualification，同时也显示 dark pillar 仍可能更适合某种离线方案。

这对 OPC 软件提出了一个很实际的新课题。OPC 交付的理想 mask target、MPC 使用的模型和 writer 能执行的 dose map，最好共享同一套误差预算。若 OPC 只优化理想几何，MPC 只追逐 mask SEM contour，双方在不同表示和不同公差上各自收敛，最后的 wafer EPE 仍可能失控。writer-aware OPC、mask-wafer co-optimization 和 design-mask-wafer co-optimization 都是在收紧这处接口。

## EUV 把曲线重新变成三维问题

DUV OPC 常能在较薄的 mask 近似下工作。EUV mask 是反射式多层膜结构，光以斜角入射，absorber 高度相对波长不可忽略。mask near field 会随 feature orientation、偏振和 source point 改变。

曲线把一条边上的方向从几个离散角度扩展成连续分布。到了 High-NA EUV，anamorphic imaging 又让两个方向的缩小倍率不同。一个只在二维轮廓上表现良好的 mask，放进严格三维模型后可能出现 shadowing、best-focus shift 和方向相关的 CD 误差。

GPU 平台会继续压低成本。NVIDIA 当前的 cuLitho 页面把 curvilinear OPC 和 High-NA EUV 列为目标场景，并给出 ILT 最高 40 倍的供应商 benchmark。页面也引用 TSMC 对 production deployment 的表述。NVIDIA cuLitho 页面 这类倍数应放回测试边界里理解。一个 imaging kernel 或 ILT 主循环的加速，不会自动消除 MRC、MPC、fracture、verification、模型校准和 I/O 的时间。

## CD 不再是一个足够的数

矩形线条可以用一两个 CD gauge 描述。自由曲线的误差分布在整条轮廓上。同样的平均 CD，可能对应完全不同的局部凹陷、凸起和高曲率偏差。

曲线 metrology 因此转向 contour-based measurement。系统从 SEM 图像提取物理轮廓，再沿目标边界布置密集法向 gauge，统计每一点的 EPE。近年的论文开始讨论 sEPE、等效 CD、等效 LER 和等效 CDU，也有人只在高曲率区域使用完整二维轮廓，在简单区域保留传统一维 CD，以控制 HVM 吞吐量。

检查也遇到类似问题。复杂 SRAF 上的一点边缘波动，可能是设计本来就允许的曲线，也可能是会打印的 defect。die-to-database inspection 必须知道目标曲线的几何公差、物理 mask 模型和 wafer printability。Samsung 在 2024 年专门发表了 curvilinear mask deep check 论文，已经说明预先发现这类缺陷正在成为独立的软件任务。论文记录

OPC model calibration 也要随之改变。训练集若仍由水平线、垂直线和少量 corner gauge 主导，模型会在连续方向、高曲率和二维邻域上外推。curve-aware calibration 需要覆盖局部半径、切向角、邻域密度、writer signature 和 contour extraction uncertainty。signoff 比主求解器更保守，因为更大的解空间也意味着更多模型外区域。

## 近期更现实的落地方式

公开材料显示，近期更可能扩大的是几条有边界的路线。整张版图无差别自由曲线还缺少公开证据。

一类是图形选择。接触孔、via、line end、二维拐角和复杂 SRAF 通常比规则的一维 line-space 获益更明显。将曲线优化集中在 lithography-sensitive 的二维区域，可以把计算和数据预算花在收益最大的地方。

一类是混合求解。重复 memory array 或 critical clip 用 ILT，外围和规则图形保留 conventional OPC，再处理两种解之间的 blend。曲线 OPC 也可以只优化 main feature，SRAF 由快速 ILT 或模型预测生成。

一类是 writer 分流。先进 EUV mask 更适合 MBMW 的像素化写入，既有 193i 流程仍可能使用 VSB，再通过 overlapping shot 和 mask-wafer co-optimization 把写入时间控制在可接受范围。

还有一类发生在软件架构里。工具内部尽量保留原生曲线，中间步骤用共享内存和 pipeline 传递对象，必要时才离散成 writer 或 legacy interface 能接受的格式。减少一次文件落盘，有时也等于减少一次几何误差。

## 接下来要看的指标

判断一项曲线 mask 发布是否接近生产，可以盯住几件具体的事。

- 
- 报告的是单个 clip、`1 mm²` 晶圆面积、full chip，还是 full reticle
- 
- runtime 只含 ILT 主循环，还是含 MRC、MPC、fracture、verification 和 I/O
- 
- mask 数据是 PWL、native Bézier、B-spline，还是 writer pixel dose
- 
- 结果来自 simulation、写后 mask SEM、AIMS、wafer exposure，还是产品层 qualification
- 
- MRC 在优化前、优化中还是输出后执行，cleanup 后有没有重新做 wafer signoff
- 
- 性能数字是否给出硬件、模型精度、process corner ���误差阈值
-

曲线掩模已经有可用的写入设备、商业 EDA 支持、晶圆厂联合验证和逐渐成形的计量方法。短板也很清楚。原生格式仍在过渡，严格 Mask3D 计算很重，二维 contour 的检查和计量吞吐量不足，不同图形的 MPC 最优解也没有统一。

它带给 OPC 的最大变化，最终落在一个朴素要求上。软件交出的对象已经变成一条连续轮廓，它需要在优化、交换、制造和签核之间保持同一份物理含义。

这条轮廓每少经历一次无谓的离散，少丢掉一份曲率信息，少消耗一点 EPE 预算，曲线 mask 就向量产走近一步。

## 主要资料

- 
- Saleh 与 Sayegh 1981 年论文
- 
- Pang 2021 年 ILT 三十年综述
- 
- 2023 年 curvilinear mask handling in OPC flow
- 
- 2025 年 TAAL curvilinear OPC
- 
- 2026 年动态控制点 curvilinear OPC
- 
- IMS 2012 年多束写入 POC 论文
- 
- IMS 多束掩模写入产品页
- 
- NuFlare 电子束掩模写入产品页
- 
- Micron 2022 年 DUV 与 EUV 曲线掩模材料
- 
- Micron 2025 年全版图在线 MPC 材料
- 
- SEMI Standards Store 的 P49 条目
- 
- Synopsys Proteus 产品页
- 
- NVIDIA cuLitho 产品页
- 
- 2026 年曲线掩模技术综述
-

*文中厂商性能数字和产品能力均按其公开材料限定使用。行业材料仅作事实引用，转载原图前仍应向权利人确认授权。*
