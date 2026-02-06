// src/main/java/org/example/xhsback/repo/CommentRepo.java
package org.example.xhsback.repo;

import org.example.xhsback.entity.CommentEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommentRepo extends JpaRepository<CommentEntity, Integer> {
    List<CommentEntity> findByNoteIdOrderByIdAsc(Integer noteId);
}
