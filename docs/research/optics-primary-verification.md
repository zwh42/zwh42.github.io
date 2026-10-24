# 光学成像、部分相干与 NILS：原始来源核查

核查日期：2026-10-25。本文是文章改写的研究记录，不是正文。只推荐原始论文、原作者公开讲义、大学课程材料或官方教材/技术文档。公式统一使用真空波长 $\lambda_0$，$\mathrm{NA}=n\sin\theta$；空间频率使用 cycles/length，不使用角空间频率。涉及投影倍率时，掩模坐标和 NA 必须先换算到同一侧。

## 1. 相干与非相干截止频率

**可以写入正文的结论。** 在标量、等晕近似下，正入射平面波照明的相干成像对**复振幅**线性：

$$U_i=h*U_o,\qquad \widetilde U_i(\mathbf f)=H(\mathbf f)\widetilde U_o(\mathbf f).$$

圆形光瞳的相干传递函数支撑半径是

$$f_{c,\mathrm{coh}}=\frac{\mathrm{NA}}{\lambda_0}.$$

完全空间非相干成像对**物体强度**线性：

$$I_i=|h|^2*I_o,\qquad \mathrm{OTF}(\mathbf f)=\frac{\int H(\boldsymbol\nu+\mathbf f)H^*(\boldsymbol\nu)\,d\boldsymbol\nu}{\int |H(\boldsymbol\nu)|^2\,d\boldsymbol\nu}.$$

两片半径为 $\mathrm{NA}/\lambda_0$ 的瞳支撑只有在间距小于两倍半径时重叠，因此

$$f_{c,\mathrm{incoh}}=\frac{2\mathrm{NA}}{\lambda_0}.$$

公式与两种线性的区分由 [A1–A4] 支持。以上是频谱支撑边界，不是统一的两点分辨判据；非相干的 OTF 在边界趋于零，不能把截止频率处的无限小调制度等同于可靠打印。相干场平方之后也可以出现到 $2f_{c,\mathrm{coh}}$ 的**强度差频**，因此“相干强度绝不可能含有高于 NA/λ 的频率”错误；后一点直接由 $I=UU^*$ 的傅里叶变换推出，应标明为推导。

**推荐引用（4 项）。**

| 编号 | 可直接使用的书目信息与链接 | 已核验内容与定位 |
|---|---|---|
| A1 | Joseph W. Goodman. *Introduction to Fourier Optics*. 4th ed. W. H. Freeman / Macmillan Learning, 2017. ISBN 9781319119164. [出版社页面](https://www.macmillanlearning.com/ed/uk/product/Introduction-to-Fourier-Optics-4th-edition/p/1319119166) | 第 7 章 *Frequency Analysis of Optical Imaging Systems*。出版社核验作者、版次、2017 年；本次没有访问到出版社的整章正文，**不要凭此链接声称已核实具体页码**。正文精确公式可同时引 A2–A4。 |
| A2 | TU Delft. *Advanced Optical Imaging*, “7 Coherent optical imaging”, §7.3. [课程原文](https://qiweb.tudelft.nl/aoi/coherentimaging/coherentimaging/) | Eq. (28) 给出圆光瞳 CTF，Eq. (29) 明示 $f_0=\mathrm{NA}_i/\lambda$。大学维护课程；页面没有稳定出版年，可用 n.d. 与访问日期。网页搜索索引可读，本次直接打开超时。 |
| A3 | TU Delft. *Advanced Optical Imaging*, “9 Incoherent imaging”, Exercise 2. [课程原文](https://qiweb.tudelft.nl/aoi/incoherentimaging/incoherentimaging/) | 相同光栅例题明确给出相干 $f_0$ 与非相干 $2f_0$，避免混用对象。大学维护课程；n.d.。网页搜索索引可读，本次直接打开超时。 |
| A4 | Lambda Research Corporation. *OSLO Optics Reference*. Revised 27 September 2021. [官方 PDF](https://lambdares.com/hubfs/Support/support/OSLOOpticsReference_Sep21.pdf#page=191) | 印刷页 191–192（PDF 页码 191–192），Eq. (7.35) OTF 为 PSF 的归一化傅里叶变换；正文说明光瞳自相关；Eq. (7.36) $\nu_0=2\mathrm{NA}/\lambda_0$。这是软件供应者的一手文档，可核公式；文档不提供开放图片转载许可。 |

## 2. 部分相干、移频支撑与 Hopkins TCC

**推荐表述。** 把扩展光源分解成互不相干的源点；每个源点对应一束倾斜平面波，先对该源点算相干场、取模平方，再对源点按亮度求和，不能先把所有源点的场相加再平方。[B1–B4]

令 $\widetilde t(\mathbf f)$ 是折算到像侧的掩模复透过率频谱，$P$ 是含离焦和像差的复光瞳，$S(\mathbf s)\ge0$ 为源强度分布。忽略对强度无影响的整体倾斜相位，可一致地写为

$$I(\mathbf x)=\int S(\mathbf s)\left|\int\widetilde t(\mathbf f)P(\mathbf f+\mathbf s)e^{i2\pi\mathbf f\cdot\mathbf x}\,d\mathbf f\right|^2d\mathbf s.$$

展开并交换积分次序，得到

$$\mathrm{TCC}(\mathbf f,\mathbf g)=\int S(\mathbf s)P(\mathbf f+\mathbf s)P^*(\mathbf g+\mathbf s)\,d\mathbf s,$$

$$I(\mathbf x)=\iint\widetilde t(\mathbf f)\widetilde t^*(\mathbf g)\mathrm{TCC}(\mathbf f,\mathbf g)e^{i2\pi(\mathbf f-\mathbf g)\cdot\mathbf x}\,d\mathbf f\,d\mathbf g.$$

这是 [B1, B4] 所述 Hopkins 表达式的连续二维记号；不同文献可用相反移频符号，只要傅里叶和入射角定义一致。TCC 将给定光源、光瞳及像差固定为一个双频率核，使不同掩模可复用系统部分；它不是单一频率的普通强度 OTF。实际高 NA、偏振或厚掩模问题需要矢量及掩模电磁模型，不能把这一标量薄掩模公式称为完整 Maxwell 求解。[B3–B4]

**$(1+\sigma)$ 的准确边界。** 定义 $\sigma=\mathrm{NA}_{\mathrm{ill}}/\mathrm{NA}$。对于居中圆源和圆光瞳，每个源点把掩模频谱相对光瞳平移；全部源点能够访问的掩模频谱支撑并集的外半径为

$$f_{\mathrm{mask,support}}=(1+\sigma)\frac{\mathrm{NA}}{\lambda_0}.$$

这是源与光瞳支撑几何关系的推导；[B2] 引言直接给出同一截止式，[B5] 用衍射级移动解释离轴照明。对常规 $0\le\sigma\le1$、以零级与一个一级干涉产生基频的线栅，可把它解释为基频通过的必要几何条件。它不保证足够对比度、NILS 或工艺窗口，也不是任意物体强度响应的通用线性截止。环形、偶极等源需写出方向相关的实际源支撑；只有外半径不足以描述成像品质。不要把 $\sigma=1$ 当作对任意复物体严格完全非相干的普遍定义；完全空间非相干是物面互强度的极限条件。[B2–B6]

**推荐引用（6 项）。**

| 编号 | 可直接使用的书目信息与链接 | 已核验内容与定位 |
|---|---|---|
| B1 | H. H. Hopkins. “On the diffraction theory of optical images.” *Proceedings of the Royal Society of London. Series A. Mathematical and Physical Sciences* **217**(1130), 408–432 (1953). [DOI: 10.1098/rspa.1953.0071](https://doi.org/10.1098/rspa.1953.0071) | 原始理论论文。Crossref 注册记录核验作者、标题、1953-05-07、卷期页码、DOI 及原始摘要。摘要说明以相干函数、有效光源和光学系统复传输构造广义 transmission factor。Royal Society 正文页本次为 403；连续 TCC 具体式以 B4 公开号对照，不虚称已读原始全文。 |
| B2 | S. Mojtaba Shakeri, Lucas J. van Vliet, Sjoerd Stallinga. “Impact of partial coherence on the apparent optical transfer function derived from the response to amplitude edges.” *Applied Optics* **56**(12), 3518–3530 (2017). [DOI: 10.1364/AO.56.003518](https://doi.org/10.1364/AO.56.003518); [TU Delft 作者接受稿](https://pure.tudelft.nl/ws/portalfiles/portal/43721912/PartialCoh_Shakerietal_author_version.pdf) | 出版社核验完整作者、标题、年份、卷期页码、DOI；作者稿 §1 明示 $\sigma=\mathrm{NA}_{ill}/\mathrm{NA}$ 和 $(1+\sigma)\mathrm{NA}/\lambda$。该文专门讨论部分相干下 edge-derived **apparent** OTF，适合说明不能套用物体无关的普通 OTF。 |
| B3 | Heinrich Kirchauer. *Photolithography Simulation*. Doctoral dissertation, TU Wien, March 1998. §4.3.1, “Abbe's Method”. [大学原文](https://www.iue.tuwien.ac.at/phd/kirchauer/node61.html) | Eq. (4.73) 先算各源点成像再非相干强度叠加；支持任意照明孔径形状；后文归一化明确采用 $\sigma\le1$。 |
| B4 | Heinrich Kirchauer. 同上，§4.3.2, “Hopkins' Method”. [大学原文](https://www.iue.tuwien.ac.at/phd/kirchauer/node62.html) | Eq. (4.86)–(4.90) 展开源点强度并交换求和，Eq. (4.89) 定义离散 TCC；明确说明固定照明、NA、离焦及像差时可复用 TCC；该节推导是标量版本。 |
| B5 | Chris A. Mack. “Off-Axis Illumination.” *The Lithography Expert / Microlithography World*, August 2003. [作者公开原稿 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR42%20%28Aug%2003%29.pdf) | PDF 第 1–2 页：斜入射移动光瞳中的衍射级；最优照明位置依赖 pitch 与方向；偶极对正交方向不等效，解释四极的来源。不应把此文中的最佳 DOF 布置写成所有图形通用最优源。 |
| B6 | Heinrich Kirchauer. 同上，§2.3.3, “Partial Coherence and Advanced Apertures”. [大学原文](https://iue.tuwien.ac.at/phd/kirchauer/node21.html) | Eq. (2.4) 定义 NA 比值；以边缘响应示例区分斜率、过冲与近邻效应；将 $\sigma\to\infty$ 描述为空间非相干极限，而非无条件以 $\sigma=1$ 定义。文中“典型 0.4–0.7”属于 1998 年背景，不可写成今天所有光刻机的普遍配置。 |

## 3. Aerial image、NILS 与剂量敏感性

**可以写入正文的结论。** Aerial image 是投影系统在像面形成的光强分布；光刻胶内部的光场、曝光潜像、烘烤后化学分布和显影轮廓是后续不同阶段。只算空气中的 $I(x,y)$ 无法宣称已预测最终 CD。[C1, C3]

在目标边缘 $x_e$，沿边缘法向定义

$$\mathrm{ILS}=\left.\frac{1}{I}\frac{\partial I}{\partial x}\right|_{x_e}=\left.\frac{\partial\ln I}{\partial x}\right|_{x_e},\qquad \mathrm{NILS}=w\,|\mathrm{ILS}|,$$

其中 $w$ 是名义线宽。原文常选定边缘方向而省绝对值；若报告两侧边缘或二维轮廓，明确使用法向斜率的大小，避免一侧得到负“质量”。对 $I\to aI$，NILS 不变；它衡量局部边缘梯度，不等同于 $(I_{max}-I_{min})/(I_{max}+I_{min})$。后者只采亮暗中心，可能漏掉线宽控制所需的边缘信息。[C1, C4]

**可在正文给出的简单推导。** 在固定 aerial image 形状、恒定曝光阈值的理想模型中，边缘满足 $D I(x_e)=E_{th}$。对剂量 $D$ 作微扰：

$$\delta x_e=-\frac{\delta\ln D}{\partial\ln I/\partial x|_{x_e}}.$$

若两侧对称，名义 CD 为 $w$，则在小扰动下

$$\left|\frac{\delta\mathrm{CD}}{w}\right|\simeq\frac{2}{\mathrm{NILS}}\left|\frac{\delta D}{D}\right|.$$

上式是阈值模型的局部结果；[C2] 给出对应的无限对比度胶关系和近似曝光裕量。真实工艺中的最低可接受 NILS 取决于胶、显影及 CD 规格，不能给出通用“达到 2 就一定可制造”。扫描 NILS 对离焦的曲线，并结合实验标定阈值，才可估计相应图形的可用 DOF。[C2, C4]

**推荐引用（5 项）。**

| 编号 | 可直接使用的书目信息与链接 | 已核验内容与定位 |
|---|---|---|
| C1 | Chris A. Mack. “Using the Normalized Image Log-Slope.” *The Lithography Expert / Microlithography World*, Winter 2001. [作者原稿 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR32%20%28Winter%2001%29.pdf) | PDF 第 1–2 页，Eq. (1) 对比度、Eq. (2) ILS、Eq. (3) NILS；明确在 desired line edge 测量，用名义线宽归一化；说明剂量整体缩放不改善 NILS。 |
| C2 | Chris A. Mack. “Using the Normalized Image Log-Slope, part 2.” *The Lithography Expert / Microlithography World*, Spring 2001. [作者原稿 PDF](https://www.lithoguru.com/scientist/litho_tutor/TUTOR33%20%28Spring%2001%29.pdf) | PDF 第 2 页，理想无限对比度胶的线宽剂量导数关系；$\pm10\%$ CD 规格且斜率近似恒定时，全范围 %EL≈10×NILS；真实胶采用经验标定、阈值依赖工艺。不能脱离该范围定义照抄系数 10。 |
| C3 | Chris Mack. “Gradient-Based Lithographic Optimization: Using the Normalized Image Log-Slope.” In *Fundamental Principles of Optical Lithography: The Science of Microfabrication*, Chapter 9. Wiley, 2007. [DOI: 10.1002/9780470723876.ch9](https://doi.org/10.1002/9780470723876.ch9) | Wiley 核验章节标题、作者、首次在线 2007-11-16；公开目录列出 aerial image、image in resist、exposure、PEB、develop、resist profile 与 LER。本次仅核验公开目录和元数据，具体公式仍以 C1–C2 引用。 |
| C4 | Heinrich Kirchauer. *Photolithography Simulation*. Doctoral dissertation, TU Wien, March 1998. §3.2.2, “Point Optimization of the Aerial Image”. [大学原文](https://www.iue.tuwien.ac.at/phd/kirchauer/node42.html) | Eq. (3.2) NILS；Eq. (3.3) $\mathrm{EL}=\alpha(\mathrm{NILS}-\beta)$；明确需通过胶的 focus-exposure matrices 标定光学指标与工艺窗口的联系。 |
| C5 | Chris A. Mack. “Understanding focus effects in submicrometer optical lithography: a review.” *Optical Engineering* **32**(10), 2350–2362 (1993). [DOI: 10.1117/12.146837](https://doi.org/10.1117/12.146837); [作者公开稿](https://www.lithoguru.com/scientist/litho_papers/1993_37_Understanding%20Focus%20Effects_Review.pdf) | 作者公开稿 Eq. (17)–(18) 给出理想阈值胶的归一化 linewidth–dose 斜率以及 NLS 与 exposure latitude 关系。Crossref 原始注册元数据核验标题、单一作者、1993-10-01、卷期页码及 DOI。注意网上部分页面把 1988 年 SPIE 会议论文 DOI `10.1117/12.968408` 错配给 1993 年综述；不可沿用。 |

## 4. 编辑时需保留的限制

- 不把空间频率的周期 $p=1/f$ 与等线空图形的线宽 $w=p/2$ 混写；也不把 Rayleigh 两点分辨、Abbe 频谱支撑与可打印半间距混成一个 $k_1$ 常数。
- 不把非相干的 $2\mathrm{NA}/\lambda_0$ 解释为所有应用下自动获得两倍相干分辨率；两者线性作用的量不同，物体与评价标准必须相同。
- 不把 NILS 与实际工艺裕量写成无需校准的等价关系；二维结构应报告边缘法向、名义尺寸和取样点。
- 上述公开 PDF/课程可作为文字引用来源；“能公开阅读”并不等于可以转载图片。本记录未授权或建议从受版权保护的 PDF 直接抽图。
