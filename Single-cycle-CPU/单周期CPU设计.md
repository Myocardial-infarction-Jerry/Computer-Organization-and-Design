# 单周期 CPU 设计

21307289 刘森元

## 实验目的

1. 掌握单周期 CPU 数据通路图的构成、原理及其设计方法；
2. 掌握单周期 CPU 的实现方法，代码实现方法；
3. 认识和掌握指令与 CPU 的关系；
4. 掌握测试单周期 CPU 的方法。

## 实验内容

​		设计一个单周期 CPU，该 CPU 至少能实现以下指令功能操作，指令与格式如下。


### 算数运算指令

*add rd rs rt*

| 000000 | rs(5 bits) | rt(5 bits) | rd(5 bits) | reserved |
| ------ | ---------- | ---------- | ---------- | -------- |
|        |            |            |            |          |

​		功能：rd = rd + rt； reserved 为预留部分，即未用，一般填「0」。



*sub rd rs rt*

| 000001 | rs(5 bits) | rt(5 bits) | rd(5 bits) | reserved |
| ------ | ---------- | ---------- | ---------- | -------- |
|        |            |            |            |          |

功能：rd = rs - rt。 



*addiu rt rs immediate*

| 000010 | rs(5 bits) | rt(5 bits) | rd(5bits) | reserved |
| ------ | ---------- | ---------- | --------- | -------- |
|        |            |            |           |          |

​		功能：rt = rs + (sign-extend)immediate；immediate符号扩展再参加[add]运算。


### 逻辑运算指令

*andi rt rs immediate*

| 010000 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：rt = rs & (zero-extend)immediate；immediate做「0」扩展再参加「and」运算。



*and rd rs rt*

| 010001 | rs(5 bits) | rt(5 bits) | rd(5 bits) | reserved |
| ------ | ---------- | ---------- | ---------- | -------- |
|        |            |            |            |          |

​		功能：rd = rs & rt；逻辑与运算。



*ori rt rs immediate*

| 010010 | rs(5 bits) | rt(5 bits) | Immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：rt = rs | (zero-extend)immediate；immediate做「0」扩展再参加「or」运算。



*or rd rs rt*

| 010011 | rs(5 bits) | rt(5 bits) | rd(5 bits) | reserved |
| ------ | ---------- | ---------- | ---------- | -------- |
|        |            |            |            |          |

​		功能：rd = rs | rt；逻辑或运算。



### 移位指令

*sll rd rt sa*

| 011000 | unused | rt(5 bits) | rd(5 bits) | sa(5 bits) | reserved |
| ------ | ------ | ---------- | ---------- | ---------- | -------- |
|        |        |            |            |            |          |

​		功能：rd = rt << (zero-extend)sa，左移 sa 位。



### 比较指令

*slti rt rs immediate*

| 011100 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：if (rs < (sign_extend)immediate) rt = 1 else rt = 0，带符号比较，详见 ALU 运算功能表。



### 存储器读/写指令

*sw rt immediate(rs)*

| 100110 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：memory[rs + (sign_extend)immmediate] = rt；immediate符号扩展再相加。即将 rt 寄存器内容保存到 rs 寄存器内容和立即数符号扩展后的数相加作为地址的内存单元中。



*lw rt immediate(rs)*

| 100111 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：rt = memory[rs + (sign-extend)immediate]；immediate 符号扩展再相加。即读取 rs 寄存器内容和立即数符号扩展后的数作为地址的内存单元中的数，然后保存到 rt 寄存器中。



### 分支指令

*beq rs rt immediate*

| 110000 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：if (rs == rt) pc = pc + 4 + (sign-extend)immediate << 2 else pc = pc + 4。

​		说明：immediate 是从 PC+4 地址开始和转移到的指令之间指令条数。immediate 符号扩展之后左移 2 位再相加。为什么要左移 2 位？由于跳转到的指令地址肯定是 4 的倍数（每条指令占 4 个字节），最低两位是「00」，因此将 immediate 放进指令码中的时候，是右移了 2 位的，也就是以上说的「指令之间指令条数」。



*bne rs rt immediate*

| 110001 | rs(5 bits) | rt(5 bits) | immediate(16 bits) |
| ------ | ---------- | ---------- | ------------------ |
|        |            |            |                    |

​		功能：if (rs != rt) pc = pc + 4 + (sign-extend)immediate << 2 else pc = pc + 4 。

​		说明：与 beq 不同点是，不等时转移，相等时顺序执行。



*bltz rs immediate*

| 110010 | rs(5 bits) | 00000 | immediate(16 bits) |
| ------ | ---------- | ----- | ------------------ |
|        |            |       |                    |

​		功能：if (rs < $zero) pc = pc + 4 + (sign-extend)immediate << 2 else pc = pc + 4。



### 跳转指令

*j addr*

| 111000 | addr[27:2] |
| ------ | ---------- |
|        |            |

​		功能：pc = {(pc + 4)[31:28], addr[27:2], 2'b00}，无条件跳转。

​		说明：由于 MIPS32 的指令代码长度占 4 个字节，所以指令地址二进制数最低 2 位均为 0，将指令地址放进指令代码中时，可省掉！这样，除了最高 6 位操作码外，还有 26 位可用于存放地址，事实上，可存放 28 位地址，剩下最高 4 位由 pc+4 最高 4 位拼接上。



### 停机指令

*halt*

| 111111 | 00000000000000000000000000(26 bits) |
| ------ | ----------------------------------- |
|        |                                     |

​		功能：停机；不改变 PC 的值，PC 保持不变。



## 实验原理

​		单周期 CPU 指的是一条指令的执行在一个时钟周期内完成，然后开始下一条指令的执行，即一条指令用一个时钟周期完成。电平从低到高变化的瞬间称为时钟上升沿，两个相邻时钟上升沿之间的时间间隔称为一个时钟周期。时钟周期一般也称振荡周期（如果晶振的输出没有经过分频就直接作为 CPU 的工作时钟，则时钟周期就等于振荡周期。若振荡周期经二分频后形成时钟脉冲信号作为 CPU 的工作时钟，这样，时钟周期就是振荡周期的两倍）。

### CPU 处理指令流程

```flow
IF=>operation: 取指令IF
ID=>operation: 指令译码ID
EXE=>operation: 指令执行EXE
MEM=>operation: 储存器访问MEM
WB=>operation: 结果写回WB
cond=>condition: HALT
s=>start: START
e=>end: END

s->IF->ID->EXE->MEM->WB->cond
cond(yes)->e
cond(no)->IF
```

