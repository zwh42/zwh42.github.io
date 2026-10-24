---
layout: post
read_time: true
show_date: true
title: "曲线掩模的表示、制造与精度控制"
date: 2026-09-01 21:08:00 +0800
tags: [光刻, 曲线掩模, ILT, 计算光刻]
author: 端点星日志
description: "从曲线几何与嵌套逆问题出发，系统分析 ILT、多束写入、MRC、MPC、格式公差、EUV 三维效应及轮廓签核。"
source_url: "https://mp.weixin.qq.com/s/uozNDwe3Sw_TvHhscfZ_kw"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

*2026-10-25 修订 · [计算光刻阅读路线](/lithography/)*

曲线掩模在求解、数据交换、电子束写入和实际制造中采用不同表示。隐式边界或样条需要转换为交换几何和写入剂量，实际掩模又包含侧壁、圆角和材料堆栈。这些转换会改变边缘位置，并通过光刻敏感度影响晶圆轮廓。

曲线的工程价值取决于新增几何自由度能否改善晶圆成像，以及这部分收益在格式转换、掩模加工和验证后能否保留。本文将掩模优化与制造视为嵌套的逆问题，分析曲线参数化、规则检查、写入成本和精度预算，并区分仿真、实物掩模及晶圆曝光所能提供的证据。

## 曲线几何与掩模优化方法

OPC 是为了补偿邻近效应而修改掩模的任务；ILT 是用光刻前向模型求解逆问题的一类方法；curvilinear 描述的是输出形状。ILT 可以输出经过矩形化的掩模，边缘式 OPC 也可以直接优化曲线，因此两者没有一一对应关系。

<figure class="technical-figure" id="fig-1">
  <div class="figure-image"><a href="/assets/images/references/optical-proximity-correction.png" target="_blank" rel="noopener" aria-label="光学邻近效应修正的设计、掩模与成像示意，在新标签页查看大图"><img src="/assets/images/references/optical-proximity-correction.png" alt="光学邻近效应修正的设计、掩模与成像示意" width="518" height="762" loading="lazy" decoding="async"></a></div>
  <figcaption markdown="span">图 1：LithoGuy，Optical proximity correction（2010），[Wikimedia Commons 原文件页](https://commons.wikimedia.org/wiki/File:Optical_proximity_correction.png)，作者释入公有领域（public domain），未修改。该图是 OPC 几何原理示意，既不是 SEM 数据，也不是本文所讨论的曲线掩模制造结果。访问日期：2026-10-25。</figcaption>
</figure>

目标晶圆图形通常含有直角，但投影光学系统带宽有限，高频几何细节不能原样传到像面。允许掩模边界自由弯曲，相当于增加了一组可调的衍射自由度：优化器可以调整不同频率和方向的复振幅，使光强等值线在目标边缘附近有合适位置与斜率。

掩模上的弧形突起、凹口和辅助图形用于调整衍射，使晶圆直边、转角和线端接近目标。轮廓平滑度本身无法确定工艺窗口，候选几何仍需在相同光学与胶模型下扫描焦点、剂量及掩模误差。

Pang 等的 2021 年论文给出曲线 ILT、多束写入、写后掩模与晶圆曝光之间的实际关联；它比一张孤立的优化截图更接近完整证据链。该论文的具体设备、材料和测试图形仍然限定了结论范围。[[1]](https://design2silicon.com/wp-content/uploads/2021/11/JM3-21046SS_online.pdf)

## 包含制造约束的嵌套逆问题

设 $T$ 为晶圆目标，$M$ 为理想掩模，$\mathcal F_c$ 是条件 $c$ 下的光学—胶模型。一个标称逆问题可以写成

$$
\min_M D\!\left(\mathcal F_{c_0}(M),T\right).
$$

只优化标称误差可能得到狭窄工艺窗口。更合理的工程目标会覆盖焦点、剂量及其他已定义条件：

$$
\begin{aligned}
&\min_M\;\sum_{c\in\mathcal C}w_cD\!\left(\mathcal F_c(M),T\right) +\lambda R_{\mathrm{shape}}(M), \\
&M\in\mathcal A_{\mathrm{mask}}.
\end{aligned}
$$

$\mathcal A_{\mathrm{mask}}$ 是可制造掩模集合，至少约束最小宽度、最小间距、局部曲率、孤立碎片与拓扑；$R_{\mathrm{shape}}$ 则可以抑制不稳定的边界振荡。约束和正则化不是同一个东西：一个小权重惩罚不能保证没有违规，最终还需要独立 MRC。

平均加权损失也可能牺牲少数关键图形。若某个极端焦点必须合格，可以增加最大误差约束 $D_c\le\tau_c$，或用 $\max_c D_c$ 构造稳健目标。条件集只是对真实波动的离散近似，不能因为跑了若干 corners 就声称覆盖了全部概率尾部。

更接近实物的关系还要把掩模制造写进去：

$$
\begin{aligned}
M_{\mathrm{phys}}&=\mathcal P(G,\mathbf d;\boldsymbol\psi), \\
C_{w,c}&=\mathcal F_c(M_{\mathrm{phys}}).
\end{aligned}
$$

$G$ 是交付几何，$\mathbf d$ 是电子束剂量图，$\mathcal P$ 包含写入、掩模胶、显影和刻蚀，$\boldsymbol\psi$ 是掩模工艺参数。OPC 求的是晶圆目标，MPC 求的是把交付数据制造成所需物理掩模。两者是嵌套的逆问题。若前者假设理想曲线，后者只能近似制造，必须把后者的偏差重新传回晶圆模型。

## 曲线表示与几何梯度

像素式方法直接优化二维场，随后用阈值或投影生成边界；level-set 用一个标量场的零等值线表示边界，便于自然地分裂和合并；样条方法直接优化控制点，可以用较少变量描述长而平滑的轮廓。它们的计算成本、拓扑能力和约束难度不同。

以 B 样条为例，边界为

$$
\mathbf C(u)=\sum_i N_{i,p}(u)\mathbf P_i.
$$

控制点少，几何紧凑但可能表达不了局部热点；控制点太密，优化器更容易追逐模型误差，产生短波起伏。对弧长 $s$ 参数化的平面曲线，可以使用

$$
R_{\mathrm{bend}}=\int\kappa(s)^2\,\mathrm ds
$$

作为弯曲正则项。它偏好平滑，却不直接保证最小线宽、最小间距或无自交。两段各自很平滑的边，仍能相互靠得过近。闭合轮廓、孔洞、邻接关系和轮廓方向，也必须由几何内核一致处理。

控制点在数学上彼此独立，并不代表晶圆响应局部独立。一个点的移动会改变一段边界，衍射又把这段变化耦合到邻域。可用链式法则连接几何与光刻梯度：

$$
\frac{\partial J}{\partial\mathbf P_i}
=\int_{\partial M}\frac{\delta J}{\delta n(s)}
\frac{\partial n(s)}{\partial\mathbf P_i}\,\mathrm ds.
$$

前一项来自光刻模型的形状敏感度，后一项来自曲线基函数。优化在何处加控制点，应同时考虑局部曲率、EPE 和敏感度，而不能只对所有边做等间距加密。曲线处理进入 OPC 主流程的公开研究，正是在处理这种几何自由度与制造约束之间的连接。[[2]](https://doi.org/10.1117/1.JMM.23.1.011203)

## 多束写入的成本结构与适用条件

可变成形束（VSB）把复杂轮廓切分为可写的 shot。曲线被逼近得越精细，通常需要越多或更复杂的分割；写入负担与 shot 数、剂量、重叠及设备模式有关。于是“光学上最好的形状”可能在写入时间或掩模误差上付出很高代价。

多束掩模写入（MBMW）使用大量并行小电子束，在像素域调制曝光。IMS 的官方产品文档列出 512×512 个可编程束的架构；这说明图形的复杂度可以主要转化成数据和剂量计算问题，而不再直接等价于 VSB 的 shot 数增长。[[3]](https://www.ims.co.at/en/products/)

多束写入对几何复杂度的时间收益具有特定比较条件：同一模式、同一面积、相近剂量及扫描策略。更高剂量、更小像素、更严格精度、更多 pass 或校准开销仍可能增加总时间。[[1]](https://design2silicon.com/wp-content/uploads/2021/11/JM3-21046SS_online.pdf)[[3]](https://www.ims.co.at/en/products/)

电子束前向和背散射、掩模胶响应、显影与刻蚀都没有因为并行束而消失。像素的剂量量化、束间一致性、数据吞吐与校准还会留下新的误差来源。多束写入解除的是一种重要的几何复杂度瓶颈，而不是 Maxwell 方程之后所有问题。

完整交付周期需要计入光刻求解、MRC/MPC、数据转换、栅格化、传输、电子束曝光、工艺和检查。主循环加速的贡献取决于其在总时间中的占比。

## 连续几何的规则检查

传统规则经常用矩形角点或有限方向距离描述。曲线边界上方向连续变化，最小距离可能出现在两个采样点之间，高曲率处也可能没有一个显眼的角。若只检查离散顶点，很容易漏掉真正的窄颈。

几何层面至少要考虑三类条件：内侧最小宽度、外侧最小间隙，以及局部最小曲率半径。用一定半径的圆盘在内外边界附近滚动，是理解这些约束的一种方法；但实际规则还可能要求危险距离持续一定弧长，以区分孤立的接近与可持续的窄缝。不同 mask shop 的验收规则仍应明确配置，不能把一个教学定义宣称为统一标准。

MRC-aware ILT 的研究把规则相关信息提前放入优化，减少最后再删除碎片、磨平尖点造成的图形损失。[[4]](https://design2silicon.com/wp-content/uploads/2020/08/111480T-2019.pdf) 但是只要做过 cleanup，就已改变 $M$。正确闭环应重新计算晶圆多条件结果，再决定是否需要优化；不能沿用 cleanup 之前的签核报告。

另一种风险来自几何公差。如果优化器、检查器与 writer 对“同一条曲线”各用不同离散化，检查通过的对象可能并不是最终制造的对象。所有接口都应记录坐标单位、取整规则、距离定义和最大逼近误差。

## 数据格式与转换公差

用分段直线（PWL）逼近圆弧，若半径为 $r$、弦长为 $\ell$，最大弦高误差为

$$
\epsilon=r-\sqrt{r^2-(\ell/2)^2}
\approx\frac{\ell^2}{8r}\qquad(\ell\ll r).
$$

给定允许误差 $\epsilon$，采样长度应大致满足 $\ell\lesssim\sqrt{8r\epsilon}$。同样公差下，小半径区域需要更密采样。这是几何推导，不是任何设备的精度承诺，也不是把 mask-plane 误差直接当作 wafer-plane EPE。

从掩模误差到晶圆误差还需通过局部光刻增益。若缩小倍率为 $R$，局部 MEEF 为 $m$，很粗略的一阶关系是 $\lvert\delta x_w\rvert\sim m\lvert\delta x_m\rvert/R$。二维曲线的响应还与方向、焦点和邻域有关，因此分配格式公差时应使用代表性图形仿真，不能只除以缩小倍率。[[5]](https://doi.org/10.1109/66.843639)

多次转换的误差也不能天然平方相加。rounding、offset、重新拟合常常带有同向偏差；保守上界应先考虑各段最大误差相加，再用实测或统计证明能否放松。若某次转换引起拓扑变化，例如窄颈消失，局部小扰动近似已经失效。

SEMI P49 为 P39 引入实验性 curvilinear multigon 扩展，以 spline 控制点传递曲线。SEMI 的 2023 年说明与标准商店摘要都强调其目标是减少插值和信息损失，同时说明与原 P39 reader 的兼容限制。[[6]](https://store-us.semi.org/products/p04900-semi-p49-specification-for-experimental-curvilinear-multigon-extension-to-semi-p39) 本文核查时，商店同时保留 Preliminary/Current 标记和原定 2025 年撤下的通知；这类网页状态不能作为“整个产业已统一格式”的证据。

实际交付更应建立互操作测试：同一基准曲线经过 writer A、reader B、MRC C 后，比较 Hausdorff 距离、面积差、最小间距与拓扑是否一致。用文件哈希能证明字节没变，证明不了两个工具对曲线语义的解释一致。

## EUV 与 High-NA 的三维响应

曲线是一种二维几何描述，而 EUV 掩模是反射式多层膜与吸收体构成的三维结构。吸收体厚度、侧壁和斜入射使出射衍射场依赖方向、偏振和源点。连续曲线意味着一条边的切向方向也在连续改变，不能只给水平边和垂直边各加一个常数偏置。

三维掩模电磁计算需要保留复振幅和相位。Pomplun 等用严谨有限元与散射数据反演侧壁角等几何参数，展示了形貌改变如何进入可测的衍射响应。[[7]](https://arxiv.org/abs/physics/0610236) 这类证据同时说明，几何参数需要计量约束；光学求解更严谨，不会自动让输入的侧壁角更真实。

High-NA EUV 还使用非等倍率（anamorphic）成像，因此要明确曲率、间距和误差在哪个坐标系定义。一次各向异性缩放能把圆变成椭圆，也会改变切向方向与局部曲率。mask-plane 规则、wafer target 和 writer 坐标不能混用；模型验证时需在变换后的正确坐标中比较轮廓。

严格求解成本推动了紧凑 Mask3D 与矢量快速成像的发展。Guo 等 2025 年工作将角度相关的掩模响应纳入全矢量 Hopkins 表述，是组织复杂响应的一种研究路线。[[8]](https://doi.org/10.1364/OPTICA.565511) 它不意味着任意曲线、任意材料堆栈都已自动获得可靠的全芯片模型；紧凑表示仍需在连续方向、曲率和邻近组合上校准与验证。

## 轮廓计量与误差分解

对自由曲线，平均 CD 相同可以对应完全不同的局部凹陷、凸起和线端偏差。更自然的观测是轮廓：在目标边界 $\mathbf r(s)$ 的法向 $\mathbf n(s)$ 上，比较实际边缘与目标的有符号距离 $e(s)$，再统计分位数、最大误差和按曲率或方向分箱的残差。

这个定义并非处处自动成立。目标附近若有多个交点、边界自交或拓扑变化，法向对应可能不唯一；远距离失配宜补充最近距离、Hausdorff 距离或连通性判定。报告 contour EPE 时必须说明配准、平滑、抽边算法与排除条件。

测量本身还包含 SEM 点扩散、边缘材料对比、束流噪声与扫描失真。把轮廓采样得更密，不会凭空增加同样多的独立信息。重复图像、不同扫描方向和计量条件有助于估计这些不确定度；算法若沿边界过度平滑，可能同时抹掉真实的高曲率制造偏差。

误差预算包含数据库到物理掩模的 mask EPE、物理掩模到晶圆的 wafer EPE，以及量测和抽边造成的观测误差。前两项通过光刻敏感度关联，第三项限制了误差的可辨识精度，轮廓叠加图需要结合计量模型解释。

## 仿真、掩模与晶圆证据

| 证据层次 | 能证明什么 | 下一步要补什么 |
| --- | --- | --- |
| 仿真 clip | 特定模型与图形上的可优化性 | 未见图形、多条件、不同模型验证 |
| full-chip / full-reticle 数据处理 | 尺度、内存和运行时间的可行性 | 写后掩模精度和完整 TAT |
| 写后 mask SEM / 计量 | 可制造性与 mask 误差 | 实际 scanner 与 wafer 结果 |
| wafer exposure / FEM | 特定工艺的晶圆轮廓与窗口 | 产品覆盖、缺陷及可靠性统计 |
| layer qualification | 指定层、机台、材料和版本的适用性 | 变更后的重新验证与持续监控 |

公开论文已给出多束写入和晶圆曝光结果，商业工具也有全芯片曲线 OPC 的技术说明。[[1]](https://design2silicon.com/wp-content/uploads/2021/11/JM3-21046SS_online.pdf)[[9]](https://resources.sw.siemens.com/en-GB/technical-paper-rapid-full-chip-curvilinear-opc-for-advanced-logic-and-memory/) 这些事实支持“整条链已有实际实现”，但不能推导为“每一层都应该改成自由曲线”。实际收益取决于该层最薄弱的图形、掩模预算、模型覆盖和写入能力。

一个可靠比较，应对曲线与基线方案使用相同 target、相同可制造约束、相同 focus/dose 条件和独立验证模型。除了标称 EPE，还要报告共同工艺窗口、mask error sensitivity、最坏轮廓、检查遗漏、文件与内存、端到端运行时间。接触孔改善而规则线阵无收益，或一个 mask tone 优于另一个，都应按实际范围呈现。

## 交付几何与验证记录

曲线掩模交付需要记录原生曲线与最终写入数据的对应关系、每次近似的公差、MRC 规则及版本、MPC 参数与适用域，以及写后掩模和晶圆验证覆盖的范围。

这份约定让优化器知道什么可以自由改变，让 mask shop 知道要制造哪一条边界，也让晶圆工程师知道仿真预测的是理想曲线还是实际掩模。曲线增加的自由度只有穿过这条证据链，才能转化成稳定的晶圆工艺余量。

## 参考文献与图片出处

网页访问日期均为 2026-10-25；文中的样条、曲率正则化、弦高与误差传递公式为一般数学表达和局部推导，并非引述某一厂商产品实现。

1. Linyong Pang, et al. “Breakthrough curvilinear ILT enabled by multi-beam mask writing.” *Journal of Micro/Nanopatterning, Materials, and Metrology*, 20(4):041405, 2021. [DOI:10.1117/1.JMM.20.4.041405](https://doi.org/10.1117/1.JMM.20.4.041405)，[作者机构全文](https://design2silicon.com/wp-content/uploads/2021/11/JM3-21046SS_online.pdf)。
2. Yung-Yu Chen, Kai-Hsiang Chang, Wen-Li Cheng, Yu-Po Tang. “Curvilinear mask handling in OPC flow.” *Journal of Micro/Nanopatterning, Materials, and Metrology*, 23(1):011203，2023 年在线发表 / 2024 年卷期。[DOI:10.1117/1.JMM.23.1.011203](https://doi.org/10.1117/1.JMM.23.1.011203)，[作者论文目录](https://yyc.solvcon.net/en/latest/writings.html)。
3. IMS Nanofabrication. “Our products.” [官方产品文档](https://www.ims.co.at/en/products/)。束阵列架构与写入模式为厂商说明，不能替代独立良率验证。
4. Ryan Pearman, et al. “Adopting curvilinear shapes for production ILT: challenges and opportunities.” *Proceedings of SPIE*, 11148:111480T, 2019. [作者机构全文](https://design2silicon.com/wp-content/uploads/2020/08/111480T-2019.pdf)。
5. Alfred K. Wong, Richard A. Ferguson, Scott M. Mansfield. “The mask error factor in optical lithography.” *IEEE Transactions on Semiconductor Manufacturing*, 13(2):235–242, 2000. [DOI:10.1109/66.843639](https://doi.org/10.1109/66.843639)，[IBM 原始摘要](https://research.ibm.com/publications/the-mask-error-factor-in-optical-lithography)。
6. SEMI. *SEMI P49-0823 (Preliminary): Specification for Experimental Curvilinear Multigon Extension to SEMI P39*, 2023. [标准目录与摘要](https://store-us.semi.org/products/p04900-semi-p49-specification-for-experimental-curvilinear-multigon-extension-to-semi-p39)，[SEMI 发布说明](https://www.semi.org/en/standards-watch-2023-jun/new-preliminary-standard-for-curvilinear-approved)。本文只据公开摘要说明，未把付费全文未读取条款写成结论。
7. Jan Pomplun, Sven Burger, Frank Schmidt, et al. “Rigorous FEM-Simulation of EUV-Masks: Influence of Shape and Material Parameters.” *Proceedings of SPIE*, 6349:63493D, 2006. [DOI:10.1117/12.686828](https://doi.org/10.1117/12.686828)，[作者预印本](https://arxiv.org/abs/physics/0610236)。
8. Shaopeng Guo, Haofeng Chen, Chunxiao Mu, et al. “Mask3D-compatible full-vectorial Hopkins imaging for lithographic modeling.” *Optica*, 2025. [DOI:10.1364/OPTICA.565511](https://doi.org/10.1364/OPTICA.565511)。
9. Siemens. “Rapid full-chip curvilinear OPC for advanced logic and memory.” Technical paper, 2021. [官方文档入口](https://resources.sw.siemens.com/en-GB/technical-paper-rapid-full-chip-curvilinear-opc-for-advanced-logic-and-memory/)。
10. Aki Fujimura, Yohan Choi, Abhishek Shendre. “Curvilinear masks overview: manufacturable mask shapes are more reliably manufacturable.” *Journal of Micro/Nanopatterning, Materials, and Metrology*, 23(4):041502, 2024. [DOI:10.1117/1.JMM.23.4.041502](https://doi.org/10.1117/1.JMM.23.4.041502)。作为商业作者对领域的综述，其优势论断应放回具体实验范围。
11. LithoGuy. “Optical proximity correction.” Wikimedia Commons, 2010. [文件、作者与公有领域声明](https://commons.wikimedia.org/wiki/File:Optical_proximity_correction.png)。
