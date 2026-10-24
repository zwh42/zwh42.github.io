# 四篇光学与计算光刻文章的改写记录

核查与访问日期：2026-10-25。范围只包含以下四篇，保留原文件名、日期、`source_url` 与由文件名产生的路由。原文已完整阅读后重写。没有创建示意图，没有修改站点配置和样式，没有提交或推送。

- `2026-03-18-why-computational-lithography.md`：从宽泛行业口号改为 Rayleigh 定义、衍射成像、受约束反问题、OPC/ILT/SMO、模型校准、误差预算和多重图形化。
- `2026-03-19-litho-lowpass-filter.md`：区分相干场线性、非相干强度线性和部分相干双频率响应；增加方波级次解析、圆瞳 OTF、二维方向性、正则化与数值收敛。
- `2026-03-22-aerial-image.md`：区分空中像、胶内像与潜像，推导阈值边缘位移及 NILS，增加二维轮廓、FEM、胶材料与公平比较规则。
- `2026-03-28-partial-coherence.md`：区分源点间与级次间相干性，增加 Abbe/Hopkins 完整公式、离轴数值例子、源互强度关系和共同工艺约束。

## 核实的主要来源

精细公式、原始 DOI 与阅读范围见独立背景研究 [optics-primary-verification.md](optics-primary-verification.md)。该记录包含原始来源的具体式号、公开全文可用范围及不能外推的条件。文章采用以下来源体系：

1. Goodman，*Introduction to Fourier Optics*，4th ed., 2017。出版社 [书目与目录](https://www.macmillanlearning.com/ed/uk/product/Introduction-to-Fourier-Optics-4th-edition/p/1319119166) 核实版本、作者、ISBN，未声称访问出版社付费全文。相干/非相干公式另由大学公开讲义与 Kirchauer 原文核验。
2. Mack，*Fundamental Principles of Optical Lithography*，2007，[DOI 10.1002/9780470723876](https://doi.org/10.1002/9780470723876)。Wiley 公开页面核实书目和章节结构，未虚报精确页码；NILS 的细节另使用作者 2001 年公开原稿。
3. Kirchauer，*Photolithography Simulation*，TU Wien 博士论文，1998 年 3 月。[原始目录](https://www.iue.tuwien.ac.at/phd/kirchauer/index.php)，尤其 §2.3.3、§3.2.1–3.2.2、§4.1.3、§4.1.5、§4.3.1–4.3.2。准确题名不含常被误加的 “Three-Dimensional”。
4. MIT 2.71/2.710 Optics，Fall 2006，[Coherent imaging / Optical Transfer Function 讲义](https://web.mit.edu/2.710/Fall06/2.710-wk11-a-ho.pdf)。用于区分振幅传递与强度传递。
5. Hopkins 1953 原始论文，[DOI 10.1098/rspa.1953.0071](https://doi.org/10.1098/rspa.1953.0071)。元数据经原始注册记录核验；原出版方全文本次不能直接读取。正文 TCC 连续式由公开 Kirchauer 离散式展开并统一记号，不声称逐字转录 Hopkins 原始全文。
6. Mack 2001，Tutor 32/33/34，[作者目录](https://www.lithoguru.com/scientist/tutor.html)。定义边缘处 NILS、与理想阈值胶剂量裕量的联系，以及潜像和材料过程的限制。
7. Mack 2003，*Off-Axis Illumination*，[作者原稿](https://www.lithoguru.com/scientist/litho_tutor/TUTOR42%20%28Aug%2003%29.pdf)。用于衍射级移频、方向性及特定双光束布置的焦深解释。
8. Rosenbluth 等 2001，[DOI 10.1117/12.435748](https://doi.org/10.1117/12.435748)，[作者机构记录](https://hub.hku.hk/handle/10722/54040)。核验 SMO 早期研究及研究示例的局部适用范围，没有把局部窗口收益外推为产品层收益。
9. Shakeri、van Vliet、Stallinga 2017，[DOI 10.1364/AO.56.003518](https://doi.org/10.1364/AO.56.003518)，[TU Delft 作者接受稿](https://pure.tudelft.nl/ws/portalfiles/portal/43721912/PartialCoh_Shakerietal_author_version.pdf)。用于部分相干的物体依赖性与表观 OTF 限制。
10. Mack 2019，*Metrics for stochastic scaling in EUV lithography*，[DOI 10.1117/12.2538985](https://doi.org/10.1117/12.2538985)，[作者原稿](https://lithoguru.com/scientist/litho_papers/2019_Metrics%20for%20stochastic%20scaling%20in%20EUV.pdf)。用于剂量、图像质量与材料随机性的区分。
11. ASML [计算光刻](https://www.asml.com/products/computational-lithography)、[Rayleigh](https://www.asml.com/en/technology/lithography-principles/rayleigh-criterion)、[k1](https://www.asml.com/en/technology/lithography-principles/pushing-k1-further) 官方说明。用于系统范围、缩放定义与预修正作用，没有将宣传概括当作具体层工艺数据。

## 已修正或删除的原文主张

- 删除原文公式缺失与乱码，所有推导作为可渲染公式写入，不采用公式截图。
- `NA/λ` 指正入射相干场振幅截止，`2NA/λ` 指完全非相干强度 OTF 截止；两者不对应同一种输入线性量。
- 部分相干模型必须先在单源点叠加场并取强度，再对互不相干源点加强度。不能把一般光刻写为二值掩膜与强度 PSF 的普通卷积。
- `(1+σ)NA/λ` 明确限制为圆源与圆瞳的可达掩膜频谱支撑并集；不冒充通用强度 OTF 或充分可打印条件。
- `σ=1` 不等于任意对象严格完全非相干；不同形状的源不能以一个外半径代替。
- 节点名称不作为 Rayleigh 半间距；多重图形化结果不冒充单次曝光突破带宽；`NA=1.35` 不称普遍物理上限。
- 删除没有原始证据的固定线端缩短范围、固定密度偏差、fragment 总数、计算光刻成本超过机器成本、各节点通用 k1 和 OPC 必然达到某绝对纳米值等断言。
- OPC/ILT 都是受约束反设计；ILT 不声称保证全局最优；正问题不声称永远唯一稳定容易。
- 空中像不再称为“决定一切”；阈值模型明确为近似，并说明正/负胶图形极性、深度状态与随机性。
- NILS 使用名义宽度与法向斜率的大小，给出两侧边缘导致因子 2 的剂量敏感性，未给通用合格阈值。
- 解析例子、误差传播、线性正则化与源相关性公式标明为解释或推导，不伪称为实验数据或工业扫描机结果。

## 图片来源与使用情况

这些图片由主任务或其他负责图片核验的代理提供，本文只复用已下载本地文件并加完整图注，没有自行绘制。详细出处均在对应文章图注中。

| 本地文件 | 文章 | 原始出处、作者、许可及改动 |
|---|---|---|
| `/assets/images/references/optical-proximity-correction.png` | why-computational-lithography | [Commons: Optical proximity correction.png](https://commons.wikimedia.org/wiki/File:Optical_proximity_correction.png)，LithoGuy，2010，作者释入公有领域，未修改。 |
| `/assets/images/references/illumination-shapes.png` | partial-coherence | [Commons: EUV illumination shapes.png](https://commons.wikimedia.org/wiki/File:EUV_illumination_shapes.png)，Guiding light，2017，[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)，未修改。 |
| `/assets/images/wechat/back-to-basics-fitting-02.png` | litho-lowpass-filter | Konijnenberg、Adam、Urbach，*BSc Optics*，2nd ed., 2024，[DOI 10.59490/tb.91](https://doi.org/10.59490/tb.91)，图 6.18，书页 164，[PDF 第 169 页](https://books.open.tudelft.nl/home/catalog/download/174/319/559?inline=1#page=169)，[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)，从教材页裁切，图内内容未改。明确说明它是 4f 原理图，而非实际扫描机结构。 |
| `/assets/images/wechat/back-to-basics-fitting-01.png` | aerial-image | 同一教材，图 5.8，书页 125，[PDF 第 130 页](https://books.open.tudelft.nl/home/catalog/download/174/319/559?inline=1#page=130)，[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)，从教材页裁切，图内内容未改。仅用作连续干涉强度解释，未标成生产空中像。 |

## 本地检查

- 逐篇检查引用锚点 `ref-N` 与正文引用一一对应；6 / 6 / 7 / 7 条参考文献，无占位链接。
- 四个图片路径均存在，每篇一张；图注包含来源、作者、年份、许可与改动说明。
- 四篇保留 `toc: true`，补齐 `mathjax: true`。
- 检查显示公式成对、源文件没有异常控制字符。
- 按主任务浏览器反馈，将行内公式中的原始竖线全部改为 `\lvert` / `\rvert`，避免 Kramdown 将其解析为伪表格。
- 站点级构建与浏览器检查由主任务统一执行，未在共享工作区重复启动服务。
