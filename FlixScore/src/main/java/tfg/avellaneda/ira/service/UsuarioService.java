package tfg.avellaneda.ira.service;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.google.cloud.firestore.DocumentSnapshot;

import tfg.avellaneda.ira.model.ModeloUsuario;
import tfg.avellaneda.ira.repositories.UsuarioRepository;

/**
 * Service REST para gestionar los usuarios.
 * * @author Israel
 */
@Service
public class UsuarioService {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    private final UsuarioRepository repo;

    // Inyección de dependencias por constructor
    public UsuarioService(UsuarioRepository repo) {
        this.repo = repo;
    }

    /**
     * Obtiene todos los usuarios.
     * 
     * @return Lista de todos los ModeloUsuario.
     * @throws RuntimeException si la operación falla.
     */
    public List<ModeloUsuario> getAll() {
        try {
            return repo.getAll()
                    .get() // Espera la finalización del Future/Task
                    .toObjects(ModeloUsuario.class);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); // Restaurar el estado de interrupción
            logger.error("Error (Interrupción) al obtener los usuarios: {}", e.getMessage());
            // Usamos RuntimeException, que no necesita ser declarada
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener los usuarios: {}", e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    /**
     * Obtiene un usuario por ID.
     * 
     * @param usuarioId El ID del usuario.
     * @return Un Optional que contiene ModeloUsuario si existe.
     * @throws RuntimeException si la operación falla.
     */
    public Optional<ModeloUsuario> getUsuarioById(String documentID) {
        try {
            DocumentSnapshot document = repo.getUsuarioById(documentID).get();

            if (document.exists()) {
                return Optional.ofNullable(document.toObject(ModeloUsuario.class));
            } else {
                return Optional.empty(); // Usuario no encontrado
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener el usuario {}: {}", documentID , e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener el usuario {}: {}", documentID, e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    /**
     * Obtiene usuarios por nick.
     * 
     * @param nick El nick del usuario a buscar.
     * @return Lista de ModeloUsuario que coinciden con el nick.
     * @throws RuntimeException si la operación falla.
     */
    public List<ModeloUsuario> getUsuarioByNick(String nick) {
        try {
            return repo.getUsuarioByNick(nick)
                    .get()
                    .toObjects(ModeloUsuario.class);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener el usuario por nick {}: {}", nick, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener el usuario por nick {}: {}", nick, e.getMessage());
            throw new RuntimeException("Fallo en la comunicación con la base de datos.", e.getCause());
        }
    }

    /**
     * Elimina un usuario por ID.
     * 
     * @param usuarioId El ID del usuario a eliminar.
     * @throws RuntimeException si la operación falla.
     */
    public void deleteUsuario(String usuarioId) {
        try {
            repo.deleteUsuario(usuarioId).get();
            logger.info("Usuario eliminado correctamente: {}", usuarioId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al eliminar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al eliminar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Fallo al eliminar el usuario.", e.getCause());
        }
    }

    /**
     * Añade un nuevo usuario.
     * 
     * @param entity El ModeloUsuario a añadir.
     * @return El ModeloUsuario creado (incluyendo el ID generado por la DB).
     * @throws RuntimeException si la operación falla.
     */
    public ModeloUsuario addUsuario(ModeloUsuario entity) {
        try {
            // 1. Obtiene la referencia al documento recién creado
            var docRef = repo.addUsuario(entity).get();

            // 2. Lee el documento de vuelta para obtener el objeto completo, incluyendo el
            // ID
            var document = docRef.get().get();

            if (document.exists()) {
                ModeloUsuario creado = document.toObject(ModeloUsuario.class);
                logger.info("Usuario añadido correctamente con ID: {}", creado.getDocumentID());
                return creado;
            } else {
                logger.error("Usuario añadido pero no se pudo recuperar el documento: {}", entity);
                throw new RuntimeException("El usuario fue añadido, pero el documento no se pudo recuperar.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al añadir el usuario: {}", e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al añadir el usuario: {}", e.getMessage());
            throw new RuntimeException("Fallo al añadir el usuario.", e.getCause());
        }
    }

    /**
     * Actualiza un usuario.
     * 
     * @param usuarioId El ID del usuario a actualizar.
     * @param usuario   El ModeloUsuario con los datos a actualizar.
     * @throws RuntimeException si la operación falla.
     */
    public void updateUsuario(String usuarioId, ModeloUsuario usuario) {
        try {
            repo.updateUsuario(usuarioId, usuario).get();
            logger.info("Usuario actualizado correctamente: {}", usuarioId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al actualizar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al actualizar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Fallo al actualizar el usuario.", e.getCause());
        }
    }
}