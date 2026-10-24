# OPC、ILT 与 SMO 原始文献核验

核验日期：2026-10-25。以下以论文、出版商页面与作者所在机构保存的原文为依据；Crossref 只用于复核出版日期、卷期和 DOI。本文是编辑研究记录，不作为二手综述替代原论文。

## 必须修正的历史叙述

- **1981 不是 Nashold 与 Saleh**：1981 年原始论文作者为 Bahaa E. A. Saleh 与 Soheil I. Sayegh，题为 *Reduction of Errors of Microphotographic Reproductions by Optimal Corrections of Original Masks*。Nashold 与 Saleh 的迭代投影工作发表于 **1985** 年，不能合并成一项成果。1981 论文 DOI 元数据确认日期为 1981-10-01；部分聚合平台显示 2004，属于重印/记录混淆。
- **Liu 与 Zakhor 的经典论文发表于 1992，不是 2003**：IEEE TSM 5(2), 138–152。其内容是基于 Hopkins 成像与光刻胶非线性，用 branch-and-bound 和 simulated annealing 合成二值/相移掩模。不能将它写成梯度法起点，也不能用 2003 年制造商业化事件代替其发表时间。
- **Poonawala 不能缩成 Poon**：Amyn Poonawala 与 Peyman Milanfar 在 2006 SPIE 会议论文提出像素表征、连续函数形式、解析梯度及正则化框架；2007 IEEE TIP 论文提供更完整的逆成像论述。2007 IEEE 论文 DOI 中的 `2006` 不是出版年。原文支持“基于梯度的迭代优化”，目前核得的原始摘要不足以支持“2006 年首创共轭梯度”这种精确优先权说法，应删去该归因或另给直接证据。
- **Rosenbluth 有两个版本**：2001 SPIE 会议版 DOI 10.1117/12.435748；2002 JM3 期刊版 DOI 10.1117/1.1448500，后者明确说明是会议版修订。可以写“2001 年会议提出、2002 年期刊扩展”，不宜将二者当成两次独立发明。
- **2009 年像素 SMO 不应写成 Intel 首创**：Ma 与 Arce 的作者单位为 University of Delaware。Intel 是研究资助方之一，不是作者机构；且 Rosenbluth 等人的联合优化早已发表于 2001/2002 年。2009 年应作为自由度更多的数值方法及工业研究推进节点。
- **2019、2020 和 2024 的曲线 ILT 进展应分开**：D2S/Micron 在 2019 年报道全芯片、无拼接曲线 ILT；2020 年论文讨论使 VSB 写入更快的 mask–wafer co-optimization（MWCO）；2024 年期刊论文汇总掩模和晶圆验证。多束写入与 VSB 是两条不同的制造路线，不能把“2020 年出现多束写入”写成发明时间。
- **不要将有限实验的增益泛化**：例如 2002 论文的 2–6 倍工艺窗口来自小区域、特定测试图形；2019/2024 的超过 100% 来自特定 memory/contact/via 条件。必须带上对象、基线和论文条件。

## 可直接用于正文的建模口径

下式是多篇原论文共同建模结构的教学性归纳，符号统一过，**不是某一篇论文的逐式转录**。

1. 目标图形为 \(T\)，可制造掩模为 \(m\)，照明角度/瞳面功率分布为 \(s\)，工艺条件为 \(\theta\)。正向模型 \(Z(m,s;\theta)=R_\theta[I(m,s;\theta)]\) 先求 aerial image，再经过 resist/process model 求晶圆图形。
2. 部分相干薄掩模模型的一种离散源表示为 \(I(x)=\sum_j s_j\lvert h_j*m\rvert^2\)，其中 \(s_j\ge0\)、通常归一化为 \(\sum_j s_j=1\)。等价的相干模态/SOCS 形式依赖给定光源的成像算子分解；改变光源时，不能把模态核和权重无条件视为常数。
3. 固定照明的掩模优化为 \(\min_{m\in\mathcal M}L[Z(m,s_0;\theta_0),T]+\lambda\Omega(m)\)。ILT 与常规模型 OPC 的差别主要在自由度、表征及优化方式，不能将二者说成毫无关系的物理技术。
4. SMO 则联合求 \(\min_{m\in\mathcal M,s\in\mathcal S}L[Z(m,s;\theta_0),T]+\lambda\Omega(m)+\mu\Psi(s)\)。\(\mathcal M,\mathcal S\) 承担可制造性与照明器能力约束；优化应对代表图形集合求共同目标，避免一个图形最优却使另一图形失效。
5. 工艺鲁棒性可以采用期望损失 \(\sum_qw_qL[Z(m,s;\theta_q),T]\)、最坏情形 \(\max_q L_q\) 或工艺窗口约束。三者含义不同；期望最优不自动等于最坏情形最优。Shen 等 2011 原文直接支持以随机 defocus/aberration 条件加权损失的期望型方法。
6. 可微 sigmoid 光刻胶只是优化代理：\(R(I)=1/(1+\exp[-a(I-I_{th})])\)。最后仍须用离散掩模和经校准的制造模型复核 EPE、CD、工艺窗口、MRC、SRAF 不打印及掩模写入约束；代理损失下降不等价于量产良率保证。

## 17 项可引用原始来源

所有链接访问/核验日期均为 **2026-10-25**。作者较多的条目用 et al. 缩写；正文按所用文献保留对应编号或脚注，不应在段尾堆积全部来源。

1. **Saleh, B. E. A.; Sayegh, S. I. (1981).** “Reduction of Errors of Microphotographic Reproductions by Optimal Corrections of Original Masks.” *Optical Engineering* **20**(5), 781–784. DOI: [10.1117/12.7972810](https://doi.org/10.1117/12.7972810). 适合引用：早期掩模预补偿、以逆问题计算原始图形。出版商 DOI 页面本轮抓取不可读；出版元数据已从 Crossref 原记录复核，勿引用聚合平台的 2004 日期。

2. **Nashold, K. M.; Saleh, B. E. A. (1985).** “Image construction through diffraction-limited high-contrast imaging systems: an iterative approach.” *JOSA A* **2**(5), 635–643. DOI: [10.1364/JOSAA.2.000635](https://doi.org/10.1364/JOSAA.2.000635). [出版商页面](https://opg.optica.org/josaa/abstract.cfm?uri=josaa-2-5-635)。适合引用：输入预处理、迭代投影、连续透射率解与高对比成像。

3. **Liu, Y.; Zakhor, A. (1992).** “Binary and phase shifting mask design for optical lithography.” *IEEE Transactions on Semiconductor Manufacturing* **5**(2), 138–152. DOI: [10.1109/66.136275](https://doi.org/10.1109/66.136275). 适合引用：Hopkins 模型、二值/相移掩模、分支定界、模拟退火与光刻胶对比增强。IEEE 出版商摘要核得出版日期 1992-05-31。

4. **Pati, Y. C.; Kailath, T. (1994).** “Phase-shifting masks for microlithography: automated design and mask requirements.” *JOSA A* **11**, 2438–2452. DOI: [10.1364/JOSAA.11.002438](https://doi.org/10.1364/JOSAA.11.002438). 适合引用：自动相移掩模设计及其可制造性问题。勿与 Liu–Zakhor 的方法混称同一种优化算法。

5. **Rosenbluth, A. E.; Bukofsky, S. J.; Hibbs, M. S.; et al. (2001).** “Optimum mask and source patterns to print a given shape.” *Proc. SPIE* **4346**, 486–502. DOI: [10.1117/12.435748](https://doi.org/10.1117/12.435748). [作者机构 HKU 记录](https://hub.hku.hk/handle/10722/54040)。适合引用：早期联合光源与掩模优化；需要注明其小场周期图形条件。

6. **Rosenbluth, A. E.; Bukofsky, S.; Fonseca, C.; et al. (2002).** “Optimum mask and source patterns to print a given shape.” *Journal of Microlithography, Microfabrication, and Microsystems* **1**(1), 13–30. DOI: [10.1117/1.1448500](https://doi.org/10.1117/1.1448500). [作者机构原文](https://hub.hku.hk/bitstream/10722/42897/1/71720.pdf)。适合引用：先求简化目标全局解，再用完整模型局部优化；照明与掩模协同提供更大自由度；原文写明修订自 2001 会议版。

7. **Poonawala, A.; Milanfar, P. (2006).** “OPC and PSM design using inverse lithography: a nonlinear optimization approach.” *Proc. SPIE* **6154**, 61543H. DOI: [10.1117/12.655904](https://doi.org/10.1117/12.655904). 适合引用：像素表征、连续函数、解析梯度、二/三透射值与复杂度正则化。Crossref 原记录核得日期 2006-03-10，作者仅两位，勿沿用聚合平台的“+1 more”。

8. **Poonawala, A.; Milanfar, P. (2007).** “Mask Design for Optical Microlithography—An Inverse Imaging Problem.” *IEEE Transactions on Image Processing* **16**(3), 774–788. DOI: [10.1109/TIP.2006.891332](https://doi.org/10.1109/TIP.2006.891332). [作者保存原文](https://users.soe.ucsc.edu/~milanfar/publications/journal/Microlithography_Inverse_Final.pdf)；[作者书目](https://sites.google.com/view/milanfarhome/papers)。适合引用：逆成像、非唯一性、连续松弛、正则化。摘要明确先重点分析理想非相干系统，再讨论相干/部分相干扩展；不宜描述成已完整覆盖所有量产光学条件。

9. **Poonawala, A.; Milanfar, P. (2007).** “A pixel-based regularization approach to inverse lithography.” *Microelectronic Engineering* **84**(12), 2837–2852. DOI: [10.1016/j.mee.2007.02.005](https://doi.org/10.1016/j.mee.2007.02.005). [出版商摘要](https://www.sciencedirect.com/science/article/abs/pii/S0167931707003140)。适合引用：相干、非相干和部分相干成像；assist bar 的两阶段策略；透射率与 aerial-image penalty；对可制造性的显式处理。

10. **Ma, X.; Arce, G. R. (2007).** “Generalized inverse lithography methods for phase-shifting mask design.” *Optics Express* **15**, 15066–15079. DOI: [10.1364/OE.15.015066](https://doi.org/10.1364/OE.15.015066). 适合引用：复数空间梯度搜索、多相位量化、wavelet regularization。

11. **Ma, X.; Arce, G. R. (2009).** “Pixel-based simultaneous source and mask optimization for resolution enhancement in optical lithography.” *Optics Express* **17**(7), 5783–5793. DOI: [10.1364/OE.17.005783](https://doi.org/10.1364/OE.17.005783). [出版商当期目录](https://opg.optica.org/OE/issue.cfm?issue=7&volume=17)。适合引用：像素 SMO、将部分相干系统分解成相干系统之和、cost sensitivity 与拓扑约束。在线发布日期 2009-03-26，期号日期 2009-03-30，二者无需视为矛盾。

12. **Rosenbluth, A. E.; Melville, D. O.; Tian, K.; et al. (2009).** “Intensive optimization of masks and sources for 22nm lithography.” *Proc. SPIE* **7274**, 727409. DOI: [10.1117/12.814844](https://doi.org/10.1117/12.814844). [IBM Research 原始出版记录与摘要](https://research.ibm.com/publications/intensive-optimization-of-masks-and-sources-for-22nm-lithography)。适合引用：集体优化多个 mask 变量、source 变量跨整个图形场耦合、图形多样性与共同照明折衷。不是 Intel 论文。

13. **Shen, Y.; Wong, N.; Lam, E. Y. (2009).** “Level-set-based inverse lithography for photomask synthesis.” *Optics Express* **17**(26), 23690–23701. DOI: [10.1364/OE.17.023690](https://doi.org/10.1364/OE.17.023690). [作者机构原文](https://www.eee.hku.hk/optima/pub/journal/0912_OE.pdf)。适合引用：以隐式函数表示掩模边界、时间相关 PDE 及有限差分求解、拓扑变化。

14. **Shen, Y.; Jia, N.; Wong, N.; Lam, E. Y. (2011).** “Robust level-set-based inverse lithography.” *Optics Express* **19**(6), 5511–5521. DOI: [10.1364/OE.19.005511](https://doi.org/10.1364/OE.19.005511). [作者机构原文](https://www.eee.hku.hk/optima/pub/journal/1103_OE.pdf)。适合引用：部分相干、失焦与像差随机变量、期望型鲁棒目标；不宜替它声称解决了所有 resist stochastic defect。

15. **Pang, L.; Russell, E. V.; Baggenstoss, B.; et al. (2019).** “Study of mask and wafer co-design that utilizes a new extreme SIMD approach to computing in memory manufacturing: full-chip curvilinear ILT in a day.” *Proc. SPIE*, *Photomask Technology 2019*. DOI: [10.1117/12.2534629](https://doi.org/10.1117/12.2534629). [同年作者报告摘要](https://lithoworkshop.org/assets/2019/2019-Litho-Workshop-Program-Book-v1.2.pdf)，第 19 页 “Stitchless Full Chip Curvilinear ILT in a Day”。适合引用：GPU、SIMD、整芯片耦合求解、拼接问题。书目细节以 DOI 为准，不要使用聚合页面给出的不一致页码。

16. **Pang, L.; Russell, E. V.; Baggenstoss, B.; et al. (2020).** “Enabling Faster VSB Writing of 193i Curvilinear ILT Masks That Improve Wafer Process Windows for Advanced Memory Applications.” *Proc. SPIE* **11518**, 115180W. DOI: [10.1117/12.2579729](https://doi.org/10.1117/12.2579729). [作者公司保存原文](https://design2silicon.com/wp-content/uploads/2020/10/115180W.pdf)。适合引用：以 MWCO 协调掩模写入与晶圆成像、VSB 路线、存储器晶圆验证。不能将 VSB 和 MBMW 混为一谈。

17. **Pang, L.; Lu, S.; Russell, E. V.; et al. (2024).** “Make the impossible possible: use variable-shaped beam mask writers and curvilinear full-chip inverse lithography technology for 193i contacts/vias with mask-wafer co-optimization.” *Journal of Micro/Nanopatterning, Materials, and Metrology* **23**(1), 011207. DOI: [10.1117/1.JMM.23.1.011207](https://doi.org/10.1117/1.JMM.23.1.011207). [出版商全文页](https://nanolithography.spiedigitallibrary.org/journals/journal-of-micro-nanopatterning-materials-and-metrology/volume-23/issue-01/011207/Make-the-impossible-possible--use-variable-shaped-beam-mask/10.1117/1.JMM.23.1.011207.full)；[作者保存原文](https://design2silicon.com/wp-content/uploads/2024/02/JM3-23056SS_online.pdf)。适合引用：2019/2020 事件的明确回顾与实际 mask/wafer 数据、特定条件下约 12 小时 VSB 写入；应保留工艺、图形和比较基线。

## 图像使用边界

以上论文可作为科学论述来源，但“可在线阅读”不等于“允许将所有插图重新发布”。尤其 HKU 保存的 2001 SPIE 记录明确包含限制再分发的版权说明。用户要求来自规范 wiki 或教材文档的配图，优先选择 Wikimedia Commons 中许可明确的原文件并逐图记录作者、文件名、原页和许可证；不要把研究论文截图当作自动获准的开放图片。若使用教材图，需要教材页面直接给出开放许可，并核对单张图是否有另列第三方署名。

## 本轮扩写补充核验

- **DiffOPC 正确作者**：Guojin Chen, Haoyu Yang, Haoxing Ren, Bei Yu, David Z. Pan，题为 *Differentiable Edge-based OPC*，2024 ICCAD。原文误列 R. Chen，现已修正。原始预印本：[arXiv:2408.08969](https://arxiv.org/abs/2408.08969)。
- **DevelSet 性能口径**：2021 ICCAD 初版，2023 TCAD 扩展版，DOI [10.1109/TCAD.2023.3286262](https://doi.org/10.1109/TCAD.2023.3286262)，42(12): 5020–5033，Crossref 元数据复核。实验摘要为约 1 秒级局部实验，不是毫秒级全芯片签核。作者提供原文：[TCAD PDF](https://www.cse.cuhk.edu.hk/~byu/papers/J96-TCAD2023-DevelSet.pdf)。
- **全芯片 SMO**：M.-C. Tsai et al., *Full-chip Source and Mask Optimization*, SPIE 7973, 79730A, 2011, DOI [10.1117/12.881633](https://doi.org/10.1117/12.881633)；主办方当年[技术摘要集](https://www.spie.org/Documents/ConferencesExhibitions/AL11-Abstracts.pdf)与[会议议程](https://spie.org/documents/conferencesexhibitions/al11-final-l.pdf)可核实题名、作者与图形筛选/固定源掩模流程。
- **BiSMO**：G. Chen, H. He, P. Xu, H. Geng, B. Yu, *Efficient Bilevel Source Mask Optimization*, DAC 2024, DOI [10.1145/3649329.3656252](https://doi.org/10.1145/3649329.3656252)。[作者原文](https://www.cse.cuhk.edu.hk/~byu/papers/C227-DAC2024-BiSMO.pdf)支持加速 Abbe 与双层 hypergradient；收敛与 benchmark 改善不应写成生产全局最优保证。
- **High-NA 原文**：S. Hwang, W. Gillijns, S. De Gendt, R.-H. Kim, *Source Mask Optimization (SMO) Study for High-NA EUV Lithography to Achieve Single Patterning on Random Logic Metal*, SPIE 12954, 129540X, 2024, DOI [10.1117/12.3010869](https://doi.org/10.1117/12.3010869)。[imec 官方书目](https://imec-publications.be/entities/publication/f98b3cc7-e696-483b-a979-8a8c86a14a0a)及 Crossref 已核实；原旧文的卷号 12955 与作者首字母 R. R.-H. 予以纠正。
- **随机性与指标**：J.-H. Franke et al., *Elucidating the Role of Imaging Metrics for Variability and After Etch Defectivity*, JM3 21(2), 023201, 2022, DOI [10.1117/1.JMM.21.2.023201](https://doi.org/10.1117/1.JMM.21.2.023201)，[imec 作者原文](https://imec-publications.be/bitstreams/946ece8a-8975-4250-95c4-c56170aaf945/download)。需区分随机 CDU、缺孔、合孔所对应的不同像面指标，不能将 NILS 当作所有缺陷率的完整替代。
- **OPC/ILT 工程边界**：Synopsys 2024 [Proteus 官方 PDF](https://www.synopsys.com/content/dam/synopsys/silicon/datasheets/proteus-ds.pdf)第 2 页明确同时支持曲线 OPC、场 ILT 和 Manhattan ILT；只引用能力边界与流程，不采用营销式最高性能/良率断言。

以上补充来源访问日期均为 **2026-10-25**。四篇保留文件名与发布日期，加入 toc/mathjax、完整数字引用与 Commons 署名，删除无可核验证据的良率、美元节省与通用加速比例。SAQP 改为自对准侧墙节距倍增，删除“四次曝光四层对准”描述。未使用研究论文插图或自绘图片。
