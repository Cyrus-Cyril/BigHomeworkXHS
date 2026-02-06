// src/main/java/org/example/xhsback/controller/ApiResp.java
package org.example.xhsback.controller;

public class ApiResp<T> {
    public boolean ok;
    public String msg;
    public T data;

    public static <T> ApiResp<T> ok(T data) {
        ApiResp<T> r = new ApiResp<>();
        r.ok = true;
        r.data = data;
        return r;
    }

    public static <T> ApiResp<T> fail(String msg) {
        ApiResp<T> r = new ApiResp<>();
        r.ok = false;
        r.msg = msg;
        return r;
    }
}
