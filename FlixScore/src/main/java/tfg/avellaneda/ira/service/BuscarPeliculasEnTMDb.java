package tfg.avellaneda.ira.service;

import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;
import java.util.List;
import tfg.avellaneda.ira.model.MovieSalida;
import tfg.avellaneda.ira.model.TmdbResponse;
import tfg.avellaneda.ira.model.MovieEntrada;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Lógica de negocio para la búsqueda y procesamiento de películas de TMDb.
 * Depende de TmdbService para la conexión HTTP.
 * * @author Adrián
 */
@Service
public class BuscarPeliculasEnTMDb {

        private static final Logger logger = LoggerFactory.getLogger(BuscarPeliculasEnTMDb.class);

        private final TmdbService tmdbService;

        public BuscarPeliculasEnTMDb(TmdbService tmdbService) {
                this.tmdbService = tmdbService;
        }

        /**
         * Busca películas por nombre y las procesa (filtra + completa detalles).
         * * @param nombrePelicula El nombre de la película a buscar.
         * 
         * @return Un Mono con la lista de MovieSalida.
         */
        public Mono<List<MovieSalida>> buscarPeliculaPorNombre(String nombrePelicula) {
                String apiKey = tmdbService.getApiKey();

                // Comprobación de la API Key: Si no está definida, devolvemos lista vacía.
                if (apiKey == null || apiKey.isEmpty()) {
                        logger.error("ERROR: Intento de buscar películas fallido. TMDB_API_KEY no está configurada.");
                        return Mono.just(List.of());
                }

                // Si la clave existe, procede con la llamada
                Mono<TmdbResponse> responseMono = tmdbService.getBaseRequest()
                                .uri(uriBuilder -> uriBuilder
                                                .path("/search/movie")
                                                // Usamos la clave obtenida localmente.
                                                .queryParam("api_key", apiKey)
                                                .queryParam("query", nombrePelicula)
                                                .queryParam("language", "es-ES")
                                                .build())
                                .retrieve()
                                .bodyToMono(TmdbResponse.class);

                return responseMono
                                .flatMapMany(response -> Flux.fromIterable(response.getResults()))
                                .filter(movie -> !movie.isAdult()) // Evitamos el cine Nopor
                                // Usamos flatMap, pero limitamos la concurrencia a 5 para no saturar TMDb
                                .flatMap(this::completarDetalles, 5)
                                .collectList();
        }

        /**
         * Busca una película por ID.
         * * @param idPelicula El ID de la película a buscar.
         * 
         * @return Un Mono con la lista de MovieSalida (contendrá 0 o 1 elemento).
         */
        public Mono<List<MovieSalida>> buscarPeliculaPorId(String idPelicula) {
                String apiKey = tmdbService.getApiKey();

                // Comprobación de la API Key: Si no está definida, devolvemos lista vacía.
                if (apiKey == null || apiKey.isEmpty()) {
                        logger.error("ERROR: Intento de buscar película por ID fallido. TMDB_API_KEY no está configurada.");
                        return Mono.just(List.of());
                }

                // Si la clave existe, procede con la llamada
                Mono<MovieEntrada> movieMono = tmdbService.getBaseRequest()
                                .uri(uriBuilder -> uriBuilder
                                                .path("/movie/{id}")
                                                // Usamos la clave obtenida localmente.
                                                .queryParam("api_key", apiKey)
                                                .queryParam("language", "es-ES")
                                                .build(idPelicula))
                                .retrieve()
                                // Si la búsqueda por ID falla (ej. 404), devuelve un Mono vacío.
                                .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(),
                                                clientResponse -> Mono.empty())
                                .bodyToMono(MovieEntrada.class);

                // Enriquecemos la película encontrada y la devolvemos envuelta en una lista
                return movieMono
                                .flatMap(this::completarDetalles)
                                .map(List::of)
                                .defaultIfEmpty(List.of());
        }

        // Lógica de enriquecimiento de datos
        private Mono<MovieSalida> completarDetalles(MovieEntrada movie) {
                String apiKey = tmdbService.getApiKey();

                // Comprobación de la API Key: Si no está definida, devolvemos la película
                // sin enriquecer o, mejor, detenemos el flujo para evitar el error.
                if (apiKey == null || apiKey.isEmpty()) {
                        return Mono.empty();
                }

                return tmdbService.getBaseRequest()
                                .uri(uriBuilder -> uriBuilder
                                                .path("/movie/{id}")
                                                .queryParam("api_key", apiKey)
                                                .queryParam("language", "en-US")
                                                .build(movie.getId()))
                                .retrieve()
                                .bodyToMono(MovieEntrada.class)
                                .map(enMovie -> {
                                        // Lógica de mapeo de DTO (MovieEntrada a MovieSalida)
                                        MovieSalida dto = new MovieSalida();
                                        dto.setId(movie.getId());
                                        dto.setTitulo(movie.getTitle() != null && !movie.getTitle().isEmpty()
                                                        ? movie.getTitle()
                                                        : enMovie.getTitle());
                                        dto.setTituloOriginal(enMovie.getOriginalTitle());
                                        dto.setResumen(movie.getOverview() != null && !movie.getOverview().isEmpty()
                                                        ? movie.getOverview()
                                                        : enMovie.getOverview());
                                        dto.setFechaEstreno(enMovie.getReleaseDate());
                                        dto.setPopularidad(movie.getPopularity());
                                        dto.setPuntucionMedia(movie.getVoteAverage());
                                        dto.setRecuentoVotos(movie.getVoteCount());
                                        dto.setRutaPoster(enMovie.getPosterPath());
                                        dto.setRutaFondo(enMovie.getBackdropPath());
                                        dto.setIdiomaOriginal(enMovie.getOriginalLanguage());
                                        dto.setGenerosIds(movie.getGenreIds());
                                        return dto;
                                });
        }
}