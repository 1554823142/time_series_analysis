# 存储时间序列

- 事务型数据与时间序列数据的区别:
  - 事务型数据现有的数据点经常更新, 而时间序列数据通常不需要更新
  - 事务型数据访问有一定的随机性, 无需底层排序规则, 时间序列数据写操作的随机访问优先级很低
  - 事务型数据只会告诉我们最终的状态, 时间序列数据会阐述某事物的整个历史
- 时间序列数据对于数据库的要求:
  - 写操作 > 读操作
  - 数据以时间顺序操作
  - 并发读取的可能性高
  - 除时间外无其他的主键
  - 批量删除可能性大

综上所述, **NoSQL更适合存储时间序列数据**, 因为这个数据库本身的特性就是插入速率不受数据库规模的影响, 写操作较快, 但是相比于SQL, 不适用于分组分层, 不便于交叉引用和验证以及相关的横截面数据相关联

## 使用influxdb存储

### 配置docker镜像

- 拉取镜像(不知道为什么如果使用2.x版本总是无法启动influxdb,所以就用1.x了)

  ```bash
  docker pull influxdb:1.8
  ```

- 启动容器

  ```bash
  docker run -p 8083:8083 -p 8086:8086 --name influxdb2 -td influxdb:1.8
  ```

- 进入容器

  ```bash
  docker exec -it influxdb2 bash
  ```

### 使用influxdb

- 启动

```bash
root@085ede29ec87:/# influx
Connected to http://localhost:8086 version 1.8.10
InfluxDB shell version: 1.8.10
>
```

- 建库. 展示库. 对库进行操作

  ```sql
  > create database mydb
  > show databases
  name: databases
  name
  ----
  _internal
  mydb
  > use mydb
  Using database mydb
  >
  ```

  

- 插入数据

  > InfluxDB中的数据按照`time series(时间序列)`来组织，其包含一个被测量的指标值，如“cpu_load”或者”temperature”。time series有零个或多个`points(数据点)`，每个point都是一个测量值。point由`time`（一个时间戳）、`measurement`（测量指标，例如“cpu_load”）、至少一个key-value格式的`field`（测量值，例如“value=0.64”或者“temperature=2.12”）和零或多个包含测量值元数据的key-value格式的`tag`（标签，例如“host=server01”，“region=EMEA”，“dc=Frankfurt”）组成。
  >
  > 
  >
  > 从概念上来讲，您可以将`measurement`看成是SQL里面的**table**。其中，`time`始终是**主索引**，`tag`和`field`是表格中的**列**，`tag`会**被索引**，而`field`则不会。不同之处在于，使用InfluxDB，您可以有数百万的measurements，无需预先定义数据的schema，并且**null值不会被存储**。

​	数据写入InfluxDB需要使用行协议(Line Protocol)，该协议遵循以下格式:

```txt
<measurement>[,<tag-key>=<tag-value>...] <field-key>=<field-value>[,<field2-key>=<field2-value>...] [unix-nano-timestamp]
```

​	eg:

```sql
cpu,host=serverA,region=us_west value=0.64

payment,device=mobile,product=Notepad,method=credit billed=33,licenses=3i 1434067467100293230

stock,symbol=AAPL bid=127.46,ask=127.48

temperature,machine=unit42,type=assembly external=25,internal=37 1434067467000000000
```

概念对照:

| `cpu`                             | <measurement>             | 表(table)                                            |
| --------------------------------- | ------------------------- | ---------------------------------------------------- |
| `host=serverA` , `region=us_west` | <tag-key>=<tag-value>     | **tags**:描述数据的维度(被用作查询时的**索引**)(key) |
| `value=0.64`                      | <field-key>=<field-value> | **Fields**:包含数据的值                              |



插入数据与查询数据:

- 示例1:

```sql
> insert cpu,host=ServerA,region=us_west value=64
> select "host", "region", "value" from "cpu"
name: cpu
time                host    region  value
----                ----    ------  -----
1737288422666221268 ServerA us_west 64
```

- 示例2:

  ```sql
  > INSERT temperature,machine=unit42,type=assembly external=25,internal=37
  > select * from "temperature"
  name: temperature
  time                external internal machine type
  ----                -------- -------- ------- ----
  1737288543666242404 25       37       unit42  assembly
  ```

  ps: 如果想要输出的时间格式为年月日,则设置:

  >第一种方式：进入命令行之前:`influx -precision rfc3339`
  >
  >第二种方式：进入命令行之后:`precision rfc3339`

### influxdb python api

[参见.ipynb](../../my_code/chap5/influxdb.ipynb)

### influxdb GUI

[Time Series Admin](https://timeseriesadmin.github.io/)