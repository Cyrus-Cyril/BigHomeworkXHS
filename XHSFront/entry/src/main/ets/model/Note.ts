export interface Note {
  id: number;
  title: string;
  content: string;
  // 封面：优先使用 coverUri，其次 coverIndex 对应资源
  coverIndex: number;
  coverUri?: string;
  coverHeight: number;   // 用于瀑布流效果
  images?: string[];     // 笔记配图（首图为封面）
  author: string;
  authorId: string;
  authorAvatarIndex?: number;
  likeCount: number;
  liked: boolean;
  collected: boolean;    // 是否收藏
  collectCount: number;  // 收藏数
  commentCount: number;  // 评论数
  createdAt: number;
}
