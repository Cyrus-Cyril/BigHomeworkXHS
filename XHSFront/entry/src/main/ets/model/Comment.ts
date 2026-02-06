// entry/src/main/ets/model/Comment.ts
export interface Comment {
  id: number;
  noteId: number;
  author: string;
  content: string;
  likeCount: number;
  liked: boolean;
  createdAt: number;
  replies?: Comment[]; // 回复评论
}

