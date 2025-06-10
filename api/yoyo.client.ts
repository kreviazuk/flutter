import type { IReturn } from "./model.dtos";
import { GovScope } from "@/api/model.dtos";
import { omit } from "lodash-es";

export class JsonServiceClient {
  baseUrl: string;

  constructor(baseUrl = `${import.meta.env.VITE_APP_API_URL}`) {
    this.baseUrl = baseUrl;
  }

  public send<T>(request: IReturn<T>): Promise<T> {
    return this.uniRequest<T>(request, this.getMethod(request));
  }

  public get<T>(request: IReturn<T>): Promise<T> {
    return this.uniRequest<T>(request, "GET");
  }

  public post<T>(request: IReturn<T>): Promise<T> {
    return this.uniRequest<T>(request, "POST");
  }

  private getMethod<T>(request: IReturn<T>): UniApp.RequestOptions["method"] {
    return typeof request.getMethod == "function"
      ? (request.getMethod() as UniApp.RequestOptions["method"])
      : ("POST" as UniApp.RequestOptions["method"]);
  }

  private queryPaths = [] as string[];

  public toAbsoluteUrl<T>(request: IReturn<T>): string {
    this.queryPaths = [];
    const tmpl = request.getUrl();
    
    // 替换路径参数
    let url = tmpl;
    if (tmpl.includes("{")) {
      url = tmpl.replace(/\{([^}]+)\}/g, (_, key) => {
        this.queryPaths.push(key);
        return (request as any)[key];
      });
    }

    // 处理查询参数
    const queryParams: string[] = [];
    Object.keys(request).forEach((key) => {
      if (!this.queryPaths.includes(key) && key !== 'body') {
        const value = (request as any)[key];
        if (value !== undefined && value !== null) {
          console.log(`处理参数 ${key}:`, value);
          if (Array.isArray(value)) {
            // 处理数组参数，确保每个元素都生成独立的参数
            value.forEach((v, index) => {
              console.log(`处理数组元素 [${index}]:`, v);
              // 为每个数组元素创建独立的参数
              queryParams.push(`${encodeURIComponent(key)}=${encodeURIComponent(v)}`);
            });
          } else {
            console.log(`处理非数组参数:`, value);
            queryParams.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
          }
        }
      }
    });

    if (queryParams.length > 0) {
      console.log('最终查询参数:', queryParams);
      console.log('参数数量:', queryParams.length);
      url += (url.includes('?') ? '&' : '?') + queryParams.join('&');
    }
    console.log('最终URL:', `${this.baseUrl}${url}`);
    return `${this.baseUrl}${url}`;
  }

  private toData<T>(request: IReturn<T>) {
    // 如果是GET请求，不需要传递data
    if (this.getMethod(request) === "GET") {
      return undefined;
    }

    const obj = {} as any;
    Object.keys(request).forEach((key) => {
      if (!this.queryPaths.includes(key) && key !== 'body') {
        obj[key] = (request as any)[key];
      }
    });
    const data = this.getMethod(request) === "POST" ? request.body : obj;
    // 添加默认的 scope
    if (data && typeof data === "object") {
      (data as any).Scope = GovScope.JiGou;
    }
    return data;
  }

  private async uniRequest<T>(
    request: IReturn<T>,
    method: UniApp.RequestOptions["method"]
  ): Promise<T> {
    const res: any = await new Promise((resolve, reject) => {
      const token = uni.getStorageSync("token");
      const url = this.toAbsoluteUrl(request);
      const data = this.toData(request);
      
      console.log('请求方法:', method);
      console.log('请求URL:', url);
      console.log('请求数据:', data);
      
      uni.request({
        method: method,
        url: url,
        enableHttp2: true,
        header: {
          Authorization: token || "",
        },
        data: data,
        success: (res: UniApp.RequestSuccessCallbackResult) => {
          console.log("成功了", res);
          
          const responseData = res.data as any;
          console.log('responseData',responseData);
          
          // 检查业务状态码
          if (responseData.code === 600) {
            uni.removeStorageSync("token");
            uni.showToast({
              title: responseData.msg,
              icon: "none",
              duration: 2000,
            });
            setTimeout(() => {
              uni.reLaunch({ url: "/pages/login/index" });
            }, 2000);
            reject(new Error(responseData.Message || "登录已过期"));
            return;
          }
          resolve(responseData);
        },
        fail: (res: any) => {
          console.log("失败了", res);
          uni.showToast({
            title: "网络请求失败，请稍后重试",
            icon: "none",
          });
          reject(res);
        },
      });
    });

    return res;
  }
  public async upload<T>({
    request,
    files,
  }: {
    request: IReturn<T>;
    files: UniNamespace.UploadFileOptionFiles[];
  }): Promise<T> {
    const res: any = await new Promise((resolve, reject) => {
      const token = uni.getStorageSync("token");
      const names = files?.map((x) => x.name!);
      uni.uploadFile({
        url: this.toAbsoluteUrl(request),
        enableHttp2: true,
        header: {
          Authorization: token || "",
        },
        files,
        formData: omit(request, names),
        success: (res: UniApp.UploadFileSuccessCallbackResult) => {
          resolve(res.data);
        },
        fail: (res: UniApp.GeneralCallbackResult) => {
          reject(res);
        },
      });
    });

    return res;
  }
}

// 导出单例
export const request = new JsonServiceClient();
