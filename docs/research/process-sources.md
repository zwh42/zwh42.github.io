# 工艺、紧凑模型与掩模制造来源核查

访问日期：2026-10-25。检索原则：原始论文、作者正式预印本、机构论文库、官方产品文档优先；DOI 用于永久定位。仅摘要可读的来源只支持摘要明确陈述的结论，不应外推为行业通用数值。专利是公开方案，不是量产实施证明。下列说明均为意译。

## physics-to-model 原稿 26 项参考文献映射

编号对应去除原末尾空白条目后的 26 个名称，保留正文 [1]–[26] 的逻辑。

| 原编号 | 规范来源及永久链接 | 已核实的支持范围 / 限制 |
| --- | --- | --- |
| 1 | Hwang S, Gillijns W, De Gendt S, Kim R-H. Source mask optimization (SMO) study for high-NA EUV lithography to achieve single patterning on random logic metal. Proc. SPIE 12954, 129540X (2024). [DOI](https://doi.org/10.1117/12.3010869); [imec 全文](https://imec-publications.be/bitstream/handle/20.500.12860/44033.2/129540X.pdf?isAllowed=y&sequence=1). | 24/22/20 nm pitch、200 gauges、八种 mask tone/absorber/SRAF 组合的仿真；不能写成已经在产品量产硅片验证。 |
| 2 | Zhang D, Chua G, Foong Y, et al. Source mask optimization methodology (SMO) and application to real full chip optical proximity correction. Proc. SPIE 8326, 83261V (2012). [DOI](https://doi.org/10.1117/12.916614). | source 优化后用新 wafer CD 重校 OPC、调整 recipe、制作 reticle，并验证 wafer；13%/17%/12% 是该案例 DOF/MEEF/PV-band 改善。 |
| 3 | Huang T, Huang C-Y, Chiou T-B, et al. Improvement of lithography process by using a FlexRay illuminator for memory applications. Proc. SPIE 7973, 79731X (2011). [DOI](https://doi.org/10.1117/12.879567). | DRAM 案例、scanner pupil 实测确认、FEM 与缺陷检查；DOF 最高改善 50% 只属于该实验。题名/DOI 已核实，摘要可读。 |
| 4 | Zhu J, Wei F, Chen L, et al. Source mask optimization study based on latest Nikon immersion scanner. Proc. SPIE 9780, 97801P (2016). [DOI](https://doi.org/10.1117/12.2223576). | illuminator 硬件约束、pupil 渲染与实测、MRC 与 source 的共同约束。论文明确说明原设计 tuning mask 尚不存在，使用相近结构验证，须保留限制。 |
| 5 | Keck M C, Bodendorf C, Schmidtling T, et al. Modular process modeling for OPC. Proc. SPIE 6520, 652044 (2007). [DOI](https://doi.org/10.1117/12.716295). | mask、optics、resist、etch 分模块建模及工艺更改后替换模块。作者全文副本和 SPIE 官方会议摘要互证。 |
| 6 | Weisbuch F, Koh K K, Jantzen K. Bringing SEM-contour based OPC to production. Proc. SPIE 9052, 905224 (2014). [DOI](https://doi.org/10.1117/12.2048288). | contour 与 gauge 比较、通过重复曝光与平均处理噪声、样本覆盖；某案例 55 vs 650 structures 不是一般缩减比例。 |
| 7 | Viswanathan R, Jaiswal O, Casati N, et al. Experiments using automated sample plan selection for OPC modeling. Proc. SPIE 9426, 94260W (2015). [DOI](https://doi.org/10.1117/12.2086049); [IBM](https://research.ibm.com/publications/experiments-using-automated-sample-plan-selection-for-opc-modeling). | 自动决定校准集大小，在设计覆盖与 metrology 成本间折中；不是对每个样本都做物理可辨识证明。 |
| 8 | Alkoken R, Baram M, Oron G, et al. Low landing energy as an enabler for optimal contour based OPC modeling in the EUV era. Proc. SPIE 12955, 1295516 (2024). [DOI](https://doi.org/10.1117/12.3010898); [imec 全文](https://imec-publications.be/bitstreams/53c14cf4-951c-4f51-b0ff-24a87d5030d3/download). | 150 eV 扫描减小 shrinkage，但 SNR 降低；SEM 条件影响 modeling residue。四片 wafer 已核实为 2 post-litho + 2 post-etch，每种各一片 nominal、一片 FEM。不得把这个分组直接写成 calibration/verification 分组。 |
| 9 | Yu P, Shi S X, Pan D Z. Process variation aware OPC with variational lithography modeling. DAC (2006), 785–790. [DOI](https://doi.org/10.1145/1146909.1147108); [原文](https://www.cs.york.ac.uk/rts/docs/DAC-1964-2006/PAPERS/2006/DAC06/PDFFILES/P0785.PDF). | dose/focus variation 与 V-EPE；原稿含糊的“Process variation aware OPC modeling”应改为准确题名。 |
| 10 | Klostermann U K, Mülders T, Ponomarenco D, et al. Calibration of physical resist models: methods, usability, and predictive power. Proc. SPIE 7273, 727342 (2009). [DOI](https://doi.org/10.1117/12.814216). | independent validation、source 实测与 3D-mask 描述影响预测、参数可超过 20 但其案例最多调整 8 个；不能泛称八个参数足够。 |
| 11 | Mack C A. Improved methods for lithography model calibration. Proc. SPIE 6607, 66071D (2007). [DOI](https://doi.org/10.1117/12.728961); [作者全文](https://www.lithoguru.com/scientist/litho_papers/2007_156_Improved%20Methods%20for%20Lithography%20Model%20Calibration.pdf). | 普通最小二乘不稳健；focus/dose 也有输入误差；robust fitting、total least squares。 |
| 12 | Mack C A, Sturtevant J L, Deng Y, Zuniga C D, Adam K. Modeling metrology for calibration of OPC models. Proc. SPIE 9778 (2016). [DOI](https://doi.org/10.1117/12.2218534); [作者全文](https://lithoguru.com/scientist/litho_papers/2016_Modeling_Metrology_for_OPC.pdf). | Analytical Linescan Model 把系统性 SEM 量测偏差纳入观测链，以 validation 比较模型。 |
| 13 | Lai C-J, Anderson S. Method and system of correcting optical proximity correction (OPC) model for manufacturing semiconductor device. US20260003293A1, published 2026-01-01; assignee TSMC. [公开文本](https://patents.google.com/patent/US20260003293A1/en). | 独立 metrology-aware correction model；仅能称“TSMC 的专利申请公开方案”，不能证明具体量产流程。 |
| 14 | 确定掩模图案偏差值的方法、装置、设备、介质及产品. CN119516574A (2025). [公开文本](https://patents.google.com/patent/CN119516574A/zh). | 背景技术明确描述 conventional SSA table 流程：test mask、ADI/AEI 量测、偏差表、产品补偿。属于申请人对既有流程的描述，不能代表所有厂。 |
| 15 | 提高版图光刻性能的方法、修正后的版图及仿真方法. CN110989289A (2020). [公开文本](https://patents.google.com/patent/CN110989289A/zh). | FDA / forbidden pitch 的 retargeting 方案已确认；是否确切用“SSA”术语尚未核对，不宜把专利标题写成“SSA retargeting patent”。 |
| 16 | He J, Dong L, Zhao L, Wei Y. Retargeting of forbidden-dense-alternate structures for lithography capability improvement in advanced nodes. Applied Optics 57(27):7811–7817 (2018). [DOI](https://doi.org/10.1364/AO.57.007811); [PubMed](https://pubmed.ncbi.nlm.nih.gov/30462046/). | FDA 局部 target 调整及源优化折中；论文结果不宜外推成 arbitrary layout 全局有效。 |
| 17 | Etch modeling for model-based optical proximity correction for 65 nm node. Microelectronic Engineering 84:770–773 (2007). [DOI](https://doi.org/10.1016/j.mee.2007.01.085). | rule-based etch correction 的局限，density kernel 模型及非对称性；作者列表可从 DOI metadata 补齐。 |
| 18 | Weisbuch F, Lutich A, Schatz J, et al. Improving contact layer patterning using SEM contour based etch model. Proc. SPIE (2016). [DOI](https://doi.org/10.1117/12.2248013). | contact litho/etch bias 不均匀，contour 辅助 etch 模型。DOI 和题名经 Crossref 核实；卷号未核，不编造。 |
| 19 | Wu C-E, Yang W, Luan L, Song H. Photoresist 3D profile related etch process simulation and its application to full chip etch compact modeling. Proc. SPIE 9426, 94261Q (2015). [DOI](https://doi.org/10.1117/12.2086048); [大学库全文](https://ir.lib.nycu.edu.tw/bitstream/11536/125141/1/b4d40abd0615970d1c2ae8c7a7a6b51b.pdf). | SWA、plasma ion reflection/source anisotropy 影响 etch bias；这些为仿真产生的虚拟数据，不能写成已全面实物验证。 |
| 20 | Etch-aware OPC model calibration by using an etch bias filter. US8255838B2 (2012); application US20110179393A1 (2011). [公开文本](https://patents.google.com/patent/US8255838B2/en). | ADI/AEI paired data，inverse bias filter，staged/integrated calibration 的公开实现；不证明行业统一做法。 |
| 21 | TSMC. Mask Services. [官方页](https://www.cld.tsmc.com/english/dedicatedFoundry/services/mask_services). | 官方描述 silicon-validated OPC database 与 wafer processing technology 的配合；属于服务说明，不是独立性能论文。 |
| 22 | TSMC. DCE Platform – N7/N6 Technology. [官方页](https://www.cld.tsmc.com/english/dedicatedFoundry/technology/platform_DCE_N7_N6). | 官方明确 lithography process optimization、OPC、etch co-optimization；不能从营销页反推未公开校准细节。 |
| 23 | Intel. With High NA EUV, Intel Foundry Opens New Frontier in Chipmaking (2024-04-18). [官方页](https://www.intel.de/content/www/de/de/newsroom/news/intel-foundry-opens-new-frontier-chipmaking.html). | 2024 年安装完成、开始 calibration。历史状态应使用当时语气，不能写成 2026 当前成熟度判断。 |
| 24 | Mack C A. SPIE Advanced Lithography and Patterning Symposium 2025 – day 3. [作者博客原文](https://lithoguru.com/life/?p=736). | 已用终端从作者网页读取全文：记述 Intel Can Guven 在 scanner 出货前测 aberration，借 rigorous simulation 预测 early wafer 与最终调整后结果之差，提前校准。作者自己警告可能遗漏或误解细节，故仅作署名会议笔记；勿用它证明 Intel POR 量产 qualification。 |
| 25 | Ghosh P, Kwok W Y, et al. Full-chip high sigma probabilistic modeling, defect detection and repair in advanced EUV nodes. Proc. SPIE (2026-04-10). [DOI](https://doi.org/10.1117/12.3093415); [Synopsys 官方会议页](https://www.synopsys.com/events/spie-advanced-lithography-patterning/spie-papers.html). | 题名和 DOI 经 Crossref 核实，官方页列出该报告；尚未核对正文，不能支持具体 sigma/失效率数字。 |
| 26 | Pandey N, Hunsche S, Lyons A, et al. Aerial imaging (AIMS®) based computational lithography model calibration and mask metrology for high-NA EUV. Proc. SPIE PC12751, PC127510Z (2023-12-12). [DOI](https://doi.org/10.1117/12.2688109); [ZEISS 官方 PDF](https://asset-downloads.zeiss.com/catalogs/download/smt/3489dbf4-5e34-4ebe-965b-c8993ec3f7fe/PC127510Z.pdf). | 搜索索引给出摘要：直接 aerial-image 量测分离 mask/optical 效应，属于 preliminary study。该 PDF 在直接 open 时 404，但索引首页明确给出 DOI 10.1117/12.2688109、2023-12-12；使用 DOI 为稳定入口。 |

## 四篇扩写可用的补充来源

1. Wong A K, Ferguson R A, Mansfield S M. The mask error factor in optical lithography. IEEE Transactions on Semiconductor Manufacturing 13(2):235–242 (2000). [DOI](https://doi.org/10.1109/66.843639); [IBM 原始摘要](https://research.ibm.com/publications/the-mask-error-factor-in-optical-lithography). 论断：MEEF 随 pattern nesting 和 image integrity 改变；二维 ED window 可扩展到三维 mask–exposure–defocus volume。不要把某个 MEEF 值视为全局常数。
2. Mack C A, Schellenberg F M. Impact of mask errors on optical lithography (1999). [作者全文](https://www.lithoguru.com/scientist/litho_papers/1999_93_Impact%20of%20Mask%20Errors%20on%20Optical%20Litho.pdf). 论断：contacts 和 lines 的 MEEF 不同；mask CD variation 会使不同 mask condition 的 process-window intersection 收缩。
3. Mack C A. Impact of resist on the mask error enhancement factor. The Lithography Expert (Winter 2000). [作者教程](https://www.lithoguru.com/scientist/litho_tutor/TUTOR28%20%28Winter%2000%29.pdf). 论断：finite resist contrast 与 PEB diffusion 会改变 MEEF，不能仅从 aerial image 推出最终 resist sensitivity。
4. Mack C A. Inside PROLITH: A Comprehensive Guide to Optical Lithography Simulation. FINLE, 1997, ISBN 0-9650922-0-8. [官方作者 PDF](https://www.lithoguru.com/scientist/litho_papers/Inside_PROLITH.pdf). 第 9 章 lumped parameter model；第 10 章 process-window 定义与 focus/exposure error rectangle。图示为教材来源但 All Rights Reserved，不能仅因可下载而当成开放授权图片复制。
5. Byers J, Mack C, Huang R, Jug S. Automatic calibration of lithography simulation parameters using multiple data sets. Microelectronic Engineering 61–62:89–95 (2002). [DOI](https://doi.org/10.1016/S0167-9317(02)00438-0); [作者论文目录](https://www.lithoguru.com/scientist/papers.html). 论断：多 NA、多 pitch、多 feature 数据共同约束一组参数，提高唯一性与预测性；该论文不是“仅靠低 RMS 证明辨识”的依据。
6. Kumar P, Rosenbluth A E, Pusuluri R M, et al. Multiple stages of regression to improve accuracy in calibrated lithography process models. JM3 (2018). [IBM 原始摘要](https://research.ibm.com/publications/multiple-stages-of-regression-to-improve-accuracy-in-calibrated-lithography-process-models). 论断：regularization 与 cross-validation；增加单阶段复杂度在其例中收益有限。45%/55% RMS 改善只属于论文 14 nm 案例。
7. Calibration of Compact Resist Model Through CNN Training. IEEE Transactions on Semiconductor Manufacturing 36(2):180–187 (2023). [DOI](https://doi.org/10.1109/TSM.2023.3267670). 论断：compact kernel convolution 可映射 CNN；数据不足容易 overfit；优化 kernels 不是物理参数被唯一测出的证明。
8. Pearman R, Ungar J, Shirali N, et al. Adopting curvilinear shapes for production ILT: challenges and opportunities. Proc. SPIE 11148, 111480T (2019). [作者机构全文](https://design2silicon.com/wp-content/uploads/2020/08/111480T-2019.pdf). 论断：mask variability、MRC-aware ILT 与 mask-process systematics；多束写入没有自动免除 MRC。
9. Pang L, et al. Breakthrough curvilinear ILT enabled by multi-beam mask writing. J. Micro/Nanopattern. Mater. Metrol. 20(4), 041405 (2021). [作者机构全文](https://design2silicon.com/wp-content/uploads/2021/11/JM3-21046SS_online.pdf). 论断：VSB shot count 与曲线 fracturing 成本，多束像素域写入与 ILT runtime 两个不同瓶颈。写入恒时是在特定写入模式条件下的形状复杂度比较，不能写成任何工艺参数均无影响。
10. Fujimura A, Choi Yohan, Shendre Abhishek. Curvilinear masks overview: manufacturable mask shapes are more reliably manufacturable. JMM 23(4), 041502 (2024). [DOI](https://doi.org/10.1117/1.JMM.23.4.041502). 论断：综述 VSB/MBMW curvilinear mask 制造及 wafer process window。商业作者综述，参数与优势须保留具体工艺范围。
11. Siemens. Rapid full-chip curvilinear OPC for advanced logic and memory (2021 SPIE paper). [官方技术文档](https://resources.sw.siemens.com/en-GB/technical-paper-rapid-full-chip-curvilinear-opc-for-advanced-logic-and-memory/). 论断：MBMW 缓解 curvilinear MDP/writing 门槛，但 full-chip generation runtime 仍需算法设计。
12. IMS Nanofabrication. Our products. [官方文档](https://www.ims.co.at/en/products/). 论断：MBMW-101 使用 512×512 可编程 beams；固定模式下复杂曲线无额外写入时间。页面具体机型属历史产品说明，不外推到所有 writer。

## 图片选择

- 用户限定 wiki 或教材文档。上述商业论文图、专利图与设备照片不应作为文章配图来源，除非用户进一步允许这些来源。
- 可将 Inside PROLITH 教材作为“阅读原图”外链（第 10 章 process window），但因其版权声明，尚未确认复用许可，未下载/复制图示。
- 推荐从 Wikimedia Commons 中选择通用 photolithography、optical proximity correction 或 overfitting 教学图，必须核查每个 File 页面作者/许可/版本，不能只标“Wikipedia”。当前未落实具体图档，避免以不明图片冒充引用完整。

核查补充：Wong 的 DOI 必须是 **10.1109/66.843639**，不是 10.1109/66.843657（后者 Crossref 返回 404）。De Bisschop P. Stochastic effects in EUV lithography: random, local CD variability, and printing failures. JM3 16(4), 041013 (2017-12-29). [DOI](https://doi.org/10.1117/1.JMM.16.4.041013) 已经 Crossref 与 [imec 原始记录](https://imec-publications.be/entities/publication/42d06377-de99-42aa-a256-c25202dca659) 双重核实。

## 本次编辑补充核查与图像

- MEEF 正确 DOI 是 10.1109/66.843639；旧暂写 843657 已清除。
- 曲线综述 10.1117/1.JMM.23.4.041502 的作者由 Crossref 原始元数据再次核对，为 Aki Fujimura、Yohan Choi、Abhishek Shendre。
- Erdmann 教材 ISBN 9781510639010 已确认；10.1515/aot-2021-0018 是 Melvin 书评，不能写成教材 DOI。未验证的 SPIE Book/2573107 链接已移除，改用作者机构明确提到该书的出版记录。
- physics-to-model 原文称 Gardin 的 65 nm etch 论文为 Torres，现改正。原 SSA 专利编号 CN111025856B 实为禁止周期辨识；正文已改为实际描述 FDA retarget 的 CN110989289A，并不据此断言专利使用 SSA 名称或已量产。
- TU Delft 官方 PDF https://books.open.tudelft.nl/home/catalog/download/174/319/559?inline=1 已下载核对。BSc Optics 2nd edition (Konijnenberg, Adam, Urbach, 2024), DOI 10.59490/tb.91。图 5.8 在书页 125/PDF130，图6.18在书页164/PDF169；版权页为CC BY4.0，例外图清单不含这两张。现有两张截图与教材一致，仅裁切未重绘，文章已补精确来源、页码与许可。
- mask-to-wafer 的两个原 wechat 图因来源不明从正文删除，改用 root 核实的 Commons 工艺图；physics 与曲线稿分别用 root 核实的 illumination-shapes 和 OPC 图。新图 provenance 由共享 assets/images/references/SOURCES.json 记录。
- back-to-basics 原波前相位项缺少对波长的除法、边缘误差式丢分母，均按正文定义修复为可渲染 LaTex。
