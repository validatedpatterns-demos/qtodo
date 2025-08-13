package org.fictional.qtodo;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

/**
 * REST endpoint for managing To-do items.
 * Provides CRUD operations and interacts with the database via Panache.
 */
@Path("/api/todos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TodoRestEndpoint {

    /**
     * Retrieves all to-do items from the database.
     * @return A list of all Todo entities.
     */
    @GET
    public List<TodoEntity> getAll() {
        return TodoEntity.listAll();
    }

    /**
     * Adds a new to-do item to the database.
     * @param todo The new Todo item to create.
     * @return The created Todo item with its generated ID.
     */
    @POST
    @Transactional
    public Response create(TodoEntity te) {
        TodoEntity.persist(te);
        return Response.ok(te).status(Response.Status.CREATED).build();
    }

    /**
     * Deletes a to-do item by its ID.
     * @param id The ID of the item to delete.
     * @return A no-content response.
     */
    @DELETE
    @Path("/{id}")
    @Transactional
    public Response delete(@PathParam("id") long id) {
        if (TodoEntity.deleteById(id)) {
            return Response.noContent().build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }
}
