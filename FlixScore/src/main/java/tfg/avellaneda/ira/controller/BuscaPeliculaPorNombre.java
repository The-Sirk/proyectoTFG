package tfg.avellaneda.ira.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.service.BuscarPeliculasEnTMDb; 
import java.util.List;

/**
 * Endpoint para búsqueda de películas por nombre
 * @author Adrián
 */
@RestController
public class BuscaPeliculaPorNombre {

    private final BuscarPeliculasEnTMDb buscarPeliculasEnTMDb;

    public BuscaPeliculaPorNombre(BuscarPeliculasEnTMDb buscarPeliculasEnTMDb) {
        this.buscarPeliculasEnTMDb = buscarPeliculasEnTMDb;
    }

    @GetMapping("/peliculasPorNombre")
    public Mono<List<MovieSalida>> getMovies(@RequestParam String nombre) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorNombre(nombre);
    }
}