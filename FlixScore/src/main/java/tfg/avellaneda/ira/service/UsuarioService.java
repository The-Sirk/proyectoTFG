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
 * 
 * @author Adrián
 *         Se hacen modificaciones para añadir validaciones
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
     * * @return Lista de todos los ModeloUsuario.
     * 
     * @throws RuntimeException si la operación falla.
     */
    public List<ModeloUsuario> getAll() {
        try {
            return repo.listarUsuarios()
                    .get() // Espera la finalización del Future/Task
                    .toObjects(ModeloUsuario.class);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener los usuarios: {}", e.getMessage());
            throw new RuntimeException("Error en el servidor: Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener los usuarios: {}", e.getMessage());
            throw new RuntimeException("No se pudo obtener la lista de usuarios.",
                    e.getCause());
        }
    }

    /**
     * Obtiene un usuario por documentId.
     * * @param documentID El ID del usuario.
     * 
     * @return Un Optional que contiene ModeloUsuario si existe.
     * @throws RuntimeException si la operación falla.
     */
    public Optional<ModeloUsuario> getUsuarioById(String documentID) {
        try {
            DocumentSnapshot document = repo.getUsuarioById(documentID).get();

            if (document.exists()) {
                // El documentID se asigna automáticamente con @DocumentId en el modelo
                return Optional.ofNullable(document.toObject(ModeloUsuario.class));
            } else {
                return Optional.empty(); // Usuario no encontrado
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al obtener el usuario {}: {}", documentID, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al obtener el usuario {}: {}", documentID, e.getMessage());
            throw new RuntimeException("No se pudo obtener el usuario con documentID " + documentID,
                    e.getCause());
        }
    }

    /**
     * Obtiene usuarios por nick.
     * * @param nick El nick del usuario a buscar.
     * 
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
            throw new RuntimeException("No se pudo obtener el usuario con nick " + nick,
                    e.getCause());
        }
    }

    /**
     * Elimina un usuario por ID.
     * * @param usuarioId El ID del usuario a eliminar.
     * 
     * @return true si la eliminación fue exitosa, false si el usuario no existía.
     * @throws RuntimeException si la operación falla.
     */
    public boolean deleteUsuario(String usuarioId) {
        try {
            // Se comprueba si el usuario existe antes de intentar eliminar
            DocumentSnapshot document = repo.getUsuarioById(usuarioId).get();
            if (!document.exists()) {
                logger.warn("Intento de eliminar usuario no existente: {}", usuarioId);
                return false; // Usuario no encontrado, se devuelve false
            }

            // Realiza la eliminación
            repo.deleteUsuario(usuarioId).get();
            logger.info("Usuario eliminado correctamente: {}", usuarioId);
            return true; // Eliminación exitosa, se devuelve true
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al eliminar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al eliminar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Fallo al eliminar el usuario con ID " + usuarioId, e.getCause());
        }
    }

    /**
     * Añade un nuevo usuario.
     * * @param entity El ModeloUsuario a añadir.
     * 
     * @return El ModeloUsuario creado (incluyendo el ID generado por la DB).
     * @throws RuntimeException si la operación falla o si el nick ya existe.
     */
    public ModeloUsuario addUsuario(ModeloUsuario entity) {
        try {
            // Usamos el método existente para buscar el nick.
            List<ModeloUsuario> usuariosExistentes = getUsuarioByNick(entity.getNick());

            if (!usuariosExistentes.isEmpty()) {
                logger.warn("Intento de registro con nick duplicado: {}", entity.getNick());
                throw new RuntimeException("Conflicto: El nick '" + entity.getNick() + "' ya se encuentra registrado.");
            }

            // Proceso de registro solo si el nick es único
            // Obtiene la referencia al documento recién creado
            var docRef = repo.addUsuario(entity).get();

            // Lee el documento de vuelta para obtener el objeto completo, incluyendo el
            // documentId
            var document = docRef.get().get();

            if (document.exists()) {
                ModeloUsuario creado = document.toObject(ModeloUsuario.class);
                logger.info("Usuario añadido correctamente con ID: {}", creado.getDocumentID());
                return creado;
            } else {
                logger.error("Usuario añadido pero no se pudo recuperar el documento: {}", entity);
                throw new RuntimeException(
                        "Error al crear usuario: el documento se creó, pero no se pudo recuperar de Firestore.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al añadir el usuario: {}", e.getMessage());
            throw new RuntimeException("Error en el servidor: Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al añadir el usuario: {}", e.getMessage());
            throw new RuntimeException("Error de base de datos: Fallo al añadir el usuario.", e.getCause());
        }
    }

    /**
     * Actualiza un usuario.
     * * @param usuarioId El ID del usuario a actualizar.
     * 
     * @param usuario El ModeloUsuario con los datos a actualizar.
     * @throws RuntimeException si la operación falla, si el usuario no existe, o si
     *                          el nick está duplicado.
     */
    public void updateUsuario(String usuarioId, ModeloUsuario usuario) {
        try {
            // Comprobamos su existencia
            DocumentSnapshot document = repo.getUsuarioById(usuarioId).get();
            if (!document.exists()) {
                logger.warn("Intento de actualizar usuario no existente: {}", usuarioId);
                throw new RuntimeException("Actualización fallida: No se encontró el usuario con ID " + usuarioId);
            }

            // Comprobamos que el nick no esté duplicado
            List<ModeloUsuario> usuariosExistentesConMismoNick = getUsuarioByNick(usuario.getNick());

            // Si encontramos algún usuario con el mismo nick verificamos que el usuario
            // encontrado no sea el mismo que estamos actualizando
            if (!usuariosExistentesConMismoNick.isEmpty()) {
                boolean esMismoUsuario = usuariosExistentesConMismoNick.stream()
                        .anyMatch(u -> usuarioId.equals(u.getDocumentID()));

                // Si encontramos que hay un usuario con el mismo nick y es otro usuario
                if (!esMismoUsuario) {
                    logger.warn("Intento de actualizar usuario {} con nick duplicado: {}", usuarioId,
                            usuario.getNick());
                    throw new RuntimeException("Conflicto: El nick '" + usuario.getNick()
                            + "' ya está siendo utilizado por otro usuario.");
                }
            }

            repo.updateUsuario(usuarioId, usuario).get();
            logger.info("Usuario actualizado correctamente: {}", usuarioId);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error (Interrupción) al actualizar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Error en el servidor: Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            logger.error("Error (Ejecución) al actualizar el usuario {}: {}", usuarioId, e.getMessage());
            throw new RuntimeException("Error de base de datos: Fallo al actualizar el usuario con ID " + usuarioId,
                    e.getCause());
        }
    }
}