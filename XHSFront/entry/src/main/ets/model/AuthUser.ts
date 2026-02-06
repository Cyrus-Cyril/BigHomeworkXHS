// entry/src/main/ets/model/AuthUser.ts
export interface AuthUser {
  id: string;          // user id
  username: string;    // 登录名
  password: string;    // 简化存储，实际应加密
  name: string;        // 显示昵称
  avatarIndex: number; // 头像索引 head_1/2/3
  bio?: string;
}

