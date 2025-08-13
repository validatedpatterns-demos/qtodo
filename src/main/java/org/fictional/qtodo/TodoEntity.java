package org.fictional.qtodo;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Entity;

/**
 * A simple JPA entity representing a to-do item.
 * We use PanacheEntity for a simplified, active-record-style
 * interaction with the database.
 */
@Entity
public class TodoEntity extends PanacheEntity {

    // The title of the to-do item
    public String title;

    // The status of the to-do item (e.g., true for completed, false for active)
    public boolean completed;

    /**
     * Default constructor for JPA.
     */
    public TodoEntity() {
    }

    /**
     * Constructor to create a new to-do item.
     * @param title The title of the to-do item.
     * @param completed The initial completion status.
     */
    public TodoEntity(String title, boolean completed) {
        this.title = title;
        this.completed = completed;
    }
}
