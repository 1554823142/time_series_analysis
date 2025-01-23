# 绘图

## 调整多个图的布局

### 使用`par()`

`mfrow`和`mfcol`参数可以用来控制图形的布局。

- **`mfrow=c(nrow, ncol)`**：按行填充图形，先填满第一行，再填第二行，依此类推。
- **`mfcol=c(nrow, ncol)`**：按列填充图形，先填满第一列，再填第二列，依此类推。

**eg:**

```R
par(mfrow = c(3, 2))
plot(fitted(fit, h = 3))
plot(fitted(fit, h = 5))
plot(fitted(fit, h = 10))
plot(fitted(fit, h = 20))
plot(fitted(fit, h = 30))
```

输出为:

<img src="plot.assets/image-20250123204311504.png" alt="image-20250123204311504" style="zoom:50%;" />

### 使用`layout()`函数自定义布局

可以通过**矩阵**来指定每个图形的位置

- 基本语法:

  ```R
  layout(mat, widths = NULL, heights = NULL, respect = FALSE)
  ```

  - **`mat`**：

    一个矩阵，定义了图形的布局。矩阵中的每个元素表示一个图形的位置，*相同数字的元素表示同一个图形占据多个区域*。

  - **`widths`**：

    一个向量，定义每一列的宽度。默认值为`NULL`，表示所有列的宽度相等

    `heights`与它同理, 定义每一行的高度

  - **`respect`**：

    - 逻辑值，表示是否保持图形的宽高比。默认为`FALSE`，表示不保持宽高比。
    - 如果设置为`TRUE`，则图形的宽高比会根据`widths`和`heights`的比例进行调整。

- 例子:

  还拿上面那个示例, 只不过我想设计成最后一行铺满一整行

  ```R
  mat <- matrix(c(1:4, 5, 5), nrow = 3, byrow = TRUE)
  layout(mat)
  plot(fitted(fit, h = 3))
  plot(fitted(fit, h = 5))
  plot(fitted(fit, h = 10))
  plot(fitted(fit, h = 20))
  plot(fitted(fit, h = 30))
  ```

  效果:

  <img src="plot.assets/image-20250123205433469.png" alt="image-20250123205433469" style="zoom:40%;" />

- 显示布局:

  `layout.show()`直观地查看布局效果