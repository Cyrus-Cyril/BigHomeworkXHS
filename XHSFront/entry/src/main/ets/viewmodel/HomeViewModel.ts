// entry/src/main/ets/viewmodel/HomeViewModel.ts
import { Note } from '../model/Note';
import { Comment } from '../model/Comment';
import { User } from '../model/User';
import { AuthUser } from '../model/AuthUser';
import { StorageUtil } from '../utils/StorageUtil';
import { Api, ApiResp } from '../network/Api';

interface LoginRespUser {
  id: string;
  name: string;
  avatarIndex: number;
  bio?: string;
}

interface NoteDto {
  id: number;
  title: string;
  content: string;
  createdAt: number;
  authorId: string;
  authorName: string;
  avatarIndex: number;

  images?: string[];
  coverUri?: string;
  coverIndex?: number;
  coverHeight?: number;
  likeCount?: number;
  collectCount?: number;
  commentCount?: number;
}

type LoginResp = {
  token?: string;
  user: {
    id: string;
    username?: string;
    name: string;
    avatarIndex: number;
    bio?: string;
  }
}

export class HomeViewModel {
  private notesInternal: Note[] = [];
  private commentsInternal: Comment[] = [];

  // 这些本来是本地账号体系；现在改为后端账号体系，但为了不改前端，保留字段
  private accounts: AuthUser[] = [];
  private users: User[] = [];

  private currentUser: User = { id: 'me', name: '我', avatarIndex: 1, bio: '这个人很懒，什么都没有留下~' };
  private followedUserIds: string[] = [];
  private isInitialized: boolean = false;
  private isLoggedInFlag: boolean = false;

  constructor() {}

  get notes(): Note[] {
    return this.notesInternal;
  }

  getCurrentUser(): User {
    return this.currentUser;
  }

  getUsers(): User[] {
    return this.users;
  }

  getFollowedUserIds(): string[] {
    return this.followedUserIds;
  }

  isLoggedIn(): boolean {
    return this.isLoggedInFlag;
  }

  isFollowing(userId: string): boolean {
    return this.followedUserIds.includes(userId);
  }

  // =========================
  // 关键：初始化数据（从后端拉取）
  // =========================
  async initData(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    // 1) 先恢复“登录态”（本地仅保存当前用户）
    const savedProfile = await StorageUtil.loadUserProfile();
    if (savedProfile) {
      this.currentUser = savedProfile as User;
      this.isLoggedInFlag = true;
    } else {
      this.isLoggedInFlag = false;
    }

    // 2) 恢复关注列表
    this.followedUserIds = await StorageUtil.loadFollowings();

    // 3) 从后端拉取 notes
    await this.refreshNotesFromServer();

    // 4) 评论：你前端暂时是本地存储，先保留（后续再接后端 comments）
    const savedComments = await StorageUtil.loadComments();
    if (savedComments && savedComments.length > 0) {
      this.commentsInternal = savedComments as Comment[];
    }

    this.isInitialized = true;
  }

  private async refreshNotesFromServer(): Promise<void> {
    try {
      // 如果你的后端是 /api/notes，把这里改成 '/api/notes'
      const dtoList = await Api.getData<NoteDto[]>('/notes');

      this.notesInternal = dtoList.map(dto => this.mapDtoToNote(dto));

      // 用户列表从 notes 构建（保证关注栏可用）
      this.buildUsersFromNotes();

      // 同步保存到本地（可选：断网时还能显示）
      await StorageUtil.saveNotes(this.notesInternal);
    } catch (e) {
      // 如果后端没连上，fallback 用本地缓存，保证应用还能跑
      const cached = await StorageUtil.loadNotes();
      if (cached && cached.length > 0) {
        this.notesInternal = cached.map((note: any) => ({
          ...note,
          collected: note.collected ?? false,
          collectCount: note.collectCount ?? 0,
          commentCount: note.commentCount ?? 0,
          authorId: note.authorId ?? 'user' + (note.author ?? '0'),
          authorAvatarIndex: note.authorAvatarIndex ?? 1,
          images: note.images ?? []
        }));
        this.buildUsersFromNotes();
      } else {
        // 完全没有缓存时，再用你原来的 mock（确保第一次也能看见内容）
        this.initMockData();
        await StorageUtil.saveNotes(this.notesInternal);
        this.buildUsersFromNotes();
      }
    }
  }

  private mapDtoToNote(dto: NoteDto): Note {
    const heights: number[] = [140, 160, 180, 200, 220, 240, 260];
    const h = dto.coverHeight ?? heights[dto.id % heights.length];

    // 兼容你前端 Note 结构需要的字段
    return {
      id: dto.id,
      title: dto.title ?? '无标题',
      content: dto.content ?? '',
      coverIndex: dto.coverIndex ?? ((dto.id % 3) + 1),
      coverUri: dto.coverUri,
      coverHeight: h,
      images: dto.images ?? (dto.coverUri ? [dto.coverUri] : []),

      author: dto.authorName ?? '匿名',
      authorId: dto.authorId ?? 'unknown',
      authorAvatarIndex: dto.avatarIndex ?? 1,

      likeCount: dto.likeCount ?? 0,
      liked: false, // 先不做按用户区分的点赞态，后端接了 like 表再做
      collected: false,
      collectCount: dto.collectCount ?? 0,
      commentCount: dto.commentCount ?? 0,
      createdAt: dto.createdAt ?? Date.now()
    };
  }

  private buildUsersFromNotes() {
    const map = new Map<string, User>();

    for (const n of this.notesInternal) {
      map.set(n.authorId, {
        id: n.authorId,
        name: n.author,
        avatarIndex: n.authorAvatarIndex ?? 1,
        bio: ''
      });
    }

    // 确保自己在列表中
    map.set(this.currentUser.id, this.currentUser);
    this.users = Array.from(map.values());
  }

  // =========================
  // 登录/注册：改走后端
  // =========================
  async register(username: string, password: string, name: string, avatarIndex: number): Promise<{ ok: boolean; msg?: string }> {
    if (!username || !password || !name) {
      return { ok: false, msg: '请输入完整信息' };
    }

    try {
      // 如果你的后端是 /api/auth/register，把这里改一下
      const user = await Api.postData<LoginRespUser>('/register', { username, password, name, avatarIndex });

      this.currentUser = { id: user.id, name: user.name, avatarIndex: user.avatarIndex, bio: user.bio ?? '' };
      this.isLoggedInFlag = true;

      await StorageUtil.saveUserProfile(this.currentUser);

      // 注册后刷新一下列表
      await this.refreshNotesFromServer();
      return { ok: true };
    } catch (e) {
      return { ok: false, msg: (e as Error).message };
    }
  }

  async login(username: string, password: string): Promise<{ ok: boolean; msg?: string }> {
    if (!username || !password) {
      return { ok: false, msg: '请输入用户名和密码' };
    }

    try {
      const user = await Api.postData<LoginRespUser>('/login', { username, password });

      this.currentUser = { id: user.id, name: user.name, avatarIndex: user.avatarIndex, bio: user.bio ?? '' };
      this.isLoggedInFlag = true;

      await StorageUtil.saveUserProfile(this.currentUser);

      // 登录后刷新一下列表
      await this.refreshNotesFromServer();
      return { ok: true };
    } catch (e) {
      return { ok: false, msg: (e as Error).message };
    }
  }

  async logout(): Promise<void> {
    this.isLoggedInFlag = false;
    await StorageUtil.saveUserProfile(null);
  }

  // =========================
  // 发布：走后端，成功后刷新列表
  // =========================
  async publishNote(title: string, content: string, images: string[], coverHeight: number): Promise<void> {
    // 后端先最小实现：不传 images 也可以
    const payload = {
      title: title || '无标题',
      content: content || '',
      authorId: this.currentUser.id
      // 你后端如果支持 images/coverUri 可加：images
    };

    try {
      await Api.postData<any>('/notes', payload);
      await this.refreshNotesFromServer();
    } catch (e) {
      // 如果后端失败，退回本地插入（保证发布按钮不“没反应”）
      const coverIndex = 1;
      const newNote: Note = {
        id: this.notesInternal.length > 0 ? Math.max(...this.notesInternal.map(n => n.id)) + 1 : 1,
        title: payload.title,
        content: payload.content,
        coverIndex,
        coverUri: images.length > 0 ? images[0] : undefined,
        coverHeight,
        images,
        author: this.currentUser.name,
        authorId: this.currentUser.id,
        authorAvatarIndex: this.currentUser.avatarIndex,
        likeCount: 0,
        liked: false,
        collected: false,
        collectCount: 0,
        commentCount: 0,
        createdAt: Date.now()
      };
      this.notesInternal = [newNote, ...this.notesInternal];
      await StorageUtil.saveNotes(this.notesInternal);
      this.buildUsersFromNotes();
    }
  }

  // =========================
  // 点赞/收藏/关注：暂时本地（后端可后续再接）
  // =========================
  async toggleLike(noteId: number): Promise<void> {
    const target = this.notesInternal.find(n => n.id === noteId);
    if (!target) return;
    target.liked = !target.liked;
    target.likeCount += target.liked ? 1 : -1;
    await StorageUtil.saveNotes(this.notesInternal);
  }

  async toggleCollect(noteId: number): Promise<void> {
    const target = this.notesInternal.find(n => n.id === noteId);
    if (!target) return;
    target.collected = !target.collected;
    target.collectCount += target.collected ? 1 : -1;
    await StorageUtil.saveNotes(this.notesInternal);
  }

  async toggleFollow(userId: string): Promise<void> {
    if (userId === this.currentUser.id) return;

    if (this.followedUserIds.includes(userId)) {
      this.followedUserIds = this.followedUserIds.filter(id => id !== userId);
    } else {
      this.followedUserIds = [...this.followedUserIds, userId];
    }
    await StorageUtil.saveFollowings(this.followedUserIds);
  }

  getFollowedUsers(): User[] {
    return this.users.filter(u => this.followedUserIds.includes(u.id));
  }

  getFollowedNotes(): Note[] {
    return this.notesInternal.filter(n => this.followedUserIds.includes(n.authorId));
  }

  getRecommendedNotes(): Note[] {
    return this.notesInternal;
  }

  getMyNotes(): Note[] {
    return this.notesInternal.filter(n => n.authorId === this.currentUser.id);
  }

  // =========================
  // 用户资料更新：目前先本地，后端可后续加 /users/update
  // =========================
  async updateProfile(name: string, bio: string, avatarIndex: number): Promise<void> {
    this.currentUser = { ...this.currentUser, name, bio, avatarIndex };

    this.notesInternal = this.notesInternal.map(note => {
      if (note.authorId === this.currentUser.id) {
        return { ...note, author: name, authorAvatarIndex: avatarIndex };
      }
      return note;
    });

    await StorageUtil.saveUserProfile(this.currentUser);
    await StorageUtil.saveNotes(this.notesInternal);
    this.buildUsersFromNotes();
  }

  // =========================
  // 评论：你现在本地，先保持不动
  // =========================
  getComments(noteId: number): Comment[] {
    return this.commentsInternal.filter(c => c.noteId === noteId);
  }

  async addComment(noteId: number, content: string, author: string = this.currentUser.name): Promise<void> {
    const newComment: Comment = {
      id: this.commentsInternal.length > 0 ? Math.max(...this.commentsInternal.map(c => c.id)) + 1 : 1,
      noteId,
      author,
      content,
      likeCount: 0,
      liked: false,
      createdAt: Date.now()
    };
    this.commentsInternal.push(newComment);

    const note = this.notesInternal.find(n => n.id === noteId);
    if (note) {
      note.commentCount = (note.commentCount || 0) + 1;
      await StorageUtil.saveNotes(this.notesInternal);
    }
    await StorageUtil.saveComments(this.commentsInternal);
  }

  getNote(noteId: number): Note | undefined {
    return this.notesInternal.find(n => n.id === noteId);
  }

  // =========================
  // 你的原 Mock 仍保留：用于断网/没后端时兜底
  // =========================
  private initMockData(): void {
    const titles: string[] = [
      '校园随手拍', '备考日常', '电路实验记录', '图书馆打卡', '夜跑记录', '学习桌面分享',
      '食堂测评', '周末出游', '课程笔记整理', '面试准备', '项目进度', '开源日记'
    ];

    const mockUsers: User[] = [
      { id: 'u1', name: 'Pincheng', avatarIndex: 1, bio: '爱摄影，爱生活' },
      { id: 'u2', name: 'CS Student', avatarIndex: 2, bio: '准备考研中' },
      { id: 'u3', name: 'OH Dev', avatarIndex: 3, bio: 'OpenHarmony 爱好者' },
      { id: 'u4', name: 'Lab Member', avatarIndex: 1, bio: '实验室一员' },
      { id: 'u5', name: '同学A', avatarIndex: 2, bio: '热爱运动' },
      { id: 'u6', name: '同学B', avatarIndex: 3, bio: '美食分享' }
    ];
    this.users = [this.currentUser, ...mockUsers];

    const heights: number[] = [140, 160, 180, 200, 220, 240, 260];
    const result: Note[] = [];
    const now = Date.now();

    for (let i = 1; i <= 36; i++) {
      const author = mockUsers[i % mockUsers.length];
      result.push({
        id: i,
        title: `${titles[i % titles.length]} #${i}`,
        content: `这是第 ${i} 条测试笔记，用于验证瀑布流列表滚动与渲染效果。`,
        coverIndex: (i % 3) + 1,
        coverUri: undefined,
        coverHeight: heights[i % heights.length],
        images: [],
        author: author.name,
        authorId: author.id,
        authorAvatarIndex: author.avatarIndex,
        likeCount: (i * 7) % 200,
        liked: i % 5 === 0,
        collected: i % 7 === 0,
        collectCount: (i * 3) % 100,
        commentCount: (i * 2) % 50,
        createdAt: now - i * 3600 * 1000
      });
    }

    this.followedUserIds = ['u1', 'u2'];
    this.notesInternal = result;
  }
}
