---
layout: post
read_time: true
show_date: true
title: "从物理实在到计算光刻模型"
date: 2026-08-20 21:25:00 +0800
tags: [光刻, 建模, 计算光刻]
author: 端点星日志
description: "光源、掩模、光刻胶和刻蚀的数据怎样进入模型？本文从目标定义、实验辨识、模型校准到量产资格，梳理计算光刻连接物理工艺的完整方法。"
source_url: "https://mp.weixin.qq.com/s/4dKlGEMIXfpQee4tS9nzmg"
toc: true
last_modified_at: 2026-10-25
mathjax: true
---

*2026-10-25 修订 · [计算光刻阅读路线](/lithography/)*

**工业界怎样把真实工艺变成可预测、可反演、可量产的模型**

一张版图完成设计规则检查以后，离晶圆上的真实图形还很远。

它先被转换成 wafer target，再经过 retargeting、OPC 或 ILT，成为 mask pattern。掩模写出来以后，曝光机用特定的照明光瞳把它成像到光刻胶。显影得到 ADI 图形，刻蚀再把图形转移到薄膜中，形成 AEI 图形。每一步都会改变边缘位置、线宽、圆角、侧壁和缺陷概率。

器件和良率团队关心的是最后那一层 AEI 图形。mask engineer 能直接交付的却是掩模图形。计算光刻要在两者之间建立一种可计算的关系。

先看正向问题。给定 mask、source、scanner、resist、etch 和 process condition，晶圆上会形成什么图形。

$$ C_{\mathrm{wafer}}=\mathcal F(M,S,\mathrm{scanner},\mathrm{resist},\mathrm{etch};\mathbf c). $$

再看逆向问题。给定最终 wafer target，什么样的 source 和 mask 能让多种图形在 dose、focus 与其他过程波动下都留在规格内。SMO、SSA、OPC 和 ILT 分别在这个逆向问题的不同位置上工作。

所以，一套 OPC model 的建立远远超过一次数据拟合。工程团队先定义最终目标和允许误差，再把连续的制造过程拆成若干可以量测、可以验证的子问题。他们设计实验让关键过程效应显现出来，用实测数据校准正向模型，再用正向模型求 source 和 mask。新 reticle 与产品 wafer 随后检验整个推导。进入量产以后，模型还要跟着设备、材料和 recipe 的状态一起管理。

整套逻辑可以压缩成六个相互依赖的方法步骤。

| 方法步骤 | 工程问题与验收 |
| --- | --- |
| 目标定义 | 晶圆上究竟要得到什么<br>验收<br>模型优化的目标与 AEI、电性和良率要求一致 |
| 因果拆分 | 哪些过程效应需要单独描述<br>验收<br>mask、optical、resist、etch 与 metrology 参数具有清楚归属 |
| 实验辨识 | 怎样让过程效应在数据里显现<br>验收<br>test vehicle、FEM、process split 与重复量测足以区分待估效应 |
| 预测压缩 | 怎样从有限数据得到全芯片预测<br>验收<br>compact model 在适用域内能够预测未见图形 |
| 约束求逆 | 怎样从预测反求 source、target 和 mask<br>验收<br>SMO、SSA、OPC 或 ILT 的解可以被 scanner 和 mask shop 实现 |
| 资格管理 | 怎样相信模型可以量产并持续使用<br>验收<br>model、process 与 metrology 作为兼容版本接受验证和变更控制 |

后面的 source、FEM、SSA 和 etch data 都从这六个问题展开。文章的重心放在工程逻辑，以及每一步为什么要这样做。

公开资料无法给出先进晶圆厂的完整 process of record。本文使用的是 imec、Intel、TSMC、GlobalFoundries、IBM、设备厂和 EDA 厂商公开的论文、专利与技术资料。文中的实验数字用于展示实际做法和数量级，不应被理解为所有晶圆厂通用的配方。

## 先从最终目标和误差预算决定模型边界

模型开发的第一项工作，是确认模型准备预测哪一个平面。CD collection 要服从这个目标。

只做 lithography correction 时，输出通常是 ADI contour。面向最终图形的 etch-aware OPC 则要预测 AEI contour。contact、line end 或多层交叠结构还可能需要把局部面积、placement 或 overlay 后的有效重叠写进目标。target 平面不同，实验数据、模型结构和验收指标都会跟着变化。

团队随后分配 EPE budget。mask writing、scanner、resist、etch、overlay、metrology 和 OPC residual 各自可以占用多少误差，要在模型建立前说清楚。这个预算决定哪些效应必须单独建模，哪些可以作为受控 variation，哪些只能留给工艺控制。若 etch 已经占去大部分 pattern-dependent bias，继续增加 optical model 的复杂度很难救回最终 AEI。

模型边界确定以后，初始信息可以分成四层。

| 数据层 | 典型内容 |
| --- | --- |
| 工艺与设备设定 | 波长、NA、dose、focus、照明设定、胶厚、PEB、膜层、etch recipe |
| 独立物理量测 | source map、aberration、flare、polarization、mask CD、膜厚、材料 n 和 k |
| 晶圆响应 | ADI CD、SEM contour、Bossung、FEM、缺陷、AEI CD、AEI contour、截面 profile |
| 拟合所得参数 | effective threshold、diffusion length、loading kernel、etch kernel、metrology correction |

获取方式和风险也要分开记录。

| 数据层 | 获取方式与主要风险 |
| --- | --- |
| 工艺与设备设定 | 来自设备 recipe、材料记录和工艺记录。设定值可能偏离晶圆实际经历值 |
| 独立物理量测 | 来自 scanner sensor、AIMS、mask SEM、scatterometry 和膜厚量测。量测误差可能被后级经验参数吸收 |
| 晶圆响应 | 来自曝光 split、CD-SEM、e-beam inspection、XSEM 和 AFM。主要风险包括 sampling bias、SEM shrinkage、charging 和图形匹配错误 |
| 拟合所得参数 | 来自模型校准和残差分析。参数可能互相补偿，造成训练误差很小而外推失效 |

这四层不能随意混在一起。前两层告诉模型制造系统是什么，第三层告诉模型系统做出了什么，第四层才是软件根据前三层求出的参数。

波长、NA、source shape 和 lens aberration 能够独立量测时，应尽量把它们作为 optical model 的物理输入。胶的 diffusion length 或经验 threshold 很难直接从量产胶中完整分离，通常要由晶圆 CD 和 contour 拟合。etch 的局部 loading effect 更复杂，往往只能压缩成少量 kernel 或规则表。

这种分层还有一个现实作用。模型失配时，工程师可以按层追问。source 是否漂移，mask CD 是否变化，胶厚或 PEB 是否偏移，CD-SEM recipe 是否改变，还是 compact model 的形式覆盖不了新图形。若所有现象都被塞进一个高度灵活的 resist term，训练误差可能很好看，根因却很难定位。

背后的方法是先分配因果，再拟合参数。能独立量到的物理量尽量固定，难以直接量到的效应才交给 calibration。这样做未必让训练 RMS 最低，却能减少参数之间的相互补偿，让模型在 source、mask 或 condition 变化时仍有可预测性。

## 这些数据由谁一起做出来

在晶圆厂里，模型开发很少由一个 OPC engineer 独立完成。不同团队掌握不同的物理对象，也对不同的 release 风险负责。

| 角色 | 主要工作与交付数据 |
| --- | --- |
| lithography process engineer | 定 scanner、resist、track、PEB、develop 和 process window<br>数据<br>POR 条件、FEM wafer、ADI CD、defect 与 profile |
| scanner 和 application engineer | 建 illumination、量 pupil、aberration、focus、dose 与 tool matching<br>数据<br>measured source、lens signature、scanner limit 和 monitor data |
| mask engineer | 做 test mask、量 mask CD、corner rounding、absorber 与 writing error<br>数据<br>measured mask geometry、mask stack、MRC 与 mask variation |
| metrology engineer | 定 CD-SEM recipe、轮廓提取、重复量测与 tool matching<br>数据<br>CD、contour、uncertainty、shrinkage 与 charging assessment |
| OPC modeling engineer | 设计 sample plan、拟合子模型、分析 residual、维护 recipe<br>数据<br>calibration、validation、model package、coverage report |
| etch engineer | 定 etch POR、做 process split、量 AEI 与 profile<br>数据<br>ADI 和 AEI pair、etch bias、loading 与 chamber information |
| integration、device 和 yield engineer | 定最终 wafer target，确认跨层、电性和良率结果<br>数据<br>target、EPE budget、product hotspot、defect 与 electrical result |

这张分工表也解释了为什么 OPC 开发周期很难只靠增加算力缩短。test mask 要先写出，scanner 和 track 要有稳定条件，wafer 要排进实验，CD-SEM recipe 要调好，etch 后还要找到与 ADI 对应的图形。任一环节的样本编号、condition 或坐标管理出错，拟合工具仍可能给出一组参数，只是这组参数已经失去物理意义。

所以建模项目还需要一套严格的数据谱系。每个 gauge 或 contour 至少应能追溯到 design target、mask location、wafer、lot、field、die、focus、dose、process step、metrology recipe 和 image。被删除的 outlier 也要保留原因。否则下一轮 wafer 结果变化时，团队无法判断过程变了，量测变了，还是数据处理变了。

## source 的方法从优化目标走到真实硬件

### 先定义 source 要服务哪些图形

这里的 source 通常指照明光瞳上的强度分布，而非光源功率本身。

![环形、偶极与四极等照明光瞳形状示意](/assets/images/references/illumination-shapes.png)

*图 1：Guiding light，EUV illumination shapes（2017），[Wikimedia Commons 原文件页](https://commons.wikimedia.org/wiki/File:EUV_illumination_shapes.png)，[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)，未修改。它只示意不同光源形状，不代表本文案例实际量到的 pupil、偏振或机台 recipe。访问日期：2026-10-25。*

source 的候选方案来自待印图形和工艺目标。工程师会准备一组有代表性的 clips 或 gauges，覆盖关键 pitch、dense 和 isolated 图形、line end、tip-to-tip、拐角、contact、SRAM 以及历史 hotspot。SMO 工具改变 pupil 中各位置的照明强度，同时调整主图形或 SRAF，并在多个评价量之间求折中。

常见评价量包括 common depth of focus、exposure latitude、NILS、MEEF、EPE、process variation band，以及掩模复杂度和 mask rule constraint。目标不会只是 nominal condition 下的一次完美成像。source 要让多种图形在同一 dose 和 focus 范围内同时可制造，还要能被真实 illuminator 实现。

这里用到的是代表性采样与稳健优化。版图空间远大于 SMO 能一次处理的 clips 数量，工程师先让 sample set 覆盖主要成像行为，再优化最差图形、平均表现和硬件约束之间的折中。若优化集只包含 dense line，算法很可能牺牲 isolated 和二维端点。若只追求 best focus 下的 EPE，所得 source 也可能没有可用的 process window。

imec 在 2024 年公开的一项 High-NA EUV 研究，从一平方微米的随机 logic metal cell 中选取 200 个 gauges，覆盖 dense、isolated 和 tip-to-tip 图形，再比较 bright field、dark field、不同 absorber 与有无 SRAF 的组合。[[1]](https://doi.org/10.1117/12.3010869) 这类 pattern selection 很重要。选择过少，source 会偏爱少量测试图形。选择过多而不做覆盖分析，计算成本和数据冗余又会迅速上升。

GlobalFoundries 与 ASML Brion 公开过更接近量产导入的 ArF SMO 案例。第一组包含 112 个关键 SRAM、test pattern 和 hotspot，用于 source optimization。第二组超过 500 个 clips，用于独立验证，另有较大器件结构参与检查。[[2]](https://doi.org/10.1117/12.916614) 这个做法揭示了一条基本原则，参与优化的图形和验证 source 泛化能力的图形应当分开。

### 区分 target、programmed 与 measured source

source 进入晶圆厂后，会先后出现三种形态。

第一种是 SMO 工具给出的 target source。它可能是连续强度分布，也可能具有很细的自由形状。

第二种是曝光机能够加载的 programmed source。连续 source 需要经过 rendering，还要满足 illuminator 的最小 pupil fill、blur、强度分辨率和硬件可实现性。

第三种是曝光机里实际形成的 measured source。它由 scanner 的 pupil sensor 或相应量测方法得到，包含实际光学系统的偏差。

这三者接近，仿真才有资格代表真实曝光。Huang 等人的 FlexRay 实验先用 Tachyon 做 full SMO 和 source-only optimization，再把 source 加载到 ASML XT 1950i。曝光前后，研究者使用 scanner 内置传感器收集 pupil 信息，比较 produced source、programmed source 和模拟 CD，随后跑 FEM 与 critical defect scan。[[3]](https://doi.org/10.1117/12.879567)

Nikon、Huali 与 Mentor 的联合研究也把 measured source map 与 SMO source 做相关性验证，并用 FEM wafer 检查 simulation 和 wafer process window。[[4]](https://doi.org/10.1117/12.2223576) 这说明 source 优化完成只是中间节点。将 source 渲染、写入 scanner、量出实际 pupil，再看晶圆响应，才完成一次实物验证。

### 新 source 会改变模型的适用域

source 决定了哪些衍射级进入投影物镜，也改变 aerial image、NILS、through-pitch 行为和 focus sensitivity。原模型里的 resist term 即使能够勉强吸收部分变化，也容易损害外推能力。

GlobalFoundries 的公开流程在 optimized source 安装后，重新收集 nominal、off-focus 和 off-dose 的 wafer CD，校准新的 mask 3D model，调新的 OPC recipe，制作新 reticle，再做 silicon verification。[[2]](https://doi.org/10.1117/12.916614) 这个顺序很有代表性。

因此，只用一张 pupil 图片无法描述 SMO 的完整产物。实际交付还包括彼此匹配的 source specification、scanner setting、OPC model、OPC recipe、SRAF strategy、MRC 与 verification condition。

## 实验设计要让关键过程效应显现出来

有了候选 source 和初步工艺，下一步是设计能让模型看到过程行为的 test vehicle。

test vehicle 的方法论目标可以用一个词概括，辨识力。一个待估参数发生变化时，量测数据中应当出现能够和其他参数区分的签名。dense 到 isolated 的 pitch sweep 用来观察 proximity behavior，focus 和 dose split 用来观察 Bossung 斜率，mask bias split 帮助区分 mask response，ADI 与 AEI 配对则把 lithography 和 etch 分开。只收 nominal CD，许多参数会给出几乎相同的拟合结果。

最基本的一维图形包括 dense 到 isolated 的 line and space、不同 target CD、不同 pitch、line 和 space 两种 tone、有无 SRAF、不同 mask bias。二维图形包括 line end、corner、jog、T 形交叉、tip-to-tip、tip-to-line、contact 或 via 阵列、二维 island，以及 SRAM 和真实产品热点。

为什么还需要规则图形。因为它们便于控制单个变量，能清楚观察 through-pitch、dose 和 focus 响应。为什么还需要二维和产品图形。因为量产失效经常发生在规则阵列没有覆盖的局部环境里，诸如圆角、端点回缩、相邻边耦合和 SRAF 交互。

test mask 还要故意放进一些边界样本。它们可能接近 resist collapse、bridge、scum、missing contact 或 mask rule limit。边界样本不一定适合承担主拟合，却很适合检验模型能否识别 failure onset。这类尺寸和间距经过特意安排、接近 marginal printing 的 custom features，可以在模型建成后承担额外验证。稳定的模型既要把正常图形的平均 CD 拟合准确，也要预测这些图形何时开始失效。

Keck 等人公开的 modular modeling 实例使用 1560 个 CD measurement，覆盖四种 process condition。约 85% 是一维图形，约 15% 是二维图形，内容包括带或不带 SRAF 的 line and space、isolated pattern 和 line end。[[5]](https://doi.org/10.1117/12.716295) Weisbuch 等人在 28 nm active layer 的生产导入中，又比较了传统 gauge 与 SEM contour。contour 能在一个二维结构中产生大量 EPE 点，提高局部边缘覆盖。[[6]](https://doi.org/10.1117/12.2048288)

到了更先进的节点，test vehicle 还要有意识地覆盖真实产品的 image parameter space。只按几何 width 和 space 取样可能漏掉光学上完全不同的二维邻域。IBM 的自动 sample plan 研究尝试从候选图形中挑选更少但更有代表性的样本。[[7]](https://doi.org/10.1117/12.2086049)

sample plan 也受量测时间约束。一块 test mask 可以放很多图形，CD-SEM 却要逐个寻址、自动对焦、识别图形、采图和量边缘。规则 CD gauge 较快，二维 contour 和大视场 image 提供的信息更多，采集和处理成本也更高。工程师会把少量高信息量 contour 与较大规模的 CD gauges 混合使用，并给关键图形安排重复 die，以区分系统误差和随机变化。

一份可用的 sample plan 同时满足四件事。图形要覆盖产品空间，process split 要对参数敏感，重复量测要能估计噪声，validation sample 还要与 calibration sample 保持独立。数据数量排在这四件事之后。几千个高度重复的 gauges，提供的信息可能少于几十个经过挑选的二维 contours。

### imec 的一套公开实验怎样安排

imec、Applied Materials 和 Siemens 在 2024 年公开了一套很具体的 EUV 实验。[[8]](https://doi.org/10.1117/12.3010898)

他们使用 imec iN3 BEOL design、EUV CAR 和 PTD，以及经过 SMO 的 curvilinear test mask。实验一共用了四片 wafer。

| wafer 用途 | 数据目的 |
| --- | --- |
| litho nominal wafer | 找 ADI nominal response，也用于比较 CD-SEM scan condition |
| litho FEM wafer | 收集 focus 和 dose 变化下的 ADI 数据 |
| etch nominal wafer | 得到 nominal AEI 与 etch bias |
| etch process-window wafer | 检查 process variation 下的 etch response |

公开数据里，nominal wafer 选择了 50 个一维图形，FEM wafer 选择了 42 个二维位置。量测对不同 landing energy 和重复次数做了安排。source 优化时使用了 focus 从负 30 nm 到正 30 nm、15 nm 步长，dose 从正 5% 到负 5%、2.5% 步长，并加入 global mask bias split。

source 安装并曝光以后，团队才确定最终 OPC model sampling plan。test mask 上的一维 line and space 从 32 nm pitch 延伸到 320 nm isolated pitch，二维部分来自多个 pitch 的 post-OPC BEOL design。最终用于 calibration 的数据约为 700 个 gauges 加 15 个 contours，用于 verification 的数据约为 1400 个 gauges 加 42 个 contours。[[8]](https://doi.org/10.1117/12.3010898)

这些数字不宜复制成任何工厂的标准模板。它们说明了数据计划的结构。nominal 与 process window 分开，一维与二维并存，calibration 与 verification 分开，ADI 与 AEI 分开，同时保留重复量测来观察随机变化和量测误差。

### FEM 用斜率约束模型

FEM 是 focus exposure matrix。晶圆上的不同 field 或 die 使用不同 focus 和 dose 组合曝光，显影后量 CD、EPE、轮廓和缺陷，就能得到 Bossung curve 与 process window。

在一维图形上，Bossung curve 能显示 CD 随 focus 的变化，以及不同 dose 下曲线的平移。对多个 pitch 和图形类型同时采样，模型就能学习 dense 和 isolated 图形的 best focus 差异、through-pitch bias、dose sensitivity 和 focus sensitivity。

nominal data 适合锁定 best condition 下的图形误差。off-focus-off-dose data 用于约束模型的斜率和 process window 行为。若模型只在 nominal condition 校准，可能在中心点非常准确，离开中心点后迅速失真。process-window OPC 和 verification 因而需要连续或多条件模型。[[9]](https://doi.org/10.1145/1146909.1147108)

这就是实验设计与模型目标之间的关系。nominal CD 约束截距，focus 和 dose split 约束局部导数，through-pitch pattern 约束邻域响应，重复 die 估计随机误差。工程师收集数据时，心里要有一个问题，每一组 split 准备排除哪种错误解释。

数据也不必全部进入拟合。比较稳健的做法是提前划出 calibration set 和 validation set。validation set 应包含未参加拟合的 pitch、二维环境或 process condition。它检验的内容比总体 RMS 更重要，包括系统残差是否随 pitch、CD、orientation、focus、dose、mask bias 或图形类别变化。

Klostermann 等人的物理 resist model 研究使用数千个 CD 和多达 30 个 FEM，并明确区分 training 与 validation。他们还发现，使用 measured source shape 与 nominal source shape 会得到不同的模型质量。[[10]](https://doi.org/10.1117/12.814216) 这再次表明，晶圆数据和 scanner signature 必须相互对应。

## 正向模型要分层校准，也要满足全芯片计算

### 能直接量的参数先直接量

Mack 对 OPC calibration 的总结列出了一批能够独立量测的输入，包括 wavelength、NA、lens aberration、source shape、resist thickness、absorption 与 mask linewidth。[[11]](https://doi.org/10.1117/12.728961) 先进模型还会加入 polarization、flare、mask absorber n 和 k、mask thickness、wafer film stack，以及需要时的 mask 3D effect。

imec、ASML Brion 与 ZEISS 在 High-NA EUV 上还研究了 AIMS aerial image 的直接用途。AIMS 使用与 scanner illumination 对应的条件观察 actinic aerial image，可以提供 ILS、contrast、SRAF image 和 through-focus pattern shift，并帮助分离 mask parameter 与后续 resist effect。[[26]](https://doi.org/10.1117/12.2688109) 它不能替代最终 wafer calibration，却能让 mask 和 aerial image 子模型少依赖后级参数补偿。

mask model 负责从设计 mask 转到真实 mask transmission。optical model 负责从 mask 到 aerial image。resist model 负责从 aerial image 到显影后 contour。三个模块分开后，mask CD 或 source 更新可以在一定范围内替换相应输入，避免所有变化都重新拟合进 resist term。

分开并不意味着完全独立。参数之间仍可能补偿。例如错误的 source shape 可以被 resist threshold 部分吸收，错误的 mask CD 可以被 global bias 吸收。工程师会先固定高可信度物理参数，再逐步释放少量待拟合参数，同时查看不同图形和不同 condition 的残差签名。

compact model 还受一个很硬的约束，它要在全芯片上被调用许多次。rigorous Maxwell solver、完整 resist chemistry 和 plasma simulation 可以帮助理解局部物理，却很难直接承担全芯片 OPC 的反复迭代。工业模型因此选择一组计算得动、对关键变化足够敏感的状态量。校准工作的本质，是在物理完整性、可辨识性、预测精度和 runtime 之间选一个能进入生产的抽象层次。

### 训练误差不能代替预测能力

模型优化器总能把更多参数用于降低 calibration RMS。参数过多时，模型会开始解释 metrology noise、偶然 wafer variation 和 sample plan 的偏差。训练集更准，未见图形和 off-condition 反而更差。

所以 validation 要在拟合前划出。它应包含未参与 calibration 的 pitch、二维环境、process condition 或产品 clips。工程师还会逐一查看各 pattern class 的 residual，总 RMS 只是其中一个指标。残差若随 pitch 单向漂移，说明 proximity response 仍有遗漏。残差若随 focus 改变符号，可能是 source、aberration 或 focus model 有问题。随机散布很大时，先查 metrology 和 process variation，再考虑增加模型自由度。

这套方法把模型评价从 curve fitting 变成了有边界的预测。模型只对经过数据覆盖和独立验证的 design space、process window、scanner configuration 与 material stack 负责。超出这个范围时，正确动作是补实验或限制使用域，不能用已有 RMS 代替证据。

### CD-SEM 也有自己的模型

晶圆上的边缘没有自动变成数据库里的真值。电子束和 resist 会相互作用，landing energy、scan direction、frame 数、current density 和 charging 都会改变图像。薄 EUV resist 尤其容易发生 shrinkage。

Mack 等人的 modeling metrology 研究使用 221 个一维 features、728 个 through-focus-through-dose gauges，并划分 calibration 与 validation。把 CD-SEM 的系统偏差作为 metrology model 加入后，validation 表现得到改善。[[12]](https://doi.org/10.1117/12.2218534)

imec 联合实验则比较 500 eV 与 150 eV 的 ADI imaging。低 landing energy 降低了 resist shrinkage，却带来更低的信噪比和更高的 contour extraction 要求。团队用同一组 AEI contour 分别配对两种 ADI contour，得到两套 etch bias data。结果显示，ADI 量测方式的变化会一路传递到 etch model residual。[[8]](https://doi.org/10.1117/12.3010898)

TSMC 在 2026 年公开的一项专利申请也直接描述了 metrology-aware OPC。方案从同一 wafer 的多张图像建立 metrology error function，把 metrology model 与 OPC model 串联，并允许用后续 wafer image 继续训练。[[13]](https://patents.google.com/patent/US20260003293A1/en) 专利不等于量产披露，但它清楚展示了先进晶圆厂正在处理的问题。模型看到的 wafer image 也需要被建模。

## SSA 与 OPC 分别改变 target 和 mask

正向模型从 mask 预测 ADI 或 AEI，逆向求解则沿相反方向工作。若最终目标在 AEI，先对 etch 或 retarget 求逆。

AEI target⟶ADI target

再对 lithography 或 OPC 求逆。

ADI target⟶mask pattern

这两步解释了 SSA、etch compensation 与 OPC 的分工。SSA 或 retargeting 先决定 OPC 应该追逐什么 wafer target，OPC 再移动 mask edge 去实现这个 target。两步都表现为尺寸变化，优化对象却不同。

### SSA 先改变 target

SSA 常被展开为 Selective Size Adjustment。它修改的是 OPC 的 wafer target。随后 OPC 再根据这个新 target 求 mask shape。

这种操作的动机来自 common process window。某些 forbidden-dense-alternate 图形即使 nominal CD 能对准，在 focus 或 dose 改变时也可能比其他图形更快越过规格。工程师可以对特定 width、space 或 pattern class 预先加一个 target bias，让不同图形的 Bossung curve 和 process window 更好地重合。

因此，SSA bias 通常不能只取 nominal CD error 的相反数。它还要考虑 focus、dose、MEEF、NILS、最终电性 target、设计规则、mask rule 和相邻图形的共同窗口。

### SSA table 来自共同工艺窗口

公开专利给出了一条很直观的路径。[[14]](https://patents.google.com/patent/CN119516574A/zh)

1. 设计一组 width 和 space test patterns，并按图形类别组织。
2. 在 scanner 上做 focus 和 dose step scan，完成曝光和显影。
3. 量测不同 condition 下的 resist width，画出 Bossung 和 process window。
4. 为每个 CD 与 spacing 组合求使共同窗口达标的 target adjustment。
5. 把结果整理为按 target CD、space、tone 或 pattern class 索引的 bias table。
6. 在 OPC 前将 table 应用于 design target，再运行 OPC 和 full-chip verification。

中国科学院微电子研究所的公开专利 CN110989289A 描述了对 forbidden-dense-alternate 图形作选择性展宽的 retargeting 方案。[[15]](https://patents.google.com/patent/CN110989289A/zh) 它可说明目标调整的动机，但不能据此断言所有机构都将该流程命名为 SSA，或该专利方案已进入量产。 Applied Optics 上的相关论文进一步展示了这类 retargeting 对共同工艺窗口的作用。[[16]](https://doi.org/10.1364/AO.57.007811)

真实流程往往还会把 simulation 放进循环。模型可以先扫大量 width、space 和 condition，缩小需要上 wafer 的组合。wafer data 再校正模型与规则表。若产品热点落在 table coverage 以外，就需要新增测试图形或转向 model-based retargeting。

这里的方法仍然是先用模型扩展搜索，再用晶圆确定现实边界。simulation 适合低成本扫描大量组合，wafer experiment 负责发现模型没有描述的效应。table 是这轮搜索的压缩结果，它必须带着适用的 CD、space、tone、process condition 和 pattern class 一起发布。

### SSA 还有一个容易混淆的语境

一些晶圆厂资料也会把补偿 ADI 到 AEI 差异的 size adjustment table 称为 SSA table。此时它承载的是 etch bias 或 pattern transfer bias。

两类表的建立方法相似，都按图形环境整理 bias，也都在 OPC 前修改 target。物理目标却不同。一类处理 lithography process window，另一类处理 resist 到最终薄膜的图形转移。实际项目应先看 table 的输入和输出定义，再判断内部缩写指向哪一类。

## etch model 把最终图形带回计算流程

### 先区分工艺开发数据与 OPC 数据

etch engineer 为开发 recipe 会收集许多数据，包括 blanket etch rate、selectivity、within-wafer uniformity、chamber matching、endpoint signal、plasma condition、profile、sidewall angle、depth、residue 和材料损伤。

OPC etch model 的目标更窄。它需要在全芯片上快速预测 pattern transfer 对边缘位置的系统影响。最核心的数据因此是同一类图形环境下的 ADI 和 AEI 配对。

一个常用定义是

$$ b_{\mathrm{etch}}=\mathrm{CD}_{\mathrm{AEI}}-\mathrm{CD}_{\mathrm{ADI}}. $$

对二维图形，工程师更关心沿 contour 的局部位移。line end、inner corner、outer corner、contact 的不同方向可以有不同 bias。local pattern density、open area、feature visibility、相邻结构、underlayer 和 resist profile 都可能参与。

Gardin 等人的 65 nm etch modeling 研究显示，简单 width 和 space 规则在复杂 pattern environment 中会遇到覆盖边界，compact etch model 需要描述局部 density 与邻域影响。[[17]](https://doi.org/10.1016/j.mee.2007.01.085)

### ADI 和 AEI 要怎样配对

理想做法是为同一个 design location 获取 ADI 与 AEI contour。实际操作要处理一个麻烦，ADI 的 SEM 量测本身可能让 resist shrink，影响后续 etch。

一项 contact layer 研究采用同一 wafer、不同 field 的方式采集 ADI 与 AEI，避免在待刻蚀位置上重复电子束照射。研究覆盖约 40 类 contact configuration，每类量八个 fields。约三分之一结构用于 calibration，其余用于 verification。contour 上每隔约 5 nm 放置 EPE sample，一个结构可以产生约 500 个局部数据点。[[18]](https://doi.org/10.1117/12.2248013)

imec 的 2024 年实验采用四片 wafer，把 litho 与 etch、nominal 与 process-window 分开。对 1D 和 2D 图形都保留重复量测，并将 ADI contour 与 AEI contour 重叠形成 etch bias。[[8]](https://doi.org/10.1117/12.3010898)

对先进节点，只量 top-down CD 可能仍然不够。相同 top CD 可以对应不同 sidewall angle 和 resist 3D profile，进入 etch 后产生不同 lateral erosion 或 profile transfer。Wu 等人的研究将 resist 3D simulation 与 compact etch model 连接，明确讨论了 sidewall angle、ion energy、angular distribution、gas、pressure 和 material etch rate 等因素。[[19]](https://doi.org/10.1117/12.2086048)

量产 OPC model 不可能把整个 plasma reactor 的多尺度物理都逐点算一遍。工程师会选择与 wafer data 有稳定相关性的少量描述量，压缩成 gaussian kernel、visibility kernel、density kernel 或其他经验基函数。压缩得过度会漏掉二维行为，基函数太多又容易 overfit。

### 三种常见整合方式

| 方式 | 校准对象、优点与风险 |
| --- | --- |
| lumped model | 校准对象<br>直接用 AEI data 拟合一个总模型<br>优点<br>流程简单，直接瞄准最终图形<br>风险<br>litho 与 etch 根因混在一起，换任一 process 后维护困难 |
| retarget flow | 校准对象<br>用 ADI 到 AEI bias 生成 target adjustment<br>优点<br>速度快，容易进入现有 OPC recipe<br>风险<br>table 或简单模型覆盖不了复杂二维环境 |
| staged model | 校准对象<br>先建 litho model，再建 ADI 到 AEI 的 etch model<br>优点<br>物理边界清楚，可分别验证<br>风险<br>数据配对和模型管理更复杂 |

公开专利 US8255838B2 详细讨论了 staged、retarget 与 lumped 的差别，并用 ADI wafer、ADI model 和 AEI wafer 之间的 residual 构建 etch-aware calibration。[[20]](https://patents.google.com/patent/US8255838B2/en) 工厂选择哪一种，还取决于 layer、process stability、runtime、现有工具和维护成本。

三种方式代表三种模型分解假设。lumped flow 假设集成 process 足够稳定，可以直接学习 mask 到 AEI 的总响应。retarget flow 假设主要 etch effect 能压缩成 target bias。staged flow 假设 lithography 与 etch 可以通过 ADI measurement 有效分开。工程师会用 holdout structure、process change 和 runtime 去检验这些假设。某种模型在一层 metal 上有效，不代表它能直接搬到 contact、implant 或另一套 etch stack。

这里还有一个维护问题。resist 或 source 经常变化，而 etch 相对稳定时，staged model 允许只更新 lithography 部分。两段数据很难可靠配对，或者最终 AEI 才是唯一可信量测时，lumped model 可能更现实。模型结构应当服从数据能支持的因果分解，不能反过来要求数据证明一个预先选好的软件结构。

## 模型通过一轮轮预测和实验走到量产

前面的步骤放在一起，得到的是一套反复更新的工程方法。当前模型先提出 source、target bias 和 mask solution，实验把这些解落到 scanner、resist 与 etch 上，wafer result 再修正模型。每一轮都要回答两个问题，预测错在哪里，下一片 wafer 怎样最有效地区分几种可能原因。

整个开发过程可以按六道证据关口理解。

| 关口 | 主要动作与通过条件 |
| --- | --- |
| 产品定义 | 从 AEI、电性、可靠性和良率确定 wafer target 与 EPE budget<br>通过条件<br>每个优化指标都能追溯到产品要求 |
| 工艺定义 | 固定候选 scanner、source、mask、resist、film stack、develop 和 etch<br>通过条件<br>development model 对应明确的 process version |
| 可观测性 | 量物理输入，设计 test vehicle、FEM、process split 和 metrology recipe<br>通过条件<br>关键效应在数据中具有可区分的签名 |
| 模型资格 | 分层 calibration，做 holdout validation、residual 与 uncertainty review<br>通过条件<br>未见图形和 off-condition 的误差满足预算 |
| 逆向解资格 | 做 SMO、SSA、OPC 或 ILT，完成 source rendering、MRC 和 full-chip verification<br>通过条件<br>solution 能被 scanner 与 mask shop 实现，产品版图没有系统 hotspot |
| 硅上资格 | 写 reticle，跑产品或接近产品的 wafer，检查 CD、EPE、defect 和 electrical result<br>通过条件<br>simulation、wafer 与产品指标在规定窗口内一致 |

这些关口有先后关系，却很少只走一遍。新的 wafer hotspot 可能说明 sample plan 没有覆盖某类二维环境，团队要把它放回 test vehicle。measured source 与 target source 的偏差可能要求重新 rendering，也可能要求重建 model。AEI residual 若只在某种 underlayer 上出现，etch model 的输入边界就要扩大。

full-chip verification 在这里承担一个特殊角色。test mask 用有限样本建立模型，产品版图却包含数量巨大的局部环境。verification deck 用 compact model 扫描整片设计，寻找超出 calibration coverage、process window 过窄、MRC 冲突和迭代不收敛的位置。它把有限实验和全芯片 pattern space 接起来，但最后的 qualification 仍要回到新 reticle 与 wafer。

TSMC 对外介绍 mask service 时，明确称其 OPC model 覆盖 silicon process tools、process materials 和 DFM requirements，并维护 silicon-validated OPC database。[[21]](https://www.cld.tsmc.com/english/dedicatedFoundry/services/mask_services) TSMC 对 N6 的公开描述也把 lithography process optimization、OPC 和 etch co-optimization 放在同一量产技术路径中。[[22]](https://www.cld.tsmc.com/english/dedicatedFoundry/technology/platform_DCE_N7_N6) 这些官方材料没有公布内部 recipe，能够支持的判断仍然很清楚。量产 qualification 面向整套 process、model 与 design rule 的组合。

## Intel High-NA 展示了渐进式建模

大多数流程默认先有稳定 scanner 和 process，再收 wafer data 建模型。High-NA EUV 的首次导入打破了这个顺序。

Intel 在 2024 年完成首台商用 EXE 5000 的安装后，公开说明设备仍要经过 calibration 才能服务未来 process roadmap。[[23]](https://www.intel.de/content/www/de/de/newsroom/news/intel-foundry-opens-new-frontier-chipmaking.html) 设备、mask、resist、etch、metrology 和 OPC 的开发必须并行，否则所有工作都排在 scanner acceptance 之后，学习周期会很长。

Chris Mack 对 2025 年 SPIE 会议的记录提到，Intel 的 Can Guven 介绍了一种提前校准思路。团队在 scanner 发货前量测 aberration，再对最终 optics adjustment 后的状态做预测，用 rigorous simulation 推断早期 wafer result 与预期最终结果的差异，从而让 OPC calibration 更早开始。[[24]](https://lithoguru.com/life/?p=736)

这个案例的价值在于展示 physical measurement 与 simulation 的另一种连接方式。wafer data 仍然重要，但它不一定要等所有硬件和工艺完全冻结后才出现。高可信度的 mask、aberration 和 aerial image simulation 可以先建立 development model，早期 wafer 用来更新它，进入稳定工艺后仍需用独立 wafer 与产品图形完成 qualification；这是本文提出的工程验证要求，不是该会议笔记已经证明的实施结果。

这是一种渐进式精度策略。早期模型用已知物理量和 rigorous simulation 回答架构问题，帮助准备 test mask 与初始 OPC。scanner 安装后的早期 wafer 负责修正 tool-specific signature。process 与材料稳定以后，最终资格仍应由稳定工艺下的独立 wafer 与产品验证承担。每一阶段的模型都有清楚的证据等级和使用限制。

这种做法能缩短串行等待，却没有取消 wafer verification。它只是把原本集中在 scanner ready 之后的学习拆到多个阶段并行进行。越早期的模型越依赖物理先验，越接近量产的模型越要接受产品图形、真实 process window 和 metrology 的约束。

这段早期校准信息来自 Mack 的署名会议笔记，作者同时提醒转述可能遗漏或误解细节；它不构成 Intel 官方的量产资格披露。它适合说明一种先进开发策略，不适合写成 Intel 已公开的完整量产 recipe。

## EUV 把模型目标从平均轮廓扩展到失效概率

ArF 时代的 compact model 主要关注系统性 CD 和 EPE。EUV 中的 photon、secondary electron、resist chemistry 和材料随机性会产生 LER、LCDU、missing contact、microbridge 等概率事件。

平均 contour 对系统误差很有用，却会抹平随机缺陷。工程师需要在同一图形、同一 condition 下采集更多重复 SEM image，把 mean edge、variance、spatial correlation 和 defect probability 分开处理。用于高 sigma defect prediction 的实验数量会非常大，严谨 Monte Carlo simulation 也承担一部分数据生成任务。[[25]](https://doi.org/10.1117/12.3093415)

未来的 OPC package 可能同时包含两个模型。一个预测平均轮廓与 process window，另一个预测在该平均条件周围发生随机失效的概率。两者会共享 source、mask、resist 和 metrology data，却有不同的采样设计和验证指标。

方法也会随之改变。系统模型依靠跨 pattern 和跨 condition 的受控差异，概率模型还需要同一 condition 下的大量重复样本。前者主要问平均边缘落在哪里，后者要问分布尾部有多厚，以及某个罕见缺陷是否会在全芯片规模上变得可见。把重复 SEM image 简单平均，会改善系统 contour，却会删掉概率模型最需要的信息。

## 量产意味着持续管理模型的适用域

低 calibration RMS 只说明模型解释了参与拟合的数据。量产需要更多证据。

模型应当通过独立 validation set，覆盖 nominal 与 process window，能够解释关键 residual trend。source 在 scanner 上可实现并经过量测。ADI 与 AEI 之间的边界清楚。metrology bias 有评估。full-chip verification 没有大量 out-of-coverage pattern。新 reticle 的产品 wafer 结果与模拟一致。过程漂移也有 monitor 和 change control。

release 的对象是一组兼容关系。model version 要绑定 source、scanner configuration、mask stack、resist 与 film stack、etch chamber family、metrology recipe、OPC recipe、MRC 和 verification deck。脱离这些状态单独复制一个 model file，原有 validation 结论就失去了适用条件。

可以把 release 条件概括成六项。

1. 物理输入与设备状态已经版本化。
2. calibration data 与 validation data 相互独立。
3. 一维、二维和产品热点均有覆盖。
4. nominal、focus、dose 与必要的 mask 或 process variation 均有验证。
5. ADI、AEI 和 metrology error 的归属可以追踪。
6. reticle、product wafer、defect 与电性结果已经相互核对。

当其中一项发生变化，工程团队要判断改动是否仍在模型适用域内。小变化可以通过 requalification 证明兼容，超出适用域的变化则需要补数据、更新参数、重建模型或限制模型使用范围。

这项判断可以分三层。受控波动仍在原 calibration distribution 内时，量产 monitor 负责确认。可独立量测的 physical input 改变，但模型形式仍有效时，可以替换输入并做针对性 requalification。新的 process signature 落到覆盖范围以外时，团队要重新设计 split、补 calibration 与 validation data，再发布新的 model package。

## 从工业流程中抽象出一套六步建模法

流程说明告诉工程师先做什么、后做什么。方法论还要回答另一类问题。换一个 layer、source、resist 或 etch stack 以后，团队应当怎样决定收什么数据、允许模型使用多少自由度、何时相信预测、哪种变化会让已有结论失效。

前面的公开案例可以归纳成一套六步建模法。它的对象不限于某一家 EDA 软件，也不限于 ArF、EUV 或 High-NA。只要任务仍然是用有限实验建立可用于全芯片求解的工艺模型，这六步就有意义。

| 方法步骤 | 要回答的问题与主要动作 |
| --- | --- |
| 目标定义 | 问题<br>最终要保护哪个 wafer geometry 或器件功能<br>动作<br>选定 ADI 或 AEI target，分配 EPE budget，写清 nominal 与 process-window 指标 |
| 因果拆分 | 问题<br>哪些物理效应应当分开，哪些可以压缩<br>动作<br>画出 mask、optical、resist、etch 与 metrology 的正向关系，固定能独立量测的输入 |
| 实验辨识 | 问题<br>什么实验能够区分几种可能原因<br>动作<br>设计 pitch sweep、FEM、mask bias、process split、重复 die、ADI 与 AEI pair，并预留 holdout |
| 预测压缩 | 问题<br>最小的哪组状态量足以预测全芯片<br>动作<br>分层校准 compact model，检查分类 residual、off-condition 与独立 validation |
| 约束求逆 | 问题<br>怎样把 wafer target 变成可制造的 source、target bias 与 mask<br>动作<br>在多 condition 下做 SMO、SSA、OPC 或 ILT，把 illuminator、MRC、mask complexity 与收敛约束放进求解 |
| 资格管理 | 问题<br>怎样证明解能进入量产，证据何时需要更新<br>动作<br>量 measured source，写 reticle，跑产品 wafer，核对 defect 与 electrical result，并绑定 process 和 metrology 版本 |

方法能否落地，还要看交付物和失败信号。

| 方法步骤 | 交付物与必须退回重做的信号 |
| --- | --- |
| 目标定义 | 产物<br>target specification、error budget、验收指标<br>重做信号<br>数据很多，却说不清模型误差会伤到哪个产品指标 |
| 因果拆分 | 产物<br>model boundary、参数归属、量测清单<br>重做信号<br>多组参数可以互相补偿，process 变化后找不到误差来源 |
| 实验辨识 | 产物<br>test vehicle、sample plan、metrology recipe、uncertainty estimate<br>重做信号<br>增加 measurement 仍未增加信息，多个效应在数据里始终混在一起 |
| 预测压缩 | 产物<br>model package、validation report、适用域与 runtime<br>重做信号<br>calibration RMS 很低，holdout pattern 却出现稳定残差或外推失效 |
| 约束求逆 | 产物<br>source specification、SSA table、OPC recipe、mask pattern、verification deck<br>重做信号<br>nominal simulation 很好，source 无法渲染、mask 无法制造或 process window 过窄 |
| 资格管理 | 产物<br>silicon qualification、兼容版本表、monitor 与 requalification 规则<br>重做信号<br>model file 脱离原 scanner、材料、etch 或 metrology 条件继续使用 |

公开资料没有把这六步放进同一套命名。这里是对多家实践的归纳。imec 的四片 wafer 与 calibration、verification 分组说明实验怎样分离问题。[[8]](https://doi.org/10.1117/12.3010898) GlobalFoundries 在 optimized source 上重收数据、重建模型并制作新 reticle，说明正向模型与逆向解必须随硬件一起更新。[[2]](https://doi.org/10.1117/12.916614) Intel 的安装公告与 Mack 的会议笔记提供了硬件校准、早期模型开发的公开例子。[[23]](https://www.intel.de/content/www/de/de/newsroom/news/intel-foundry-opens-new-frontier-chipmaking.html)[[24]](https://lithoguru.com/life/?p=736) 将它们进一步组织为 development、early-wafer 与最终 qualification 三个阶段，是本文的方法论归纳。 TSMC 对 silicon-validated OPC、lithography、OPC 与 etch co-optimization 的公开描述，则说明量产资格属于整套 process 与 model 的组合。[[21]](https://www.cld.tsmc.com/english/dedicatedFoundry/services/mask_services)[[22]](https://www.cld.tsmc.com/english/dedicatedFoundry/technology/platform_DCE_N7_N6)

这六步有三次方向变化。产品要求先沿制造过程向上游逆推，决定 target、error budget、模型边界和实验内容。设备、mask、wafer 与 metrology data 随后沿正向过程建立模型，回答给定输入会印出什么。正向模型通过独立验证以后，求解器才沿逆向过程计算 source、target bias 和 mask pattern。最终解回到 scanner、reticle 和 wafer，接受实物检查。

这种方向安排解决了一个常见误区。数据采集不能从现有量测菜单出发，再期待模型自动找到物理意义。工程师要先写出几种可能原因，再选择能够把它们区分开的实验。through-pitch gauges 分辨 proximity response，FEM 约束 focus 和 dose 斜率，mask bias split 识别 mask response，ADI 与 AEI pair 分离 lithography 和 etch，重复 die 估计 noise，holdout clips 检验预测。每组数据都应当对应一种清楚的区分任务。

模型自由度也应服从同一原则。一个参数只有在数据中留下可区分的签名，才有理由成为拟合自由度。能独立量测的 source、aberration、mask CD 和 film stack 应尽量作为物理输入。难以直接分离的 resist、etch 和 metrology effect 可以交给拟合，但它们需要接受跨 pattern、跨 condition 和独立样本的残差检查。训练误差无法替代这些证据。

每次 model release 最后都应当写成一条带条件的资格声明。它说明模型预测哪个 target，覆盖哪些 design pattern 和 process window，绑定哪组 scanner、source、mask、resist、etch 与 metrology version，并在多大的误差预算内通过了哪些独立验证。任何一项条件改变，团队都要重新判断原证据是否仍然成立。

这套方法把物理实在和仿真计算放进各自合适的位置。实验决定模型能够获得哪些解释，也限定结论可以相信到哪里。simulation 在这个范围内扫描大量组合，求出实验无法逐一尝试的 source 和 mask。新 wafer 再检查这些求解结果，并告诉下一轮实验应该区分什么。source、resist、etch 或 metrology 一旦改变，团队就回到资格声明，找出已经失效的证据，再决定补哪一组 wafer split。


## 从拟合残差走到参数可辨识性

前文反复提出“参数可能互相补偿”，需要给出一个可计算的判据。设第 $i$ 个实验输入是 $\mathbf x_i$，模型参数为 $\boldsymbol\theta$，预测量为 $g_i(\mathbf x_i;\boldsymbol\theta)$。实际量测更完整地写成

$$
\mathbf y=\mathcal H\!\left(\mathcal F(\mathbf x;\boldsymbol\theta);\boldsymbol\phi\right)
+\boldsymbol\epsilon.
$$

$\mathcal H$ 是计量与抽边过程，$\boldsymbol\phi$ 是计量参数，$\boldsymbol\epsilon$ 是随机误差。输入 $\mathbf x$ 本身也可能有不确定度，例如 scanner 的实际焦点、剂量和掩模 CD。把这些量全当成精确常数，会迫使工艺参数吸收输入误差。Mack 的校准研究讨论了稳健回归与 total least squares；它说明损失函数的选择必须服从实际误差位于哪里。[[11]](https://doi.org/10.1117/12.728961)[[12]](https://doi.org/10.1117/12.2218534)

若先采用输出噪声模型，残差 $\mathbf r=\mathbf y-\mathbf g(\boldsymbol\theta)$ 的加权目标可写为

$$
\widehat{\boldsymbol\theta}=\arg\min_{\boldsymbol\theta}
\mathbf r^\mathsf T\Sigma^{-1}\mathbf r
+\lambda R(\boldsymbol\theta),
\qquad \boldsymbol\theta\in\Theta_{\mathrm{phys}}.
$$

$\Sigma$ 是量测协方差，$\Theta_{\mathrm{phys}}$ 是物理可接受参数域。CD 点若来自同一曝光场，共同的 focus 偏差会使它们相关；一条 SEM contour 上相邻点也不独立。用对角矩阵代替全部协方差是可以采用的工程近似，但要评估这种近似是否造成某些轮廓被过度加权。

辨识能力由噪声归一化的敏感度决定。对参数作局部线性化：

$$
\Delta\mathbf y\approx J\Delta\boldsymbol\theta,
\qquad J_{ij}=\frac{\partial g_i}{\partial\theta_j},
\qquad A=\Sigma^{-1/2}J=U\operatorname{diag}(s_k)V^\mathsf T.
$$

很小的奇异值 $s_k$ 表示沿对应参数组合改变，预测响应仍被噪声淹没。此时得到唯一的优化器输出，不等于数据给出了唯一的物理解释。多 NA、多 pitch 和多 feature 数据联合校准，能够增加独立约束，但仍要检查它们是否真的改变敏感度方向。[[27]](https://doi.org/10.1016/S0167-9317(02)00438-0)

例如只用标称 CD，同时放开 source blur、resist diffusion、SEM blur，三个参数都可能让边缘变缓。增加同 pitch 的重复点主要降低噪声，不一定能分开它们。引入独立 pupil measurement、PEB split、不同 landing energy 的 SEM 数据，才有机会让三种机制留下不同签名。即便如此，若工艺本身变化不可控，结论仍可能是“只能识别一个有效 blur”，应诚实保留这个抽象。

对非线性模型，SVD 是局部工具。还可以固定某个参数，在一系列值上重新优化其他参数，画出 profile loss；若很宽的参数范围都具有相近损失，其不确定度就不能用单次优化器的收敛标志掩盖。不同初值、多批次 bootstrap 和独立物理量测，也有助于检验结论是否依赖偶然样本。

## 怎样设计下一片 wafer，而不只是增加数据

在局部近似下，实验的信息矩阵是 $F=J^\mathsf T\Sigma^{-1}J$。这给出选择 sample plan 的一种数学语言：增加 $\log\det(F+\alpha I)$ 可鼓励覆盖多个敏感方向，提高最小特征值可优先补最难辨识的方向。$\alpha$ 是避免奇异的正则项。这些是一般实验设计准则，本文不声称某家工厂按同一公式选 wafer。

关键在于不要把一个实验的独立数据点数与其像素数混淆。同一个二维图形可以产生几百个 EPE 点，但共同的配准和抽边偏差可能只增加少量独立信息。重复 wafer、重复 die 和改变测量方向能帮助估计噪声结构；新 pitch、方向与 process split 则可能增加新的敏感方向。两类实验解决不同问题。

一个具体决策例子是：模型在 off-focus 的 line end 上出现同向残差，而 nominal 长直线已经足够好。下一轮优先收集对焦点与二维方向敏感的图形，并确认实际 focus 与 mask contour；再收一批相同 nominal 长直线，很可能只是重复已有约束。若怀疑 etch，不应先释放更多 optical 参数，而要补能可靠配对的 ADI/AEI 或 profile 信息。

IBM 的自动 sample selection 研究给出在设计覆盖与量测成本之间折中的实际例子；多阶段回归研究则说明，增加模型复杂度和提高验证精度并非同一回事。[[7]](https://doi.org/10.1117/12.2086049)[[28]](https://research.ibm.com/publications/multiple-stages-of-regression-to-improve-accuracy-in-calibrated-lithography-process-models) 数学准则用于提出候选，最终 sample plan 还要满足 test mask 面积、wafer 数量、SEM 寻址与工艺可执行性。

## 验证报告要拆开数值误差、模型误差和观测误差

数值收敛是第一层。固定模型、输入与参数，分别增加电磁网格、源点采样、SOCS 核数和像面分辨率，检查预测及其优化梯度是否稳定。若每次增加核数又重拟合胶参数，数值变化与参数补偿混在一起，就无法判断光学算法本身是否收敛。

第二层才是预测验证。保留拟合结果，预测没有参与调参的数据。随机把相邻 gauge 分成两组可能泄露几何和工艺信息；若实际任务是预测新产品或新 wafer，holdout 应按图形家族、独立 wafer 或独立条件分组。为了选择模型复杂度使用的 validation，也不能在最后继续当作从未看过的 test set。

第三层是逆问题验证。一个前向模型能够预测固定 clip，不代表其梯度对求解器足够准确。OPC/ILT 会主动寻找模型认为有利的形状，也可能走向训练覆盖之外。应当用更高精度仿真或独立模型检查最终掩模，再用写后掩模和 wafer 验证。这个检查尤其应覆盖新出现的高曲率、细小 SRAF 和极端邻域。

评价量应包括：按图形和条件分箱的偏差、分位数与最大 EPE、工艺窗口交集、形貌与连通性失败，以及整套 verification 的运行时间。全局 RMS 容易被数量多的简单图形支配；某个关键 tip-to-tip 的稳定失败，不应被平均掉。

计量误差与模型误差还要分别估计。重复量测可以近似估计 precision，不能单独证明 accuracy；同一 SEM recipe 稳定地把所有边缘偏移，重复一百次仍会稳定地偏。必须结合量测模型、独立计量或已知物理变化，识别这类系统偏差。[[12]](https://doi.org/10.1117/12.2218534)

## 不确定度怎样进入签核与变更控制

如果输出边缘为 $\mathbf c(\boldsymbol\theta)$，参数协方差为 $\Sigma_\theta$，局部传播为

$$
\Sigma_c\approx G\Sigma_\theta G^\mathsf T,
\qquad G=\frac{\partial\mathbf c}{\partial\boldsymbol\theta}.
$$

这个结果只反映已定义模型与参数的不确定度，不包含遗漏物理的系统偏差。若不同合理模型在训练集同样好、在某类产品图形预测分歧很大，这种分歧本身就应触发额外验证。不能因为参数置信区间很窄，就宣布模型形式误差也很小。

对缺陷概率，验证要求又不同。若 $N$ 次独立机会中零失败，单侧 95% 上界为 $1-0.05^{1/N}\approx3/N$。当声称的失效率远低于这个上界，必须说明额外证据来自更大规模实验、重要性采样、物理概率模型还是未经验证的外推。真实晶圆的空间相关性还会减少有效独立样本数。平均 CD 的标准误无法替代稀有失效概率的置信区间。

因此模型 release 应带着一份明确的适用域声明：目标平面、图形类别、focus/dose 范围、mask/resist/etch/计量版本、数值精度以及独立验证证据。换 source 可能主要影响光学输入，换 SEM recipe 首先改变观测链，换 etch chemistry 则可能改变整个模块的函数形式。变更控制要根据受影响的因果路径选择实验，而不能对所有变化一律套用同一小组 monitor。

这也是从物理实在走到计算模型时最需要保存的东西：不仅保存最终系数，还保存为什么这组数据能够约束这些系数、哪些参数只能作为有效参数解释，以及什么变化会让原证据失效。

## 参考文献与来源说明

网页访问日期均为 2026-10-25。原始论文、专利、机构技术文档和署名会议笔记承担不同的证据作用；专利表示公开方案，服务页表示机构公开说明，会议笔记表示作者对报告的转述，均不能独自替代产品量产资格证据。文中的 Jacobian、SVD、信息矩阵和误差传播为一般数学方法，已标出局部与统计假设。

1. Hwang S, Gillijns W, De Gendt S, Kim R-H. “Source mask optimization (SMO) study for high-NA EUV lithography to achieve single patterning on random logic metal.” Proc. SPIE 12954:129540X, 2024. [永久链接 / 原始记录](https://doi.org/10.1117/12.3010869)。
2. Zhang D, Chua G, Foong Y, et al. “Source mask optimization methodology (SMO) and application to real full chip optical proximity correction.” Proc. SPIE 8326:83261V, 2012. [永久链接 / 原始记录](https://doi.org/10.1117/12.916614)。
3. Huang T, Huang C-Y, Chiou T-B, et al. “Improvement of lithography process by using a FlexRay illuminator for memory applications.” Proc. SPIE 7973:79731X, 2011. [永久链接 / 原始记录](https://doi.org/10.1117/12.879567)。
4. Zhu J, Wei F, Chen L, et al. “Source mask optimization study based on latest Nikon immersion scanner.” Proc. SPIE 9780:97801P, 2016. [永久链接 / 原始记录](https://doi.org/10.1117/12.2223576)。
5. Keck M C, Bodendorf C, Schmidtling T, et al. “Modular process modeling for OPC.” Proc. SPIE 6520:652044, 2007. [永久链接 / 原始记录](https://doi.org/10.1117/12.716295)。
6. Weisbuch F, Koh K K, Jantzen K. “Bringing SEM-contour based OPC to production.” Proc. SPIE 9052:905224, 2014. [永久链接 / 原始记录](https://doi.org/10.1117/12.2048288)。
7. Viswanathan R, Jaiswal O, Casati N, et al. “Experiments using automated sample plan selection for OPC modeling.” Proc. SPIE 9426:94260W, 2015. [永久链接 / 原始记录](https://doi.org/10.1117/12.2086049)。
8. Alkoken R, Baram M, Oron G, et al. “Low landing energy as an enabler for optimal contour based OPC modeling in the EUV era.” Proc. SPIE 12955:1295516, 2024. [永久链接 / 原始记录](https://doi.org/10.1117/12.3010898)。
9. Yu P, Shi S X, Pan D Z. “Process variation aware OPC with variational lithography modeling.” Design Automation Conference, pp.785–790, 2006. [永久链接 / 原始记录](https://doi.org/10.1145/1146909.1147108)。
10. Klostermann U K, Mülders T, Ponomarenco D, et al. “Calibration of physical resist models: methods, usability, and predictive power.” Proc. SPIE 7273:727342, 2009. [永久链接 / 原始记录](https://doi.org/10.1117/12.814216)。
11. Mack C A. “Improved methods for lithography model calibration.” Proc. SPIE 6607:66071D, 2007. [永久链接 / 原始记录](https://doi.org/10.1117/12.728961)。
12. Mack C A, Sturtevant J L, Deng Y, et al. “Modeling metrology for calibration of OPC models.” Proc. SPIE 9778, 2016. [永久链接 / 原始记录](https://doi.org/10.1117/12.2218534)。
13. Lai C-J, Anderson S; assignee TSMC. “Method and system of correcting optical proximity correction (OPC) model for manufacturing semiconductor device.” 专利申请 US20260003293A1, 2026-01-01. [永久链接 / 原始记录](https://patents.google.com/patent/US20260003293A1/en)。
14. 张生睿、俞宗强、施伟杰；申请人 Dongfang Jingyuan Electron Ltd. “掩膜图形偏差值确定方法、装置、设备、介质及产品.” 专利申请 CN119516574A, 2025-02-25. [永久链接 / 原始记录](https://patents.google.com/patent/CN119516574A/zh)。
15. 何建芳、韦亚一、董立松等；申请人：中国科学院微电子研究所. “提高版图光刻性能的方法、修正后的版图及仿真方法.” 专利申请 CN110989289A, 2020-04-10. [永久链接 / 原始记录](https://patents.google.com/patent/CN110989289A/zh)。
16. He J, Dong L, Zhao L, Wei Y. “Retargeting of forbidden-dense-alternate structures for lithography capability improvement in advanced nodes.” Applied Optics 57(27):7811–7817, 2018. [永久链接 / 原始记录](https://doi.org/10.1364/AO.57.007811)。
17. Gardin C, Belledent J, Trouiller Y, et al. “Etch modeling for model-based optical proximity correction for 65 nm node.” Microelectronic Engineering 84:770–773, 2007. [永久链接 / 原始记录](https://doi.org/10.1016/j.mee.2007.01.085)。
18. Weisbuch F, Lutich A, Schatz J, et al. “Improving contact layer patterning using SEM contour based etch model.” Proc. SPIE, 2016. [永久链接 / 原始记录](https://doi.org/10.1117/12.2248013)。
19. Wu C-E, Yang W, Luan L, Song H. “Photoresist 3D profile related etch process simulation and its application to full chip etch compact modeling.” Proc. SPIE 9426:94261Q, 2015. [永久链接 / 原始记录](https://doi.org/10.1117/12.2086048)。
20. Jing Xue, Jensheng Huang; assignee Synopsys Inc. “Etch-aware OPC model calibration by using an etch bias filter.” 美国专利 US8255838B2, 2012-08-28. [永久链接 / 原始记录](https://patents.google.com/patent/US8255838B2/en)。
21. TSMC. “Mask Services.” 官方服务文档，未标年份. [永久链接 / 原始记录](https://www.cld.tsmc.com/english/dedicatedFoundry/services/mask_services)。
22. TSMC. “DCE Platform – N7/N6 Technology.” 官方技术平台文档，未标年份. [永久链接 / 原始记录](https://www.cld.tsmc.com/english/dedicatedFoundry/technology/platform_DCE_N7_N6)。
23. Intel. “With High NA EUV, Intel Foundry Opens New Frontier in Chipmaking.” 官方公告，2024-04-18. [永久链接 / 原始记录](https://www.intel.de/content/www/de/de/newsroom/news/intel-foundry-opens-new-frontier-chipmaking.html)。
24. Mack C A. “SPIE Advanced Lithography 2025, day 3 conference notes.” 作者署名会议笔记，2025. [永久链接 / 原始记录](https://lithoguru.com/life/?p=736)。
25. Ghosh P, Kwok W Y, et al. “Full-chip high sigma probabilistic modeling, defect detection and repair in advanced EUV nodes.” Proc. SPIE, 2026. [永久链接 / 原始记录](https://doi.org/10.1117/12.3093415)。
26. Pandey N, Hunsche S, Lyons A, et al. “Aerial imaging (AIMS®) based computational lithography model calibration and mask metrology for high-NA EUV.” Proc. SPIE PC12751:PC127510Z, 2023. [永久链接 / 原始记录](https://doi.org/10.1117/12.2688109)。
27. Byers J, Mack C, Huang R, Jug S. “Automatic calibration of lithography simulation parameters using multiple data sets.” Microelectronic Engineering 61–62:89–95, 2002. [永久链接 / 原始记录](https://doi.org/10.1016/S0167-9317(02)00438-0)。
28. Kumar P, Rosenbluth A E, Pusuluri R M, et al. “Multiple stages of regression to improve accuracy in calibrated lithography process models.” Journal of Micro/Nanolithography, MEMS, and MOEMS, 2018. [永久链接 / 原始记录](https://research.ibm.com/publications/multiple-stages-of-regression-to-improve-accuracy-in-calibrated-lithography-process-models)。
