// src/main/java/org/example/xhsback/controller/NoteController.java
package org.example.xhsback.controller;

import org.example.xhsback.entity.NoteEntity;
import org.example.xhsback.entity.UserEntity;
import org.example.xhsback.repo.NoteRepo;
import org.example.xhsback.repo.UserRepo;
import org.springframework.web.bind.annotation.*;

import java.io.Serializable;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin
public class NoteController {
    private final NoteRepo noteRepo;
    private final UserRepo userRepo;

    public NoteController(NoteRepo noteRepo, UserRepo userRepo) {
        this.noteRepo = noteRepo;
        this.userRepo = userRepo;
    }

    @GetMapping("/notes")
    public ApiResp<List<Map<String, Object>>> listNotes() {
        List<NoteEntity> list = noteRepo.findAllByOrderByIdDesc();

        List<Map<String, Object>> data = list.stream()
                .map(n -> Map.<String, Object>of(
                        "id", n.id,
                        "title", n.title,
                        "content", n.content,
                        "createdAt", n.createdAt,
                        "authorId", n.authorId,
                        "authorName", n.authorName,
                        "avatarIndex", n.authorAvatar
                ))
                .toList();

        return ApiResp.ok(data);

    }

    @PostMapping("/notes")
    public ApiResp<Map<String, Object>> createNote(@RequestBody Map<String, Object> body) {
        String title = (String) body.getOrDefault("title", "无标题");
        String content = (String) body.getOrDefault("content", "");
        String authorId = (String) body.getOrDefault("authorId", "me"); // ✅ string

        Optional<UserEntity> u = userRepo.findById(authorId);
        if (u.isEmpty()) {
            return ApiResp.fail("authorId 不存在");
        }

        UserEntity user = u.get();
        NoteEntity n = new NoteEntity();
        n.title = title;
        n.content = content;
        n.authorId = user.id;
        n.authorName = user.name;
        n.authorAvatar = user.avatarIndex;
        n.createdAt = System.currentTimeMillis();

        noteRepo.save(n);
        return ApiResp.ok(Map.of("id", n.id));
    }
}
