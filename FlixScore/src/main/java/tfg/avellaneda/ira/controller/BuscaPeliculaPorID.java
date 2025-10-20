package tfg.avellaneda.ira.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.service.BuscarPeliculasEnTMDb; 
import java.util.List;

/**
 * Endpoint para búsqueda de películas por id
 * @author Adrián
 */
@RestController
public class BuscaPeliculaPorID {

    private final BuscarPeliculasEnTMDb buscarPeliculasEnTMDb;

    public BuscaPeliculaPorID(BuscarPeliculasEnTMDb buscarPeliculasEnTMDb) {
        this.buscarPeliculasEnTMDb = buscarPeliculasEnTMDb;
    }

    @GetMapping("/peliculasPorId")
    public Mono<List<MovieSalida>> getMovies(@RequestParam String id) {
        return buscarPeliculasEnTMDb.buscarPeliculaPorId(id);
    }
}
