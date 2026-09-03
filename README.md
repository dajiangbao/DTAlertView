<img width="423" height="403" alt="截屏2026-09-03 15 43 28" src="https://github.com/user-attachments/assets/ff1c1699-9a41-48d2-9033-d0a711c5cf5a" />
# DTAlertView
简单好用的弹窗对话框
标题文本支持自定义 
内容自定义  
按钮文本自定义
超长文本显示

调用方式：

        DTAlert.show(title: "标题",content: "文字内容文字内容文字内容文字内容\n文字内容文字内容文字内容",leftTitle: "取消",rightTitle: "确定",
            leftAction: {
                print("样式1 - 点击了取消")
            },
            rightAction: {
                print("样式1 - 点击了确定")

            }
        )


        DTAlert.show(title: nil,content: "文字内容文字内容文字内容文字内容\n文字内容文字内容文字内容",leftTitle: "取消",rightTitle: "确定",
            leftAction: {
                print("样式2 - 点击了取消")
            },
            rightAction: {
                print("样式2 - 点击了确定")
            }
        )


         DTAlert.show(title: "标题",content: nil,leftTitle: "取消",rightTitle: "确定",
            leftAction: {
                print("样式3 - 点击了取消")
            },
            rightAction: {
                print("样式3 - 点击了确定")
         

            }
        )


        let longText = String(repeating: "文字内容文字内容文字内容文字内容\n", count: 6)
        DTAlert.show(title: nil,content: longText,leftTitle: "取消",rightTitle: "确定",
            leftAction: {
                print("样式4 - 点击了取消")
            },
            rightAction: {
                print("样式4 - 点击了确定")


            }
        )


        let veryLongText = String(repeating: "文字内容文字内容文字内容文字内容\n", count: 100)
        DTAlert.show(title: "标题",content: veryLongText,leftTitle: nil,rightTitle: "知道了",
            rightAction: {
                print("样式5 - 点击了知道了")
        
            }
        )
