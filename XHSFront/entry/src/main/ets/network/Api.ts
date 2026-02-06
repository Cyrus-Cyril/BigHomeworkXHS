// entry/src/main/ets/network/Api.ts
import http from '@ohos.net.http';


export type ApiResp<T> =
  | { ok: boolean; msg?: string; data?: T }
    | { code: number; msg?: string; data?: T };

export class Api {
  /**
   * baseUrl 设置说明：
   * 1) 真机：改成你电脑局域网 IP，例如 http://192.168.1.5:3000
   * 2) 模拟器：优先试 http://10.0.2.2:3000
   */
  static baseUrl: string = 'http://127.0.0.1:3000';

  // 如果你后端做了 token 登录，把 token 存这里（也可接 StorageUtil）
  static token: string | null = null;

  private static buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (Api.token) {
      headers['Authorization'] = `Bearer ${Api.token}`;
    }
    return headers;
  }

  private static async requestRaw(
    method: http.RequestMethod,
    path: string,
    body?: object
  ): Promise<string> {
    const client = http.createHttp();
    const url = `${Api.baseUrl}${path}`;

    try {
      const res = await client.request(url, {
        method,
        header: Api.buildHeaders(),
        extraData: body ? JSON.stringify(body) : undefined,
        expectDataType: http.HttpDataType.STRING,
        readTimeout: 15000,
        connectTimeout: 15000
      });

      return (res.result ?? '') as string;
    } finally {
      client.destroy();
    }
  }

  private static parseJson<T>(text: string): T {
    try {
      return JSON.parse(text) as T;
    } catch (_) {
      throw new Error(`API 返回不是合法 JSON：${text}`);
    }
  }

  private static isOk<T>(resp: ApiResp<T>): boolean {
    // A) ok === true
    if ((resp as any).ok !== undefined) {
      return (resp as any).ok === true;
    }
    // B) code === 0
    if ((resp as any).code !== undefined) {
      return (resp as any).code === 0;
    }
    return false;
  }

  private static getMsg<T>(resp: ApiResp<T>): string {
    return (resp as any).msg ?? '请求失败';
  }

  static async get<T>(path: string): Promise<T> {
    const text = await Api.requestRaw(http.RequestMethod.GET, path);
    return Api.parseJson<T>(text);
  }

  static async post<T>(path: string, body?: object): Promise<T> {
    const text = await Api.requestRaw(http.RequestMethod.POST, path, body);
    return Api.parseJson<T>(text);
  }

  /**
   * 推荐用法：后端是 ApiResp 包装时用它
   */
  static async getData<T>(path: string): Promise<T> {
    const resp = await Api.get<ApiResp<T>>(path);
    if (!Api.isOk(resp)) {
      throw new Error(Api.getMsg(resp));
    }
    return (resp as any).data as T;
  }

  static async postData<T>(path: string, body?: object): Promise<T> {
    const resp = await Api.post<ApiResp<T>>(path, body);
    if (!Api.isOk(resp)) {
      throw new Error(Api.getMsg(resp));
    }
    return (resp as any).data as T;
  }
}
