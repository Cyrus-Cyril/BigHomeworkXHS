import { HomeViewModel } from '../viewmodel/HomeViewModel';

@Component
export struct AuthPage {
  @Prop vm: HomeViewModel;
  @Link authed: boolean;

  @State isLogin: boolean = true;
  @State username: string = '';
  @State password: string = '';
  @State name: string = '';
  @State avatarIndex: number = 1;
  @State errorMsg: string = '';

  build() {
    Column() {
      Text(this.isLogin ? '登录' : '注册')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16, top: 40 })

      // 用户名
      TextInput({ placeholder: '账号（用户名）', text: this.username })
        .onChange(v => this.username = v)
        .borderRadius(8)
        .backgroundColor('#f5f5f5')
        .padding(12)
        .margin({ bottom: 12 })

      // 密码
      TextInput({ placeholder: '密码', text: this.password })
        .type(InputType.Password)
        .onChange(v => this.password = v)
        .borderRadius(8)
        .backgroundColor('#f5f5f5')
        .padding(12)
        .margin({ bottom: 12 })

      if (!this.isLogin) {
        // 昵称
        TextInput({ placeholder: '昵称（显示名称）', text: this.name })
          .onChange(v => this.name = v)
          .borderRadius(8)
          .backgroundColor('#f5f5f5')
          .padding(12)
          .margin({ bottom: 12 })

        // 头像选择
        Column() {
          Text('选择头像')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Row() {
            ForEach([1, 2, 3], (idx: number) => {
              Column() {
                Image($r(this.getAvatarResourceName(idx)))
                  .width(60)
                  .height(60)
                  .borderRadius(30)
                  .objectFit(ImageFit.Cover)
                  .border({
                    width: this.avatarIndex === idx ? 3 : 0,
                    color: '#ff4d4f',
                    radius: 30
                  })
                  .onClick(() => this.avatarIndex = idx)
              }
              .margin({ right: 12 })
            })
          }
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.errorMsg.length > 0) {
        Text(this.errorMsg)
          .fontSize(12)
          .fontColor('#ff4d4f')
          .margin({ bottom: 12 })
      }

      // 提交按钮
      Text(this.isLogin ? '登录' : '注册')
        .fontSize(16)
        .fontColor('#ffffff')
        .backgroundColor('#ff4d4f')
        .padding({ top: 12, bottom: 12 })
        .borderRadius(20)
        .width('100%')
        .textAlign(TextAlign.Center)
        .onClick(async () => {
          if (this.isLogin) {
            const res = await this.vm.login(this.username.trim(), this.password.trim());
            if (!res.ok) {
              this.errorMsg = res.msg ?? '登录失败';
            } else {
              this.errorMsg = '';
              this.authed = true;
            }
          } else {
            const res = await this.vm.register(
              this.username.trim(),
              this.password.trim(),
              this.name.trim(),
              this.avatarIndex
            );
            if (!res.ok) {
              this.errorMsg = res.msg ?? '注册失败';
            } else {
              this.errorMsg = '';
              this.authed = true;
            }
          }
        })
        .margin({ bottom: 16 })

      // 切换登录/注册
      Text(this.isLogin ? '还没有账号？去注册' : '已有账号？去登录')
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .width('100%')
        .onClick(() => {
          this.isLogin = !this.isLogin;
          this.errorMsg = '';
        })

      Blank()
    }
    .padding({ left: 24, right: 24, bottom: 40 })
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  private getAvatarResourceName(idx: number): string {
    switch (idx) {
      case 1:
        return 'app.media.head_1';
      case 2:
        return 'app.media.head_2';
      case 3:
      default:
        return 'app.media.head_3';
    }
  }
}

