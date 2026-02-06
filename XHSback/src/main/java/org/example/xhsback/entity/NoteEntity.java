// src/main/java/org/example/xhsback/entity/NoteEntity.java
package org.example.xhsback.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "notes")
public class NoteEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Integer id;

    @Column(nullable = false, length = 200)
    public String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    public String content;

    @Column(name = "author_id", nullable = false, length = 64)
    public String authorId;

    @Column(name = "author_name", nullable = false, length = 64)
    public String authorName;

    @Column(name = "author_avatar", nullable = false)
    public Integer authorAvatar;

    @Column(name = "created_at", nullable = false)
    public Long createdAt;
}
