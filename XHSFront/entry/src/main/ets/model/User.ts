// entry/src/main/ets/model/User.ts
export interface User {
  id: string;
  name: string;
  avatarIndex: number; // 对应资源 head_1 / head_2 / head_3
  bio?: string;
}

