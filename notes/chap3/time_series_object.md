# R中的时间序列对象

## ts:基础 R 中的时间序列对象

表示**等间隔**的时间序列数据（例如，季度数据、月度数据、年度数据等）

## `zoo` 对象

可以处理**不等间隔**的时间序列数据，或者时间戳为非整数的情况

**索引可以是任意类型**, 可以是 `Date` 类型、`POSIXct` 类型，或者任何其他可以表示时间的类型，提供了更多灵活性

可以处理时间序列中的**缺失值**，并提供灵活的填补缺失值的方法

- 创建`zoo`对象:

  ```R
  zoo(x = NULL, order.by = index(x), frequency = NULL,
    calendar = getOption("zoo.calendar", TRUE))
  ```

- 函数:

	- **`rollapply(zoo_x, width, FUN)`**：滚动应用函数，计算滑动窗口的统计量（如均值、标准差等）
	- **`na.approx(zoo_x)`**：插值函数，用于填补缺失值

## `xts` 对象

`xts`（eXtensible Time Series）是 `zoo` 包的扩展，提供了更强大的功能，特别适合金融时间序列分析

相比于`zoo`, 在处理大规模时间序列数据时更为高效

函数:

- **`apply.daily(xts_x, FUN)`**：按天应用函数，用于计算每日统计量
- **`merge.xts(xts_x, other_xts)`**：合并多个 `xts` 对象
- **`period.apply(xts_x, endpoints(xts_x, "months"), FUN = mean)`**：按时间段（如按月）应用函数。

