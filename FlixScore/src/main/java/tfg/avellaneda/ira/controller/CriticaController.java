package tfg.avellaneda.ira.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.ModeloCritica;
import tfg.avellaneda.ira.service.CriticaService;
import tfg.avellaneda.ira.service.UsuarioService;

import org.springframework.web.bind.annotation.GetMapping;
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
@RequestMapping("/api/v1/criticas/")
public class CriticaController {

    @Autowired
    CriticaService criticaService;

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @GetMapping
    public Flux<ModeloCritica> getCriticas(
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String peliculaId) {

        if (id != null) {
            return Mono.fromCallable(() -> criticaService.getCriticaById(id))
                    .filter(java.util.Optional::isPresent)
                    .map(java.util.Optional::get)
                    .flux()
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener critica", e));
                    });
        } else if (userId != null) {
            logger.info("Desde Controller {}", userId);
            return Mono.fromCallable(() -> criticaService.getCriticasByUserId(userId))
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de usuario", e));
                    });
        } else if (peliculaId != null) {
            return Mono.fromCallable(() -> criticaService.getCriticasByPeliculaId(Integer.parseInt(peliculaId)))
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener criticas de pelicula", e));
                    });
        } else {
            return Mono.fromCallable(() -> criticaService.getAll())
                    .flatMapMany(Flux::fromIterable)
                    .onErrorResume(RuntimeException.class, e -> {
                        return Flux.error(new ResponseStatusException(
                                HttpStatus.INTERNAL_SERVER_ERROR, "Error al obtener todos los usuarios", e));
                    });
        }
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
