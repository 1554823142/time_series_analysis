# UCR数据集的使用

## 下载

- 参考:

  [(6 封私信 / 80 条消息) UCR Time Series Classification Archive 是个什么数据集? - 知乎](https://www.zhihu.com/question/334948347)

- 下载密码:

  `someone`

## 介绍

- 数据集格式:

  每个数据集包含两个部分：训练集（TRAIN partition）和测试集（TEST partition）。例如，对于Fungi数据集，有两个文件：`Fungi_TEST.tsv` 和 `Fungi_TRAIN.tsv`。这两个文件格式相同，但通常大小不同，并且是以标准的ASCII格式存储，可以直接被大多数工具/语言读取。

- 数据集参数

  [官方参数文档](../../data/UCRArchive_2018/DataSummary.csv)

  | ID   | Type | Name | Train | Test | Class | Length | ED (w=0) | DTW (learned_w) | DTW (w=100) | Default rate | Data donor/editor |
  | ---- | ---- | ---- | ----- | ---- | ----- | ------ | -------- | --------------- | ----------- | ------------ | ----------------- |

  每行代表一个时间序列样本，第一个值是**类别标签**（一个介于1和类别总数之间的整数），其余的值是数据样本值。时间序列样本的顺序没有特殊含义，大多数情况下是随机的。

