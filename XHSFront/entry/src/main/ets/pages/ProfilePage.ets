import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { Note } from '../model/Note';
import { NoteCard } from './NoteCard';
import { User } from '../model/User';

interface SplitNotesResult {
  left: Note[];
  right: Note[];
}

@Component
export struct ProfilePage {
  @Prop vm?: HomeViewModel;
  @Link notesList: Note[];
  @Link detailVisible: boolean;
  @Link selectedNoteId: number;
  @Link followVersion: number;

  @State myNotes: Note[] = [];
  @State name: string = '';
  @State bio: string = '';
  @State avatarIndex: number = 1;

  aboutToAppear() {
    this.loadProfile();
    this.updateMyNotes();
  }

  private loadProfile() {
    if (!this.vm) {
      return;
    }
    const user: User = this.vm.getCurrentUser();
    this.name = user.name;
    this.bio = user.bio ?? '';
    this.avatarIndex = user.avatarIndex ?? 1;
  }

  private updateMyNotes() {
    if (this.vm) {
      this.myNotes = this.vm.getMyNotes();
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('我的')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column() {
          // 用户信息卡片 + 编辑
          Column() {
            // 头像和基本信息
            Row() {
              // 头像
              Image(this.getAvatarResource(this.avatarIndex))
                .width(80)
                .height(80)
                .borderRadius(40)
                .objectFit(ImageFit.Cover)

              Column() {
                TextInput({ placeholder: '昵称', text: this.name })
                  .onChange(v => this.name = v)
                  .fontSize(18)
                  .padding({ left: 0, right: 0, top: 4, bottom: 4 })
                  .margin({ bottom: 4 })

                TextArea({ placeholder: '个人简介', text: this.bio })
                  .onChange(v => this.bio = v)
                  .fontSize(12)
                  .height(60)
                  .backgroundColor('#f5f5f5')
                  .borderRadius(8)
                  .padding(8)
              }
              .layoutWeight(1)
              .margin({ left: 16 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .margin({ bottom: 12 })

            // 头像选择
            Column() {
              Text('选择头像')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 6 })
              Row() {
                ForEach([1, 2, 3], (idx: number) => {
                  Column() {
                    Image(this.getAvatarResource(idx))
                      .width(56)
                      .height(56)
                      .borderRadius(28)
                      .objectFit(ImageFit.Cover)
                      .border({
                        width: this.avatarIndex === idx ? 3 : 0,
                        color: '#ff4d4f',
                        radius: 28
                      })
                      .onClick(() => this.avatarIndex = idx)
                  }
                  .margin({ right: 12 })
                })
              }
            }
            .width('100%')
            .margin({ bottom: 12 })

            // 保存按钮
            Row() {
              Text('保存资料')
                .fontSize(14)
                .fontColor('#ffffff')
                .backgroundColor('#ff4d4f')
                .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                .borderRadius(18)
                .onClick(async () => {
                  if (this.vm) {
                    await this.vm.updateProfile(this.name.trim(), this.bio.trim(), this.avatarIndex);
                    this.updateMyNotes();
                    this.notesList = [...this.vm.notes];
                    if (this.followVersion !== undefined) {
                      this.followVersion = this.followVersion + 1;
                    }
                  }
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .margin({ bottom: 12 })

          // 我的笔记标题
          Row() {
            Text('我的笔记')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 16 })
          }
          .width('100%')
          .height(48)
          .backgroundColor('#ffffff')
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 8 })

          // 笔记列表（瀑布流）
          if (this.myNotes.length > 0) {
            Row() {
              Column() {
                ForEach(this.splitNotes().left, (item: Note) => {
                  Column() {
                    NoteCard({ note: item, vm: this.vm! })
                  }
                  .onClick(() => {
                    this.selectedNoteId = item.id;
                    this.detailVisible = true;
                  })
                }, (item: Note) => item.id.toString())
              }
              .layoutWeight(1)

              Column() {
                ForEach(this.splitNotes().right, (item: Note) => {
                  Column() {
                    NoteCard({ note: item, vm: this.vm! })
                  }
                  .onClick(() => {
                    this.selectedNoteId = item.id;
                    this.detailVisible = true;
                  })
                }, (item: Note) => item.id.toString())
              }
              .layoutWeight(1)
            }
            .alignItems(VerticalAlign.Top)
            .padding({ left: 8, right: 8, bottom: 20 })
          } else {
            Column() {
              Text('还没有发布笔记')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 40 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  private splitNotes(): SplitNotesResult {
    const left: Note[] = [];
    const right: Note[] = [];
    let leftH = 0;
    let rightH = 0;

    for (const n of this.myNotes) {
      const h = n.coverHeight ?? 180;
      if (leftH <= rightH) {
        left.push(n);
        leftH += h;
      } else {
        right.push(n);
        rightH += h;
      }
    }
    return { left, right } as SplitNotesResult;
  }

  private getAvatarResource(idx: number): Resource {
    switch (idx) {
      case 1:
        return $r('app.media.head_1');
      case 2:
        return $r('app.media.head_2');
      case 3:
      default:
        return $r('app.media.head_3');
    }
  }
}
