import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { Note } from '../model/Note';
import { NoteCard } from './NoteCard';
import { PublishPage } from './PublishPage';
import { ProfilePage } from './ProfilePage';
import { NoteDetailPage } from './NoteDetailPage';
import { User } from '../model/User';
import { AuthPage } from './AuthPage';


interface NoteColumns {
  left: Note[];
  right: Note[];
}

enum BottomTab {
  Home = 0,
  Publish = 1,
  Profile = 2
}

@Entry
@Component
export struct HomePage {
  private vm: HomeViewModel = new HomeViewModel();
  @State topTab: number = 0; // 推荐/关注
  @State bottomTab: number = BottomTab.Home; // 首页/发布/我的
  @State detailVisible: boolean = false;
  @State selectedNoteId: number = -1;
  @State notesList: Note[] = []; // 用于响应式更新
  @State followVersion: number = 0; // 用于刷新关注列表/过滤
  @State authed: boolean = false;

  async aboutToAppear() {
    // 初始化时加载数据
    await this.vm.initData();
    this.notesList = this.vm.notes;
    this.authed = this.vm.isLoggedIn();
  }

  build() {
    // 底部栏固定：用 Column + layoutWeight(1) 让内容区占剩余高度
    Column() {
      if (!this.authed) {
        AuthPage({ vm: this.vm, authed: this.authed })
      } else {
        // 内容区（切换区域）
        Column() {
          if (this.detailVisible) {
            NoteDetailPage({
              visible: this.detailVisible,
              note: this.getSelectedNote(),
              vm: this.vm,
              followVersion: this.followVersion
            })
          } else if (this.bottomTab === BottomTab.Home) {
            this.buildHomeContent();
          } else if (this.bottomTab === BottomTab.Publish) {
            PublishPage({
              currentTab: this.bottomTab,
              vm: this.vm,
              notesList: this.notesList
            })
          } else {
            ProfilePage({
              vm: this.vm,
              notesList: this.notesList,
              detailVisible: this.detailVisible,
              selectedNoteId: this.selectedNoteId,
              followVersion: this.followVersion
            })
          }
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.detailVisible) {
          this.buildBottomBar();
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // =========================
  // 首页内容：顶部 Tabs + 真瀑布流
  // =========================
  @Builder
  private buildHomeContent() {
    Column() {
      this.buildTopTabs();
      if (this.topTab === 1) {
        this.buildFollowedUsersBar();
      }
      this.buildMasonryFeed();
    }
    .width('100%')
    .height('100%')
  }

  // 顶部 Tabs：推荐/关注
  @Builder
  private buildTopTabs() {
    Row() {
      this.buildTopTabItem('推荐', 0);
      this.buildTopTabItem('关注', 1);
    }
    .width('100%')
    .backgroundColor('#ffffff') // 修改为与主背景一致
    .padding({ top: 0, bottom: 10 }) // 去除顶部padding
  }

  @Builder
  private buildTopTabItem(text: string, idx: number) {
    Column() {
      Text(text)
        .fontSize(16)
        .fontWeight(this.topTab === idx ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.topTab === idx ? '#000000' : '#888888')
        .padding({ left: 10, right: 10, bottom: 6 })

      if (this.topTab === idx) {
        Row() {
        }
        .height(2)
        .width(24)
        .backgroundColor('#ff4d4f')
        .borderRadius(1)
      } else {
        Row() {
        }
        .height(2)
        .width(24)
        .backgroundColor('#ffffff')
        .borderRadius(1)
      }
    }
    .width('50%')
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.topTab = idx;
    })
  }

  // 真瀑布流：左右两列独立堆叠
  @Builder
  private buildMasonryFeed() {
    Scroll() {
      Row() {
        Column() {
          ForEach(this.splitNotes().left, (item: Note) => {
            Column() {
              NoteCard({ note: item, vm: this.vm })
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
              NoteCard({ note: item, vm: this.vm })
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
      .padding({
        left: 8,
        right: 8,
        top: 0,
        bottom: 64
      }) // 给底栏+凸起按钮留空间
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#f5f5f5')
  }

  private splitNotes(): NoteColumns {
    const left: Note[] = [];
    const right: Note[] = [];
    let leftH = 0;
    let rightH = 0;

    const notes = this.getDisplayNotes();
    for (const n of notes) {
      const h = n.coverHeight ?? 180;
      if (leftH <= rightH) {
        left.push(n);
        leftH += h;
      } else {
        right.push(n);
        rightH += h;
      }
    }
    return { left, right };
  }

  private getSelectedNote(): Note {
    const notes = this.notesList.length > 0 ? this.notesList : this.vm.notes;
    const found = notes.find(n => n.id === this.selectedNoteId);
    return found ?? notes[0];
  }

  private getDisplayNotes(): Note[] {
    if (this.topTab === 0) {
      return this.notesList.length > 0 ? this.notesList : this.vm.notes;
    }
    const all = this.notesList.length > 0 ? this.notesList : this.vm.notes;
    // 依赖 followVersion 触发刷新
    const _fv = this.followVersion;
    return all.filter(n => this.vm.isFollowing(n.authorId));
  }

  @Builder
  private buildFollowedUsersBar() {
    Scroll() {
      Row() {
        ForEach(this.vm.getFollowedUsers(), (u: User) => {
          Column() {
            Image($r(this.getAvatarResourceName(u.avatarIndex)))
              .width(48)
              .height(48)
              .borderRadius(24)
              .objectFit(ImageFit.Cover)
              .margin({ bottom: 4 })

            Text(u.name)
              .fontSize(12)
              .fontColor('#666666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width(60)
              .textAlign(TextAlign.Center)
          }
          .width(60)
          .padding({
            left: 8,
            right: 8,
            top: 6,
            bottom: 6
          })
        }, (u: User) => u.id)
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height(90)
    .backgroundColor('#ffffff')
    .padding({ left: 8, right: 8 })
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

  // =========================
  // 底部栏：固定不变
  // =========================
  @Builder
  private buildBottomBar() {
    Stack() {
      // 底栏主体
      Row() {
        // 首页
        Column() {
          Text('首页')
            .fontSize(12)
            .fontColor(this.bottomTab === BottomTab.Home ? '#ff4d4f' : '#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.bottomTab = BottomTab.Home;
        })

        // 中间占位（给 + 按钮留位置）
        Column() {
        }
        .layoutWeight(1)

        // 我的
        Column() {
          Text('我的')
            .fontSize(12)
            .fontColor(this.bottomTab === BottomTab.Profile ? '#ff4d4f' : '#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.bottomTab = BottomTab.Profile;
        })
      }
      .width('100%')
      .height(64)
      .padding({ top: 10, bottom: 16 })
      .backgroundColor('#ffffff')
      .shadow({
        radius: 8,
        color: '#10000000', // 调整透明度
        offsetY: -1          // 减少偏移量
      })

      // 凸起“+”按钮（发布）
      Column() {
        Text('+')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .backgroundColor('#ff4d4f')
          .borderRadius(20)
          .shadow({
            radius: 12,
            color: '#33000000',
            offsetX: 0,
            offsetY: 4
          })
      }
      .width(56)
      .height(56)
      .margin({ left: '50%' })
      .position({ x: -28 })
      .onClick(() => {
        this.bottomTab = BottomTab.Publish;
      })
    }
    .width('100%')
    .height(64) // 明确指定高度
    .margin({ bottom: -16 }) // 抵消shadow偏移
  }
}
