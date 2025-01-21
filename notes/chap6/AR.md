- 今天找到一个中文翻译的时序分析教材:[**预测:方法与实践**](https://otexts.com/fppcn/)

## AR模型_R

### ar()阶次的选择---**赤池信息量准则**

- **赤池信息量准则**（Akaike information criterion，**AIC**）

  - 准则等式
    $$
    AIC = 2k - 2lnL
    $$

    - $$k$$为模型参数的个数, $$L$$为最大似然函数

  - 目的: 

    降低模型复杂度的同时(减少$$k$$), 同时提高模型的似然性/拟合度(增大$$L$$)

    这也是一个优化目标函数(惩罚函数), 使得$$AIC$$的值最小

### ARIMA 算法(AutoRegressive Integrated Moving Average)

本质就是把数据中带有趋势的(`trend`)的，带有季节性的(`seasonal`)的, 带有业务场景周期性(`domain cycle`)的规律先找出来，*一层一层将有规律的信息从数据中抽出来*，最后的数据就剩下没有规律的，或叫噪声，理想的时候是**白噪声**(`white noise series`)

因为具有趋势和季节性的时间序列不是平稳时间序列, 而白噪声序列是平稳的

$$
y'_t=c+\phi_1y'_{t-1}+\dots+\phi_py'_{t-p} + \theta_1\epsilon_{t-1}+\dots+\theta_q\epsilon_{t-q}+\epsilon_t
$$
其中$$y'$$为差分序列(可能进行了多次差分), 此模型称为$$ARIMA(p,d,q)$$模型($$p$$:自回归模型阶数,$$d$$:差分阶数, $$q$$:移动平均模型阶数

- ARIMA模型的特例:

  | 白噪声               | $$ARIMA(0,0,0)$$                  |
  | -------------------- | --------------------------------- |
  | 随机游走模型         | $$ARIMA(0,1,0)$$ with no constant |
  | 带漂移的随机游走模型 | $$ARIMA(0,1,0) $$ with a constant |
  | 自回归模型           | $$ARIMA(p,0,0)$$                  |
  | 移动平均模型         | $$ARIMA(0,0,q)$$                  |

  
