import { Note } from '../model/Note';
import { Comment } from '../model/Comment';
import { HomeViewModel } from '../viewmodel/HomeViewModel';

@Component
export struct NoteDetailPage {
  @Link visible: boolean;
  @Prop note: Note;
  @Prop vm?: HomeViewModel;
  @Link followVersion: number;
  @State currentNote: Note = {} as Note;
  @State comments: Comment[] = [];
  @State commentInput: string = '';
  @State showComments: boolean = true;

  aboutToAppear() {
    this.updateNoteData();
  }

  private updateNoteData() {
    // 从ViewModel获取最新数据
    if (this.vm) {
      const latestNote = this.vm.getNote(this.note.id);
      this.currentNote = latestNote || this.note;
      this.comments = this.vm.getComments(this.note.id);
    } else {
      this.currentNote = this.note;
      this.comments = [];
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 顶部栏：返回 + 头像 + 昵称 + 关注 + 分享
          Row() {
            Text('←')
              .fontSize(20)
              .padding(8)
              .onClick(() => {
                this.visible = false;
              })

            Image(this.getAvatarResource(this.currentNote.authorAvatarIndex ?? 1))
              .width(36)
              .height(36)
              .borderRadius(18)
              .objectFit(ImageFit.Cover)
              .margin({ left: 4 })

            Text(this.currentNote.author ?? '用户')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 10 })

            Blank()

            // 关注按钮
            Text(this.vm && this.currentNote.authorId && this.vm.isFollowing(this.currentNote.authorId) ? '已关注' :
              '关注')
              .fontSize(14)
              .fontColor('#ff4d4f')
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8
              })
              .borderRadius(18)
              .border({ width: 1, color: '#ff4d4f' })
              .margin({ right: 10 })
              .onClick(async () => {
                if (this.vm && this.currentNote.authorId) {
                  await this.vm.toggleFollow(this.currentNote.authorId);
                  if (this.followVersion !== undefined) {
                    this.followVersion = this.followVersion + 1;
                  }
                }
              })

            // 分享占位
            Text('⤴')
              .fontSize(18)
              .padding(10)
          }
          .width('100%')
          .backgroundColor('#ffffff')
          .padding({
            left: 8,
            right: 8,
            top: 24,
            bottom: 8
          })

          // 主体：图片区域
          Column() {
            Image(this.getCoverResource())
              .width('100%')
              .height(420)
              .objectFit(ImageFit.Cover)
          }
          .width('100%')
          .height(420)

          // 文案区
          Column() {
            Text(this.currentNote.title ?? '')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 6 })

            Text(this.currentNote.content ?? '')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ bottom: 10 })

            // 标签占位
            Row() {
              Text('#标签')
                .fontSize(14)
                .fontColor('#2f54eb')
            }
            .margin({ bottom: 10 })

            // 时间 / 地点
            Row() {
              Text(this.formatDate(this.currentNote.createdAt))
                .fontSize(12)
                .fontColor('#999999')

              Text(' · ')
                .fontSize(12)
                .fontColor('#999999')

              Text('浙江') // 可以从 note 里加字段
                .fontSize(12)
                .fontColor('#999999')

              Blank()

              Text('不喜欢')
                .fontSize(12)
                .fontColor('#999999')
                .padding({
                  left: 10,
                  right: 10,
                  top: 6,
                  bottom: 6
                })
                .borderRadius(14)
                .border({ width: 1, color: '#e6e6e6' })
            }
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 14,
            bottom: 16
          })
          .backgroundColor('#ffffff')

          // 评论列表（可滚动，显示无评论提示）
          Column() {
            Row() {
              Text('评论 (' + this.comments.length + ')')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 8
            })

            if (this.comments.length > 0) {
              Column() {
                ForEach(this.comments, (comment: Comment) => {
                  this.buildCommentItem(comment);
                }, (comment: Comment) => comment.id.toString())
              }
              .width('100%')
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 16
              })
            } else {
              Column() {
                Text('暂无评论，快来抢沙发吧~')
                  .fontSize(14)
                  .fontColor('#999999')
                  .padding(20)
              }
              .width('100%')
            }
          }
          .width('100%')
          .backgroundColor('#ffffff')
        }
        .width('100%')
      }
      .layoutWeight(1)

      // 底部操作栏（固定）
      Row() {
        // 评论输入框
        Row() {
          TextInput({ placeholder: '说点什么…', text: this.commentInput })
            .onChange((value: string) => {
              this.commentInput = value;
            })
            .onSubmit(async () => {
              await this.submitComment();
            })
            .fontSize(14)
            .backgroundColor('#f2f2f2')
            .borderRadius(20)
            .padding({ left: 12, right: 12 })
            .layoutWeight(1)
            .height(36)

          if (this.commentInput.trim().length > 0) {
            Text('发送')
              .fontSize(14)
              .fontColor('#ff4d4f')
              .margin({ left: 8 })
              .onClick(async () => {
                await this.submitComment();
              })
          }
        }
        .layoutWeight(1)
        .margin({ right: 8 })

        // 右侧按钮区：点赞/收藏/评论
        Row() {
          // 点赞
          Column() {
            Image($r('app.media.ic_like'))
              .width(20)
              .height(20)
              .fillColor(this.currentNote.liked ? '#ff4d4f' : '#666666')
            Text(this.currentNote.likeCount.toString())
              .fontSize(10)
              .fontColor('#666666')
              .margin({ top: 2 })
          }
          .margin({ right: 12 })
          .onClick(async () => {
            if (this.vm) {
              await this.vm.toggleLike(this.currentNote.id);
              this.currentNote = this.vm.getNote(this.currentNote.id) || this.currentNote;
            }
          })

          // 收藏
          Column() {
            Text(this.currentNote.collected ? '★' : '☆')
              .fontSize(20)
              .fontColor(this.currentNote.collected ? '#ff4d4f' : '#666666')
            Text(this.currentNote.collectCount.toString())
              .fontSize(10)
              .fontColor('#666666')
              .margin({ top: 2 })
          }
          .margin({ right: 12 })
          .onClick(async () => {
            if (this.vm) {
              await this.vm.toggleCollect(this.currentNote.id);
              this.currentNote = this.vm.getNote(this.currentNote.id) || this.currentNote;
            }
          })

          // 评论
          Column() {
            Text('💬')
              .fontSize(18)
            Text(this.comments.length.toString())
              .fontSize(10)
              .fontColor('#666666')
              .margin({ top: 2 })
          }
          .margin({ right: 6 })
          .onClick(() => {
            // 仅供点击时滚动回评论区域，当前简化为 no-op
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(64)
      .padding({
        left: 12,
        right: 12,
        top: 10,
        bottom: 14
      })
      .backgroundColor('#ffffff')
      .shadow({
        radius: 10,
        color: '#22000000',
        offsetX: 0,
        offsetY: -2
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  private getCoverResource(): Resource {
    if (this.currentNote.coverUri) {
      if (this.currentNote.coverUri.indexOf('note_cover_1') >= 0) {
        return $r('app.media.note_cover_1');
      }
      if (this.currentNote.coverUri.indexOf('note_cover_2') >= 0) {
        return $r('app.media.note_cover_2');
      }
      if (this.currentNote.coverUri.indexOf('note_cover_3') >= 0) {
        return $r('app.media.note_cover_3');
      }
    }
    switch (this.currentNote.coverIndex) {
      case 1:
        return $r('app.media.note_cover_1');
      case 2:
        return $r('app.media.note_cover_2');
      case 3:
      default:
        return $r('app.media.note_cover_3');
    }
  }

  @Builder
  private buildCommentItem(comment: Comment) {
    Row() {
      // 头像
      Column() {
        Text(comment.author.charAt(0))
          .fontSize(14)
          .fontColor('#ffffff')
      }
      .width(32)
      .height(32)
      .borderRadius(16)
      .backgroundColor('#ff4d4f')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      Column() {
        Row() {
          Text(comment.author)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ right: 8 })
          Text(comment.content)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          Text(this.formatDate(comment.createdAt))
            .fontSize(12)
            .fontColor('#999999')
          Blank()
          Text('👍 ' + comment.likeCount)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: '#f0f0f0' })
  }

  private formatDate(ts: number): string {
    if (!ts) {
      return '';
    }
    const d = new Date(ts);
    const m = d.getMonth() + 1;
    const day = d.getDate();
    const hour = d.getHours();
    const minute = d.getMinutes();
    const now = new Date();
    const diff = now.getTime() - ts;
    const diffDays = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      return `${hour}:${minute.toString().padStart(2, '0')}`;
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 7) {
      return `${diffDays}天前`;
    } else {
      return `${m}-${day}`;
    }
  }

  private async submitComment(): Promise<void> {
    if (this.commentInput.trim().length === 0 || !this.vm) {
      return;
    }
    await this.vm.addComment(this.currentNote.id, this.commentInput.trim());
    this.comments = this.vm.getComments(this.currentNote.id);
    this.currentNote = this.vm.getNote(this.currentNote.id) || this.currentNote;
    this.commentInput = '';
    this.showComments = true; // 自动展开评论列表
  }

  private getAvatarResource(index: number): Resource {
    switch (index) {
      case 1:
        return $r('app.media.head_1');
      case 2:
        return $r('app.media.head_2');
      case 3:
        return $r('app.media.head_3');
      default:
        return $r('app.media.head_1');
    }
  }
}
