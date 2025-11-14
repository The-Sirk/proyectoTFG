package tfg.avellaneda.ira.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.ModeloUsuario;
import tfg.avellaneda.ira.service.UsuarioService;
import jakarta.validation.Valid;

/**
 * Controller REST para gestionar los usuarios.
 * 
 * @author Israel
 * @author Adrián
 *         Se hacen modificaciones para añadir validaciones y se renombran
 *         algunos endpoints para que sean autodescriptivos.
 */

@RestController
@RequestMapping("/api/v1/usuarios")
@Tag(name = "Usuarios", description = "Gestión de usuarios y sus perfiles")
public class UsuarioController {

        @Autowired
        UsuarioService usuarioService;

        /**
         * Devuelve todos los usuarios
         * 
         * @return Un Flux que emite una lista de ModeloUsuario.
         *         Devuelve HTTP 200 OK si es exitoso.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Obtiene todos los usuarios", description = "Devuelve una lista de todos los usuarios registrados.", responses = {
                        @ApiResponse(responseCode = "200", description = "Lista de usuarios obtenida exitosamente. Puede ser una lista vacía.", content = @Content(schema = @Schema(implementation = ModeloUsuario.class))),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor o de la base de datos.")
        })
        @GetMapping
        @ResponseStatus(HttpStatus.OK)
        public Flux<ModeloUsuario> getAll() {
                return Mono.fromCallable(() -> usuarioService.getAll())
                                .flatMapMany(Flux::fromIterable)
                                .onErrorResume(RuntimeException.class, e -> {
                                        return Flux.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Permite la búsqueda de un usuario por su documentId
         * 
         * @param documentId documentId del usuario buscado
         * @return Un Mono que envuelve un ResponseEntity de ModeloUsuario.
         *         Devuelve HTTP 200 OK con el objeto ModeloUsuario si es encontrado.
         *         Devuelve HTTP 404 NOT FOUND si el usuario no existe.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Busca un usuario por su documentID", description = "Busca y devuelve un usuario si su ID existe.", responses = {
                        @ApiResponse(responseCode = "200", description = "Usuario encontrado exitosamente.", content = @Content(schema = @Schema(implementation = ModeloUsuario.class))),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @GetMapping("/{documentId}")
        public Mono<ResponseEntity<ModeloUsuario>> getUsuarioByID(
                        @Parameter(description = "ID del usuario a buscar.") @PathVariable String documentId) {
                return Mono.fromCallable(() -> usuarioService.getUsuarioById(documentId))
                                .filter(java.util.Optional::isPresent)
                                .map(java.util.Optional::get)
                                .map(ResponseEntity::ok)
                                .defaultIfEmpty(ResponseEntity.notFound().build())
                                .onErrorResume(RuntimeException.class, e -> {
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Permite buscar un usuario por su "Nick"
         * 
         * @param nick Nick del usuario buscado
         * @return Un Flux que emite una secuencia de cero o más objetos ModeloUsuario
         *         que coincidan con el nick.
         *         Devuelve HTTP 200 OK si es exitoso (lista vacía [] si no se
         *         encuentran coincidencias).
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Busca usuarios por Nick", description = "Busca el usuario cuyo nick coincida con el parámetro.", responses = {
                        @ApiResponse(responseCode = "200", description = "Búsqueda exitosa. Devuelve una lista (puede ser vacía).", content = @Content(schema = @Schema(implementation = ModeloUsuario.class))),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @GetMapping("/nick/{nick}")
        public Flux<ModeloUsuario> getByNick(
                        @Parameter(description = "Nick del usuario a buscar. La búsqueda es sensible a mayúsculas/minúsculas.") @PathVariable String nick) {
                return Mono.fromCallable(() -> usuarioService.getUsuarioByNick(nick))
                                .flatMapMany(Flux::fromIterable)
                                .onErrorResume(RuntimeException.class, e -> {
                                        return Flux.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Permite crear un usuario, incluye validación en su correo electrónico
         * 
         * @param usuario El objeto ModeloUsuario a crear, validado con @Valid.
         * @return Un Mono que emite el objeto ModeloUsuario creado (incluyendo el
         *         documentID asignado por la DB).
         *         Devuelve HTTP 201 CREATED si el usuario es creado exitosamente.
         *         Devuelve HTTP 400 BAD REQUEST si falla la validación del campo
         *         'correo'.
         *         Devuelve HTTP 409 CONFLICT si el nick ya está registrado.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Registra un nuevo usuario", description = "Crea un nuevo usuario y comprueba que no exista su nick y el formato del correo.", responses = {
                        @ApiResponse(responseCode = "201", description = "Usuario creado exitosamente.", content = @Content(schema = @Schema(implementation = ModeloUsuario.class))),
                        @ApiResponse(responseCode = "400", description = "Correo electrónico no válido."),
                        @ApiResponse(responseCode = "409", description = "Conflicto: El nick ya está en uso."),
                        @ApiResponse(responseCode = "500", description = "Error al guardar en la base de datos.")
        })
        @PostMapping("/crearUsuario")
        @ResponseStatus(HttpStatus.CREATED)
        public Mono<ModeloUsuario> addUsuario(@Valid @RequestBody ModeloUsuario usuario) {
                return Mono.fromCallable(() -> usuarioService.addUsuario(usuario))
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null && e.getMessage().startsWith("Conflicto: El nick")) {
                                                return Mono.error(new ResponseStatusException(
                                                                HttpStatus.CONFLICT, e.getMessage(), e));
                                        }
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Permite la modificación de un Usuario con el documentId dado.
         * 
         * @param documentId El ID del usuario a actualizar, obtenido de la URL.
         * @param usuario    El objeto ModeloUsuario con los nuevos datos, validado
         *                   con @Valid.
         * @return Un Mono que envuelve un ResponseEntity vacío (<Void>).
         *         Devuelve HTTP 204 NO CONTENT si el usuario es actualizado
         *         exitosamente.
         *         Devuelve HTTP 400 BAD REQUEST si falla la validación del campo
         *         'correo' (u otro campo validado).
         *         Devuelve HTTP 404 NOT FOUND si no se encuentra el usuario con el ID
         *         proporcionado.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Actualiza un usuario existente", description = "Permite modificar un usuario por su documentID, validando los campos y que el nick sea único.", responses = {
                        @ApiResponse(responseCode = "204", description = "Usuario actualizado exitosamente (No Content)."),
                        @ApiResponse(responseCode = "400", description = "Error de validación: correo electrónico no válido o campos faltantes."),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado."),
                        @ApiResponse(responseCode = "409", description = "Conflicto: El nuevo nick ya está en uso por otro usuario."),
                        @ApiResponse(responseCode = "500", description = "Error al actualizar en la base de datos.")
        })
        @PutMapping("/editarUsuario/{documentId}")
        public Mono<ResponseEntity<Void>> updateUsuario(
                        @Parameter(description = "documentId del usuario a actualizar.") @PathVariable String documentId,
                        @Valid @RequestBody ModeloUsuario usuario) {
                return Mono.fromCallable(() -> {
                        usuarioService.updateUsuario(documentId, usuario);
                        return ResponseEntity.noContent().<Void>build();
                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null && e.getMessage()
                                                        .contains("Actualización fallida: No se encontró")) {
                                                return Mono.just(ResponseEntity.notFound().build());
                                        }
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Elimina el usuario con el documentId proporcionado
         * 
         * @param documentId El ID del usuario a eliminar, obtenido de la URL.
         * @return Un Mono que envuelve un ResponseEntity con un mensaje de String.
         *         Devuelve HTTP 200 OK con un mensaje de confirmación si el usuario fue
         *         eliminado exitosamente.
         *         Devuelve HTTP 404 NOT FOUND si no se encontró el usuario con el ID
         *         proporcionado.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo en la base
         *         de datos o en el servidor.
         */
        @Operation(summary = "Elimina un usuario por su documentID", description = "Elimina el usuario si el ID existe y devuelve un mensaje de confirmación.", responses = {
                        @ApiResponse(responseCode = "200", description = "Usuario eliminado exitosamente.", content = @Content(schema = @Schema(implementation = String.class))),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado para eliminar."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @DeleteMapping("/{documentId}")
        public Mono<ResponseEntity<String>> deleteUsuario(
                        @Parameter(description = "ID del usuario a eliminar.") @PathVariable String documentId) {
                return Mono.fromCallable(() -> usuarioService.deleteUsuario(documentId))
                                .map(deleted -> {
                                        if (deleted) {
                                                return ResponseEntity.ok(
                                                                "Usuario " + documentId + " eliminado exitosamente.");
                                        } else {
                                                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                                                                .body("No se encontró el usuario con ID " + documentId
                                                                                + " para eliminar.");
                                        }
                                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Calcula el número de amigos que tienen en común dos usuarios.
         * * @param usuarioPrincipalId El ID del primer usuario.
         * 
         * @param usuarioAmigoId El ID del segundo usuario a comparar.
         * @return Un Mono que envuelve un ResponseEntity con el número de amigos
         *         comunes.
         *         Devuelve HTTP 200 OK con el conteo si ambos usuarios existen.
         *         Devuelve HTTP 404 NOT FOUND si alguno de los usuarios no existe.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo interno.
         */
        @Operation(summary = "Cuenta amigos en común", description = "Devuelve el número de amigos en común entre dos usuarios. Excluye a los dos usuarios de la cuenta.", responses = {
                        @ApiResponse(responseCode = "200", description = "Conteo de amigos en común exitoso.", content = @Content(schema = @Schema(implementation = Integer.class))),
                        @ApiResponse(responseCode = "404", description = "Uno o ambos usuarios no fueron encontrados."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @GetMapping("/amigosEnComun/{usuarioPrincipalId}/{usuarioAmigoId}")
        public Mono<ResponseEntity<Integer>> contarAmigosComun(
                        @Parameter(description = "ID del usuario principal.") @PathVariable String usuarioPrincipalId,
                        @Parameter(description = "ID del amigo para buscar amigos en común.") @PathVariable String usuarioAmigoId) {

                return Mono.fromCallable(() -> usuarioService.contarAmigosEnComun(usuarioPrincipalId, usuarioAmigoId))
                                .map(optionalCount -> {
                                        if (optionalCount.isPresent()) {
                                                // Si ambos usuarios existen se devuelve 200 OK
                                                return ResponseEntity.ok(optionalCount.get());
                                        } else {
                                                return ResponseEntity.notFound().<Integer>build();
                                        }
                                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        // Manejo de errores generales (500 Internal Server Error)
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR,
                                                        "Error al calcular amigos en común: " + e.getMessage(), e));
                                });
        }

        /**
         * Añade un usuario a la lista de amigos de otro.
         * * @param usuarioPrincipalId El ID del usuario que envía la solicitud/añade el
         * amigo.
         * 
         * @param usuarioAmigoId El ID del usuario que será añadido como amigo.
         * @return Un Mono que envuelve un ResponseEntity vacío.
         *         Devuelve HTTP 204 NO CONTENT si la relación es creada/actualizada con
         *         éxito.
         *         Devuelve HTTP 404 NOT FOUND si alguno de los usuarios no existe.
         *         Devuelve HTTP 409 CONFLICT si la amistad ya existe.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo interno.
         */
        @Operation(summary = "Añadir un amigo", description = "Crea la relación de amistad entre dos usuarios. Si ya existe, devuelve 204.", responses = {
                        @ApiResponse(responseCode = "204", description = "Amistad agregada o ya existente (No Content)."),
                        @ApiResponse(responseCode = "404", description = "Uno o ambos usuarios no fueron encontrados."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @PostMapping("/agregarAmigo/{usuarioPrincipalId}/{usuarioAmigoId}")
        @ResponseStatus(HttpStatus.NO_CONTENT)
        public Mono<ResponseEntity<Void>> addAmigo(
                        @Parameter(description = "ID del usuario principal.") @PathVariable String usuarioPrincipalId,
                        @Parameter(description = "ID del usuario a añadir como amigo.") @PathVariable String usuarioAmigoId) {

                return Mono.fromCallable(() -> {
                        usuarioService.addAmigo(usuarioPrincipalId, usuarioAmigoId);
                        return ResponseEntity.noContent().<Void>build();
                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null
                                                        && e.getMessage().contains("Usuario no encontrado")) {
                                                return Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
                                        } else if (e.getMessage() != null
                                                        && e.getMessage().contains(("No puedes añadirte"))) {
                                                return Mono.error(new ResponseStatusException(HttpStatus.CONFLICT, "No te añadas tu mismo triste"));
                                        }
                                        // Manejo de otros posibles errores, como si ya son amigos (que idealmente el
                                        // servicio manejaría sin error si se considera idempotente).
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR,
                                                        "Error al añadir amigo: " + e.getMessage(), e));
                                });
        }

        /**
         * Elimina un usuario de la lista de amigos de otro.
         * * @param usuarioPrincipalId El ID del usuario del que se eliminará el amigo.
         * 
         * @param usuarioAmigoId El ID del usuario que será eliminado de la lista.
         * @return Un Mono que envuelve un ResponseEntity vacío.
         *         Devuelve HTTP 204 NO CONTENT si la relación fue eliminada con éxito.
         *         Devuelve HTTP 404 NOT FOUND si alguno de los usuarios no existe o la
         *         amistad no existía.
         *         Devuelve HTTP 500 INTERNAL SERVER ERROR si ocurre un fallo interno.
         */
        @Operation(summary = "Eliminar un amigo", description = "Elimina la relación de amistad entre dos usuarios.", responses = {
                        @ApiResponse(responseCode = "204", description = "Amistad eliminada exitosamente (No Content)."),
                        @ApiResponse(responseCode = "404", description = "Uno o ambos usuarios no fueron encontrados, o la amistad no existía."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @DeleteMapping("/eliminarAmigo/{usuarioPrincipalId}/{usuarioAmigoId}")
        @ResponseStatus(HttpStatus.NO_CONTENT)
        public Mono<ResponseEntity<Void>> removeAmigo(
                        @Parameter(description = "ID del usuario principal.") @PathVariable String usuarioPrincipalId,
                        @Parameter(description = "ID del amigo a eliminar.") @PathVariable String usuarioAmigoId) {

                return Mono.fromCallable(() -> {
                        usuarioService.removeAmigo(usuarioPrincipalId, usuarioAmigoId);
                        return ResponseEntity.noContent().<Void>build();
                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null && (e.getMessage().contains("Usuario no encontrado")
                                                        || e.getMessage().contains("Amistad no existente"))) {
                                                return Mono.just(ResponseEntity.notFound().build());
                                        }
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR,
                                                        "Error al eliminar amigo: " + e.getMessage(), e));
                                });
        }

        /**
         * Permite cambiar únicamente el nick de un usuario.
         *
         * @param documentId ID del usuario cuyo nick se quiere actualizar.
         * @param nuevoNick  Nuevo nick que se desea asignar.
         * @return Mono<ResponseEntity<Void>>
         *         Devuelve HTTP 204 si se actualizó.
         *         Devuelve HTTP 409 si el nick ya está en uso.
         *         Devuelve HTTP 404 si el usuario no existe.
         *         Devuelve HTTP 500 si hay un error interno.
         */
        @Operation(summary = "Cambiar el nick de un usuario", description = "Actualiza el nick de un usuario validando que no esté duplicado.", responses = {
                        @ApiResponse(responseCode = "204", description = "Nick actualizado exitosamente."),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado."),
                        @ApiResponse(responseCode = "409", description = "El nuevo nick ya está en uso."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @PatchMapping("/{documentId}/nick")
        public Mono<ResponseEntity<Void>> cambiarNick(
                        @Parameter(description = "ID del usuario") @PathVariable String documentId,
                        @RequestParam("Nick") String nuevoNick) {

                return Mono.fromCallable(() -> {
                        usuarioService.cambiarNick(documentId, nuevoNick);
                        return ResponseEntity.noContent().<Void>build();
                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null
                                                        && e.getMessage().contains("El nick ya está en uso")) {
                                                return Mono.just(ResponseEntity.status(HttpStatus.CONFLICT).build());
                                        }
                                        if (e.getMessage() != null
                                                        && e.getMessage().contains("Usuario no encontrado")) {
                                                return Mono.just(ResponseEntity.notFound().build());
                                        }
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

        /**
         * Permite actualizar únicamente la URL de la imagen de perfil de un usuario.
         *
         * @param documentId ID del usuario a actualizar
         * @param urlImagen  nueva URL de imagen (puede ser null o vacía para borrarla)
         * @return Mono<ResponseEntity<Void>>
         *         Devuelve HTTP 204 si se actualizó.
         *         Devuelve HTTP 404 si el usuario no existe.
         *         Devuelve HTTP 500 si hay error interno.
         */
        @Operation(summary = "Cambiar imagen de perfil", description = "Actualiza solo el campo imagen_perfil de un usuario.", responses = {
                        @ApiResponse(responseCode = "204", description = "Imagen actualizada exitosamente."),
                        @ApiResponse(responseCode = "404", description = "Usuario no encontrado."),
                        @ApiResponse(responseCode = "500", description = "Error interno del servidor.")
        })
        @PatchMapping("/{documentId}/urlImagen")
        public Mono<ResponseEntity<Void>> cambiarImagenPerfil(
                        @Parameter(description = "ID del usuario") @PathVariable String documentId,
                        @RequestParam(value = "urlImagen", required = false) String urlImagen) {

                return Mono.fromCallable(() -> {
                        usuarioService.cambiarImagenPerfil(documentId, urlImagen);
                        return ResponseEntity.noContent().<Void>build();
                })
                                .onErrorResume(RuntimeException.class, e -> {
                                        if (e.getMessage() != null
                                                        && e.getMessage().contains("Usuario no encontrado")) {
                                                return Mono.just(ResponseEntity.notFound().build());
                                        }
                                        return Mono.error(new ResponseStatusException(
                                                        HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e));
                                });
        }

}