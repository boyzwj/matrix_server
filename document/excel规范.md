# Excel表格规范

## Excel文件命名

* 统一用xlsx后缀格式
* 采用中文名称首字母+中文名称
* 原则上避免一个Excel文件里存在多个可以导出的标签页

***Example***

```bash
C常量配置.xlsx  D兑换码.xlsx
```

## Sheet规范

* 每个标签页对应有该表的导出规则（主要由程序管理）和 表格内容（主要由策划管理）两部分，具体规则如下

### 导出定义部分

| A          | B                     | C | D | E |
| ---------- | --------------------- | - | - | - |
| MOD        | {模块名称}            |   |   |   |
| BACK_TYPE  | {后端导出字段类型}... |   |   |   |
| FRONT_TYPE | {前段导出字段类型}... |   |   |   |
| DES        | {字段中文描述}...     |   |   |   |
| NAMES      | {字段名}...           |   |   |   |
| KEYS       | {主键定义}...         |   |   |   |
| ENUM       | {枚举定义}            |   |   |   |

* 模块名称 对应表格导出的类名/文件名,统一用 Data.开头，例如  Data.Const  Data.Gun,以Json为例导出的文件名为
  data_const.json  data_gun.json ..
* 后端导出字段类型  string | int | float | list ,不填则后端不导出该字段,若所有字段都不填，则后端不导出该表
* 前端导出字段类型  string | loc_string | int | float | list ,不填则前端不到处该字段,若所有字段都不填，则前端不导出该表（int类型会做一次四舍五入取整操作,比如字段内容为4.9 实际导出则为5）

***int类型 会做一次四舍五入取整操作,比如字段内容为4.9 实际导出则为5***
***list类型 会导出时额外加一层括号，例如当填1时,则实际导出为[1],填 1,2,3,4,5 则导出为 [1,2,3,4,5]***

* 字段中文描述 仅供注释解释字段含义用途，不影响导出逻辑
* 主键定义  填YES或其他  当填YES的时候, 该列作为主键，有多个YES字段的时候,这些字段作为联合主键,若都不填,则默认字段第一列为主键
* 枚举定义  参与的枚举内容以 | 分割开, 该列的所有内容导出时以枚举定义的顺序替换成对应索引，例: 定义枚举
  男|女 导出时 男 替换为  0  女替换为  1

### 数据内容部分

* 不填的部分,暂定字符串部分为空字符串，list为空列表, 为避免潜规则，数字内容则为空

***Example***

| A     | B        | C        | D        | E        | F        |
| ----- | -------- | -------- | -------- | -------- | -------- |
| VALUE | 内容     | 内容     | 内容     | 内容     | 内容     |
| VALUE | 内容     | 内容     | 内容     | 内容     | 内容     |
|       | 分隔注释 | 分隔注释 | 分隔注释 | 分隔注释 | 分隔注释 |
| VALUE | 内容     | 内容     | 内容     | 内容     | 内容     |
| VALUE | 内容     | 内容     | 内容     | 内容     | 内容     |
| VALUE | 内容     | 内容     | 内容     | 内容     | 内容     |
|       |          |          |          |          |          |
|       | 图片     |          |          |          |          |
|       |          | 草稿     |          |          |          |
|       |          |          | 注释     |          |          |
|       |          |          |          |          |          |

* 导出时,仅关心第一列为VALUE的部分，其他部分可以作为注释和草稿用途,支持嵌入图片

* ### 案例

| MOD_NAME   | Data.Redpoint |          |                             |          |           |                                      |
| :--------- | :------------ | :------- | :-------------------------- | :------- | :-------- | :----------------------------------- |
|            |               |          |                             |          |           |                                      |
| BACK_TYPE  | int           |          |                             |          |           |                                      |
| FRONT_TYPE | int           | string   | string                      | list     | int       | string                               |
| DES        | 红点id        | 红点描述 | 红点父级gameobject          | 红点位置 | 父红点id  | 红点逻辑函数所在模块（不填就不执行） |
| NAMES      | id            | desc     | parent_go                   | pos      | parent_id | logic_mod                            |
| KEYS       | YES           |          |                             |          |           |                                      |
| ENUM       |               |          |                             |          |           |                                      |
| 主界面：   | id（1-99）    |          |                             |          |           |                                      |
| 底部：     | id（1-9）     |          |                             |          |           |                                      |
| VALUE      | 1             | 钻石商店 | TopPanel.Toggle_DiamondShop | 30,40    |           |                                      |
| VALUE      | 2             | 绘本     | TopPanel.Toggle_DrawBook    | 30,40    |           |                                      |
| VALUE      | 3             | 家园     | TopPanel.Toggle_Home        | 30,40    |           |                                      |
| VALUE      | 4             | 咪啵社   | TopPanel.Toggle_Community   | 30,40    |           |                                      |
| VALUE      | 5             | 日常成就 | TopPanel.Toggle_Achievement | 30,40    |           | Mod/activeness_data                  |
|            |               |          |                             |          |           |                                      |
| 左侧：     | id（10-19）   |          |                             |          |           |                                      |
| VALUE      | 10            | 手机     | MainPanel.BtnPhone          | 40,40    |           |                                      |
| VALUE      | 11            | 问卷     | MainPanel.BtnQA             | 40,40    |           | Controller/QACtrl                    |
|            | 12            | 胜利宝箱 | MainPanel.BtnOperationBox   | 40,40    |           | Controller/OperationBoxCtrl          |
|            | 13            | 竞速活动 | MainPanel.BtnOperationRace  | 40,40    |           | Controller/OperationRaceCtrl         |
|            |               |          |                             |          |           |                                      |
|            |               |          |                             |          |           |                                      |
