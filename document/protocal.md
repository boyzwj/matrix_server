# 前后端通信协议

## 基础数据包结构

### 第一层编码  

    [len :: 协议长度 :: 16-little , body :: 协议内容 :: binary_size(len)]

### 第二层编码  

    [proto_type :: 协议类型::8, body::协议内容 ]

* 协议类型定义  1：登录验证 2：心跳  3：断线重连 4: Protobuf RC4  5: Protobuf LZ4

### 第三层编码

* 每次连接产生一个唯一的会话ID[session_id: 暂定36字节]
* 每个会话存在登陆验证前，和登录验证后 两个状态
* 不同登录状态只会接受特定的协议类型

----
#### 1.登录验证协议

* C2S     
```
data = RC4_ENC([token::登录token::binary, gamekey::约定密钥::binary])
```

* S2C     
```
data = RC4_ENC([role_id::玩家ID::64-little,  session_id::会话TOKEN::binary_size(36)] , gamekey::约定密钥::binary)
```
#### 2.心跳协议

* C2S   
```
data = [client_time::时间戳::32-little]
```

* S2C
``` 
data = [client_time::时间戳::32-little, server_time::时间戳::32-little]
```

#### 3.断线重连协议

* C2S 
```
data = RC4_ENC([client_last_recv_index::客户最后收到的PB协议编号::32-little,role_id::玩家角色ID::64-little,session_id::会话ID::binary_size(36)],game_key::约定密钥)
```

* S2C 重连成功  
```
data = [1::byte , last_recv_index::服务端最后接收的PB协议编号::32-little]
```
* S2C 重连失败  
```
data = [0::byte]
```


#### 4.Protobuf RC4协议
***小数据包（byte_size <256）采用RC4加密***
```
data = [compress_flag::8, body::binary]
```
* 协议包加密采用RC4算法, crypto_key 的生成法则是    MD5([session_id ,  role_id  ,  gamekey])

* C2S  
```
data =  RC4_ENC([index::自增ID::32-little,proto_id::协议号::16-little, pb_body::binary] , crypto_key)
```
* S2C  
```
data =  RC4_ENC([index::自增ID::32-little,proto_id::协议号::16-little, pb_body::binary] , crypto_key)
```


#### 5.Protobuf LZ4协议
***大数据包（byte_size>=512）采用LZ4压缩,由于压缩后不再是明文，不需要再次RC4加密***
* C2S  
```
data =  LZ4.Compress([index::自增ID::32-little,proto_id::协议号::16-little, pb_body::binary])
```
* S2C  
```
data =  LZ4.Compress([index::自增ID::32-little,proto_id::协议号::16-little, pb_body::binary])
```



***pb_body根据协议号获得解码器解码出协议对象结构, 协议号跟编解码器对应文件需要服务端根据PB文件统一生成***



