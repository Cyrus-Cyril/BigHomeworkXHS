// src/main/java/org/example/xhsback/repo/NoteRepo.java
package org.example.xhsback.repo;

import org.example.xhsback.entity.NoteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NoteRepo extends JpaRepository<NoteEntity, Integer> {
    List<NoteEntity> findAllByOrderByIdDesc();
}
