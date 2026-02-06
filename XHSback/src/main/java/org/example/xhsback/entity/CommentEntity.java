// src/main/java/org/example/xhsback/entity/CommentEntity.java
package org.example.xhsback.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "comments")
public class CommentEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Integer id;

    @Column(name = "note_id", nullable = false)
    public Integer noteId;

    @Column(name = "author_id", nullable = false, length = 64)
    public String authorId;

    @Column(name = "author_name", nullable = false, length = 64)
    public String authorName;

    @Column(nullable = false, columnDefinition = "TEXT")
    public String content;

    @Column(name = "like_count", nullable = false)
    public Integer likeCount;

    @Column(name = "created_at", nullable = false)
    public Long createdAt;
}
