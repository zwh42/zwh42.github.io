---
layout: post
read_time: true
show_date: true
title: "Partial Coherence 与 Illumination Shape：为什么光源形状能改变光刻命运"
date: 2026-03-28 22:41:13 +0800
tags: [光刻, 部分相干, 照明, SMO]
author: 端点星日志
description: "Partial Coherence 与 Illumination Shape：为什么光源形状能改变光刻命运—"
source_url: "https://mp.weixin.qq.com/s/mhlnUuVk1ZF27v8BnTiK2Q"
toc: true
mathjax: true
---

#### ——从部分相干成像到 SMO 的物理逻辑

---

## 一、很多人忽略的一个事实

如果只看光刻系统最基本的参数，似乎只有三个最重要：

- 波长 $\lambda$
- 数值孔径 $NA$
- 工艺因子 $k_{1}$

Rayleigh 公式写成：

$$R=k_{1}\frac{\lambda }{NA}$$

它几乎出现在所有光刻教材的第一页。

但如果你真正做过 OPC 或 lithography modeling，就会发现一个奇怪的事情：

> 同样的(NA)、同样的波长、同样的 mask，换一种 illumination，图像就变了。

有时候对 dense line 更好，有时候对 contact hole 更好。

这件事的源头，是一个常被低估的概念：

**Partial Coherence（部分相干成像）。**

---

## 二、真实的光刻系统，从来不是完全相干

在理想光学课本里，经常会讨论两种极端情况：

**完全相干（coherent）成像**

$$I(x,y)=|E(x,y)|^{2}$$

图像由电场直接叠加。

以及

**完全非相干（incoherent）成像**

$$I(x,y)=O(x,y)\otimes PSF(x,y)$$

物体强度和点扩散函数卷积。

但光刻机既不是这两种。

真实情况是：

> 部分相干 illumination。

在 projection lithography 中，mask 上的每一个点，并不是由单一方向的平面波照亮，而是由一组不同角度的光共同照射。

换句话说，illumination 不是一个点，而是 **pupil 平面上的一个分布**。

这一点在光刻成像理论中，是 Fourier optics 描述的核心部分。

---

## 三、部分相干的一个直觉理解

先想象一个最简单的 line/space。

Mask 可以写成一个周期结构：

$$M(x)=\sum _{n}A_{n}e^{i2\pi nx/p}$$

其中

$p$

是 pitch。

这意味着 mask 会产生一系列 **衍射级次（diffraction orders）**：

$$0,\pm 1,\pm 2...$$

projection lens 的 NA 决定了哪些衍射级可以被收集。

但 illumination 还决定另一件事：

> 这些衍射级之间，是如何干涉的。

如果 illumination 是完全相干的，所有光彼此相干，干涉最强。

如果 illumination 完全非相干，不同方向的光互不干涉。

而 partial coherence 就在两者之间。

---

## 四、用 σ 描述部分相干

在光刻里，一个常见参数叫做：

$$\sigma =\frac{NA_{illumination}}{NA_{projection}}$$

它描述 illumination pupil 相对于投影镜头 pupil 的大小。

- $\sigma \rightarrow 0$ → 接近相干成像
- $\sigma \rightarrow 1$ → 接近非相干成像

这不是一个简单的“亮度”参数，而是决定：

> 系统在频域如何组合不同衍射级。

---

## 五、为什么 dense pattern 和 isolated pattern 不一样

很多 OPC 工程师都有一个经验：

dense line 和 isolated line 的成像表现完全不同。

原因就在这里。

以 line/space 为例：

dense pattern 的主要衍射级是：

$$0,\pm 1$$

只要 NA 能收集到 ±1 级，图像就能形成。

但 isolated line 需要更多频率分量。

partial coherence 会改变这些衍射级的干涉方式，从而改变图像对比度和 NILS。

这也是为什么 illumination 可以改善某些 pitch 的成像，而恶化另一些。

---

## 六、为什么 illumination shape 会改变成像

到这里，我们已经可以回答一个问题：

> 为什么改变 illumination shape 会改变 lithography performance？

因为 illumination shape 实际上改变的是：

**pupil 中哪些 k-vector 在参与成像。**

换句话说：

illumination 决定了

$$k_{incident}$$

而 mask 决定

$$k_{diffracted}$$

projection lens 决定

$$k_{collected}$$

三者共同决定最终的 aerial image。

---

## 七、从 conventional illumination 到 off-axis illumination

早期光刻系统使用的是 **conventional illumination**：

pupil 中心一块圆形光源。

但随着 feature size 变小，人们发现一个问题：

很多关键衍射级落在 NA 边缘。

于是出现了 **off-axis illumination (OAI)**。

最典型的两种是：

### Dipole illumination

两个对称光源。

特别适合 line/space。

原因是它可以让 ±1 diffraction order 更容易进入 pupil。

---

### Quadrupole illumination

四个光源。

更适合 contact hole 或二维结构。

它能够在多个方向增强衍射级。

这些 illumination 技术，被统称为：

**Optical Resolution Enhancement Techniques (RET)**。

---

## 八、为什么 illumination 可以“延长摩尔定律”

在 193nm 光刻时代，单纯依靠 NA 已经很难继续提高分辨率。

但通过 illumination engineering，可以改变成像频谱。

直观理解就是：

> 把光放在更有用的位置。

例如 dipole illumination，可以让系统有效传递更高的空间频率。

结果就是：

在相同 NA 下，可以印更小的 feature。

---

## 九、从 illumination engineering 到 SMO

当 illumination shape 变得越来越复杂，人们意识到一个问题：

illumination 和 mask 是耦合的。

一个 mask 在某种 illumination 下很好，但换一种 illumination 就变差。

于是出现了一个更激进的思路：

**同时优化 source 和 mask。**

这就是

$$SMO=Source Mask Optimization$$

数学上可以写成：

$$min_{M,S}\,Error(f(M,S),Target)$$

其中

- $M$ 是 mask
- $S$ 是 illumination source
- $f$ 是 lithography forward model

SMO 的核心思想是：

> 不再固定 illumination，而是把它当成设计变量。

---

## 十、为什么 SMO 会成为主流

随着节点进入 20nm 以下，单纯 OPC 已经很难解决所有问题。

因为 mask modification 只能在空间域补偿。

而 illumination optimization 可以在 **频域改变系统响应**。

这使得：

- NILS 提高
- process window 增大
- EPE 降低

很多先进节点的 patterning，已经离不开 SMO。

---

## 十一、小结

这一篇其实只讲了一件事：

> illumination 不是背景光，而是成像系统的一部分。

partial coherence 决定了不同衍射级如何干涉。

illumination shape 决定了哪些频率能够进入系统。

而 SMO 则把 illumination 从“固定参数”变成了“设计变量”。

从 Fourier optics 的角度看：

整个问题其实就是在调整系统的频率传递。
