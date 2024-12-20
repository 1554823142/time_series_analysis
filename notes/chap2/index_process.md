## pandas索引处理

- **注意** 

  如果将 DataFrame 的某一列设置为索引后，该列将不再出现在 `columns` 中，**而是成为 `index` 的一部分**

### pandas.MultiIndex

在数据框（DataFrame）或系列（Series）中处理**多级索引**,通过组合多个索引列来表示更复杂的数据结构

* **可以使用 **`pandas.MultiIndex` 从一个*列表、数组或元组*创建一个多级索引

```
import pandas as pd

# 使用元组创建 MultiIndex
index = pd.MultiIndex.from_tuples([('A', 1), ('A', 2), ('B', 1), ('B', 2)], names=['letter', 'number'])

# 使用 MultiIndex 创建一个 DataFrame
df = pd.DataFrame({'data': [10, 20, 30, 40]}, index=index)
print(df)

```

​	输出

```
               data
letter number      
A      1         10
       2         20
B      1         30
       2         40
```

- 访问 MultiIndex

​	可以通过 `.loc` 或 `.xs` 来访问多级索引的数据

* `set_index()`

​	将参数列表里的列作为DateFrame的**复合索引**

```
>>> emails.set_index(['week', 'user'])

emailsOpened
weekuser
2015-06-291.03.0
2015-07-131.02.0
2015-07-201.02.0
2015-07-271.03.0
2015-08-031.01.0
.........
2018-04-30998.03.0
2018-05-07998.03.0
2018-05-14998.03.0
2018-05-21998.03.0
2018-05-28998.03.0
25488 rows × 1 columns
```

* `reindex` 根据指定的index(可能是一个包含完整索引的列表、数组或 MultiIndex) 重新进行索引
* `reset_index`
  **将多级索引（在这里是 **`week` 和 `user`）重置为*普通的列*，而不是索引
  **还可以创建新的默认整数索引(即在第一列表示次序的索引)**
* **索引选择与切片**
  * **基于标签的索引 **`loc` , 根据标签（包括索引标签）来选取数据
  * **基于位置的索引 **`iloc` , 通过位置进行索引，即按行号和列号进行访问
