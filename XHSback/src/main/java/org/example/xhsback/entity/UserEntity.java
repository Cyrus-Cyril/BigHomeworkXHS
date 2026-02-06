// src/main/java/org/example/xhsback/entity/UserEntity.java
package org.example.xhsback.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class UserEntity {
    @Id
    @Column(length = 64)
    public String id;

    @Column(nullable = false, unique = true, length = 64)
    public String username;

    @Column(nullable = false, length = 128)
    public String password;

    @Column(nullable = false, length = 64)
    public String name;

    @Column(name = "avatar_index", nullable = false)
    public Integer avatarIndex;

    @Column(length = 255)
    public String bio;
}
