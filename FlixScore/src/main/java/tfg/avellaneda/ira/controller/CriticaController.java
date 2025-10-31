package tfg.avellaneda.ira.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.service.CriticaService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

/**
 * Controlador REST para gestionar las críticas de películas.
 * Proporciona endpoints para crear, recuperar por usuario y por película.
 * 
 * @author Israel
 * 
 *         TODO: Añadir manejo de excepciones personalizado.
 */

@RestController
@RequestMapping("/api/v1/criticas")
public class CriticaController {

    @Autowired
    CriticaService criticaService;

    @GetMapping
    public Flux<ModeloCritica> getAll() {
        return Mono.fromCallable(() -> criticaService.getAll())
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener todos los usuarios", e));
                });
    }

    @GetMapping("{id}")
    public Mono<ResponseEntity<ModeloCritica>> getByCriticaID(@PathVariable String id) {
        // Envolvemos el método de bloqueo getUsuarioById() en un Mono
        return Mono.fromCallable(() -> criticaService.getCriticaById(id))
                .filter(java.util.Optional::isPresent)
                .map(java.util.Optional::get)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.just(ResponseEntity.status(
                            HttpStatus.INTERNAL_SERVER_ERROR).build());
                });
    }

    @GetMapping("{userId}")
    public Flux<ModeloCritica> getByUserId(@PathVariable String userId) {
        return Mono.fromCallable(() -> criticaService.getCriticasByUserId(userId))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de usuario", e));

                });
    }

    @GetMapping("{peliculaId}")
    public Flux<ModeloCritica> getByPeliculaId(@PathVariable String peliculaId) {
        return Mono.fromCallable(() -> criticaService.getCriticasByPeliculaId(peliculaId))
                .flatMapMany(Flux::fromIterable)
                .onErrorResume(RuntimeException.class, e -> {
                    return Flux.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de pelicula", e));

                });
    }

    @PostMapping
    public Mono<ModeloCritica> addCritica(@RequestBody ModeloCritica critica) {
                return Mono.fromCallable(() -> criticaService.addCritica(critica))
                .onErrorResume(RuntimeException.class, e -> {
                    return Mono.error(new ResponseStatusException(
                            HttpStatus.INTERNAL_SERVER_ERROR, "Error al añadir usuario", e));
                });
    }

}
