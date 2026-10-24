---
layout: post
read_time: true
show_date: true
title: "从掩模到晶圆：光刻前向模型与误差传播"
date: 2026-07-31 22:32:07 +0800
tags: [光刻, 掩模, 计算光刻]
author: 端点星日志
description: "沿掩模散射、投影、光刻胶、显影和刻蚀建立前向链，推导 NILS、MEEF 与误差传播，再检查共同工艺窗口和随机失效。"
source_url: "https://mp.weixin.qq.com/s/l4Bico-q_nLVzB86DzI4ZQ"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

*2026-10-25 修订 · [计算光刻阅读路线](/lithography/)*

从掩模数据库到刻蚀后晶圆轮廓，图形转移经历几何、电磁场、化学状态与材料边界之间的转换。写后掩模的三维形貌决定出射衍射场，投影光学与膜堆栈决定胶内能量分布；曝光和后曝光烘烤改变材料溶解性，显影与刻蚀再形成最终边界。

这些过程可以按工程接口分解为多个前向模块：

> 设计几何 → 写后掩模三维边界 → 掩模出射复数场 → 空中像与胶内能量分布 → 曝光潜像 → PEB 后溶解度场 → 显影后三维胶形 → 刻蚀后晶圆轮廓

本文采用八类前向物理转换，并将计量校准和随机过程另行讨论。模块划分服务于模型接口和误差预算，不构成统一的软件分类。每个接口需要保留下游计算所依赖的相位、深度或材料状态，否则各模块的局部精度无法保证组合后的预测精度。

## 设计目标、掩模目标与物理掩模

日常交流里的“mask pattern”常常混指三种对象：

1. 设计目标：晶圆上希望得到的目标轮廓，属于设计坐标系。
2. 掩模目标：经过光学邻近效应修正（OPC）、逆向光刻技术（ILT）或光源—掩模协同优化（SMO）得到的 reticle target。它可能带有偏置、serif、hammerhead、亚分辨率辅助图形，甚至是曲线化或像素化形状。
3. 物理掩模：实际制造出来的掩模。电子束写入、抗蚀剂、显影、刻蚀和计量会带来线边粗糙、角部圆化、侧壁角和局部尺寸误差。

模型输入必须明确对应理想版图、OPC 后的掩模目标或写后实测三维掩模。


三者不能直接互换。把理想多边形交给成像模型，等于假设掩模制造没有误差。在宽松节点，这类误差可能被工艺窗口吸收；到了低 $k_1$、强 OPC、EUV 或高数值孔径场景，它会进入边缘放置误差（EPE）和最佳焦面误差。

<figure class="technical-figure" id="fig-1">
  <div class="figure-image"><a href="/assets/images/references/photolithography-etching-process.svg" target="_blank" rel="noopener" aria-label="正性光刻胶涂布、曝光、显影及刻蚀的纵向工艺示意，在新标签页查看大图"><img src="/assets/images/references/photolithography-etching-process.svg" alt="正性光刻胶涂布、曝光、显影及刻蚀的纵向工艺示意" width="260" height="1300" loading="lazy" decoding="async"></a></div>
  <figcaption markdown="span">图 1：Cmglee，Photolithography etching process（2011），[Wikimedia Commons 原文件页](https://commons.wikimedia.org/wiki/File:Photolithography_etching_process.svg)，[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)，原文件未修改。图示正胶曝光、显影和图形转移的基本步骤，不按实际比例，也未画出本文全部光学、化学与计量过程。访问日期：2026-10-25。</figcaption>
</figure>

## 掩模的三维电磁响应

薄掩模近似又称 Kirchhoff 模型，计算成本较低。它把掩模视为没有厚度的二维复透过率函数：开口区透光，吸收区遮光，移相区再附加相位。掩模衍射谱可以直接由二维傅里叶变换得到，速度很快，适合全芯片 OPC。

但真实掩模有厚度。当特征尺寸与曝光波长进入同一量级，或 EUV 多层膜、吸收体和侧壁不可忽略时，光会在材料界面反射、耦合并发生偏振转换，改变各衍射级次的振幅和相位。

相位尤其关键。晶圆图形由多个衍射级次干涉形成；相对相位有误，即使各级次能量看起来接近，最佳焦面、左右不对称性和线端位置仍可能偏移。全芯片 3D 计算光刻研究已经展示了随节距和入射角变化的非零最佳焦面偏移。[[3]](https://doi.org/10.1117/12.916076)

严谨模型直接求解 Maxwell 方程，常见方法包括 FDTD、RCWA/波导法和有限元法。它们能处理三维形貌、材料色散、斜入射和偏振，但代价远高于一次傅里叶变换。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)[[4]](https://www.iue.tuwien.ac.at/phd/kirchauer/)

生产流程通常先用严谨求解器计算代表性结构，再把面积、边和角部响应压缩为可复用的局部滤波器，用于全芯片快速计算。M3D 就是这一思路的代表。[[3]](https://doi.org/10.1117/12.916076)

对 EUV，这一层更复杂。反射式多层膜、约 6° 斜入射和吸收体遮蔽会让水平与垂直图形出现不同响应，掩模形貌还会与非远心性耦合。

## 照明与投影光学

掩模输出的是复数电磁场，不是几何轮廓。它把入射光分解成不同空间频率的衍射级次；物镜光瞳只允许一部分级次通过；通过的级次在像面重新叠加，形成空中像。

这解释了为什么临界尺寸相同的孤立线和密集线会有不同响应，为什么线端缩短、直角圆化，也解释了亚分辨率辅助图形（SRAF）的作用：它不必在晶圆上成像，却能改变进入光瞳的衍射谱。

部分相干成像有两条经典计算路径：

- Abbe 方法按光源点逐个计算相干像，最后对强度求和，物理直观但计算昂贵。
- Hopkins 方法把光源和投影系统编码进传输交叉系数（TCC），再通过相干系统分解（SOCS）压缩为少量卷积核：

$$ I(x,y)\approx\sum_{k=1}^{K}\lambda_k\left|(h_k*M)(x,y)\right|^2. $$

完整 Hopkins 积分并不便宜。全芯片成像能算下来，依靠的是低秩分解、少量主导核和 FFT。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)[[2]](https://doi.org/10.1515/aot-2012-0037)[[5]](https://doi.org/10.1631/jzus.C1000219)

真实成像模型还要接收光源形状、数值孔径、光瞳透过率、偏振、Zernike 像差、杂散光、焦点、带宽和扫描扰动。高数值孔径成像还必须考虑矢量电场。

OPC 还需要在焦点—剂量空间中评价各图形的共同工艺窗口，单个焦面的空中像只描述其中一个条件。

## 膜堆栈与胶内场

光刻胶有折射率、吸收系数和有限厚度，下方还有底部抗反射层、硬掩模、氧化层、硅以及已有器件结构。

光进入多层膜后会透射和反射。入射波与反射波在胶内干涉，形成随深度变化的驻波；胶厚或下层反射率变化，会带来局部能量和 CD 摆动。对平坦膜堆栈，可以用 Fresnel 关系或传输矩阵法高效求解。[[4]](https://www.iue.tuwien.ac.at/phd/kirchauer/)

如果晶圆已有明显三维形貌，下层结构还会让光再次衍射。W3D 模型描述的正是晶圆已有形貌对本次曝光光场的影响，而不是刻蚀。[[3]](https://doi.org/10.1117/12.916076)

空中像与三维胶内像对应不同的状态和接口。对厚胶、非平坦基底及高 NA 场景，单一像面缺少胶内传播所需的深度与材料边界信息。

## 曝光动力学与潜像

对化学放大型光刻胶（CAR），曝光使光致产酸剂（PAG）产生酸。PAG 消耗可采用以下简化反应式描述：

$$ \frac{\partial [\mathrm{PAG}]}{\partial t}=-C I[\mathrm{PAG}]. $$

其中 $I$ 是胶内局部光强，$C$ 与感光速度有关。曝光后的状态以三维酸浓度或潜像分布描述。

这里还必须区分胶体系。经典 Dill ABC 模型首先针对常规正性胶中的感光物种消耗，写作 $\alpha=Am+B$ 和 $\partial_t m=-CIm$；它不是完整的化学放大胶产酸—淬灭—脱保护模型。将类似的一阶感光反应式用于 PAG 是一种简化，必须重新说明反应物和参数含义，不能把 DNQ 胶的 ABC 参数直接移植过来。[[6]](https://www.iue.tuwien.ac.at/phd/kirchauer/node69.html)

光刻胶响应包含非线性光化学与后续材料过程。固定阈值以空中像等值线近似胶边界，适用于经校准的受限条件，无法完整描述这些机制。

## 后曝光烘烤的反应与扩散

曝光后烘烤（PEB）期间，酸扩散并催化聚合物脱保护，淬灭剂与酸中和。这是一个耦合的反应—扩散问题，决定显影时哪里溶得快、哪里溶得慢。

扩散一方面能平滑曝光阶段的微观不均匀性，另一方面也会推宽边缘，甚至连接本不该连通的区域。扩散长度粗略随 $\sqrt{2Dt}$ 增长，因此温度、时间和扩散系数本身就是成像参数。

在先进节点，光子散粒噪声、PAG 离散分布和二次电子先造成潜像波动，PEB 再把这些波动传递为线边粗糙度、局部 CD 和缺失或桥连概率。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)[[2]](https://doi.org/10.1515/aot-2012-0037)

完整反应—扩散方程无法在每次全芯片 OPC 迭代中求解。紧凑光刻胶模型通常用高斯扩散项、非线性变换和可校准系数近似。R3D 模型则保留多尺度扩散、垂直方向和顶部损失等关键自由度，同时把计算量压到生产可接受范围。[[3]](https://doi.org/10.1117/12.916076)

## 显影速率与三维界面演化

PEB 后得到的是脱保护程度或溶解度场。显影模型才把连续场转成三维表面。

Mack 类模型把局部溶解速率与抑制剂或脱保护比例联系起来；cell removal、level set 和 fast marching 等方法再推进溶解前沿。最终输出包括顶部与底部 CD、侧壁角、顶部损失、footing、undercut，以及线端和接触孔的完整三维形状。

二维模型可能判断某个底部轮廓合格，三维模型却会发现顶部已经损失、侧壁过斜，或 SRAF 在胶顶意外显影。单一高度的胶层 CD，不等于完整胶形，更不等于最终晶圆 CD。[[3]](https://doi.org/10.1117/12.916076)

## 刻蚀与图形转移

显影完成只是图形形成的中间站。刻蚀模型还要接收三维胶形、剩余胶厚、硬掩模与材料堆栈、离子和活性物种、入射方向与能量、材料选择比、再沉积和局部图形密度。

胶顶损失、侧壁角和底部 footing 会改变刻蚀开口；节距与图形密度会改变局部反应物供给；再沉积又会继续塑造侧壁。因此，刻蚀后 CD 与显影后 CD 未必是简单线性关系。[[2]](https://doi.org/10.1515/aot-2012-0037)

严谨刻蚀模型可以描述离子输运、化学反应、吸附、溅射和界面演化，但很难直接用于全芯片。生产级 etch-aware OPC 更多使用经过晶圆数据校准的经验或半经验模型。

> 如果 OPC 的目标是刻蚀后晶圆轮廓，那么只把显影后胶轮廓做到 EPE 为零，并不保证最终 EPE 为零。

目标停在哪一层，决定前面的模型应该如何校准。

## 参数校准与独立预测

模型不会凭空知道材料参数、像差、扩散长度和刻蚀偏差。CD-SEM、轮廓 SEM、散射计量、AIMS、膜厚和材料表征提供观测，校准再反向调整模型参数。

最大的风险是参数补偿。如果没有显式建模掩模 3D 效应，光刻胶模型仍可能靠额外模糊或可变阈值把晶圆 CD 拟合得很好。一旦照明、数值孔径、掩模堆栈或图形分布改变，被光刻胶参数“代偿”的误差就会暴露。

高质量校准需要主动打破参数相关性：

- 同时覆盖密集、半密集和孤立图形；
- 同时包含一维与二维结构；
- 扫描焦点和剂量，而不只使用标称条件；
- 除 CD 外加入轮廓、侧壁和顶部损失；
- 让校准集、验证集和产品图形分布彼此独立。

Kafai Lai 把从掩模一直预测到刻蚀后晶圆轮廓、再交给器件模型评估的完整链称为“虚拟晶圆厂”。[[2]](https://doi.org/10.1515/aot-2012-0037) 实验仍不可替代，但它不再只用于试错，也用于建立和检验模型的可迁移性。

## 严谨模型与紧凑模型

显式保留主导物理机制，有助于解释工艺变化，但跨工艺预测仍取决于材料输入、边界条件和验证数据；更严谨的方程并不自动保证更强外推。其计算代价也往往更高。全芯片 OPC 面对海量边缘片段和多组工艺条件，不可能在每次移动掩模边缘后，都重新求解三维 Maxwell 方程、反应—扩散、显影前沿和等离子体输运。

生产流程因此需要两个相互依赖的尺度：

- 小区域严谨模型回答哪个物理效应主导误差、哪些近似已经失效，以及哪些自由度必须保留。
- 全芯片紧凑模型回答完整掩模能否通过验证、哪些边缘要移动、哪些热点会在工艺窗口边缘失效。


严谨模型提供物理参考，紧凑模型承担全芯片计算，实验约束参数并检验预测。三者分别控制物理近似、计算成本与实际适用范围。

## 前向模型中的掩模优化

把所有模块合起来，从掩模到晶圆可以写成一个前向算子：

$$ C_{\mathrm{wafer}}=\mathcal F(M;\mathbf p). $$

其中 $M$ 是掩模，$\mathbf p$ 包含光源、像差、膜堆栈、光刻胶、刻蚀、焦点和曝光剂量等工艺参数。

OPC 要做的是给定目标轮廓 C_target，寻找一个掩模，使得：

$$ \mathcal F(M;\mathbf p)\approx C_{\mathrm{target}}. $$

这个逆问题并不友好。投影系统会丢掉高空间频率，不同掩模可能得到相近的晶圆像；掩模几何还受到最小尺寸、间距和写入约束。最佳掩模不仅要在标称条件下对齐，还要对焦点、剂量和掩模误差保持稳健。

传统模型 OPC 会把边界切成线段，在控制点上计算 EPE，再移动边缘。矩阵方法会评估多个线段对每个控制点的共同影响，但 Jacobian 计算昂贵。稀疏矩阵 OPC 利用光学核的局域敏感区域，忽略大量弱耦合项，可以在保持接近矩阵法精度的同时减少计算。[[5]](https://doi.org/10.1631/jzus.C1000219)


## 边缘敏感度与误差传播

不同模块使用不同单位：掩模几何以长度计，光学场有振幅和相位，酸以浓度计，显影以前沿速度计。若只比较各自的拟合残差，就无法回答最终边缘误差来自哪里。必须把扰动一直传播到同一个晶圆观测量。

采用二维阈值近似，设沿边界法向的坐标为 $n$，归一化像强为 $I(n)$，曝光剂量为 $D$，边界满足 $D I(n)=E_{\mathrm{th}}$。一阶微分给出

$$
\delta n\approx\frac{\delta E_{\mathrm{th}}-I\delta D-D\delta I}{D\,\partial_n I}.
$$

上述局部条件数表明，边缘像强斜率越小，同样的输入扰动对应越大的位置误差。低对比度线端或接触孔边缘可能因此主导最坏 EPE，而在整幅图的平均光强误差中占比较小。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)

取一个特征宽度 $w$，可以定义无量纲归一化像对数斜率：

$$
\mathrm{NILS}=w\left|\frac{\partial\ln I}{\partial n}\right|_{\mathrm{edge}}.
$$

在阈值、焦点和像形保持不变的小扰动条件下，单边剂量敏感度约为

$$
|\delta n|\approx\frac{w}{\mathrm{NILS}}\left|\frac{\delta D}{D}\right|.
$$

这里计算的是单边位置，不能未经说明就当作双边 CD 变化。两条边的法向不同，还可能发生不对称移动；真实显影和反应扩散会进一步改变关系。NILS 是定位薄弱图形的光学指标，不能单独替代晶圆工艺窗口。

掩模误差的传播也要写明坐标。设缩小倍率为 $R$，掩模上测得的 CD 为 $d_m$，其晶圆尺度等效值为 $d_m/R$，则一种常用定义是

$$
\mathrm{MEEF}=\frac{\partial d_w}{\partial(d_m/R)}
=R\frac{\partial d_w}{\partial d_m}.
$$

若忘记缩小倍率，两个团队报告的 MEEF 会差一个 $R$。MEEF 还取决于图形、焦点和曝光条件；某一点的 MEEF 不能代表整片版图。Wong 等将掩模误差与焦点、剂量放在同一分析中，正是为了避免只在标称点讨论掩模容差。[[7]](https://doi.org/10.1109/66.843639)

推广到整个链，令 $\mathbf x_j$ 表示第 $j$ 个模块的输出状态，其局部线性化为

$$
\begin{aligned}
\delta\mathbf x_{j+1}&=J_j\delta\mathbf x_j+B_j\delta\mathbf p_j, \\
J_j&=\frac{\partial\mathcal F_j}{\partial\mathbf x_j}.
\end{aligned}
$$

上游误差经过后续 Jacobian 连乘才到达最终边缘。这个式子解释了为什么同样的掩模制造精度，对不同 pitch 或不同照明的晶圆结果可以不同：下游传递增益本来就不同。

如果用协方差传播，最终的近似形式是 $\Sigma_y\approx J\Sigma_xJ^\mathsf T$，其中必须保留相关项。只有在误差独立或相关性可忽略时，才可以把各项标准差做平方和开根。光源漂移同时改变多类图形，掩模 CD 的区域偏差同时移动邻近边缘，都不满足天然独立的假设。本文这些微分式是局部分析，遇到桥连、断线和轮廓拓扑变化，应直接进行非线性仿真或统计抽样。

## 共同工艺窗口

单个图形在标称焦点和剂量下符合 CD，只说明它通过了一个点。对第 $i$ 类图形，在焦点 $f$、剂量 $D$ 下定义允许区域

$$
\Omega_i=\{(f,D):\ |\mathrm{EPE}_{i,q}(f,D)|\le e_{i,q}
\ \text{且形貌与连通性符合规格}\}.
$$

全层的共同工艺窗口是 $\Omega=\bigcap_i\Omega_i$。孤立线、密集线、线端、接触孔可能各自在很大的区域内可印，但它们的区域错开以后，交集依然很小。OPC 或 source 优化若只提高容易图形的标称匹配，不一定扩大这个交集。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)[[2]](https://doi.org/10.1515/aot-2012-0037)

实践中应分别检查三个层次。第一是每一种图形的焦点—剂量响应，包括 CD、EPE 和残胶形貌。第二是同一组曝光条件下所有关键图形是否共同合格。第三是在掩模误差、膜厚、材料与设备状态改变后，这个共同窗口还剩多少。固定阈值的二维仿真对第一层已有帮助，但不能直接声称完成第三层资格验证。

因此，模型链的交付物应该包含条件：预测的是 ADI 还是 AEI，覆盖哪些图形、材料、焦点和剂量，使用哪个计量定义，模型残差与数值误差各有多大。没有适用域的“精度”是一个缺少主语的数字。

## 随机波动与局部失效

对于 EUV 等对离散事件敏感的情形，平均轮廓只描述分布的一部分。理想化地，面积 $A$ 上吸收光子数的期望可写为

$$
\begin{aligned}
\bar N&=\frac{D A\,a}{hc/\lambda}, \\
\frac{\sigma_N}{\bar N}&=\frac1{\sqrt{\bar N}},
\end{aligned}
$$

其中 $a$ 是该面积内的有效吸收比例，假设独立光子且计数服从泊松分布。这个教学关系说明剂量、波长与采样体积为什么会影响统计波动；它并不把真实胶中的二次电子、反应与分子分布简化成只有一种噪声。[[1]](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)

从光子到缺陷还有几层传递：局部能量分布改变产酸，反应和扩散引入空间相关性，显影又把连续状态变成边界或连通性事件。两个模型可以具有相近平均 CD，却给出不同的 LER、孔缺失概率和桥连概率。因而随机模型要验证分布、空间相关性和稀有失效，不能只重新拟合一次平均 CD。[[8]](https://doi.org/10.1117/1.JMM.16.4.041013)

报告“没有看到缺陷”还需要样本量。若 $N$ 次独立机会中观察到零次失败，单侧 95% 二项分布上界为 $p_{\mathrm{up}}=1-0.05^{1/N}$，大样本时约为 $3/N$。这只是统计推导，真实晶圆的空间相关会减少有效独立样本数。仿真声称极低缺陷率时，同样必须说明尾部估计方法和验证证据。

模型复杂度应分配给最终指标敏感且实验能够辨识的环节。增加某一模块的自由度，需要同时检查它对最终误差预算的贡献和可用数据的约束能力。

## 模型接口的状态要求

模块接口应与下游需要的状态一致。对相位、偏振或斜入射敏感的投影计算，需要掩模出射复场；胶内传播需要膜堆栈和材料边界；侧壁、顶部损失及刻蚀转移预测需要深度方向的胶状态。最终目标平面决定这些状态可以被压缩到何种程度。

## 模型划分与目标平面

在早期概念验证中，“薄掩模 + 标量成像 + 固定阈值”三个模型就能得到二维轮廓。

在本文所采用的生产级工程边界下：

1. 掩模制造与写后形貌；
2. 掩模电磁衍射；
3. 照明与投影成像；
4. 膜堆栈与胶内像；
5. 光刻胶曝光；
6. PEB 反应扩散；
7. 显影与三维胶形；
8. 刻蚀与图形转移；
9. 计量与校准；
10. 随机性、工艺波动与设备漂移。

上述前八项描述前向物理转换，后两项分别约束观测与校准，以及过程波动。进一步拆分光源、像差、写入或设备漂移时，模块数量会增加；划分应以接口和验证需求为依据。

模型划分的有效性取决于接口信息是否充分、严谨模型到紧凑模型的近似是否经过验证，以及组合后的输出能否预测独立实验。概念模型可以采用较少状态，工艺开发与产品修正则应按最终平面及误差预算选择保真度。

OPC 沿这条前向链求解掩模几何，使显影后胶形或刻蚀后材料边界满足目标。数据采集、参数校准和制造验证均应与所选择的输出平面一致。

---

## 参考文献

以下论文和教材用于对应的物理或方法论说明；文中的敏感度、协方差及零失效上界为在已写明假设下的推导。网页访问日期均为 2026-10-25。

1. Andreas Erdmann. *Optical and EUV Lithography: A Modeling Perspective*. SPIE Press, 2021. ISBN 9781510639010. [作者机构出版记录](https://www.iisb.fraunhofer.de/de/press_media/pressemitteilungen/pressearchiv/archiv_2026/frits-zernike-award.html)。
2. Kafai Lai. “Review of computational lithography modeling: focusing on extending optical lithography and design-technology co-optimization.” *Advanced Optical Technologies*, 1(4):249–267, 2012. [DOI:10.1515/aot-2012-0037](https://doi.org/10.1515/aot-2012-0037)。
3. Peng Liu, Zhengfan Zhang, Song Lan, et al. “A full-chip 3D computational lithography framework.” *Proceedings of SPIE*, 8326:83260A, 2012. [DOI:10.1117/12.916076](https://doi.org/10.1117/12.916076)。该文的 M3D/W3D/R3D 是其特定框架命名，不是全部软件共同采用的接口标准。
4. Heinrich Kirchauer. *Photolithography Simulation*. TU Wien 博士论文在线版，1998，第 4–5 章。[大学原始文档](https://www.iue.tuwien.ac.at/phd/kirchauer/)。
5. Bin Lin, Xiao-lang Yan, Zheng Shi, Yi-wei Yang. “A sparse matrix model-based optical proximity correction algorithm with model-based mapping between segments and control sites.” *Journal of Zhejiang University-SCIENCE C*, 12(5):436–442, 2011. [DOI:10.1631/jzus.C1000219](https://doi.org/10.1631/jzus.C1000219)。[勘误](https://doi.org/10.1631/jzus.C10e0219)。
6. F. H. Dill, W. P. Hornberger, P. S. Hauge, J. M. Shaw. “Characterization of Positive Photoresist.” *IEEE Transactions on Electron Devices*, 22(7):445–452, 1975. [DOI:10.1109/T-ED.1975.18159](https://doi.org/10.1109/T-ED.1975.18159)；公式及参数定义另见 Kirchauer 论文 [§5.1.2](https://www.iue.tuwien.ac.at/phd/kirchauer/node69.html)。
7. Alfred K. Wong, Richard A. Ferguson, Scott M. Mansfield. “The mask error factor in optical lithography.” *IEEE Transactions on Semiconductor Manufacturing*, 13(2):235–242, 2000. [DOI:10.1109/66.843639](https://doi.org/10.1109/66.843639)。
8. Peter De Bisschop. “Stochastic effects in EUV lithography: random, local CD variability, and printing failures.” *Journal of Micro/Nanolithography, MEMS, and MOEMS*, 16(4):041013, 2017. [DOI:10.1117/1.JMM.16.4.041013](https://doi.org/10.1117/1.JMM.16.4.041013)。
