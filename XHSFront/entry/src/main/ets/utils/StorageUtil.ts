// entry/src/main/ets/utils/StorageUtil.ts
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

const PREF_NAME = 'xhs_notes_pref';
const NOTES_KEY = 'notes_data';
const USER_PROFILE_KEY = 'user_profile';
const FOLLOWINGS_KEY = 'followings';
const COMMENTS_KEY = 'comments_data';
const ACCOUNTS_KEY = 'accounts_data';
const CURRENT_UID_KEY = 'current_uid';

export class StorageUtil {
  private static dataPreferences: preferences.Preferences | null = null;

  // 初始化Preferences
  static async init(context: Context): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, PREF_NAME);
    } catch (err) {
      console.error('Failed to get preferences. Cause: ' + JSON.stringify(err));
    }
  }

  // 保存笔记数据
  static async saveNotes(notes: any[]): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      const notesJson = JSON.stringify(notes);
      await this.dataPreferences.put(NOTES_KEY, notesJson);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save notes. Cause: ' + JSON.stringify(err));
    }
  }

  // 加载笔记数据
  static async loadNotes(): Promise<any[]> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }
    try {
      const notesJson = await this.dataPreferences.get(NOTES_KEY, '[]');
      if (typeof notesJson === 'string') {
        return JSON.parse(notesJson);
      }
      return [];
    } catch (err) {
      console.error('Failed to load notes. Cause: ' + JSON.stringify(err));
      return [];
    }
  }

  // 保存用户资料
  static async saveUserProfile(profile: any): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await this.dataPreferences.put(USER_PROFILE_KEY, JSON.stringify(profile));
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save user profile. Cause: ' + JSON.stringify(err));
    }
  }

  static async loadUserProfile(): Promise<any | null> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return null;
    }
    try {
      const raw = await this.dataPreferences.get(USER_PROFILE_KEY, '');
      if (typeof raw === 'string' && raw.length > 0) {
        return JSON.parse(raw);
      }
      return null;
    } catch (err) {
      console.error('Failed to load user profile. Cause: ' + JSON.stringify(err));
      return null;
    }
  }

  // 保存/读取关注列表
  static async saveFollowings(followings: string[]): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await this.dataPreferences.put(FOLLOWINGS_KEY, JSON.stringify(followings));
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save followings. Cause: ' + JSON.stringify(err));
    }
  }

  static async loadFollowings(): Promise<string[]> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }
    try {
      const raw = await this.dataPreferences.get(FOLLOWINGS_KEY, '[]');
      if (typeof raw === 'string') {
        return JSON.parse(raw);
      }
      return [];
    } catch (err) {
      console.error('Failed to load followings. Cause: ' + JSON.stringify(err));
      return [];
    }
  }

  // 评论存储
  static async saveComments(comments: any[]): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await this.dataPreferences.put(COMMENTS_KEY, JSON.stringify(comments));
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save comments. Cause: ' + JSON.stringify(err));
    }
  }

  static async loadComments(): Promise<any[]> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }
    try {
      const raw = await this.dataPreferences.get(COMMENTS_KEY, '[]');
      if (typeof raw === 'string') {
        return JSON.parse(raw);
      }
      return [];
    } catch (err) {
      console.error('Failed to load comments. Cause: ' + JSON.stringify(err));
      return [];
    }
  }

  // 账户存储
  static async saveAccounts(accounts: any[]): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await this.dataPreferences.put(ACCOUNTS_KEY, JSON.stringify(accounts));
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save accounts. Cause: ' + JSON.stringify(err));
    }
  }

  static async loadAccounts(): Promise<any[]> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }
    try {
      const raw = await this.dataPreferences.get(ACCOUNTS_KEY, '[]');
      if (typeof raw === 'string') {
        return JSON.parse(raw);
      }
      return [];
    } catch (err) {
      console.error('Failed to load accounts. Cause: ' + JSON.stringify(err));
      return [];
    }
  }

  static async saveCurrentUid(uid: string | null): Promise<void> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      if (uid) {
        await this.dataPreferences.put(CURRENT_UID_KEY, uid);
      } else {
        await this.dataPreferences.delete(CURRENT_UID_KEY);
      }
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save current uid. Cause: ' + JSON.stringify(err));
    }
  }

  static async loadCurrentUid(): Promise<string | null> {
    if (!this.dataPreferences) {
      console.error('Preferences not initialized');
      return null;
    }
    try {
      const raw = await this.dataPreferences.get(CURRENT_UID_KEY, '');
      if (typeof raw === 'string' && raw.length > 0) {
        return raw;
      }
      return null;
    } catch (err) {
      console.error('Failed to load current uid. Cause: ' + JSON.stringify(err));
      return null;
    }
  }

  // 清除所有数据
  static async clearAll(): Promise<void> {
    if (!this.dataPreferences) {
      return;
    }
    try {
      await this.dataPreferences.clear();
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to clear data. Cause: ' + JSON.stringify(err));
    }
  }
}

