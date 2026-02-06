// src/main/java/org/example/xhsback/controller/AuthController.java
package org.example.xhsback.controller;

import org.example.xhsback.entity.UserEntity;
import org.example.xhsback.repo.UserRepo;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@CrossOrigin
public class AuthController {
    private final UserRepo userRepo;

    public AuthController(UserRepo userRepo) {
        this.userRepo = userRepo;
    }

    @PostMapping("/register")
    public ApiResp<Map<String, Object>> register(@RequestBody Map<String, Object> body) {
        String username = (String) body.getOrDefault("username", "");
        String password = (String) body.getOrDefault("password", "");
        String name = (String) body.getOrDefault("name", "");
        Integer avatarIndex = (Integer) body.getOrDefault("avatarIndex", 1);

        if (username.isBlank() || password.isBlank() || name.isBlank()) {
            return ApiResp.fail("请输入完整信息");
        }
        if (userRepo.findByUsername(username).isPresent()) {
            return ApiResp.fail("用户名已存在");
        }

        UserEntity u = new UserEntity();
        u.id = "u_" + UUID.randomUUID();   //生成 string id，迎合前端
        u.username = username;
        u.password = password;
        u.name = name;
        u.avatarIndex = avatarIndex;
        u.bio = "";

        userRepo.save(u);

        return ApiResp.ok(Map.of("user", Map.of(
                "id", u.id,
                "username", u.username,
                "name", u.name,
                "avatarIndex", u.avatarIndex
        )));
    }

    @PostMapping("/login")
    public ApiResp<Map<String, Object>> login(@RequestBody Map<String, Object> body) {
        String username = (String) body.getOrDefault("username", "");
        String password = (String) body.getOrDefault("password", "");

        Optional<UserEntity> found = userRepo.findByUsernameAndPassword(username, password);
        if (found.isEmpty()) {
            return ApiResp.fail("用户名或密码错误");
        }
        UserEntity u = found.get();
        return ApiResp.ok(Map.of("user", Map.of(
                "id", u.id,
                "username", u.username,
                "name", u.name,
                "avatarIndex", u.avatarIndex
        )));
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("ok", true);
    }
}
