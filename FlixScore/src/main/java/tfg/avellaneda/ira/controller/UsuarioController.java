package tfg.avellaneda.ira.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.ModeloUsuario;
import tfg.avellaneda.ira.service.UsuarioService;

/**
 * Controller REST para gestionar los usuarios.
 */
@RestController
@RequestMapping("/api/v1/usuarios")
public class UsuarioController {

    @Autowired
    UsuarioService usuarioService;

    /**
     * Resuelve el error de Type Mismatch. Devuelve Flux<ModeloUsuario>.
     * La llamada al service está envuelta en Mono.fromCallable() para
     * ejecutarla en un hilo aparte y no bloquear WebFlux.
     * GET /api/v1/usuarios
     */
    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public Flux<ModeloUsuario> getAll() {
        // Envolvemos el método de bloqueo getAll() en un Mono y luego lo
        // convertimos a Flux
        return Mono.fromCallable(() -> usuarioService.getAll())
                .flatMapMany(Flux::fromIterable)
                // Manejo básico de errores reactivos (ej. base de datos no disponible)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener todos los usuarios", e));
                });
    }

    /**
     * GET /api/v1/usuarios/{id}
     */
    @GetMapping("/{id}")
    public Mono<ResponseEntity<ModeloUsuario>> getUsuarioByID(@PathVariable String id) {
        // Envolvemos el método de bloqueo getUsuarioById() en un Mono
        return Mono.fromCallable(() -> usuarioService.getUsuarioById(id))
                .filter(java.util.Optional::isPresent)
                .map(java.util.Optional::get)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.just(ResponseEntity.status(
                            HttpStatus.INTERNAL_SERVER_ERROR).build());
                });
    }

    /**
     * Resuelve la Ambiguous handler methods error.
     * Nueva ruta: GET /api/v1/usuarios/nick/{nick}
     */
    @GetMapping("/nick/{nick}")
    public Flux<ModeloUsuario> getByNick(@PathVariable String nick) {
        // Devuelve una lista de usuarios (Flux)
        return Mono.fromCallable(() -> usuarioService.getUsuarioByNick(nick))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener usuario por nick", e));
                });
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<ModeloUsuario> addUsuario(@RequestBody ModeloUsuario usuario) {
        return Mono.fromCallable(() -> usuarioService.addUsuario(usuario))
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al añadir usuario", e));
                });
    }

    @PutMapping("/{id}")
    public Mono<ResponseEntity<Void>> updateUsuario(@PathVariable String id, @RequestBody ModeloUsuario usuario) {
        return Mono.fromCallable(() -> {
            usuarioService.updateUsuario(id, usuario);
            return ResponseEntity.noContent().<Void>build();
        })
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
                });
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteUsuario(@PathVariable String id) {
        return Mono.fromRunnable(() -> usuarioService.deleteUsuario(id))
                .then()
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al eliminar usuario", e));
                });
    }
}
