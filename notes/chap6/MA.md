# 移动平均模型

## 含义

用来描述时间序列数据中的**随机波动**。MA模型的核心思想是当前的观察值*由过去一段时间的随机误差项（也叫白噪声）加权和构*成。这些随机误差项的加权和反映了过去干扰（噪声）对当前值的影响。

- 数学表达式:
  $$
  Y_t = \mu+\epsilon_t+\theta_1\epsilon_{t-1}+\theta_2\epsilon_{t-2}+\dots+\theta_q\epsilon_{t-q}
  $$

  - $$\epsilon_t$$为时刻$$t$$的白噪声(随机误差项)
  - $$\theta_i$$为模型参数

- 其他领域对于误差项的称呼:

  - 经济学: 对系统的"冲击"
  - 电器工程: 一系列脉冲, 模型本身就像是一个有限脉冲响应的滤波器

  **核心思想为**: 过去不同时刻发生的每个独立的时间都会影响随机过程的当前值

## MA模型与AR模型的转换

当你有一个AR模型时，通过白噪声的自协方差序列，可以将其转换为MA模型。反过来，如果你有一个MA模型，也可以通过其自协方差结构构建一个AR模型。

### $$AR(P)\rightarrow MA(\infin)$$

通过递推得到的自回归过程中的噪声项来逼近模型

AR(1)递推项:
$$
Y_t=\phi Y_{t-1}+\epsilon_t
$$
递推后得到:
$$
Y_t = \epsilon_t + \phi \epsilon_{t-1}+ \phi^2\epsilon_{t-2}+\dots
$$
表明AR(1)模型等价于一个无穷阶的MA模型, 每个过去的噪声点对当前值的影响衰减

### $$MA(q)\rightarrow AR(\infin)$$

MA(1)递推项:
$$
Y_t = \epsilon_t + \theta \epsilon_{t-1}
$$
递推后得到:
$$
\begin{aligned}
Y_t&= \epsilon_t + \theta \epsilon_{t-1} \\
	&= \epsilon_t + \theta(Y_{t-1}-\theta \epsilon_{t-2})\\
	&=\epsilon_t +\theta Y_{t-1} - \theta^2\epsilon_{t-2} \\
	&=\epsilon_t +\theta Y_{t-1} - \theta^2(Y_{t-2}-\theta\epsilon_{t-3})\\
	&=\epsilon_t +\theta Y_{t-1} - \theta^2Y_{t-2}+\theta^3\epsilon_{t-3}\\
	&=\epsilon_t +\theta Y_{t-1} - \theta^2Y_{t-2}+\theta^3Y_{t-3}-\dots
\end{aligned}
$$

- **ps:** MA(2) 模型转化为 $$AR(\infin)$$ 模型
  $$
  Y_t = \epsilon_t + \theta_1Y_{t-1} + (\theta_2 - \theta_1^2)Y_{t-2}+(\theta_1^3-\theta_1\theta_2)Y_{t-3}+\dots
  $$

### 后移算子

又名滞后算子, 每次应用时将数据点向后移动一步, 数学表达式为:
$$
B^ky_t = y_{t-k}
$$
可以简化MA模型为:
$$
y_t = \mu+(1+\theta_1\times B+\theta_2\times B^2 + \dots+\theta_q \times B^q)\epsilon_t
$$

## 性质

### 弱平稳性

- **含义**(Weak Stationarity)

  弱平稳性是对时间序列的一种*较为宽松*的平稳性要求要求均值和方差不随时间变化, 且**自协方差只依赖于滞后期**(即时间差$$h$$), 表示为:
  $$
  Cov(Y_t,Y_{t+h})=\gamma(t) \quad \forall t
  $$
  对于弱平稳序列，时间序列的自相关函数（ACF）应该仅取决于滞后期 $$h$$，而不依赖于具体的时间点。

  允许存在某些短期波动和变化，但要求其统计性质保持不变

- 与强平稳性的区别:

  强平稳性要求时间序列的联合分布在不同时间点上完全相同，时间序列的每个样本都遵循相同的概率分布，无论是在何时取样.

- 计算均值和方差:(误差项被假定符合IID且均值为0)

  - 均值:
    $$
    \begin{aligned}
    E(y_t &= \mu + \epsilon_t + \theta_1 \times \epsilon_{t-1} + \dots + \theta_q \times \epsilon_{t-q})\\
    	&= E(\mu)+\sum_{i=0}^\infin \theta_i \times 0\\
    	&=\mu
    \end{aligned}
    $$
    
  - 方差:
    $$
    Var(y_t)=(1+\theta_1^2 + \theta_2^2+\dots+\theta_q^2)\times \sigma_e^2
    $$
    

### ACF特征

ACF在滞后q处"截断"(即自相关函数会在滞后q处迅速降低至0), 表示滞后q之后的时间点后与当前值没有显著的相关性

## 阶次确定

在确定MA的阶次时, **ACF通常比PACF更加关键**, 因为ACF能够直接反应时间序列各个滞后项的相关性, 而MA模型的阶数与ACF的**截断特性**有直接的关系

所以, 通过观察 ACF 的图形，我们可以明确地看到自相关系数何时不再显著。这个*显著的变化点*就代表了 MA 模型的**阶数**(即如果 ACF 在滞后 q 处截断（即从滞后 q 后变为零），那么模型的阶数就是q)

## 预测

对于1阶的MA(1)过程, 无法提供超过1步的准确预测, 而对于高阶的MA(q)过程, 无法预测q步以外, 提供比该过程的均值更**有效**(最近的测量结果能够影响预测结果)的预测
