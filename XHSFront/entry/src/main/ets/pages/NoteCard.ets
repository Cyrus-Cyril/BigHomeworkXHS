// entry/src/main/ets/pages/NoteCard.ets
import { Note } from '../model/Note';
import { HomeViewModel } from '../viewmodel/HomeViewModel';


@Component
export struct NoteCard {
  @Prop note: Note;
  @Prop vm: HomeViewModel;

  private getCoverResource(): Resource {
    if (this.note.coverUri) {
      if (this.note.coverUri.indexOf('note_cover_1') >= 0) {
        return $r('app.media.note_cover_1');
      }
      if (this.note.coverUri.indexOf('note_cover_2') >= 0) {
        return $r('app.media.note_cover_2');
      }
      if (this.note.coverUri.indexOf('note_cover_3') >= 0) {
        return $r('app.media.note_cover_3');
      }
    }
    // 根据 coverIndex 选择封面图片
    switch (this.note.coverIndex) {
      case 1:
        return $r('app.media.note_cover_1');
      case 2:
        return $r('app.media.note_cover_2');
      case 3:
      default:
        return $r('app.media.note_cover_3');
    }
  }

  build() {
    Column() {
      // 使用 getCoverResource() 获取图片资源
      Image(this.getCoverResource())
        .objectFit(ImageFit.Cover)
        .height(this.note.coverHeight)
        .width('100%')
        .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 0, bottomRight: 0 })

      Column() {
        Text(this.note.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        Text(this.note.author)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ bottom: 8 })

        Row() {
          Row() {
            Image($r('app.media.ic_like'))
              .width(18)
              .height(18)
              .margin({ right: 4 })
            Text(this.note.likeCount.toString())
              .fontSize(12)
          }
          .alignItems(VerticalAlign.Center)

          Blank()

          Text(this.note.liked ? '已赞' : '点赞')
            .fontSize(12)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(12)
            .backgroundColor(this.note.liked ? '#ff4d4f' : '#f5f5f5')
            .fontColor(this.note.liked ? '#ffffff' : '#666666')
            .onClick(async () => {
              await this.vm.toggleLike(this.note.id);
            })
        }
      }
      .padding(10)
    }
    .borderRadius(12)
    .backgroundColor('#ffffff')
    .margin({ left: 6, right: 6, bottom: 12 })
    .shadow({
      radius: 8,
      color: '#22000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
