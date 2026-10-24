# Level Set 与 TCC/SOCS 核查记录

核查日期：2026-10-25。正文由原理推导、公开实现结构与本文教学算例组成；计算算例均注明不是实测。

- Level Set 基础：Osher/Sethian 1988 原文 https://math.berkeley.edu/~sethian/Papers/sethian.osher.88.pdf ；Berkeley Persson 讲义 https://persson.berkeley.edu/math228b/html/levelset_notes.html 。核查法向、曲率、迎风、CFL、距离函数与重初始化。内部为负约定全文统一；边界形状导数不意味着远场自动成核。
- 逆光刻：Shen/Wong/Lam 2009 https://www.eee.hku.hk/optima/pub/journal/0912_OE.pdf ，Shen/Jia/Wong/Lam 2011 https://hub.hku.hk/bitstream/10722/135098/1/content.pdf 。核查作者、年卷页、DOI、部分相干和期望型鲁棒目标；不引用实验倍率作通用结论。
- GPU：Yu/Chen/Ma/Yu DATE2021 https://personal.hkust-gz.edu.cn/yuzhema/papers/C22-DATE2021-LevelSet.pdf 。仅说明公开基准上的实现路线，不据此推断工业全芯片吞吐。
- 神经水平集：Ma/Hao 2023 https://arxiv.org/abs/2308.12299 ，DOI 10.1364/AO.503332。区分学习辅助和签核。
- TCC 历史：Hopkins 1953 DOI 10.1098/rspa.1953.0071；Pati/Kailath 1994 DOI 10.1364/JOSAA.11.002438；Cobb 1998 学校原始记录 https://www2.eecs.berkeley.edu/Pubs/TechRpts/1998/8059.html 及作者全文 https://www-video.eecs.berkeley.edu/papers/ncobb/cobb_phd_thesis.pdf 。移除旧稿不充分引用的 Gamo 年代、Rosenbluth 性能数字和厂商加速倍率，保留可核查核心结构。
- Hopkins 离散推导：Kirchauer https://www.iue.tuwien.ac.at/phd/kirchauer/node62.html 。坐标采用晶圆侧，光源和频率求积权重需与矩阵内积一致。
- FFT 与采样：US9645509B2 https://patents.google.com/patent/US9645509B2/en ，明确一次正FFT加n次逆FFT、2NA/lambda强度带宽和插值。原专利一处将critical sampling frequency写成长度量纲；正文独立写成采样间距，未照抄术语错误。
- 分块：US10671052B2 https://patents.google.com/patent/US10671052B2/en 。引用core/transition/halo与同步方案，只说明公开方案，不证明行业统一采用。
- 厚掩模扩展：Chen等2026 DOI10.37188/lam.2026.100，期刊原文 https://www.light-am.com/article/doi/10.37188/lam.2026.100 。只说明局部响应组织成快速通道的一条路线，不泛化其数值收益。
- 独立推导：Gram PSD、谱截断的非负光强尾项/算子界、剂量或阈值边缘敏感度、tile面积比、伴随梯度。明确离散模型与归一化条件；没有把operator norm最优等同EPE最优。
- 图片：只使用来源和许可已核验的Commons及TU Delft教材图。原稿论文/专利截图与公式图片全部撤下。见 assets/images/references/SOURCES.json。
