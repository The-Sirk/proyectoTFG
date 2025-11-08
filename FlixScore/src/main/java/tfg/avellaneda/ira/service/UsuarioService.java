package tfg.avellaneda.ira.service;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

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

    /**
     * Calcula el número de amigos que tienen en común dos usuarios (documentIDs).
     *
     * @param usuarioPrincipalId El ID del primer usuario (documentID).
     * @param usuarioAmigoId     El ID del amigo con el que se compara (documentID).
     * @return Optional que emite un Integer con el número de amigos mutuos si ambos
     *         usuarios existen.
     */
    public Optional<Integer> contarAmigosEnComun(String usuarioPrincipalId, String usuarioAmigoId) {
        Optional<ModeloUsuario> optionalPrincipal = getUsuarioById(usuarioPrincipalId);
        Optional<ModeloUsuario> optionalAmigo = getUsuarioById(usuarioAmigoId);
        return optionalPrincipal.flatMap(principal -> optionalAmigo.map(amigo -> {

            // Obtener las listas de amigos
            List<String> principalFriendsList = (principal.getAmigos_id() != null)
                    ? principal.getAmigos_id()
                    : List.of();

            List<String> amigoFriendsList = (amigo.getAmigos_id() != null)
                    ? amigo.getAmigos_id()
                    : List.of();

            // Convertir a Set para una intersección eficiente
            Set<String> principalSet = new HashSet<>(principalFriendsList);
            Set<String> amigoSet = new HashSet<>(amigoFriendsList);

            // Encontrar amigos en común
            principalSet.retainAll(amigoSet);

            // Excluir a los dos usuarios que estamos comparando de la cuenta final
            principalSet.remove(usuarioPrincipalId);
            principalSet.remove(usuarioAmigoId);

            // Devolver la cantidad de amigos mutuos restantes
            return principalSet.size();

        }));

    }

    /**
     * Añade un usuario a la lista de amigos de otro.
     * 
     * @param usuarioPrincipalId El ID del usuario que añade el amigo.
     * @param usuarioAmigoId     El ID del usuario que será añadido como amigo.
     * @throws RuntimeException si alguno de los usuarios no existe.
     */
    public void addAmigo(String usuarioPrincipalId, String usuarioAmigoId) {
        if (usuarioPrincipalId.equals(usuarioAmigoId)) {
            logger.warn("El usuario {} intentó añadirse a sí mismo como amigo.", usuarioPrincipalId);
            throw new IllegalArgumentException("No puedes añadirte a ti mismo como amigo.");
        }

        // Obtener ambos usuarios. Lanza excepción si no se encuentran
        ModeloUsuario principal = getUsuarioById(usuarioPrincipalId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + usuarioPrincipalId));
        ModeloUsuario amigo = getUsuarioById(usuarioAmigoId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + usuarioAmigoId));

        // Modificar lista y actualizar
        try {
            ensureAmigoAdded(usuarioPrincipalId, principal, usuarioAmigoId);
            logger.info("Amistad agregada (o ya existente) entre {} y {}.", usuarioPrincipalId, usuarioAmigoId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Error de interrupción al añadir amigo.", e);
        } catch (ExecutionException e) {
            throw new RuntimeException("Error de ejecución al añadir amigo.", e.getCause());
        }
    }

    /**
     * Lógica interna para asegurar que un amigo está en la lista y actualizar
     * Firestore.
     */
    private void ensureAmigoAdded(String userId, ModeloUsuario user, String friendId)
            throws InterruptedException, ExecutionException {
        List<String> currentFriends = user.getAmigos_id() != null ? user.getAmigos_id() : List.of();

        if (currentFriends.contains(friendId)) {
            return; // Ya son amigos
        }

        List<String> updatedFriends = new java.util.ArrayList<>(currentFriends);
        updatedFriends.add(friendId);

        ModeloUsuario updatedUser = new ModeloUsuario(user);
        updatedUser.setAmigos_id(updatedFriends);

        repo.updateUsuario(userId, updatedUser).get();
    }

    /**
     * Elimina un usuario de la lista de amigos de otro.
     * 
     * @throws RuntimeException si la amistad no existía o el usuario no existe.
     */
    public void removeAmigo(String usuarioPrincipalId, String usuarioAmigoId) {

        // Obtener ambos usuarios. Lanza excepción si no se encuentran.
        ModeloUsuario principal = getUsuarioById(usuarioPrincipalId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + usuarioPrincipalId));
        ModeloUsuario amigo = getUsuarioById(usuarioAmigoId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + usuarioAmigoId));

        // Modificar la lista de amigos
        try {
            boolean removedPrincipal = ensureAmigoRemoved(usuarioPrincipalId, principal, usuarioAmigoId);

            if (!removedPrincipal) {
                // Si la amistad no existía, lanzamos error para que el Controller lo mapee a
                // 404
                throw new RuntimeException("Amistad no existente entre " + usuarioPrincipalId + " y " + usuarioAmigoId);
            }
            logger.info("Amistad eliminada entre {} y {}.", usuarioPrincipalId, usuarioAmigoId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Error de interrupción al eliminar amigo.", e);
        } catch (ExecutionException e) {
            throw new RuntimeException("Error de ejecución al eliminar amigo.", e.getCause());
        }
    }

    /**
     * Lógica interna para asegurar que un amigo no está en la lista y actualizar
     * Firestore.
     */
    private boolean ensureAmigoRemoved(String userId, ModeloUsuario user, String friendId)
            throws InterruptedException, ExecutionException {
        List<String> currentFriends = user.getAmigos_id() != null ? user.getAmigos_id() : List.of();

        if (!currentFriends.contains(friendId)) {
            return false; // No estaba en la lista
        }

        List<String> updatedFriends = currentFriends.stream()
                .filter(id -> !id.equals(friendId))
                .collect(Collectors.toList());

        ModeloUsuario updatedUser = new ModeloUsuario(user);
        updatedUser.setAmigos_id(updatedFriends);

        repo.updateUsuario(userId, updatedUser).get();
        return true; // Eliminado exitosamente
    }

    /**
     * Cambia únicamente el nick de un usuario si no existe otro usuario con el
     * mismo nick.
     *
     * @param usuarioId ID del usuario a actualizar.
     * @param nuevoNick Nuevo nick deseado.
     * @throws RuntimeException si el usuario no existe, si el nick ya lo tiene otro
     *                          usuario, o si hay un error de base de datos.
     */
    public void cambiarNick(String usuarioId, String nuevoNick) {
        try {
            // Comprobar que el usuario existe
            DocumentSnapshot doc = repo.getUsuarioById(usuarioId).get();
            if (!doc.exists()) {
                logger.warn("Intento de cambiar nick a usuario inexistente: {}", usuarioId);
                throw new RuntimeException("Usuario no encontrado con ID: " + usuarioId);
            }

            // Comprobar que el nuevo nick no esté ya en uso por otro usuario
            List<ModeloUsuario> usuariosMismoNick = getUsuarioByNick(nuevoNick);
            boolean ocupadoPorOtro = usuariosMismoNick.stream()
                    .anyMatch(u -> !u.getDocumentID().equals(usuarioId));
            if (ocupadoPorOtro) {
                logger.warn("Intento de cambiar nick duplicado: {}", nuevoNick);
                throw new RuntimeException("Conflicto: El nick '" + nuevoNick + "' ya está en uso.");
            }

            // Obtener el usuario actual y cambiar el nick
            ModeloUsuario usuario = doc.toObject(ModeloUsuario.class);
            usuario.setNick(nuevoNick);
            repo.updateUsuario(usuarioId, usuario).get();

            logger.info("Nick actualizado para el usuario {}: {}", usuarioId, nuevoNick);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Operación de base de datos interrumpida.", e);
        } catch (ExecutionException e) {
            throw new RuntimeException("Error al actualizar el nick en la base de datos.", e.getCause());
        }
    }
}