import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { Note } from '../model/Note';

@Component
export struct PublishPage {
  @Link currentTab: number;
  @Prop vm: HomeViewModel;
  @Link notesList: Note[];
  @State title: string = '';
  @State content: string = '';
  @State selectedImages: number[] = []; // 选择的图片索引，首图为封面

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            this.currentTab = 0; // 返回首页
          })

        Blank()

        Text('发布')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.canPublish() ? '#ff4d4f' : '#cccccc')
          .onClick(() => {
            if (this.canPublish()) {
              this.handlePublish();
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          // 图片选择区域（首图作为封面）
          Column() {
            Text('选择图片（首张作为封面）')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 12 })
            Row() {
              ForEach([1, 2, 3], (index: number) => {
                Column() {
                  Image($r(this.getImageResourceName(index)))
                    .width(90)
                    .height(90)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                    .border({
                      width: this.selectedImages.includes(index) ? 3 : 0,
                      color: '#ff4d4f',
                      radius: 8
                    })
                    .onClick(() => {
                      this.toggleImageSelect(index);
                    })
                  if (this.selectedImages.includes(index)) {
                    Text('✓')
                      .fontSize(20)
                      .fontColor('#ffffff')
                      .width(24)
                      .height(24)
                      .borderRadius(12)
                      .backgroundColor('#ff4d4f')
                      .textAlign(TextAlign.Center)
                      .margin({ top: -32, left: 60 })
                  }
                }
                .margin({ right: 12 })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            if (this.selectedImages.length > 0) {
              Text(`已选择 ${this.selectedImages.length} 张，首张为封面`)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .margin({ bottom: 12 })

          // 标题输入
          Column() {
            Text('标题')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ bottom: 8 })
              .width('100%')

            TextInput({ placeholder: '请输入标题', text: this.title })
              .onChange((v: string) => {
                this.title = v;
              })
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .padding(12)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .margin({ bottom: 12 })

          // 内容输入
          Column() {
            Text('内容')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ bottom: 8 })
              .width('100%')

            TextArea({ placeholder: '分享你的想法...', text: this.content })
              .onChange((v: string) => {
                this.content = v;
              })
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .padding(12)
              .width('100%')
              .height(200)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .margin({ bottom: 12 })
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  private getImageResource(index: number): Resource {
    switch (index) {
      case 1:
        return $r('app.media.note_cover_1');
      case 2:
        return $r('app.media.note_cover_2');
      case 3:
      default:
        return $r('app.media.note_cover_3');
    }
  }

  private getImageResourceName(index: number): string {
    switch (index) {
      case 1:
        return 'app.media.note_cover_1';
      case 2:
        return 'app.media.note_cover_2';
      case 3:
      default:
        return 'app.media.note_cover_3';
    }
  }

  private canPublish(): boolean {
    return this.title.trim().length > 0 || this.content.trim().length > 0 || this.selectedImages.length > 0;
  }

  private async handlePublish(): Promise<void> {
    // 随机高度，模拟真实瀑布流效果
    const heights: number[] = [140, 160, 180, 200, 220, 240, 260];
    const randomHeight = heights[Math.floor(Math.random() * heights.length)];

    const images = this.selectedImages.length > 0
      ? this.selectedImages.map(i => `note_cover_${i}.png`)
      : ['note_cover_1.png'];

    await this.vm.publishNote(
      this.title.trim(),
      this.content.trim(),
      images,
      randomHeight
    );

    // 刷新笔记列表
    this.notesList = [...this.vm.notes];

    // 清空表单
    this.title = '';
    this.content = '';
    this.selectedImages = [];

    // 返回首页
    this.currentTab = 0;
  }

  private toggleImageSelect(idx: number) {
    if (this.selectedImages.includes(idx)) {
      this.selectedImages = this.selectedImages.filter(i => i !== idx);
    } else {
      this.selectedImages = [...this.selectedImages, idx];
    }
  }
}
